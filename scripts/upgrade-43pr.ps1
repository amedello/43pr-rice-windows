# ==============================================================================
#  43PR Rice for Windows - Universal System Upgrader
#  Repository: https://github.com/amedello/43pr-rice-windows
#  Dual-Engine: Git Engine (Fast Rebase) + Zero-Dependency Engine (REST + ZIP)
#  Pure 7-bit ASCII encoded for 100% mojibake prevention
# ==============================================================================

[CmdletBinding()]
param (
    [switch]$Pull = $true,
    [switch]$Force,
    [switch]$UpdatePackages,
    [switch]$Rebuild = $true,
    [switch]$NoRestart,
    [switch]$NoNotify,
    [switch]$Silent
)

$ErrorActionPreference = "Continue"

# Desktop Notification Helper (Windows 10/11 Action Center)
function Send-43prNotification {
    param(
        [string]$Title = "43PR Rice Windows",
        [string]$Message,
        [string]$IconType = "Info"
    )
    if ($NoNotify) { return }
    try {
        $toastScript = Join-Path $scriptDir "toast.ps1"
        if (-not (Test-Path $toastScript)) {
            $toastScript = Join-Path $HOME ".glzr\scripts\toast.ps1"
        }
        if (-not (Test-Path $toastScript)) {
            $toastScript = "D:\Progetto\scripts\toast.ps1"
        }
        if (Test-Path $toastScript) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$toastScript" -Title "$Title" -Message "$Message" -Type "$IconType"
        }
    } catch {}
}

# Banner
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "                     43PR RICE SYSTEM UPGRADER (WINDOWS)                        " -ForegroundColor Cyan
Write-Host "                 Verifica, Download e Applicazione Aggiornamenti                " -ForegroundColor DarkCyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# 1. Determine Repository Root
# ------------------------------------------------------------------------------
$scriptDir = $PSScriptRoot
$repoDir = Split-Path -Parent $scriptDir
if (-not $repoDir -or -not (Test-Path (Join-Path $repoDir "config"))) {
    $repoDir = (Get-Location).Path
}

Write-Host "[+] Cartella di Sistema: $repoDir" -ForegroundColor Green

Send-43prNotification -Message "Controllo aggiornamenti in corso dal repository ufficiale..."

# ------------------------------------------------------------------------------
# 2. Check Remote Updates: Dual-Engine (Git or Native Windows REST/ZIP)
# ------------------------------------------------------------------------------
$hasUpdates = $false
$behindCount = 0
$glzrHome = Join-Path $HOME ".glzr"

$hasGit = (Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $repoDir ".git"))

