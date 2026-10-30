# 43PR Automated Asset & Screenshot Generator
# Renders pixel-perfect screenshots of all native HUDs and desktop showcase

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing

$repoDir = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $repoDir "assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null
}

function Save-VisualToPng($visual, [int]$w, [int]$h, [string]$outputPath) {
    $visual.Width = $w
    $visual.Height = $h
    $visual.Measure([System.Windows.Size]::new($w, $h))
    $visual.Arrange([System.Windows.Rect]::new(0, 0, $w, $h))
    $visual.UpdateLayout()

    $rtb = [System.Windows.Media.Imaging.RenderTargetBitmap]::new($w, $h, 96, 96, [System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($visual)

    $encoder = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))

    $fs = [System.IO.FileStream]::new($outputPath, [System.IO.FileMode]::Create)
    $encoder.Save($fs)
    $fs.Close()
    Write-Host "  [+] Generated: $outputPath ($((Get-Item $outputPath).Length) bytes)" -ForegroundColor Green
}

Write-Host "Generating 43PR Showcase Screenshots and HUD Assets..." -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Cheatsheet HUD
# ------------------------------------------------------------------------------
Write-Host "`n[*] Rendering Cheatsheet HUD..." -ForegroundColor Cyan
$cheatScript = Get-Content (Join-Path $repoDir "scripts\show-cheatsheet.ps1") -Raw
if ($cheatScript -match '(?s)\$xamlText\s*=\s*@''\r?\n(.*?)\r?\n''@') {
    $window = [System.Windows.Markup.XamlReader]::Parse($matches[1])
    $content = $window.Content
    $window.Content = $null
    Save-VisualToPng $content 780 570 (Join-Path $assetsDir "hud-cheatsheet.png")
}

# ------------------------------------------------------------------------------
# 2. Sensors HUD
# ------------------------------------------------------------------------------
Write-Host "`n[*] Rendering Sensors HUD..." -ForegroundColor Cyan
$sensorScript = Get-Content (Join-Path $repoDir "scripts\sensors-hud.ps1") -Raw
$accentColor = "#7AA2F7"
if ($sensorScript -match '(?s)\$xaml\s*=\s*@"\r?\n(.*?)\r?\n"@') {
    $xaml = $ExecutionContext.InvokeCommand.ExpandString($matches[1])
    $window = [System.Windows.Markup.XamlReader]::Parse($xaml)
    
    # Populate sample values for preview
    $window.FindName("TxtCpuVal").Text = "14%"
    $window.FindName("ProgCpu").Value = 14
    $window.FindName("TxtRamVal").Text = "8.4 GB / 31.9 GB (26%)"
    $window.FindName("ProgRam").Value = 26
    $window.FindName("TxtDiskC").Text = "182.4 GB liberi su 476.1 GB (62% usato)"
    $window.FindName("ProgDiskC").Value = 62
    $window.FindName("TxtDiskD").Text = "542.1 GB liberi su 953.8 GB (43% usato)"
    $window.FindName("ProgDiskD").Value = 43
    $window.FindName("TxtUptime").Text = "05h 24m"
    $window.FindName("TxtBattery").Text = "Alimentatore AC"

    $content = $window.Content
    $window.Content = $null
    Save-VisualToPng $content 500 420 (Join-Path $assetsDir "hud-sensors.png")
}

# ------------------------------------------------------------------------------
# 3. Quick Calculator HUD
# ------------------------------------------------------------------------------
Write-Host "`n[*] Rendering Quick Calculator HUD..." -ForegroundColor Cyan
$calcScript = Get-Content (Join-Path $repoDir "scripts\calc-launcher.ps1") -Raw
if ($calcScript -match '(?s)\$xaml\s*=\s*@"\r?\n(.*?)\r?\n"@') {
    $xaml = $ExecutionContext.InvokeCommand.ExpandString($matches[1])
    $window = [System.Windows.Markup.XamlReader]::Parse($xaml)
    $txtInput = $window.FindName("TxtInput")
    if ($txtInput) { $txtInput.Text = "1280 * 720 / 1024" }
    $txtResult = $window.FindName("TxtResult")
    if ($txtResult) { $txtResult.Text = "= 900" }
    $placeholder = $window.FindName("TxtInputPlaceholder")
    if ($placeholder) { $placeholder.Visibility = "Collapsed" }
    $content = $window.Content
    $window.Content = $null
    Save-VisualToPng $content 420 460 (Join-Path $assetsDir "hud-calc.png")
}

