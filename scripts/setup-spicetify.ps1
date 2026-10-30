# 43PR Spicetify Installer for Windows
# Configures Spotify with minimalist 43PR dark theme

$ErrorActionPreference = "Stop"

if (-not (Test-Path "$env:APPDATA\Spotify\Spotify.exe")) {
    Write-Host "Spotify is not installed. Please install Spotify Desktop first." -ForegroundColor Yellow
    Write-Host "You can install it with: winget install Spotify.Spotify" -ForegroundColor DarkGray
    return
}

Write-Host "Installing Spicetify CLI..." -ForegroundColor Cyan
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" | Invoke-Expression

Write-Host "Applying 43PR Spotify theme..." -ForegroundColor Cyan
& spicetify backup apply
Write-Host "Spicetify theme applied successfully!" -ForegroundColor Green

