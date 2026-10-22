# 43PR PowerShell Profile for Windows
# Mirrors the Zsh + Starship experience

# 1. PSReadLine (Autosuggestions, history and keybindings)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    }
    Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key Tab -Function Complete -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
}

# 2. Add WinGet Links and GlazeWM to PATH if missing in current session
$extraPaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
    "$env:LOCALAPPDATA\Programs\glzr\bin",
    "$env:LOCALAPPDATA\Programs\glzr\bin\cli"
)
foreach ($p in $extraPaths) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

# 3. Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
    Invoke-Expression (&starship init powershell)
}

# 4. Aliases matching 43PR Linux setup
Set-Alias -Name ff -Value fastfetch -ErrorAction SilentlyContinue
function c { Clear-Host }
function reload-profile { . $PROFILE }

# 5. Fastfetch welcome banner (runs only in interactive user console)
if ([Environment]::UserInteractive -and (-not $MyInvocation.Line) -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    fastfetch -c "$HOME\.config\fastfetch\config.jsonc"
}