# ------------------------------------------------------------------------------
# 4. Power Menu HUD
# ------------------------------------------------------------------------------
Write-Host "`n[*] Rendering Power Menu HUD..." -ForegroundColor Cyan
$powerScript = Get-Content (Join-Path $repoDir "scripts\power-menu.ps1") -Raw
if ($powerScript -match '(?s)\$xaml\s*=\s*@"\r?\n(.*?)\r?\n"@') {
    $xaml = $ExecutionContext.InvokeCommand.ExpandString($matches[1])
    $window = [System.Windows.Markup.XamlReader]::Parse($xaml)
    $content = $window.Content
    $window.Content = $null
    Save-VisualToPng $content 580 260 (Join-Path $assetsDir "hud-power-menu.png")
}

# ------------------------------------------------------------------------------
# 5. Theme Selector HUD
# ------------------------------------------------------------------------------
Write-Host "`n[*] Rendering Theme Selector HUD..." -ForegroundColor Cyan
$accentColor = "#7AA2F7"
$autoStatusText = "Auto: Attivo"
$autoStatusColor = "#7AA2F7"
$autoStatusBorder = "#267AA2F7"

$themeScript = Get-Content (Join-Path $repoDir "scripts\theme-picker.ps1") -Raw
if ($themeScript -match '(?s)\$xaml\s*=\s*@"\r?\n(.*?)\r?\n"@') {
    $xaml = $ExecutionContext.InvokeCommand.ExpandString($matches[1])
    $window = [System.Windows.Markup.XamlReader]::Parse($xaml)
    
    # Populate sample themes
    $sampleThemes = @(
        [PSCustomObject]@{
            Name = "tokyo-night"; DisplayName = "tokyo-night"; Appearance = "dark"
            Description = "Tokyo Night Dark (Predefinito 43PR)"; AccentColor = "#7AA2F7"
            BackgroundColor = "#16161E"; ForegroundColor = "#C0CAF5"
            IsActive = $true; ActiveVisibility = "Visible"; InactiveVisibility = "Collapsed"
            CardBorderBrush = "#7AA2F7"; CardBorderThickness = "2"; CardBackground = "#24283B"
            AppearanceBadge = "DARK"; AppearanceBadgeBg = "#1F2335"; AppearanceBadgeFg = "#7AA2F7"
        },
        [PSCustomObject]@{
            Name = "catppuccin-mocha"; DisplayName = "catppuccin-mocha"; Appearance = "dark"
            Description = "Catppuccin Mocha Dark"; AccentColor = "#89B4FA"
            BackgroundColor = "#1E1E2E"; ForegroundColor = "#CDD6F4"
            IsActive = $false; ActiveVisibility = "Collapsed"; InactiveVisibility = "Visible"
            CardBorderBrush = "#313244"; CardBorderThickness = "1"; CardBackground = "#181825"
            AppearanceBadge = "DARK"; AppearanceBadgeBg = "#313244"; AppearanceBadgeFg = "#89B4FA"
        },
        [PSCustomObject]@{
            Name = "catppuccin-latte"; DisplayName = "catppuccin-latte"; Appearance = "light"
            Description = "Catppuccin Latte Light"; AccentColor = "#1E66F5"
            BackgroundColor = "#EFF1F5"; ForegroundColor = "#4C4F69"
            IsActive = $false; ActiveVisibility = "Collapsed"; InactiveVisibility = "Visible"
            CardBorderBrush = "#CCD0DA"; CardBorderThickness = "1"; CardBackground = "#E6E9EF"
            AppearanceBadge = "LIGHT"; AppearanceBadgeBg = "#DCE0E8"; AppearanceBadgeFg = "#1E66F5"
        },
        [PSCustomObject]@{
            Name = "nord"; DisplayName = "nord"; Appearance = "dark"
            Description = "Nord Arctic Frost"; AccentColor = "#88C0D0"
            BackgroundColor = "#2E3440"; ForegroundColor = "#D8DEE9"
            IsActive = $false; ActiveVisibility = "Collapsed"; InactiveVisibility = "Visible"
            CardBorderBrush = "#4C566A"; CardBorderThickness = "1"; CardBackground = "#3B4252"
            AppearanceBadge = "DARK"; AppearanceBadgeBg = "#434C5E"; AppearanceBadgeFg = "#88C0D0"
        },
        [PSCustomObject]@{
            Name = "gruvbox-dark"; DisplayName = "gruvbox-dark"; Appearance = "dark"
            Description = "Gruvbox Retro Warm Dark"; AccentColor = "#FE8019"
            BackgroundColor = "#282828"; ForegroundColor = "#EBDBB2"
            IsActive = $false; ActiveVisibility = "Collapsed"; InactiveVisibility = "Visible"
            CardBorderBrush = "#504945"; CardBorderThickness = "1"; CardBackground = "#3C3836"
            AppearanceBadge = "DARK"; AppearanceBadgeBg = "#504945"; AppearanceBadgeFg = "#FE8019"
        }
    )
    $ic = $window.FindName("ThemesList")
    if ($ic) { $ic.ItemsSource = $sampleThemes }
    $tbCount = $window.FindName("TxtThemeCount")
    if ($tbCount) { $tbCount.Text = "27 Temi installati" }

    $content = $window.Content
    $window.Content = $null
    Save-VisualToPng $content 700 560 (Join-Path $assetsDir "hud-theme-picker.png")
}

