# 43PR Windows Theme Controller
# Manages themes, wallpaper and live reload for GlazeWM, Zebar, Windows Terminal and Windows OS

param (
    [string]$Theme,
    [string]$Wallpaper,
    [switch]$NoWallpaper,
    [switch]$List
)

$ErrorActionPreference = "Stop"
$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$themesDir = Join-Path $repoDir "config\43pr\themes"
$wallpapersDir = Join-Path $repoDir "wallpapers"
$glzrHome = Join-Path $HOME ".glzr"
$zebarStyles = @(
    (Join-Path $glzrHome "zebar\starter\styles.css"),
    (Join-Path $repoDir "config\zebar\starter\styles.css"),
    (Join-Path $glzrHome "zebar\43pr-bar\style.css"),
    (Join-Path $repoDir "config\zebar\43pr-bar\style.css")
)
$glazewmConfigs = @(
    (Join-Path $glzrHome "glazewm\config.yaml"),
    (Join-Path $repoDir "config\glazewm\config.yaml")
)
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# C# helpers for wallpaper and OS theme notifications
$csharpCode = @"
using System;
using System.Runtime.InteropServices;

public class WinThemeUtil {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        UIntPtr wParam,
        string lParam,
        uint fuFlags,
        uint uTimeout,
        out UIntPtr lpdwResult);

    public static void NotifyThemeChange() {
        UIntPtr result;
        // HWND_BROADCAST = 0xffff, WM_SETTINGCHANGE = 0x001a, SMTO_ABORTIFHUNG = 0x0002
        SendMessageTimeout((IntPtr)0xffff, 0x001a, UIntPtr.Zero, "ImmersiveColorSet", 2, 100, out result);
        SendMessageTimeout((IntPtr)0xffff, 0x001a, UIntPtr.Zero, "Environment", 2, 100, out result);
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'WinThemeUtil').Type) {
    Add-Type -TypeDefinition $csharpCode
}

# 1. List available themes
if ($List) {
    Write-Host "`n=== Available 43PR Themes ===" -ForegroundColor Cyan
    Get-ChildItem -Path $themesDir -Filter "*.toml" | ForEach-Object {
        $themeName = $_.BaseName
        Write-Host "  - $themeName" -ForegroundColor White
    }
    Write-Host "`nApply with: theme -Theme <name>  (e.g.: theme -Theme tokyo-night)`n" -ForegroundColor DarkGray
    return
}

# 2. Set Wallpaper manually if provided
if ($Wallpaper) {
    if (-not (Test-Path $Wallpaper)) {
        Write-Error "Wallpaper file not found: $Wallpaper"
        return
    }
    $fullPath = (Resolve-Path $Wallpaper).Path
    Write-Host "Setting desktop wallpaper: $fullPath" -ForegroundColor Cyan
    [WinThemeUtil]::SystemParametersInfo(20, 0, $fullPath, 3) | Out-Null
    Write-Host "Wallpaper successfully set!" -ForegroundColor Green
}

