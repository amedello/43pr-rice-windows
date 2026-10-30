# 43PR Project Comprehensive Audit Script
# Tests all 6 rules from GEMINI.md / AGENTS.md in pure 7-bit ASCII

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "             43PR PROJECT HEALTH & RULES AUDIT            " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$repoDir = "D:\Progetto"
$glzrDir = "$env:USERPROFILE\.glzr"
$issuesFound = 0

# -----------------------------------------------------------------------------
# 1. SYNC CHECK: .glzr vs D:\Progetto\config
# -----------------------------------------------------------------------------
Write-Host "`n[1] Checking Synchronization (.glzr <-> D:\Progetto\config)..." -ForegroundColor Yellow

$syncItems = @(
    @{ Glzr = "$glzrDir\glazewm\config.yaml"; Repo = "$repoDir\config\glazewm\config.yaml" },
    @{ Glzr = "$glzrDir\zebar\settings.json"; Repo = "$repoDir\config\zebar\settings.json" },
    @{ Glzr = "$glzrDir\zebar\starter\with-glazewm.html"; Repo = "$repoDir\config\zebar\starter\with-glazewm.html" },
    @{ Glzr = "$glzrDir\zebar\starter\styles.css"; Repo = "$repoDir\config\zebar\starter\styles.css" },
    @{ Glzr = "$glzrDir\zebar\starter\zpack.json"; Repo = "$repoDir\config\zebar\starter\zpack.json" },
    @{ Glzr = "$glzrDir\zebar\starter\vanilla.html"; Repo = "$repoDir\config\zebar\starter\vanilla.html" },
    @{ Glzr = "$glzrDir\zebar\starter\with-komorebi.html"; Repo = "$repoDir\config\zebar\starter\with-komorebi.html" },
    @{ Glzr = "$glzrDir\zebar\43pr-bar\style.css"; Repo = "$repoDir\config\zebar\43pr-bar\style.css" },
    @{ Glzr = "$glzrDir\zebar\43pr-bar\index.html"; Repo = "$repoDir\config\zebar\43pr-bar\index.html" },
    @{ Glzr = "$glzrDir\zebar\43pr-bar\zpack.json"; Repo = "$repoDir\config\zebar\43pr-bar\zpack.json" }
)

foreach ($item in $syncItems) {
    $src = $item.Glzr
    $dst = $item.Repo
    $rel = $dst.Substring($repoDir.Length + 1)

    if (-not (Test-Path $src)) {
        Write-Host "  [?] Notice: Missing in .glzr: $src" -ForegroundColor DarkGray
        continue
    }
    if (-not (Test-Path $dst)) {
        Write-Host "  [!] ERROR: Missing in repository config: $rel" -ForegroundColor Red
        $issuesFound++
        continue
    }

    # Normalize line endings before comparing content
    $content1 = (Get-Content $src -Raw -ErrorAction SilentlyContinue) -replace "`r`n", "`n"
    $content2 = (Get-Content $dst -Raw -ErrorAction SilentlyContinue) -replace "`r`n", "`n"

    if ($content1 -eq $content2) {
        Write-Host "  [OK] Synced: $rel" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Out of sync: $rel" -ForegroundColor Red
        $issuesFound++
    }
}

# -----------------------------------------------------------------------------
# 2. ENCODING & MOJIBAKE AUDIT IN .ps1 FILES
# -----------------------------------------------------------------------------
Write-Host "`n[2] Checking Scripts for Mojibake and Font Dependencies..." -ForegroundColor Yellow

$ps1Files = Get-ChildItem -Path "$repoDir\scripts" -Filter "*.ps1" | Where-Object { $_.Name -ne "audit-project.ps1" }
foreach ($f in $ps1Files) {
    $content = Get-Content $f.FullName -Raw
    $rel = $f.Name
    $fileIssues = @()

    $lines = Get-Content $f.FullName
    $lineNum = 0
    foreach ($l in $lines) {
        $lineNum++
        foreach ($ch in $l.ToCharArray()) {
            $code = [int]$ch
            # Mojibake common start bytes (0xC2, 0xC3, 0xE2, 0xEF, 0x80)
            if ($code -ge 128 -and $code -le 160) {
                $fileIssues += "Line ${lineNum}: Contains suspicious control/mojibake byte (0x$([Convert]::ToString($code, 16)))"
                break
            }
        }
    }

    # Check WPF XAML for Nerd Font in native desktop windows
    if ($content -match 'FontFamily="[^"]*JetBrainsMono Nerd Font[^"]*"' -and $content -match 'AllowsTransparency="True"') {
        if ($content -notmatch 'Segoe Fluent Icons|Segoe MDL2 Assets') {
            $fileIssues += "Native desktop window relies on Nerd Font without Segoe MDL2/Fluent fallback"
        }
    }

    if ($fileIssues.Count -eq 0) {
        Write-Host "  [OK] Clean: $rel" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $rel has issues:" -ForegroundColor Yellow
        foreach ($iss in $fileIssues) {
            Write-Host "      - $iss" -ForegroundColor DarkYellow
            $issuesFound++
        }
    }
}

