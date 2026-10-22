# Setup GlazeWM and Zebar configurations for 43PR Rice

$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$glzrHome = Join-Path $HOME ".glzr"
$glazewmTarget = Join-Path $glzrHome "glazewm"
$zebarTarget = Join-Path $glzrHome "zebar"

Write-Host "Configuring 43PR for GlazeWM and Zebar..." -ForegroundColor Cyan

# Ensure destination folders exist
New-Item -ItemType Directory -Force -Path $glazewmTarget | Out-Null
New-Item -ItemType Directory -Force -Path $zebarTarget | Out-Null

# Link or copy glazewm config
$glazewmSrc = Join-Path $repoDir "config\glazewm\config.yaml"
$glazewmDst = Join-Path $glazewmTarget "config.yaml"

if (Test-Path $glazewmDst) {
    Remove-Item -Force $glazewmDst
}

try {
    New-Item -ItemType SymbolicLink -Path $glazewmDst -Target $glazewmSrc -ErrorAction Stop | Out-Null
    Write-Host "Created SymLink: $glazewmDst -> $glazewmSrc" -ForegroundColor Green
} catch {
    Copy-Item -Force $glazewmSrc $glazewmDst
    Write-Host "Copied config to: $glazewmDst" -ForegroundColor Yellow
}

# Link or copy zebar config and widget pack
$zebarSettingsSrc = Join-Path $repoDir "config\zebar\settings.json"
$zebarSettingsDst = Join-Path $zebarTarget "settings.json"
Copy-Item -Force $zebarSettingsSrc $zebarSettingsDst

$zebarBarSrc = Join-Path $repoDir "config\zebar\43pr-bar"
$zebarBarDst = Join-Path $zebarTarget "43pr-bar"

if (Test-Path $zebarBarDst) {
    Remove-Item -Recurse -Force $zebarBarDst
}

try {
    New-Item -ItemType SymbolicLink -Path $zebarBarDst -Target $zebarBarSrc -ErrorAction Stop | Out-Null
    Write-Host "Created SymLink: $zebarBarDst -> $zebarBarSrc" -ForegroundColor Green
} catch {
    Copy-Item -Recurse -Force $zebarBarSrc $zebarBarDst
    Write-Host "Copied bar pack to: $zebarBarDst" -ForegroundColor Yellow
}

Write-Host "`nGlazeWM & Zebar configurations are installed and ready!" -ForegroundColor Green
