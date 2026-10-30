# 43PR Floating Instant Math & Unit Calculator
# Evaluates math expressions, percentages, units, hex/dec in real-time
# Hotkey: Alt + C

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$accentColor = "#7AA2F7"
$styleFile = "D:\Progetto\config\zebar\starter\styles.css"
if (Test-Path $styleFile) {
    $content = Get-Content $styleFile -Raw
    if ($content -match '--accent:\s*(#[0-9a-fA-F]{6})') {
        $accentColor = $matches[1]
    }
}

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Calculator"
        Width="520" Height="78"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False">
    <Border Background="#F0131620"
            BorderBrush="$accentColor"
            BorderThickness="1.5"
            CornerRadius="16"
            Padding="14,10">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="24" ShadowDepth="4" Opacity="0.6"/>
        </Border.Effect>
        <Grid VerticalAlignment="Center">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- Icon -->
            <TextBlock Grid.Column="0" Text="&#xE8EF;"
                       FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                       FontSize="18" Foreground="$accentColor"
                       VerticalAlignment="Center" Margin="0,0,12,0"/>

            <!-- Input Box with Placeholder -->
            <Grid Grid.Column="1" VerticalAlignment="Center">
                <TextBlock x:Name="TxtInputPlaceholder" Text="Scrivi un calcolo (es. 15% of 250, 45*1.22, 1024 MB in GB)..."
                           FontSize="14" Foreground="#556488" FontFamily="Segoe UI Variable Text, Consolas" VerticalAlignment="Center" IsHitTestVisible="False"/>
                <TextBox x:Name="TxtInput"
                         Background="Transparent" Foreground="#CDD6F4"
                         BorderThickness="0" FontSize="17"
                         FontFamily="Segoe UI Variable Text, Consolas"
                         CaretBrush="$accentColor"
                         VerticalAlignment="Center"
                         FocusVisualStyle="{x:Null}"/>
            </Grid>

            <!-- Result -->
            <Border Grid.Column="2" Background="#1F283C" CornerRadius="8" Padding="10,4" Margin="10,0,0,0" VerticalAlignment="Center">
                <TextBlock x:Name="TxtResult" Text="= 0"
                           FontSize="16" FontWeight="Bold"
                           Foreground="$accentColor" FontFamily="Consolas"/>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$txtInput = $window.FindName("TxtInput")
$txtPlaceholder = $window.FindName("TxtInputPlaceholder")
$txtResult = $window.FindName("TxtResult")

$evalMath = {
    param([string]$expr)
    if ([string]::IsNullOrWhiteSpace($expr)) {
        return "0"
    }
    
    $clean = $expr.Trim()

    # Percentage: "X % of Y" -> (X/100) * Y
    if ($clean -match '(?i)^\s*([0-9.]+)\s*%\s*of\s*([0-9.]+)\s*$') {
        $pct = [double]$matches[1]
        $total = [double]$matches[2]
        return [string][Math]::Round(($pct / 100.0) * $total, 4)
    }

    # Number Base: "0x... in dec" or "... in hex" or "... in bin"
    if ($clean -match '(?i)^0x([0-9a-f]+)\s*(in\s*dec)?$') {
        return [string][Convert]::ToInt64($matches[1], 16)
    }
    if ($clean -match '(?i)^([0-9]+)\s*in\s*hex$') {
        return "0x" + [Convert]::ToString([int64]$matches[1], 16).ToUpper()
    }
    if ($clean -match '(?i)^([0-9]+)\s*in\s*bin$') {
        return "0b" + [Convert]::ToString([int64]$matches[1], 2)
    }

    # Storage unit conversion: "X GB in MB", "X MB in GB"
    if ($clean -match '(?i)^([0-9.]+)\s*GB\s*in\s*MB$') {
        return [string]([double]$matches[1] * 1024) + " MB"
    }
    if ($clean -match '(?i)^([0-9.]+)\s*MB\s*in\s*GB$') {
        return [string][Math]::Round([double]$matches[1] / 1024.0, 3) + " GB"
    }
    if ($clean -match '(?i)^([0-9.]+)\s*TB\s*in\s*GB$') {
        return [string]([double]$matches[1] * 1024) + " GB"
    }

    # Math sanitization
    # Support ^ as power
    $sanitized = $clean -replace '\^', '**'
    $sanitized = $sanitized -replace '(?i)\bpi\b', '[Math]::PI'
    $sanitized = $sanitized -replace '(?i)\bsqrt\(([^)]+)\)', '[Math]::Sqrt($1)'
    $sanitized = $sanitized -replace '(?i)\babs\(([^)]+)\)', '[Math]::Abs($1)'

    # Security whitelist: only allow numbers, math operators, math functions
    if ($sanitized -match '^[0-9\.\+\-\*\/\%\(\)\s,]|\[Math\]::[A-Za-z]+') {
        try {
            $val = Invoke-Expression $sanitized
            if ($val -is [double] -or $val -is [int] -or $val -is [int64]) {
                if ([double]::IsNaN($val) -or [double]::IsInfinity($val)) {
                    return "Indefinito"
                }
                return [string][Math]::Round([double]$val, 6)
            }
        } catch {}
    }
    return "..."
}

$txtInput.Add_TextChanged({
    $txtPlaceholder.Visibility = if ([string]::IsNullOrEmpty($txtInput.Text)) {
        [System.Windows.Visibility]::Visible
    } else {
        [System.Windows.Visibility]::Collapsed
    }
    $res = & $evalMath $txtInput.Text
    $txtResult.Text = "= $res"
})

$window.Add_KeyDown({
    param($s, $e)
    switch ($e.Key) {
        "Escape" { $window.Close() }
        "Enter" {
            $res = & $evalMath $txtInput.Text
            if ($res -and $res -ne "..." -and $res -ne "Indefinito") {
                [System.Windows.Clipboard]::SetText($res)
                [System.Media.SystemSounds]::Asterisk.Play()
            }
            $window.Close()
        }
    }
})

$window.Add_Loaded({
    $txtInput.Focus()
})

$window.ShowDialog() | Out-Null

