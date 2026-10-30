# 43PR Wallpaper Picker for Windows
# Cycles or selects wallpapers and updates desktop background

param (
    [switch]$Select,
    [switch]$Next
)

$ErrorActionPreference = "Stop"
$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$wpDir = Join-Path $repoDir "wallpapers"
if (-not (Test-Path $wpDir) -or (Get-ChildItem -Path $wpDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp|bmp)$' }).Count -eq 0) {
    if (Test-Path (Join-Path $HOME ".glzr\wallpapers")) {
        $wpDir = Join-Path $HOME ".glzr\wallpapers"
    }
}
$stateFile = Join-Path $HOME ".glzr\wallpaper-index.txt"

# Ensure wallpapers folder exists
if (-not (Test-Path $wpDir)) {
    New-Item -ItemType Directory -Force -Path $wpDir | Out-Null
}

$images = @(Get-ChildItem -Path $wpDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp|bmp)$' })

if ($images.Count -eq 0) {
    Write-Host "No images found in $wpDir. Please add some wallpapers!" -ForegroundColor Yellow
    return
}

$targetWallpaper = $null

if ($Select) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $wpDir
    $dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.webp)|*.jpg;*.jpeg;*.png;*.webp|All Files (*.*)|*.*"
    $dialog.Title = "43PR Wallpaper Selector"
    
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $targetWallpaper = $dialog.FileName
    } else {
        return
    }
} else {
    # Default is -Next (Cycle)
    $currentIndex = 0
    if (Test-Path $stateFile) {
        $content = Get-Content $stateFile -ErrorAction SilentlyContinue
        if ($content -match '^\d+$') {
            $currentIndex = [int]$content
        }
    }

    $nextIndex = ($currentIndex + 1) % $images.Count
    Set-Content -Path $stateFile -Value $nextIndex
    $targetWallpaper = $images[$nextIndex].FullName
}

if ($targetWallpaper -and (Test-Path $targetWallpaper)) {
    Write-Host "Applying wallpaper: $targetWallpaper" -ForegroundColor Cyan
    $themeScript = Join-Path $repoDir "scripts\theme.ps1"
    if (-not (Test-Path $themeScript)) {
        $themeScript = Join-Path $HOME ".glzr\scripts\theme.ps1"
    }
    & $themeScript -Wallpaper $targetWallpaper
}

