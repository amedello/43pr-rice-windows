# Setup Terminal, Shell, and Fastfetch for 43PR

$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$homeConfig = Join-Path $HOME ".config"

Write-Host "Configuring 43PR Terminal & Shell..." -ForegroundColor Cyan

# Ensure .config directories exist
New-Item -ItemType Directory -Force -Path $homeConfig | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $homeConfig "fastfetch") | Out-Null

# 1. Starship Config
$starshipSrc = Join-Path $repoDir "config\starship.toml"
$starshipDst = Join-Path $homeConfig "starship.toml"
Copy-Item -Force $starshipSrc $starshipDst
Write-Host "Installed: $starshipDst" -ForegroundColor Green

# 2. Fastfetch Config
$fastfetchSrc = Join-Path $repoDir "config\fastfetch\config.jsonc"
$fastfetchDst = Join-Path $homeConfig "fastfetch\config.jsonc"
Copy-Item -Force $fastfetchSrc $fastfetchDst
Write-Host "Installed: $fastfetchDst" -ForegroundColor Green

# 3. PowerShell Profiles
$profileSrc = Join-Path $repoDir "config\powershell\Microsoft.PowerShell_profile.ps1"

$profileDirs = @(
    (Join-Path $HOME "Documents\WindowsPowerShell"),
    (Join-Path $HOME "Documents\PowerShell")
)

foreach ($dir in $profileDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $dst = Join-Path $dir "Microsoft.PowerShell_profile.ps1"
    Copy-Item -Force $profileSrc $dst
    Write-Host "Installed Profile: $dst" -ForegroundColor Green
}

Write-Host "`nTerminal environment successfully configured!" -ForegroundColor Green

