# 43PR Audio Output Switcher
# Cycles through all active audio playback devices (Headphones, Speakers, Monitors, etc.)

$ErrorActionPreference = "SilentlyContinue"

$tempFile = Join-Path $env:TEMP "43pr_svv_audio.csv"
if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }

& SoundVolumeView.exe /scomma $tempFile
Start-Sleep -Milliseconds 400

if (-not (Test-Path $tempFile)) { return }

$devices = @(Import-Csv $tempFile | Where-Object { 
    $_.Type -eq "Device" -and $_.Direction -eq "Render" -and $_."Device State" -eq "Active"
})

Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

if ($devices.Count -gt 1) {
    $currentIndex = 0
    for ($i = 0; $i -lt $devices.Count; $i++) {
        if ($devices[$i].Default -eq "Render") {
            $currentIndex = $i
            break
        }
    }

    $nextIndex = ($currentIndex + 1) % $devices.Count
    $targetDevice = $devices[$nextIndex]."Command-Line Friendly ID"
    $friendlyName = $devices[$nextIndex].Name

    SoundVolumeView /SetDefault $targetDevice all
    Write-Host "Audio output switched to: $friendlyName" -ForegroundColor Green
} else {
    Write-Host "Only one active audio playback device found." -ForegroundColor Yellow
}

