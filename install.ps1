# ==============================================================================
#  43PR Rice for Windows - Universal One-Click Installer
#  Repository: https://github.com/amedello/43pr-rice-windows
# ==============================================================================

[CmdletBinding()]
param (
    [switch]$NoInteractive,
    [switch]$SkipPackages,
    [switch]$StartAfterInstall
)

$ErrorActionPreference = "Stop"

# Banner
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "                    43PR RICE FOR WINDOWS 10 / 11 INSTALLER                     " -ForegroundColor Cyan
Write-Host "                Minimalist, Elegant Tiling Desktop Environment                 " -ForegroundColor DarkCyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# 1. Determine Repository / Source Directory
# ------------------------------------------------------------------------------
$scriptSource = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptSource) -or -not (Test-Path (Join-Path $scriptSource "config"))) {
    Write-Host "[*] Web or stream installation detected." -ForegroundColor Yellow
    $installDir = Join-Path $HOME ".43pr-rice"
    if (Test-Path $installDir) {
        Write-Host "[*] Updating existing repository in $installDir..." -ForegroundColor Cyan
        git -C $installDir pull 2>$null
    } else {
        Write-Host "[*] Cloning repository to $installDir..." -ForegroundColor Cyan
        git clone https://github.com/amedello/43pr-rice-windows.git $installDir
    }
    $repoDir = $installDir
} else {
    $repoDir = $scriptSource
}

Write-Host "[+] Source Directory: $repoDir" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Package Management via Winget
# ------------------------------------------------------------------------------
if (-not $SkipPackages) {
    Write-Host "`n[*] Checking prerequisites and packages via winget..." -ForegroundColor Cyan

    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $hasWinget) {
        Write-Host "[!] Winget was not found on this system." -ForegroundColor Yellow
        Write-Host "    Please ensure Windows App Installer is installed or install GlazeWM/Zebar manually." -ForegroundColor Yellow
    } else {
        $packages = @(
            @{ Id = "glzr-io.glazewm"; Name = "GlazeWM (Tiling Window Manager)" },
            @{ Id = "glzr-io.zebar"; Name = "Zebar (Status Bar)" },
            @{ Id = "Starship.Starship"; Name = "Starship Shell Prompt" },
            @{ Id = "Fastfetch-cli.Fastfetch"; Name = "Fastfetch CLI" },
            @{ Id = "DEVCOM.JetBrainsMonoNerdFont"; Name = "JetBrains Mono Nerd Font" }
        )

        foreach ($pkg in $packages) {
            Write-Host "  -> Verifying $($pkg.Name) [$($pkg.Id)]..." -NoNewline
            $installed = winget list --id $pkg.Id --exact 2>$null
            if ($installed -match $pkg.Id) {
                Write-Host " [ALREADY INSTALLED]" -ForegroundColor Green
            } else {
                Write-Host " [INSTALLING...]" -ForegroundColor Yellow
                winget install --id $pkg.Id --exact --accept-package-agreements --accept-source-agreements --silent
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "     [OK] Successfully installed $($pkg.Name)" -ForegroundColor Green
                } else {
                    Write-Host "     [WARN] Winget returned non-zero code ($LASTEXITCODE) for $($pkg.Id)" -ForegroundColor DarkYellow
                }
            }
        }
    }
}

# ------------------------------------------------------------------------------
# 3. Environment Paths Setup
# ------------------------------------------------------------------------------
Write-Host "`n[*] Configuring Environment & Directories..." -ForegroundColor Cyan

$glzrBin = Join-Path $env:LOCALAPPDATA "Programs\glzr\bin"
if (-not (Test-Path $glzrBin)) {
    New-Item -ItemType Directory -Force -Path $glzrBin | Out-Null
}

# Ensure glzrBin is in User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -split ';' -notcontains $glzrBin) {
    Write-Host "  -> Adding $glzrBin to User PATH..." -ForegroundColor Cyan
    $newPath = $userPath.TrimEnd(';') + ";$glzrBin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:PATH = "$env:PATH;$glzrBin"
}

# ------------------------------------------------------------------------------
# 4. Compile media-ctl.exe (Zero external dependency)
# ------------------------------------------------------------------------------
Write-Host "`n[*] Building 43PR Native Controller (media-ctl.exe)..." -ForegroundColor Cyan

$cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    $cscCmd = Get-Command csc.exe -ErrorAction SilentlyContinue
    if ($cscCmd) { $cscPath = $cscCmd.Source }
}

$csSource = Join-Path $repoDir "scripts\media-ctl.cs"
$localExe = Join-Path $repoDir "scripts\media-ctl.exe"
$targetExe = Join-Path $glzrBin "media-ctl.exe"

if (Test-Path $cscPath) {
    Write-Host "  -> Compiling using $cscPath..." -ForegroundColor Cyan
    & $cscPath /target:winexe /platform:anycpu /optimize+ /out:$localExe $csSource
    if ($LASTEXITCODE -eq 0 -and (Test-Path $localExe)) {
        Write-Host "     [OK] Compiled $localExe" -ForegroundColor Green
    } else {
        Write-Host "     [WARN] Compilation failed, checking for pre-compiled binary..." -ForegroundColor DarkYellow
    }
}

