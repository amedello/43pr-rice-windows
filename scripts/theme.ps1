# 43PR Windows Theme Controller
# Manages themes, wallpaper and live reload for GlazeWM and Zebar

param (
    [string]$Theme,
    [string]$Wallpaper,
    [switch]$List
)

$ErrorActionPreference = "Stop"
$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$themesDir = Join-Path $repoDir "config\43pr\themes"
$glzrHome = Join-Path $HOME ".glzr"
$zebarStyle = Join-Path $glzrHome "zebar\starter\styles.css"
$zebarStyleAlt = Join-Path $glzrHome "zebar\43pr-bar\style.css"
$glazewmConfig = Join-Path $glzrHome "glazewm\config.yaml"

# 1. List available themes
if ($List) {
    Write-Host "`n=== Available 43PR Themes ===" -ForegroundColor Cyan
    Get-ChildItem -Path $themesDir -Filter "*.toml" | ForEach-Object {
        $themeName = $_.BaseName
        Write-Host "  • $themeName" -ForegroundColor White
    }
    Write-Host "`nApply with: .\scripts\theme.ps1 -Theme <name>`n" -ForegroundColor DarkGray
    return
}

# 2. Set Wallpaper
if ($Wallpaper) {
    if (-not (Test-Path $Wallpaper)) {
        Write-Error "Wallpaper file not found: $Wallpaper"
        return
    }
    $fullPath = (Resolve-Path $Wallpaper).Path
    Write-Host "Setting desktop wallpaper: $fullPath" -ForegroundColor Cyan

    $code = @"
using System;
using System.Runtime.InteropServices;
public class WallpaperUtil {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    if (-not ([System.Management.Automation.PSTypeName]'WallpaperUtil').Type) {
        Add-Type -TypeDefinition $code
    }
    # SPI_SETDESKWALLPAPER = 20, SPIF_UPDATEINIFILE = 1, SPIF_SENDCHANGE = 2
    [WallpaperUtil]::SystemParametersInfo(20, 0, $fullPath, 3)
    Write-Host "Wallpaper successfully set!" -ForegroundColor Green
}

# 3. Apply Theme
if ($Theme) {
    $themeFile = Join-Path $themesDir "$Theme.toml"
    if (-not (Test-Path $themeFile)) {
        Write-Error "Theme '$Theme' not found in $themesDir"
        return
    }

    Write-Host "Applying theme: $Theme..." -ForegroundColor Cyan

    # Parse key-value colors from TOML
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

    # Update Zebar style.css
    if (Test-Path $zebarStyle) {
        $css = Get-Content $zebarStyle -Raw
        $css = [regex]::Replace($css, '(--accent:\s*)[^;]+;', "`$1$accent;")
        $css = [regex]::Replace($css, '(--fg-main:\s*)[^;]+;', "`$1$fg;")
        $css = [regex]::Replace($css, '(--fg-dim:\s*)[^;]+;', "`$1$fgDim;")
        Set-Content -Path $zebarStyle -Value $css
        Write-Host "Updated Zebar colors in $zebarStyle" -ForegroundColor Green
    }

    # Update GlazeWM border color
    if (Test-Path $glazewmConfig) {
        $gwm = Get-Content $glazewmConfig -Raw
        $gwm = [regex]::Replace($gwm, '(color:\s*")#[0-9a-fA-F]{6}("\s*# Accent)', "`$1$accent`$2")
        Set-Content -Path $glazewmConfig -Value $gwm
        Write-Host "Updated GlazeWM border color in $glazewmConfig" -ForegroundColor Green

        # Reload GlazeWM live if running
        $isGwmRunning = Get-Process "glazewm" -ErrorAction SilentlyContinue
        if ($isGwmRunning) {
            $gwmCli = "$env:LOCALAPPDATA\Programs\glzr\bin\cli\glazewm.exe"
            if (Test-Path $gwmCli) {
                & $gwmCli command wm-reload-config 2>$null
                Write-Host "Reloaded running GlazeWM instance!" -ForegroundColor Green
            }
        }
    }

    Write-Host "`nTheme '$Theme' applied successfully!" -ForegroundColor Green
}