# -----------------------------------------------------------------------------
# 3. Z-ORDER & STARTUP RESILIENCY (zpack.json, settings.json)
# -----------------------------------------------------------------------------
Write-Host "`n[3] Checking Zebar Z-Order & Startup Settings..." -ForegroundColor Yellow

$zpacks = @(
    "$glzrDir\zebar\starter\zpack.json",
    "$repoDir\config\zebar\starter\zpack.json"
)

foreach ($zp in $zpacks) {
    if (Test-Path $zp) {
        $json = Get-Content $zp -Raw | ConvertFrom-Json
        $withGlaze = $json.widgets | Where-Object { $_.name -eq "with-glazewm" }
        if ($withGlaze) {
            if ($withGlaze.zOrder -eq "normal" -or $withGlaze.zOrder -eq "top_most") {
                Write-Host "  [OK] $zp (zOrder is $($withGlaze.zOrder))" -ForegroundColor Green
            } else {
                Write-Host "  [WARN] $zp (zOrder is '$($withGlaze.zOrder)' - recommended: 'normal')" -ForegroundColor Yellow
                $issuesFound++
            }
        }
    }
}

# -----------------------------------------------------------------------------
# 4. ZERO CONSOLE POPUP AUDIT (Process Spawning)
# -----------------------------------------------------------------------------
Write-Host "`n[4] Checking Zero Console Popup & WindowStyle Hidden..." -ForegroundColor Yellow

$gwmCfg = "$repoDir\config\glazewm\config.yaml"
if (Test-Path $gwmCfg) {
    $lines = Get-Content $gwmCfg
    foreach ($line in $lines) {
        if ($line -match 'shell-exec powershell' -and $line -notmatch '-WindowStyle Hidden') {
            Write-Host "  [WARN] GlazeWM keybinding launches powershell without -WindowStyle Hidden: $line" -ForegroundColor Yellow
            $issuesFound++
        }
    }
}

# -----------------------------------------------------------------------------
# 5. OFFLINE INTEGRITY (External CDNs in HTML/CSS)
# -----------------------------------------------------------------------------
Write-Host "`n[5] Checking Offline Integrity (No external CDN URLs)..." -ForegroundColor Yellow

$htmlCssFiles = Get-ChildItem -Path "$repoDir\config\zebar" -Recurse -Include "*.html", "*.css", "*.js"
$cdnFound = 0
foreach ($h in $htmlCssFiles) {
    $content = Get-Content $h.FullName -Raw
    if ($content -match 'https?://(cdn|unpkg|cdnjs|fonts\.googleapis)') {
        Write-Host "  [WARN] External CDN detected in $($h.FullName): $matches[0]" -ForegroundColor Yellow
        $cdnFound++
        $issuesFound++
    }
}
if ($cdnFound -eq 0) {
    Write-Host "  [OK] All Zebar HTML/CSS/JS resources are local and 100% offline-ready" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 6. REPOSITORY BOUNDARIES & SECRETS
# -----------------------------------------------------------------------------
Write-Host "`n[6] Checking Secrets and Repository Boundaries..." -ForegroundColor Yellow

if (Test-Path "$repoDir\junsun-ambient-light\.git") {
    Write-Host "  [OK] junsun-ambient-light has its own isolated repository" -ForegroundColor Green
} else {
    Write-Host "  [WARN] junsun-ambient-light is missing its dedicated .git folder" -ForegroundColor Yellow
    $issuesFound++
}

$gitIgn = "$repoDir\.gitignore"
if (Test-Path $gitIgn) {
    $ignContent = Get-Content $gitIgn -Raw
    if ($ignContent -match 'junsun-ambient-light') {
        Write-Host "  [OK] .gitignore properly excludes junsun-ambient-light" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] .gitignore does not explicitly exclude junsun-ambient-light" -ForegroundColor Yellow
        $issuesFound++
    }
}

# Check for hardcoded GitHub PAT tokens
$allFiles = Get-ChildItem -Path $repoDir -Recurse -File -Exclude "*.dll", "*.exe", "*.png", "*.jpg", "*.apk" | Where-Object { $_.FullName -notmatch '\\\.git\\' }
$secretFound = 0
foreach ($f in $allFiles) {
    $txt = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($txt -match 'ghp_[A-Za-z0-9_]{20}') {
        Write-Host "  [DANGER] Possible GitHub PAT found in $($f.FullName)!" -ForegroundColor Red
        $secretFound++
        $issuesFound++
    }
}
if ($secretFound -eq 0) {
    Write-Host "  [OK] No leaked GitHub tokens found in codebase" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------
Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($issuesFound -eq 0) {
    Write-Host "  AUDIT PASSED! All engineering rules and styles are compliant." -ForegroundColor Green
} else {
    Write-Host "  AUDIT COMPLETED: $issuesFound issue(s) detected needing attention." -ForegroundColor Yellow
}
Write-Host "==========================================================" -ForegroundColor Cyan