if (Test-Path $localExe) {
    Copy-Item -Force $localExe $targetExe
    Write-Host "  [+] Installed Controller: $targetExe" -ForegroundColor Green
} else {
    Write-Host "  [!] Warning: media-ctl.exe could not be compiled or located." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 5. Link / Deploy GlazeWM, Zebar and 43PR Configurations
# ------------------------------------------------------------------------------
Write-Host "`n[*] Deploying 43PR Configuration Files..." -ForegroundColor Cyan

$setupGlzrScript = Join-Path $repoDir "scripts\setup-glzr.ps1"
if (Test-Path $setupGlzrScript) {
    & $setupGlzrScript
}

# Copy scripts and wallpapers to persistent ~/.glzr/ directory
$glzrScripts = Join-Path $HOME ".glzr\scripts"
New-Item -ItemType Directory -Force -Path $glzrScripts | Out-Null
Copy-Item -Force (Join-Path $repoDir "scripts\*.*") $glzrScripts
Write-Host "  [+] Persisted scripts to $glzrScripts" -ForegroundColor Green

$glzrThemes = Join-Path $HOME ".glzr\43pr\themes"
New-Item -ItemType Directory -Force -Path $glzrThemes | Out-Null
Copy-Item -Force (Join-Path $repoDir "config\43pr\themes\*.toml") $glzrThemes
Write-Host "  [+] Persisted themes to $glzrThemes" -ForegroundColor Green

$glzrWallpapers = Join-Path $HOME ".glzr\wallpapers"
New-Item -ItemType Directory -Force -Path $glzrWallpapers | Out-Null
Copy-Item -Force (Join-Path $repoDir "wallpapers\*.*") $glzrWallpapers
Write-Host "  [+] Persisted wallpapers to $glzrWallpapers" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 6. Terminal & PowerShell Profiles Setup
# ------------------------------------------------------------------------------
Write-Host "`n[*] Configuring Windows Terminal and Shell..." -ForegroundColor Cyan
$setupTerminalScript = Join-Path $repoDir "scripts\setup-terminal.ps1"
if (Test-Path $setupTerminalScript) {
    & $setupTerminalScript
}

# ------------------------------------------------------------------------------
# 7. Apply Windows Appearance & Default Theme
# ------------------------------------------------------------------------------
Write-Host "`n[*] Applying Windows Themes and Appearance..." -ForegroundColor Cyan
$setupWinTheme = Join-Path $repoDir "scripts\setup-windows-theme.ps1"
if (Test-Path $setupWinTheme) {
    try { & $setupWinTheme } catch {}
}

$themeScript = Join-Path $repoDir "scripts\theme.ps1"
if (Test-Path $themeScript) {
    Write-Host "  -> Applying default 'tokyo-night' theme..." -ForegroundColor Cyan
    try { & $themeScript -Theme "tokyo-night" } catch {}
}

# ------------------------------------------------------------------------------
# 8. Configure Startup Autostart (shell:startup)
# ------------------------------------------------------------------------------
Write-Host "`n[*] Configuring Startup Autostart..." -ForegroundColor Cyan

$startupFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
$shortcutPath = Join-Path $startupFolder "GlazeWM.lnk"
$glazewmExe = Join-Path $glzrBin "glazewm.exe"

if (-not (Test-Path $glazewmExe)) {
    $found = Get-Command glazewm.exe -ErrorAction SilentlyContinue
    if ($found) { $glazewmExe = $found.Source }
}

if (Test-Path $glazewmExe) {
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $glazewmExe
    $shortcut.WorkingDirectory = Split-Path $glazewmExe -Parent
    $shortcut.Description = "43PR Tiling Window Manager (GlazeWM)"
    $shortcut.Save()
    Write-Host "  [+] Created Autostart Shortcut in Windows Startup: $shortcutPath" -ForegroundColor Green
} else {
    Write-Host "  [!] Could not locate glazewm.exe to create startup shortcut." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# 9. Completion & Launch
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "                 43PR RICE INSTALLATION COMPLETED SUCCESSFULLY!                " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "  Hotkeys Quick Reference:" -ForegroundColor Cyan
Write-Host "    Alt + T             : Windows Terminal" -ForegroundColor White
Write-Host "    Alt + U             : Quake Scratchpad Terminal" -ForegroundColor White
Write-Host "    Alt + Shift + T     : Interactive Theme Selector (27 Themes + Auto Mode)" -ForegroundColor White
Write-Host "    Alt + Shift + /     : Shortcuts Cheatsheet (WPF HUD)" -ForegroundColor White
Write-Host "    Alt + V             : Clipboard History Manager" -ForegroundColor White
Write-Host "    Alt + Tab / Alt + J : Window Switcher" -ForegroundColor White
Write-Host "    Alt + Shift + M     : Hardware Sensors HUD" -ForegroundColor White
Write-Host "    Alt + Shift + W     : Cycle Next Wallpaper" -ForegroundColor White
Write-Host "    Alt + Q             : Close Window" -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""

if ($StartAfterInstall) {
    Write-Host "[*] Launching 43PR Desktop now..." -ForegroundColor Cyan
    & (Join-Path $repoDir "start-43pr.bat")
} elseif (-not $NoInteractive) {
    $resp = Read-Host "Would you like to start 43PR Desktop now? (Y/n)"
    if ($resp -eq "" -or $resp -match "^[yYsS]") {
        & (Join-Path $repoDir "start-43pr.bat")
    }
}

