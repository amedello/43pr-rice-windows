# 43PR Windows System Theming Controller
# Configures Dark Mode, Tokyo Night Accent Color, and Bibata Cursors

$ErrorActionPreference = "Stop"

Write-Host "Configuring Windows System Appearance for 43PR..." -ForegroundColor Cyan

# =========================================================================
# 1. Enable Full System & App Dark Mode
# =========================================================================
$themeReg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $themeReg)) {
    New-Item -Path $themeReg -Force | Out-Null
}

Set-ItemProperty -Path $themeReg -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $themeReg -Name "SystemUsesLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $themeReg -Name "EnableTransparency" -Value 1 -Type DWord
Write-Host "  [+] Enabled Global Dark Mode (System + Apps)" -ForegroundColor Green

# =========================================================================
# 2. Sync Windows Accent Color to 43PR Tokyo Night (#7aa2f7)
# =========================================================================
# Tokyo Night Accent: #7aa2f7 -> ABGR: 0xfff7a27a
$accentDwm = 0xfff7a27a
$colorization = 0xc47aa2f7

$dwmReg = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"
if (-not (Test-Path $dwmReg)) {
    New-Item -Path $dwmReg -Force | Out-Null
}
Set-ItemProperty -Path $dwmReg -Name "AccentColor" -Value $accentDwm -Type DWord
Set-ItemProperty -Path $dwmReg -Name "ColorizationColor" -Value $colorization -Type DWord
Set-ItemProperty -Path $dwmReg -Name "ColorizationAfterglow" -Value $colorization -Type DWord
Set-ItemProperty -Path $dwmReg -Name "ColorPrevalence" -Value 0 -Type DWord

$explorerAccent = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
if (-not (Test-Path $explorerAccent)) {
    New-Item -Path $explorerAccent -Force | Out-Null
}
Set-ItemProperty -Path $explorerAccent -Name "AccentColorMenu" -Value $accentDwm -Type DWord
Write-Host "  [+] Applied 43PR Accent Color" -ForegroundColor Green

# =========================================================================
# 3. Install & Apply Bibata Modern Classic Cursors
# =========================================================================
$cursorDest = Join-Path $env:LOCALAPPDATA "Cursors\Bibata-Modern-Classic"
New-Item -ItemType Directory -Force -Path $cursorDest | Out-Null

$bibataSource = Join-Path $env:TEMP "bibata_extracted\Bibata-Modern-Classic-Regular-Windows"
if (Test-Path $bibataSource) {
    Copy-Item -Recurse -Force "$bibataSource\*" $cursorDest
    
    $cReg = "HKCU:\Control Panel\Cursors"
    Set-ItemProperty -Path $cReg -Name "(Default)" -Value "Bibata-Modern-Classic"
    Set-ItemProperty -Path $cReg -Name "Arrow" -Value (Join-Path $cursorDest "Pointer.cur")
    Set-ItemProperty -Path $cReg -Name "Help" -Value (Join-Path $cursorDest "Help.cur")
    Set-ItemProperty -Path $cReg -Name "AppStarting" -Value (Join-Path $cursorDest "Work.ani")
    Set-ItemProperty -Path $cReg -Name "Wait" -Value (Join-Path $cursorDest "Busy.ani")
    Set-ItemProperty -Path $cReg -Name "Crosshair" -Value (Join-Path $cursorDest "Cross.cur")
    Set-ItemProperty -Path $cReg -Name "IBeam" -Value (Join-Path $cursorDest "Text.cur")
    Set-ItemProperty -Path $cReg -Name "NWPen" -Value (Join-Path $cursorDest "Handwriting.cur")
    Set-ItemProperty -Path $cReg -Name "No" -Value (Join-Path $cursorDest "Unavailable.cur")
    Set-ItemProperty -Path $cReg -Name "SizeNS" -Value (Join-Path $cursorDest "Vert.cur")
    Set-ItemProperty -Path $cReg -Name "SizeWE" -Value (Join-Path $cursorDest "Horz.cur")
    Set-ItemProperty -Path $cReg -Name "SizeNWSE" -Value (Join-Path $cursorDest "Dgn1.cur")
    Set-ItemProperty -Path $cReg -Name "SizeNESW" -Value (Join-Path $cursorDest "Dgn2.cur")
    Set-ItemProperty -Name "SizeAll" -Path $cReg -Value (Join-Path $cursorDest "Move.cur")
    Set-ItemProperty -Path $cReg -Name "UpArrow" -Value (Join-Path $cursorDest "Alternate.cur")
    Set-ItemProperty -Path $cReg -Name "Hand" -Value (Join-Path $cursorDest "Link.cur")
    Set-ItemProperty -Path $cReg -Name "Pin" -Value (Join-Path $cursorDest "Pin.cur")
    Set-ItemProperty -Path $cReg -Name "Person" -Value (Join-Path $cursorDest "Person.cur")

    Write-Host "  [+] Registered Bibata Modern Classic Cursors" -ForegroundColor Green
}

# =========================================================================
# 4. Hide Desktop Icons for Clean Minimalist Rice Desktop
# =========================================================================
$explorerAdvanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (-not (Test-Path $explorerAdvanced)) {
    New-Item -Path $explorerAdvanced -Force | Out-Null
}
Set-ItemProperty -Path $explorerAdvanced -Name "HideIcons" -Value 1 -Type DWord
Write-Host "  [+] Configured Desktop Icons to Hidden (Clean Rice)" -ForegroundColor Green

# =========================================================================
# 4. Broadcast Live Settings & Cursor Change
# =========================================================================
$code = @'
using System;
using System.Runtime.InteropServices;
public class ShellRefresh {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);

    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
}
'@

if (-not ([System.Management.Automation.PSTypeName]'ShellRefresh').Type) {
    Add-Type -TypeDefinition $code
}

# SPI_SETCURSORS = 0x0057
[ShellRefresh]::SystemParametersInfo(0x0057, 0, 0, 0) | Out-Null

$result = [UIntPtr]::Zero
# WM_SETTINGCHANGE = 0x001A
[ShellRefresh]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "ImmersiveColorSet", 2, 1000, [ref]$result) | Out-Null

Write-Host "`nWindows System Theme successfully updated to 43PR Dark Mode!" -ForegroundColor Green