# 3. Apply Theme
if ($Theme) {
    $themeFile = Join-Path $themesDir "$Theme.toml"
    if (-not (Test-Path $themeFile)) {
        Write-Error "Theme '$Theme' not found in $themesDir"
        return
    }

    Write-Host "`n=== Applying 43PR Theme: $Theme ===" -ForegroundColor Cyan

    # Parse key-value colors and metadata from TOML
    $colors = @{}
    $lines = Get-Content $themeFile
    foreach ($line in $lines) {
        if ($line -match '^\s*([a-zA-Z0-9_]+)\s*=\s*"([^"]+)"') {
            $colors[$matches[1]] = $matches[2]
        }
    }

    $accent = if ($colors.ContainsKey("accent")) { $colors["accent"] } else { "#89b4fa" }
    $bg = if ($colors.ContainsKey("bg")) { $colors["bg"] } else { "#1e1e2e" }
    $fg = if ($colors.ContainsKey("fg")) { $colors["fg"] } else { "#cdd6f4" }
    $fgDim = if ($colors.ContainsKey("fg_dim")) { $colors["fg_dim"] } else { "#9399b2" }
    $appearance = if ($colors.ContainsKey("appearance")) { $colors["appearance"] } else { "dark" }
    $isLight = ($appearance -eq "light")

    # RGB components for Accent
    $r = 137; $g = 180; $b = 250
    if ($accent -match '^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$') {
        $r = [Convert]::ToInt32($matches[1], 16)
        $g = [Convert]::ToInt32($matches[2], 16)
        $b = [Convert]::ToInt32($matches[3], 16)
    }

    # 3.1 Wallpaper Auto-pairing (unless -NoWallpaper or manual -Wallpaper passed)
    if (-not $NoWallpaper -and -not $Wallpaper -and (Test-Path $wallpapersDir)) {
        $matchingWp = $null
        $wpFiles = @(Get-ChildItem -Path $wallpapersDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp)$' })
        
        if ($Theme -match 'gruvbox') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'gruvbox' } | Select-Object -First 1
        } elseif ($Theme -match 'nord|arctic') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'nord' } | Select-Object -First 1
        } elseif ($Theme -match 'catppuccin') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'catppuccin' } | Select-Object -First 1
        } elseif ($Theme -match 'tokyo') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'tokyonight' } | Select-Object -First 1
        } elseif ($Theme -match 'dracula') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'cosmic|synth' } | Select-Object -First 1
        } elseif ($Theme -match 'matrix') {
            $matchingWp = $wpFiles | Where-Object { $_.BaseName -match 'matrix' } | Select-Object -First 1
        }

        if ($matchingWp) {
            Write-Host "  [+] Setting matching wallpaper: $($matchingWp.Name)" -ForegroundColor Green
            [WinThemeUtil]::SystemParametersInfo(20, 0, $matchingWp.FullName, 3) | Out-Null
        }
    }

    # 3.2 Update Windows Terminal Color Scheme
    if (Test-Path $wtSettings) {
        try {
            $raw = Get-Content $wtSettings -Raw
            $json = $raw | ConvertFrom-Json
            if (-not $json.profiles.defaults) {
                $json.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{})
            }
            $schemeName = "43PR-$Theme"
            $json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value $schemeName -Force

            # Also ensure all active profiles inherit the new scheme
            foreach ($prof in $json.profiles.list) {
                if (Get-Member -InputObject $prof -Name "colorScheme") {
                    $prof.colorScheme = $schemeName
                }
            }

            if (-not (Get-Member -InputObject $json -Name "schemes")) {
                $json | Add-Member -MemberType NoteProperty -Name "schemes" -Value @() -Force
            }

            $schemeObj = [PSCustomObject]@{
                name = $schemeName
                background = $bg
                foreground = $fg
                cursorColor = if ($colors.ContainsKey("cursor")) { $colors["cursor"] } else { $accent }
                selectionBackground = if ($colors.ContainsKey("selection_bg")) { $colors["selection_bg"] } else { $accent }
                black = if ($colors.ContainsKey("term0")) { $colors["term0"] } else { $bg }
                red = if ($colors.ContainsKey("term1")) { $colors["term1"] } else { "#f7768e" }
                green = if ($colors.ContainsKey("term2")) { $colors["term2"] } else { "#9ece6a" }
                yellow = if ($colors.ContainsKey("term3")) { $colors["term3"] } else { "#e0af68" }
                blue = if ($colors.ContainsKey("term4")) { $colors["term4"] } else { $accent }
                purple = if ($colors.ContainsKey("term5")) { $colors["term5"] } else { "#bb9af7" }
                cyan = if ($colors.ContainsKey("term6")) { $colors["term6"] } else { "#7dcfff" }
                white = if ($colors.ContainsKey("term7")) { $colors["term7"] } else { $fg }
                brightBlack = if ($colors.ContainsKey("term8")) { $colors["term8"] } else { $fgDim }
                brightRed = if ($colors.ContainsKey("term9")) { $colors["term9"] } else { "#f7768e" }
                brightGreen = if ($colors.ContainsKey("term10")) { $colors["term10"] } else { "#9ece6a" }
                brightYellow = if ($colors.ContainsKey("term11")) { $colors["term11"] } else { "#e0af68" }
                brightBlue = if ($colors.ContainsKey("term12")) { $colors["term12"] } else { $accent }
                brightPurple = if ($colors.ContainsKey("term13")) { $colors["term13"] } else { "#bb9af7" }
                brightCyan = if ($colors.ContainsKey("term14")) { $colors["term14"] } else { "#7dcfff" }
                brightWhite = if ($colors.ContainsKey("term15")) { $colors["term15"] } else { "#ffffff" }
            }

            $existing = @($json.schemes | Where-Object { $_.name -ne $schemeName })
            $existing += $schemeObj
            $json.schemes = $existing

            $json | ConvertTo-Json -Depth 32 | Set-Content -Path $wtSettings
            Write-Host "  [+] Updated Windows Terminal palette -> '$schemeName'" -ForegroundColor Green
        } catch {
            Write-Warning "Could not update Windows Terminal settings: $_"
        }
    }

    # 3.3 Update Windows OS Accent Color and Theme (Light/Dark & Titlebars)
    try {
        $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        if (Test-Path $personalizePath) {
            $useLight = if ($isLight) { 1 } else { 0 }
            Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value $useLight -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value $useLight -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $personalizePath -Name "ColorPrevalence" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }

        # ABGR for DWM AccentColor: 0xFFBBGGRR
        $abgr = [BitConverter]::ToInt32([byte[]]($r, $g, $b, 255), 0)
        # ARGB for DWM ColorizationColor: 0xFFAABBGGRR
        $argb = [BitConverter]::ToInt32([byte[]]($b, $g, $r, 255), 0)

        $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
        if (Test-Path $dwmPath) {
            Set-ItemProperty -Path $dwmPath -Name "AccentColor" -Value $abgr -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dwmPath -Name "ColorizationColor" -Value $argb -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dwmPath -Name "ColorPrevalence" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }

        $explorerAccentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        if (Test-Path $explorerAccentPath) {
            Set-ItemProperty -Path $explorerAccentPath -Name "AccentColorMenu" -Value $abgr -Type DWord -ErrorAction SilentlyContinue
        }

        [WinThemeUtil]::NotifyThemeChange()
        Write-Host "  [+] Updated Windows OS Accent Color & Active Window Chrome ($appearance)" -ForegroundColor Green
    } catch {
        Write-Warning "Could not update Windows OS theme settings: $_"
    }

    # 3.4 Update Zebar Styles (Pills, active workspace glow & icon colors)
    $bgPill = if ($isLight) { "rgba(240, 243, 248, 0.88)" } else { "rgba(20, 24, 30, 0.78)" }
    $bgPillHover = if ($isLight) { "rgba(225, 230, 240, 0.96)" } else { "rgba(30, 36, 46, 0.88)" }
    $borderPill = if ($isLight) { "rgba(0, 0, 0, 0.12)" } else { "rgba(255, 255, 255, 0.12)" }
    $accentGlow = "rgba($r, $g, $b, 0.4)"

    $colorCpu = if ($colors.ContainsKey("term9")) { $colors["term9"] } else { "#f7768e" }
    $colorMem = if ($colors.ContainsKey("term11")) { $colors["term11"] } else { "#e0af68" }
    $colorBat = if ($colors.ContainsKey("term10")) { $colors["term10"] } else { "#9ece6a" }

    foreach ($styleFile in $zebarStyles) {
        if (Test-Path $styleFile) {
            $css = Get-Content $styleFile -Raw
            $css = [regex]::Replace($css, '(--accent:\s*)[^;]+;', "`$1$accent;")
            $css = [regex]::Replace($css, '(--accent-glow:\s*)[^;]+;', "`$1$accentGlow;")
            $css = [regex]::Replace($css, '(--fg-main:\s*)[^;]+;', "`$1$fg;")
            $css = [regex]::Replace($css, '(--fg-dim:\s*)[^;]+;', "`$1$fgDim;")
            $css = [regex]::Replace($css, '(--bg-pill:\s*)[^;]+;', "`$1$bgPill;")
            $css = [regex]::Replace($css, '(--bg-pill-hover:\s*)[^;]+;', "`$1$bgPillHover;")
            $css = [regex]::Replace($css, '(--border-pill:\s*)[^;]+;', "`$1$borderPill;")
            $css = [regex]::Replace($css, '(--color-cpu:\s*)[^;]+;', "`$1$colorCpu;")
            $css = [regex]::Replace($css, '(--color-mem:\s*)[^;]+;', "`$1$colorMem;")
            $css = [regex]::Replace($css, '(--color-bat:\s*)[^;]+;', "`$1$colorBat;")
            $css = [regex]::Replace($css, '(--color-net:\s*)[^;]+;', "`$1$accent;")
            Set-Content -Path $styleFile -Value $css
            Write-Host "  [+] Updated Zebar styling in $styleFile" -ForegroundColor Green
        }
    }

    # Restart Zebar so status bar reflects new CSS immediately
    $gwmCli = "$env:LOCALAPPDATA\Programs\glzr\bin\cli\glazewm.exe"
    $isZbarRunning = Get-Process "zebar" -ErrorAction SilentlyContinue
    if ($isZbarRunning -and (Test-Path $gwmCli)) {
        & $gwmCli command shell-exec 'taskkill /IM zebar.exe /F' 2>$null
        Start-Sleep -Milliseconds 400
        & $gwmCli command shell-exec zebar 2>$null
        Write-Host "  [+] Reloaded Zebar status bar!" -ForegroundColor Green
    } elseif (-not $isZbarRunning -and (Test-Path $gwmCli)) {
        & $gwmCli command shell-exec zebar 2>$null
        Write-Host "  [+] Started Zebar status bar!" -ForegroundColor Green
    }

    # 3.5 Update GlazeWM Border Color
    foreach ($cfg in $glazewmConfigs) {
        if (Test-Path $cfg) {
            $gwm = Get-Content $cfg -Raw
            $gwm = [regex]::Replace($gwm, '(color:\s*")#[0-9a-fA-F]{6}("\s*# Accent)', "`$1$accent`$2")
            Set-Content -Path $cfg -Value $gwm
            Write-Host "  [+] Updated GlazeWM window border in $cfg" -ForegroundColor Green
        }
    }

    $isGwmRunning = Get-Process "glazewm" -ErrorAction SilentlyContinue
    if ($isGwmRunning -and (Test-Path $gwmCli)) {
        & $gwmCli command wm-reload-config 2>$null
        Write-Host "  [+] Reloaded running GlazeWM instance!" -ForegroundColor Green
    }

    Write-Host "`n>> Theme '$Theme' successfully applied across the entire system!`n" -ForegroundColor Cyan
}
