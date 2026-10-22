# Configure Windows Terminal for 43PR Aesthetic

$ErrorActionPreference = "Stop"

$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $wtSettings)) {
    Write-Host "Windows Terminal settings.json not found yet." -ForegroundColor Yellow
    return
}

$raw = Get-Content $wtSettings -Raw
$json = $raw | ConvertFrom-Json

# 1. Set default profile aesthetics
if (-not $json.profiles.defaults) {
    $json.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{})
}

$json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value "43PR-TokyoNight" -Force
$json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "opacity" -Value 88 -Force
$json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "useAcrylic" -Value $true -Force
$json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "padding" -Value "12" -Force

$fontObj = [PSCustomObject]@{
    face = "JetBrainsMono Nerd Font"
    size = 11.0
}
$json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value $fontObj -Force

# 2. Add or update 43PR-TokyoNight scheme
if (-not (Get-Member -InputObject $json -Name "schemes")) {
    $json | Add-Member -MemberType NoteProperty -Name "schemes" -Value @() -Force
}

$tokyoNight = [PSCustomObject]@{
    name = "43PR-TokyoNight"
    background = "#1a1b26"
    foreground = "#c0caf5"
    cursorColor = "#c0caf5"
    selectionBackground = "#33467c"
    black = "#15161e"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    purple = "#bb9af7"
    cyan = "#7dcfff"
    white = "#a9b1d6"
    brightBlack = "#414868"
    brightRed = "#f7768e"
    brightGreen = "#9ece6a"
    brightYellow = "#e0af68"
    brightBlue = "#7aa2f7"
    brightPurple = "#bb9af7"
    brightCyan = "#7dcfff"
    brightWhite = "#c0caf5"
}

# Remove existing scheme if present
$existingSchemes = @($json.schemes | Where-Object { $_.name -ne "43PR-TokyoNight" })
$existingSchemes += $tokyoNight
$json.schemes = $existingSchemes

$newRaw = $json | ConvertTo-Json -Depth 32
Set-Content -Path $wtSettings -Value $newRaw

Write-Host "Windows Terminal configured with 43PR Tokyo Night acrylic style!" -ForegroundColor Green