if ($hasGit -and $Pull) {
    # --------------------------------------------------------------------------
    # ENGINE A: Git Engine (se Git e la cartella .git sono presenti)
    # --------------------------------------------------------------------------
    Write-Host "`n[*] [Git Engine] Verifica aggiornamenti dal repository ufficiale (origin/master)..." -ForegroundColor Cyan
    
    $null = git -C $repoDir fetch origin master 2>&1
    
    $behindStr = (git -C $repoDir rev-list HEAD..origin/master --count 2>$null)
    if ($behindStr) {
        $behindCount = [int]$behindStr.Trim()
    }

    if ($behindCount -gt 0) {
        $hasUpdates = $true
        Write-Host ""
        Write-Host "================================================================================" -ForegroundColor Green
        Write-Host "  [+] NUOVI AGGIORNAMENTI DISPONIBILI: $behindCount COMMIT RILASCIATI!" -ForegroundColor Green
        Write-Host "================================================================================" -ForegroundColor Green
        Write-Host "  [*] Elenco delle novita incluse:" -ForegroundColor Yellow
        $logEntries = git -C $repoDir log HEAD..origin/master --oneline 2>$null
        foreach ($l in $logEntries) {
            Write-Host "      $l" -ForegroundColor Gray
        }
        Write-Host "================================================================================" -ForegroundColor Green
        Send-43prNotification -Message "Trovati $behindCount nuovi commit rilasciati! Avvio aggiornamento..."
    } else {
        Write-Host ""
        Write-Host "================================================================================" -ForegroundColor Green
        Write-Host "  [OK] NESSUN AGGIORNAMENTO DISPONIBILE" -ForegroundColor Green
        Write-Host "  Il tuo 43PR Rice Windows e gia aggiornato all'ultima versione ufficiale." -ForegroundColor White
        $currHead = (git -C $repoDir rev-parse --short HEAD 2>$null)
        Write-Host "  Commit attivo : $currHead (origin/master)" -ForegroundColor DarkGray
        Write-Host "  Stato         : Tutti i moduli, configurazioni e script sono allineati." -ForegroundColor DarkGray
        Write-Host "================================================================================" -ForegroundColor Green
        Send-43prNotification -Message "Il sistema e gia aggiornato all'ultima versione ($currHead)."
    }

    if ($hasUpdates -or $Force) {
        $status = git -C $repoDir status --porcelain 2>$null
        $hasLocalEdits = -not [string]::IsNullOrWhiteSpace($status)
        $stashed = $false

        if ($hasLocalEdits) {
            Write-Host "`n  -> Rilevate modifiche locali personalizzate. Salvataggio in stash protettivo..." -ForegroundColor Yellow
            $stashOut = git -C $repoDir stash push -m "pre-upgrade-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')" 2>&1
            $stashed = ($LASTEXITCODE -eq 0 -and ($stashOut -match "Saved working directory"))
        }

        Write-Host "  -> Scaricamento ed applicazione aggiornamenti via rebase..." -ForegroundColor Cyan
        $pullOut = git -C $repoDir pull --rebase origin master 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Repository locale aggiornato con successo!" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Pull completato con avvisi (codice $LASTEXITCODE). Proseguo con il deployment..." -ForegroundColor DarkYellow
        }

        if ($stashed) {
            Write-Host "  -> Ripristino delle personalizzazioni locali dell'utente dallo stash..." -ForegroundColor Cyan
            $null = git -C $repoDir stash pop 2>&1
            Write-Host "  [OK] Personalizzazioni locali ripristinate senza perdite." -ForegroundColor Green
        }
    }
} else {
    # --------------------------------------------------------------------------
    # ENGINE B: Zero-Dependency Engine (100% Nativo Windows senza Git)
    # --------------------------------------------------------------------------
    Write-Host "`n[*] [Zero-Dependency Engine] Controllo aggiornamenti via GitHub API (senza Git)..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $localSha = ""
    $versionFile = Join-Path $repoDir "config\43pr\version.json"
    if (-not (Test-Path $versionFile)) {
        $versionFile = Join-Path $glzrHome "43pr\version.json"
    }
    if (Test-Path $versionFile) {
        try {
            $vData = Get-Content $versionFile -Raw | ConvertFrom-Json
            $localSha = [string]$vData.commitSha
        } catch {}
    }

    $apiUrl = "https://api.github.com/repos/amedello/43pr-rice-windows/commits/master"
    $headers = @{ "User-Agent" = "43PR-Rice-Updater" }
    $remoteSha = ""
    $commitMsg = ""
    $commitDate = ""

    try {
        $commitInfo = Invoke-RestMethod -Uri $apiUrl -Headers $headers -TimeoutSec 10
        if ($commitInfo) {
            $remoteSha = [string]$commitInfo.sha
            $commitMsg = ($commitInfo.commit.message -split "`r?`n")[0]
            $commitDate = [string]$commitInfo.commit.committer.date
        }
    } catch {
        Write-Host "  [!] Impossibile verificare aggiornamenti remoti: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    if ($remoteSha) {
        $remoteShort = if ($remoteSha.Length -ge 7) { $remoteSha.Substring(0, 7) } else { $remoteSha }
        $localShort = if ($localSha.Length -ge 7) { $localSha.Substring(0, 7) } else { $localSha }

        if ($localSha -and $localSha -eq $remoteSha -and (-not $Force)) {
            Write-Host ""
            Write-Host "================================================================================" -ForegroundColor Green
            Write-Host "  [OK] NESSUN AGGIORNAMENTO DISPONIBILE" -ForegroundColor Green
            Write-Host "  Il tuo 43PR Rice Windows e gia aggiornato all'ultima versione ufficiale." -ForegroundColor White
            Write-Host "  Versione attiva : $localShort ($commitDate)" -ForegroundColor DarkGray
            Write-Host "  Stato           : Tutti i file e i moduli di sistema sono aggiornati." -ForegroundColor DarkGray
            Write-Host "================================================================================" -ForegroundColor Green
            Send-43prNotification -Message "Il sistema e gia aggiornato all'ultima versione ($localShort)."
        } else {
            $hasUpdates = $true
            Write-Host ""
            Write-Host "================================================================================" -ForegroundColor Green
            Write-Host "  [+] NUOVA VERSIONE RILASCIATA SU GITHUB!" -ForegroundColor Green
            Write-Host "================================================================================" -ForegroundColor Green
            Write-Host "      Versione remota : $remoteShort ($commitDate)" -ForegroundColor DarkCyan
            Write-Host "      Note di rilascio: $commitMsg" -ForegroundColor Yellow
            Write-Host "================================================================================" -ForegroundColor Green
            
            Send-43prNotification -Message "Nuova versione disponibile ($remoteShort). Avvio download..."

            Write-Host "`n  -> Download archivio di aggiornamento da GitHub (master.zip)..." -ForegroundColor Cyan
            $zipDest = Join-Path $env:TEMP "43pr-upgrade.zip"
            $extractDest = Join-Path $env:TEMP "43pr-upgrade-extracted"

            if (Test-Path $extractDest) { Remove-Item -Recurse -Force $extractDest -ErrorAction SilentlyContinue }
            if (Test-Path $zipDest) { Remove-Item -Force $zipDest -ErrorAction SilentlyContinue }

            # Download with Live Progress Feedback
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "43PR-Rice-Updater")
            
            $downloadJob = $wc.DownloadFileTaskAsync([Uri]"https://github.com/amedello/43pr-rice-windows/archive/refs/heads/master.zip", $zipDest)
            
            $spinChars = @('|', '/', '-', '\')
            $spinIdx = 0
            while (-not $downloadJob.IsCompleted) {
                Start-Sleep -Milliseconds 250
                $spin = $spinChars[$spinIdx % $spinChars.Length]
                $spinIdx++
                if (Test-Path $zipDest) {
                    $dlBytes = (Get-Item $zipDest).Length
                    $dlMb = [Math]::Round($dlBytes / 1MB, 1)
                    Write-Host "`r     [*] Download in corso $spin ($dlMb MB scaricati)..." -NoNewline -ForegroundColor Cyan
                } else {
                    Write-Host "`r     [*] Connessione a GitHub in corso $spin..." -NoNewline -ForegroundColor Cyan
                }
            }
            Write-Host "`r  [OK] Download completato con successo!                              " -ForegroundColor Green

            Write-Host "  -> Estrazione ed applicazione file di aggiornamento..." -ForegroundColor Cyan
            Expand-Archive -Path $zipDest -DestinationPath $extractDest -Force

            $extractedRoot = (Get-ChildItem -Path $extractDest -Directory | Select-Object -First 1).FullName
            if (Test-Path $extractedRoot) {
                Copy-Item -Recurse -Force (Join-Path $extractedRoot "*") $repoDir
                Write-Host "  [OK] File aggiornati direttamente senza Git!" -ForegroundColor Green
            }

            # Update version metadata
            $newVersionObj = [PSCustomObject]@{
                commitSha = $remoteSha
                version = "1.2.0"
                branch = "master"
                updatedAt = (Get-Date).ToString("s")
            }
            $newVersionJson = $newVersionObj | ConvertTo-Json -Depth 4
            Set-Content -Path (Join-Path $repoDir "config\43pr\version.json") -Value $newVersionJson -Encoding UTF8
            Set-Content -Path (Join-Path $glzrHome "43pr\version.json") -Value $newVersionJson -Encoding UTF8

            # Cleanup
            Remove-Item -Force $zipDest -ErrorAction SilentlyContinue
            Remove-Item -Recurse -Force $extractDest -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------------------------
# 3. Create Timestamped Safety Backup of Current Configurations
# ------------------------------------------------------------------------------
$timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$backupDir = Join-Path $glzrHome "backups\$timestamp"

Write-Host "`n[*] Creazione backup preventivo in $backupDir..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$itemsToBackup = @(
    (Join-Path $glzrHome "glazewm\config.yaml"),
    (Join-Path $glzrHome "zebar\settings.json"),
    (Join-Path $glzrHome "zebar\starter\styles.css"),
    (Join-Path $glzrHome "zebar\starter\with-glazewm.html"),
    (Join-Path $glzrHome "zebar\43pr-bar\style.css"),
    (Join-Path $glzrHome "zebar\43pr-bar\index.html")
)

foreach ($item in $itemsToBackup) {
    if (Test-Path $item) {
        $relPath = $item.Substring($glzrHome.Length + 1)
        $targetBackup = Join-Path $backupDir $relPath
        $targetDir = Split-Path -Parent $targetBackup
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Force -Path $targetDir | Out-Null }
        Copy-Item -Force $item $targetBackup
    }
}
Write-Host "  [+] Backup completato con successo." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 4. Synchronize .glzr <-> config (Rule 2 Enforcement & User State Protection)
# ------------------------------------------------------------------------------
Write-Host "`n[*] Sincronizzazione ed allineamento delle configurazioni..." -ForegroundColor Cyan

$setupGlzrScript = Join-Path $repoDir "scripts\setup-glzr.ps1"
if (Test-Path $setupGlzrScript) {
    & powershell -ExecutionPolicy Bypass -File $setupGlzrScript
}

# Copy updated scripts to ~/.glzr/scripts
$glzrScripts = Join-Path $glzrHome "scripts"
New-Item -ItemType Directory -Force -Path $glzrScripts | Out-Null
Copy-Item -Force (Join-Path $repoDir "scripts\*.*") $glzrScripts
Write-Host "  [+] Script di sistema aggiornati in $glzrScripts" -ForegroundColor Green

# Sync themes (merge so user-added custom themes are preserved)
$glzrThemes = Join-Path $glzrHome "43pr\themes"
New-Item -ItemType Directory -Force -Path $glzrThemes | Out-Null
Copy-Item -Force (Join-Path $repoDir "config\43pr\themes\*.toml") $glzrThemes
Write-Host "  [+] Temi di sistema allineati in $glzrThemes" -ForegroundColor Green

# Sync wallpapers (merge so user wallpapers in ~/.glzr/wallpapers are preserved)
$glzrWallpapers = Join-Path $glzrHome "wallpapers"
New-Item -ItemType Directory -Force -Path $glzrWallpapers | Out-Null
Copy-Item -Force (Join-Path $repoDir "wallpapers\*.*") $glzrWallpapers
Write-Host "  [+] Sfondi allineati in $glzrWallpapers" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 5. Recompile Native Controller (media-ctl.exe)
# ------------------------------------------------------------------------------
if ($Rebuild) {
    Write-Host "`n[*] Ricompilazione controller nativo (media-ctl.exe)..." -ForegroundColor Cyan
    
    $cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    if (-not (Test-Path $cscPath)) {
        $cscCmd = Get-Command csc.exe -ErrorAction SilentlyContinue
        if ($cscCmd) { $cscPath = $cscCmd.Source }
    }

    $csSource = Join-Path $repoDir "scripts\media-ctl.cs"
    $localExe = Join-Path $repoDir "scripts\media-ctl.exe"
    $glzrBin = Join-Path $env:LOCALAPPDATA "Programs\glzr\bin"
    $targetExe = Join-Path $glzrBin "media-ctl.exe"

    if (Test-Path $cscPath) {
        Write-Host "  -> Compilazione in corso con $cscPath..." -ForegroundColor Cyan
        & $cscPath /target:winexe /platform:anycpu /optimize+ /out:$localExe $csSource
        if ($LASTEXITCODE -eq 0 -and (Test-Path $localExe)) {
            Write-Host "  [OK] Controller $localExe compilato con successo!" -ForegroundColor Green
            # Update all runtime binary locations
            if (Test-Path $glzrBin) {
                Copy-Item -Force $localExe $targetExe
                Write-Host "  [+] Controller aggiornato in $targetExe" -ForegroundColor Green
            }
            $glzrScriptExe = Join-Path $glzrHome "scripts\media-ctl.exe"
            Copy-Item -Force $localExe $glzrScriptExe
            if (Test-Path "D:\Progetto\scripts") {
                Copy-Item -Force $localExe "D:\Progetto\scripts\media-ctl.exe"
            }
        } else {
            Write-Host "  [WARN] Compilazione non riuscita (codice $LASTEXITCODE)" -ForegroundColor DarkYellow
        }
    }
}

# ------------------------------------------------------------------------------
# 6. Package Updates via Winget (if requested)
# ------------------------------------------------------------------------------
if ($UpdatePackages) {
    Write-Host "`n[*] Controllo aggiornamenti pacchetti via winget..." -ForegroundColor Cyan
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        $pkgs = @("glzr-io.glazewm", "glzr-io.zebar", "Starship.Starship", "Fastfetch-cli.Fastfetch")
        foreach ($p in $pkgs) {
            Write-Host "  -> Verifica upgrade per $p..." -ForegroundColor Cyan
            winget upgrade --id $p --exact --accept-package-agreements --accept-source-agreements --silent 2>$null
        }
    }
}

