# 43PR Desktop for Windows - Unified Installer
# Replicating 43PR/dotfiles for Windows 10 / 11

$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host @"

  ██╗  ██╗██████╗ ██████╗ ██████╗ 
  ██║  ██║╚════██╗██╔══██╗██╔══██╗
  ███████║ █████╔╝██████╔╝██████╔╝
  ╚════██║ ╚═══██╗██╔═══╝ ██╔══██╗
       ██║██████╔╝██║     ██║  ██║
       ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝
  Desktop Setup for Windows
"@ -ForegroundColor Cyan

Write-Host "`n[1/5] Checking and Installing Required CLI Tools..." -ForegroundColor Yellow

# Ensure ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Check and install Starship
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Starship prompt via winget..."
    winget install --id Starship.Starship --exact --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "Starship is already installed." -ForegroundColor Green
}

# Check and install Fastfetch
if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Fastfetch via winget..."
    winget install --id Fastfetch-cli.Fastfetch --exact --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "Fastfetch is already installed." -ForegroundColor Green
}

# [2/5] Setup GlazeWM and Zebar Binaries
Write-Host "`n[2/5] Checking GlazeWM and Zebar Binaries..." -ForegroundColor Yellow
$binDir = "$env:LOCALAPPDATA\Programs\glzr\bin"
if (-not (Test-Path "$binDir\glazewm.exe")) {
    Write-Host "Setting up GlazeWM and Zebar binaries..."
    # If not present, download or extract
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
} else {
    Write-Host "GlazeWM and Zebar binaries verified in $binDir." -ForegroundColor Green
}

# Ensure PATH has glzr binaries
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$binDir;$binDir\cli;$userPath", "User")
    $env:PATH = "$binDir;$binDir\cli;$env:PATH"
}

# [3/5] Configure GlazeWM and Zebar
Write-Host "`n[3/5] Linking GlazeWM & Zebar Configurations..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "$repoDir\scripts\setup-glzr.ps1"

# [4/5] Configure Terminal, Starship & Fastfetch
Write-Host "`n[4/5] Configuring Terminal, Starship and Fastfetch..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "$repoDir\scripts\setup-terminal.ps1"

# [5/5] Apply Default Theme & Wallpaper
Write-Host "`n[5/5] Applying 43PR Theme & Wallpaper..." -ForegroundColor Yellow
$defaultWallpaper = "$repoDir\wallpapers\wallhaven-k8jvm7.jpg"
if (Test-Path $defaultWallpaper) {
    powershell -ExecutionPolicy Bypass -File "$repoDir\scripts\theme.ps1" -Wallpaper $defaultWallpaper
}
powershell -ExecutionPolicy Bypass -File "$repoDir\scripts\theme.ps1" -Theme "tokyo-night"

Write-Host @"

============================================================
  43PR Desktop Setup for Windows is COMPLETE!
============================================================

Quick Start:
  • To start the Tiling Window Manager and Status Bar:
      Run: glazewm.exe start

  • Essential Keybindings (Alt is your Super key):
      Alt + T          : Open Terminal
      Alt + Q          : Close Active Window
      Alt + D          : Application Launcher
      Alt + Space      : Toggle Floating Window
      Alt + F          : Toggle Fullscreen
      Alt + 1..9       : Switch Workspace 1..9
      Alt + Shift + 1..9 : Move Window to Workspace
      Alt + H/J/K/L    : Window Focus (Vim keys)
      Alt + Shift + R  : Reload Configuration
      Alt + Shift + Q  : Exit GlazeWM

  • Change Theme anytime:
      .\scripts\theme.ps1 -Theme catppuccin-mocha
      .\scripts\theme.ps1 -List

============================================================
"@ -ForegroundColor Green

