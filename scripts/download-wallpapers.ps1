# 43PR Aesthetic Wallpaper Downloader
# Downloads curated high-res wallpapers for Catppuccin, Tokyo Night, Gruvbox, and Nord

$ErrorActionPreference = "Continue"
$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$wpDir = Join-Path $repoDir "wallpapers"

if (-not (Test-Path $wpDir)) {
    New-Item -ItemType Directory -Force -Path $wpDir | Out-Null
}

$wallpapers = @(
    # Catppuccin Collection
    @{
        Name = "catppuccin-clearnight.jpg"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/Clearnight.jpg"
    },
    @{
        Name = "catppuccin-evening-sky.png"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/evening-sky.png"
    },
    @{
        Name = "catppuccin-salty-mountains.png"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/salty_mountains.png"
    },
    @{
        Name = "catppuccin-shaded-landscape.png"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/shaded_landscape.png"
    },
    @{
        Name = "catppuccin-forrest.png"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png"
    },
    @{
        Name = "catppuccin-gradient-synth.png"
        Url  = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/minimalistic/gradient-synth-cat.png"
    },

    # Tokyo Night Collection
    @{
        Name = "tokyonight-city.png"
        Url  = "https://raw.githubusercontent.com/alchem1no/tokyonight-wallpapers/main/1920x1080/main/tokyonight.png"
    },
    @{
        Name = "tokyonight-cosmic.png"
        Url  = "https://raw.githubusercontent.com/alchem1no/tokyonight-wallpapers/main/1920x1080/main/cosmic%20tokyo%20night.png"
    },
    @{
        Name = "tokyonight-samurai.jpg"
        Url  = "https://raw.githubusercontent.com/alchem1no/tokyonight-wallpapers/main/1920x1080/main/samurai_dark.jpg"
    },
    @{
        Name = "tokyonight-matrix.png"
        Url  = "https://raw.githubusercontent.com/alchem1no/tokyonight-wallpapers/main/1920x1080/main/matrix.png"
    },

    # Gruvbox Collection
    @{
        Name = "gruvbox-great-wave.png"
        Url  = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/great-wave-of-kanagawa-gruvbox.png"
    },
    @{
        Name = "gruvbox-starry-sky.png"
        Url  = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/starry-sky.png"
    },
    @{
        Name = "gruvbox-sunset.png"
        Url  = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/sunset.png"
    },
    @{
        Name = "gruvbox-astro.jpg"
        Url  = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/gruvbox_astro.jpg"
    },

    # Nord Collection
    @{
        Name = "nord-abstract.png"
        Url  = "https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/Abstract-Nord.png"
    },
    @{
        Name = "nord-bird.png"
        Url  = "https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/BirdNord.png"
    }
)

Write-Host "`nDownloading curated 43PR wallpapers into: $wpDir" -ForegroundColor Cyan

for ($i = 0; $i -lt $wallpapers.Count; $i++) {
    $item = $wallpapers[$i]
    $dest = Join-Path $wpDir $item.Name
    $url = $item.Url
    $name = $item.Name

    if (Test-Path $dest) {
        Write-Host "  Already exists: $name" -ForegroundColor DarkGray
        continue
    }

    Write-Host "  Downloading $name..." -ForegroundColor White
    curl.exe -s -L -f -o $dest $url

    if ((Test-Path $dest) -and ((Get-Item $dest).Length -gt 1024)) {
        Write-Host "    -> OK ($([math]::Round((Get-Item $dest).Length / 1MB, 2)) MB)" -ForegroundColor Green
    } else {
        if (Test-Path $dest) { Remove-Item $dest -Force }
        Write-Host "    -> FAILED to download $name" -ForegroundColor Red
    }
}

$images = Get-ChildItem -Path $wpDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp|bmp)$' }
Write-Host "`nFinished! Total wallpapers now available: $($images.Count)`n" -ForegroundColor Green

