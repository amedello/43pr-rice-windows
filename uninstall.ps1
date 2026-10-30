# ==============================================================================
#  43PR Rice for Windows - Uninstaller
#  Repository: https://github.com/amedello/43pr-rice-windows
# ==============================================================================

[CmdletBinding()]
param (
    [switch]$Full,
    [switch]$NoInteractive
)

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host "                    43PR RICE FOR WINDOWS - UNINSTALLER                         " -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host ""

# 1. Stop Running Processes
Write-Host "[*] Stopping running processes..." -ForegroundColor Cyan
taskkill /IM glazewm.exe /F 2>$null
taskkill /IM zebar.exe /F 2>$null
taskkill /IM media-ctl.exe /F 2>$null
Write-Host "  [+] Stopped GlazeWM and Zebar." -ForegroundColor Green

# 2. Remove Startup Shortcut
Write-Host "`n[*] Removing Startup shortcut..." -ForegroundColor Cyan
$startupFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
$shortcutPath = Join-Path $startupFolder "GlazeWM.lnk"
if (Test-Path $shortcutPath) {
    Remove-Item -Force $shortcutPath
    Write-Host "  [+] Removed autostart shortcut: $shortcutPath" -ForegroundColor Green
} else {
    Write-Host "  [OK] No autostart shortcut found." -ForegroundColor DarkGray
}

# 3. Clean ~/.glzr Configurations and State
Write-Host "`n[*] Cleaning ~/.glzr configurations..." -ForegroundColor Cyan
$glzrHome = Join-Path $HOME ".glzr"

if (Test-Path $glzrHome) {
    $confirm = $true
    if (-not $NoInteractive -and -not $Full) {
        $r = Read-Host "Remove configuration directory '$glzrHome'? (Y/n)"
        if ($r -ne "" -and $r -notmatch "^[yYsS]") {
            $confirm = $false
        }
    }
    if ($confirm) {
        Remove-Item -Recurse -Force $glzrHome -ErrorAction SilentlyContinue
        Write-Host "  [+] Cleaned $glzrHome" -ForegroundColor Green
    }
}

# Clean state files
$stateFiles = @(
    (Join-Path $HOME ".43pr_current_theme"),
    (Join-Path $HOME ".43pr_auto_theme")
)
foreach ($sf in $stateFiles) {
    if (Test-Path $sf) {
        Remove-Item -Force $sf -ErrorAction SilentlyContinue
    }
}

# Restore Desktop Icons
$explorerAdvanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (Test-Path $explorerAdvanced) {
    Set-ItemProperty -Path $explorerAdvanced -Name "HideIcons" -Value 0 -Type DWord
    
    # Notify Windows Shell to refresh desktop view immediately
    try {
        $refreshCode = @'
        using System;
        using System.Runtime.InteropServices;
        public class ShellNotify {
            [DllImport("shell32.dll")]
            public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
        }
'@
        if (-not ([System.Management.Automation.PSTypeName]'ShellNotify').Type) {
            Add-Type -TypeDefinition $refreshCode
        }
        [ShellNotify]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
    } catch {}

    Write-Host "  [+] Restored Desktop Icons to Visible." -ForegroundColor Green
}

# Ensure Windows Taskbar is visible
try {
    $trayCode = @'
    using System;
    using System.Runtime.InteropServices;
    public class TrayRestore {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
'@
    if (-not ([System.Management.Automation.PSTypeName]'TrayRestore').Type) {
        Add-Type -TypeDefinition $trayCode
    }
    $hTray = [TrayRestore]::FindWindow("Shell_TrayWnd", $null)
    if ($hTray -ne [IntPtr]::Zero) {
        [TrayRestore]::ShowWindow($hTray, 5) | Out-Null
    }
    Write-Host "  [+] Restored Windows Taskbar visibility." -ForegroundColor Green
} catch {}

# 4. Optional Package Removal via Winget
if ($Full) {
    Write-Host "`n[*] Removing Winget packages (--Full requested)..." -ForegroundColor Cyan
    $packages = @("glzr-io.glazewm", "glzr-io.zebar")
    foreach ($pkg in $packages) {
        winget uninstall --id $pkg --exact --silent 2>$null
        Write-Host "  [+] Uninstalled $pkg" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "            43PR Rice has been successfully removed from this system.           " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""