# ------------------------------------------------------------------------------
# 6. Full Desktop Showcase Composite (1920x1080)
# ------------------------------------------------------------------------------
Write-Host "`n[*] Generating Full Desktop Showcase Composite (1920x1080)..." -ForegroundColor Cyan
$wallpaperFile = Join-Path $repoDir "wallpapers\tokyonight-city.png"
if (Test-Path $wallpaperFile) {
    $canvas = New-Object System.Drawing.Bitmap(1920, 1080)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Draw Wallpaper
    $origWp = [System.Drawing.Image]::FromFile($wallpaperFile)
    $g.DrawImage($origWp, 0, 0, 1920, 1080)
    $origWp.Dispose()

    # Draw Top Bar (Zebar 36px)
    $barBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 22, 22, 30))
    $g.FillRectangle($barBrush, 12, 6, 1896, 36)
    $barBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 122, 162, 247), 1)
    $g.DrawRectangle($barBorderPen, 12, 6, 1896, 36)

    # Top Bar Workspaces Pill
    $wsBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 36, 40, 59))
    $wsActiveBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 122, 162, 247))
    $font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $fontRegular = New-Object System.Drawing.Font("Segoe UI", 9)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $darkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 22, 22, 30))
    $grayBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 192, 202, 245))

    # Workspaces: 1 (active), 2, 3, 4
    $g.FillRectangle($wsActiveBg, 24, 12, 24, 24)
    $g.DrawString("1", $font, $darkBrush, 31, 15)
    $g.FillRectangle($wsBg, 54, 12, 24, 24)
    $g.DrawString("2", $fontRegular, $grayBrush, 61, 15)
    $g.FillRectangle($wsBg, 84, 12, 24, 24)
    $g.DrawString("3", $fontRegular, $grayBrush, 91, 15)
    $g.FillRectangle($wsBg, 114, 12, 24, 24)
    $g.DrawString("4", $fontRegular, $grayBrush, 121, 15)

    # Window Title
    $g.DrawString("Windows Terminal  ~  43PR Rice [tokyo-night]", $font, $whiteBrush, 160, 15)

    # Right side: Media player, Sensors, Battery, Clock
    $g.DrawString("Tokyo Night City Synth", $fontRegular, $grayBrush, 1420, 15)
    $g.DrawString("CPU 14%", $fontRegular, $grayBrush, 1630, 15)
    $g.DrawString("RAM 26%", $fontRegular, $grayBrush, 1710, 15)
    $g.DrawString("21:30", $font, $whiteBrush, 1820, 15)

    # Overlay Cheatsheet or Terminal in center
    $hudImgPath = Join-Path $assetsDir "hud-cheatsheet.png"
    if (Test-Path $hudImgPath) {
        $hudImg = [System.Drawing.Image]::FromFile($hudImgPath)
        $posX = [int]((1920 - 780) / 2)
        $posY = [int]((1080 - 570) / 2) + 20
        $g.DrawImage($hudImg, $posX, $posY, 780, 570)
        $hudImg.Dispose()
    }

    $showcaseTarget = Join-Path $assetsDir "desktop-showcase.png"
    $canvas.Save($showcaseTarget, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
    $g.Dispose()
    Write-Host "  [+] Generated: $showcaseTarget ($((Get-Item $showcaseTarget).Length) bytes)" -ForegroundColor Green
}

Write-Host "`nAll screenshots successfully generated in $assetsDir!" -ForegroundColor Green