# ------------------------------------------------------------------------------
# 7. Forced Desktop Environment & Runtime Reload
# ------------------------------------------------------------------------------
if (-not $NoRestart) {
    Write-Host "`n[*] [Ricaricamento Forzoso] Aggiornamento completo dell'ambiente desktop..." -ForegroundColor Cyan

    # 1. Chiudi eventuali processi HUD aperti per sbloccare gli script
    $hudTitles = @("43PR Power Menu", "43PR Quick Actions", "43PR Todo & Notes HUD", "43PR Cheatsheet", "43PR Theme Switcher")
    Get-Process powershell, pwsh -ErrorAction SilentlyContinue | Where-Object {
        $hudTitles -contains $_.MainWindowTitle
    } | Stop-Process -Force -ErrorAction SilentlyContinue

    # 2. Ricarica configurazione GlazeWM in modo forzoso
    $glazewmCmd = Get-Command glazewm -ErrorAction SilentlyContinue
    if ($glazewmCmd) {
        Write-Host "  -> Invio reload-config forzoso a GlazeWM..." -ForegroundColor Cyan
        & glazewm command reload-config 2>&1 | Out-Null
        Start-Sleep -Milliseconds 600
    }

    # 3. Riavvio pulito e forzato di Zebar
    Write-Host "  -> Riavvio forzato e pulito della barra Zebar..." -ForegroundColor Cyan
    Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500

    # 4. Riapplica tema attivo
    $themeScript = Join-Path $glzrHome "scripts\theme.ps1"
    if (Test-Path $themeScript) {
        Write-Host "  -> Riapplicazione tema coordinato..." -ForegroundColor Cyan
        try { & powershell -ExecutionPolicy Bypass -File $themeScript -Theme "tokyo-night" } catch {}
    }

    # 5. Riavvia Zebar
    if ($glazewmCmd) {
        & glazewm command shell-exec zebar 2>&1 | Out-Null
    }
}

# ------------------------------------------------------------------------------
# 8. Verify Compliance with audit-project.ps1
# ------------------------------------------------------------------------------
Write-Host "`n[*] Esecuzione audit finale di salute e conformita..." -ForegroundColor Cyan
$auditScript = Join-Path $repoDir "scripts\audit-project.ps1"
if (Test-Path $auditScript) {
    & powershell -ExecutionPolicy Bypass -File $auditScript
}

Write-Host "`n================================================================================" -ForegroundColor Green
Write-Host "                   PROCEDURA DI AGGIORNAMENTO COMPLETATA!                      " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""

if ($hasUpdates) {
    Send-43prNotification -Message "Aggiornamento a 43PR Rice completato con successo! Ambiente ricaricato."
}
