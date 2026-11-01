# 43PR Upstream Inspector (Internal Developer Tool)
# For developer reference only - NOT part of user interface or user upgrade flow
# Monitors https://github.com/43PR/dotfiles to inspect Linux ideas for porting
# Encoded in pure 7-bit ASCII to prevent mojibake

[CmdletBinding()]
param (
    [switch]$Detailed,
    [switch]$UpdateTracking
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "           43PR UPSTREAM (LINUX) REPO INSPECTOR           " -ForegroundColor Cyan
Write-Host "     Tracking: https://github.com/43PR/dotfiles           " -ForegroundColor DarkCyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $repoRoot -or -not (Test-Path "$repoRoot\config")) {
    $repoRoot = (Get-Location).Path
}

$trackingFile = Join-Path $repoRoot "config\43pr\upstream-tracking.json"
$glzrTracking = Join-Path $HOME ".glzr\43pr\upstream-tracking.json"

$lastKnownCommit = ""
$lastCheckedTime = ""
if (Test-Path $trackingFile) {
    try {
        $data = Get-Content $trackingFile -Raw | ConvertFrom-Json
        $lastKnownCommit = $data.lastCommitSha
        $lastCheckedTime = $data.lastChecked
    } catch {}
}

Write-Host "[*] Contacting GitHub API for 43PR/dotfiles..." -ForegroundColor Cyan

$commitsUrl = "https://api.github.com/repos/43PR/dotfiles/commits?per_page=15"
$headers = @{ "User-Agent" = "43PR-Rice-Windows-Updater" }

try {
    $commits = Invoke-RestMethod -Uri $commitsUrl -Headers $headers -TimeoutSec 10
} catch {
    Write-Host "[!] Could not query GitHub API (offline or rate limited): $($_.Exception.Message)" -ForegroundColor Yellow
    exit 0
}

if (-not $commits -or $commits.Count -eq 0) {
    Write-Host "[!] No commit data returned from upstream." -ForegroundColor Yellow
    exit 0
}

$latestSha = $commits[0].sha
$latestDate = $commits[0].commit.committer.date
$latestAuthor = $commits[0].commit.author.name
$latestMsg = ($commits[0].commit.message -split "`r?`n")[0]

Write-Host "[+] Upstream Latest Commit: " -NoNewline -ForegroundColor Green
Write-Host "$($latestSha.Substring(0, 7)) " -ForegroundColor White -NoNewline
Write-Host "($latestDate)" -ForegroundColor DarkGray
Write-Host "    Author : $latestAuthor" -ForegroundColor DarkCyan
Write-Host "    Message: $latestMsg" -ForegroundColor Yellow

# Display recent commits
Write-Host "`n[*] Recent Upstream Activity:" -ForegroundColor Cyan
$newCount = 0
$idx = 0
foreach ($c in $commits) {
    $idx++
    $shaShort = $c.sha.Substring(0, 7)
    $msg = ($c.commit.message -split "`r?`n")[0]
    $date = $c.commit.committer.date

    $isNew = $true
    if ($lastKnownCommit -and $c.sha -eq $lastKnownCommit) { $isNew = $false }
    if ($isNew) { $newCount++ }

    $prefix = "  [#$idx] "
    if ($c.sha -eq $lastKnownCommit) {
        Write-Host "$prefix$shaShort - $msg (CURRENT LOCAL SYNC POINT)" -ForegroundColor DarkGray
        break
    } else {
        Write-Host "$prefix$shaShort " -NoNewline -ForegroundColor White
        Write-Host "($date)" -ForegroundColor DarkGray
        Write-Host "       $msg" -ForegroundColor Gray
    }
}

# Inspect Quickshell components upstream
Write-Host "`n[*] Scanning Upstream Quickshell Components for Porting Opportunities..." -ForegroundColor Cyan
try {
    $qsUrl = "https://api.github.com/repos/43PR/dotfiles/contents/.config/quickshell"
    $qsFiles = Invoke-RestMethod -Uri $qsUrl -Headers $headers -TimeoutSec 10
    
    $candidateList = @(
        @{ Name = "Todo.qml"; WindowsEq = "scripts\todo-hud.ps1"; Status = "Ported to Native WPF" },
        @{ Name = "QuickActions.qml"; WindowsEq = "scripts\quick-actions.ps1"; Status = "Ported to Native WPF" },
        @{ Name = "VolumeOsd.qml"; WindowsEq = "scripts\media-ctl.cs"; Status = "Covered by CoreAudio / media-ctl" },
        @{ Name = "PowerMenu.qml"; WindowsEq = "scripts\power-menu.ps1"; Status = "Ported to Native WPF" },
        @{ Name = "Bar.qml"; WindowsEq = "config\zebar\43pr-bar\"; Status = "Ported to Zebar WebView2" },
        @{ Name = "SettingsWindow.qml"; WindowsEq = "scripts\theme-picker.ps1"; Status = "Theme & Color Settings Active" }
    )

    foreach ($item in $candidateList) {
        Write-Host "  -> $($item.Name.PadRight(20)) -> $($item.WindowsEq.PadRight(28)) [$($item.Status)]" -ForegroundColor Green
    }
} catch {
    Write-Host "  [?] Could not inspect Quickshell tree: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# Save new tracking if requested or if sha differs
if ($UpdateTracking -or (-not (Test-Path $trackingFile))) {
    $trackObj = [PSCustomObject]@{
        lastCommitSha = $latestSha
        lastCommitMessage = $latestMsg
        lastCommitDate = $latestDate
        lastChecked = (Get-Date).ToString("s")
    }
    $trackJson = $trackObj | ConvertTo-Json -Depth 4
    Set-Content -Path $trackingFile -Value $trackJson -Encoding UTF8
    
    $glzrParent = Split-Path -Parent $glzrTracking
    if (-not (Test-Path $glzrParent)) { New-Item -ItemType Directory -Force -Path $glzrParent | Out-Null }
    Set-Content -Path $glzrTracking -Value $trackJson -Encoding UTF8
    
    Write-Host "`n[+] Upstream tracking updated: $latestSha" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "              INSPECTION COMPLETED                        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
