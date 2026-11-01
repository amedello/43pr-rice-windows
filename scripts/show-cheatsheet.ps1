# 43PR Desktop Shortcuts Cheatsheet (CLI + WPF HUD)
# Displays all active keybindings and commands for GlazeWM and 43PR Rice
# Pure 7-bit ASCII encoded for 100% mojibake prevention

[CmdletBinding()]
param (
    [switch]$Cli
)

# CLI Mode
if ($Cli) {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                 43PR DESKTOP RICE - GUIDA SCORCIATOIE TASTIERA                 " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan

    Write-Host "`n  -- GESTIONE FINESTRE E TILING -----------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + Q               " -NoNewline -ForegroundColor White; Write-Host "Chiudi finestra attiva" -ForegroundColor Gray
    Write-Host "  Alt + F               " -NoNewline -ForegroundColor White; Write-Host "Schermo intero (Fullscreen toggle)" -ForegroundColor Gray
    Write-Host "  Alt + Space           " -NoNewline -ForegroundColor White; Write-Host "Finestra fluttuante (Floating toggle)" -ForegroundColor Gray
    Write-Host "  Alt + S               " -NoNewline -ForegroundColor White; Write-Host "Alterna divisione orizzontale/verticale" -ForegroundColor Gray
    Write-Host "  Alt + H / J / K / L   " -NoNewline -ForegroundColor White; Write-Host "Sposta focus (Sinistra / Basso / Alto / Destra)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + H/J/K/L " -NoNewline -ForegroundColor White; Write-Host "Sposta posizione finestra attiva" -ForegroundColor Gray
    Write-Host "  Alt + 1 .. 9          " -NoNewline -ForegroundColor White; Write-Host "Passa al Workspace 1 .. 9" -ForegroundColor Gray
    Write-Host "  Alt + Shift + 1 .. 9  " -NoNewline -ForegroundColor White; Write-Host "Sposta finestra attiva nel Workspace 1 .. 9" -ForegroundColor Gray

    Write-Host "`n  -- APPLICAZIONI E STRUMENTI -------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + T               " -NoNewline -ForegroundColor White; Write-Host "Windows Terminal" -ForegroundColor Gray
    Write-Host "  Alt + U               " -NoNewline -ForegroundColor White; Write-Host "Terminale Quake Scratchpad a discesa" -ForegroundColor Gray
    Write-Host "  Alt + V               " -NoNewline -ForegroundColor White; Write-Host "Clipboard History Manager (Appunti)" -ForegroundColor Gray
    Write-Host "  Alt + Tab / Alt + J   " -NoNewline -ForegroundColor White; Write-Host "Global Window Switcher (Cambia app)" -ForegroundColor Gray
    Write-Host "  Alt + N               " -NoNewline -ForegroundColor White; Write-Host "Note & Todo HUD (Attivita e note rapide)" -ForegroundColor Gray
    Write-Host "  Alt + A               " -NoNewline -ForegroundColor White; Write-Host "Quick Actions Hub (Azioni rapide)" -ForegroundColor Gray
    Write-Host "  Alt + C               " -NoNewline -ForegroundColor White; Write-Host "Calcolatrice Rapida & Unita al volo" -ForegroundColor Gray
    Write-Host "  Alt + Shift + C       " -NoNewline -ForegroundColor White; Write-Host "Pipetta Color Picker (Cattura colore pixel)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + M       " -NoNewline -ForegroundColor White; Write-Host "Sensori Hardware HUD (CPU, GPU, RAM, Dischi)" -ForegroundColor Gray
    Write-Host "  Alt + D               " -NoNewline -ForegroundColor White; Write-Host "Flow Launcher (Cerca app e file)" -ForegroundColor Gray
    Write-Host "  Alt + E               " -NoNewline -ForegroundColor White; Write-Host "Esplora Risorse" -ForegroundColor Gray
    Write-Host "  Alt + B               " -NoNewline -ForegroundColor White; Write-Host "Browser Web predefinito" -ForegroundColor Gray
    Write-Host "  Alt + Shift + S       " -NoNewline -ForegroundColor White; Write-Host "Strumento Cattura Schermo" -ForegroundColor Gray
    Write-Host "  Alt + Shift + B       " -NoNewline -ForegroundColor White; Write-Host "Mostra/Nascondi barra inferiore Windows" -ForegroundColor Gray
    Write-Host "  Alt + Shift + A       " -NoNewline -ForegroundColor White; Write-Host "Cambia uscita audio (Cuffie / Casse)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + G       " -NoNewline -ForegroundColor White; Write-Host "Zen Mode / Gaming Mode toggle" -ForegroundColor Gray
    Write-Host "  Alt + Shift + Esc     " -NoNewline -ForegroundColor White; Write-Host "Blocca sessione Windows" -ForegroundColor Gray
    Write-Host "  Alt + P / Alt + \     " -NoNewline -ForegroundColor White; Write-Host "Wlogout Power Menu" -ForegroundColor Gray

    Write-Host "`n  -- PERSONALIZZAZIONE E BARRA ------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + Shift + T       " -NoNewline -ForegroundColor White; Write-Host "Selettore Grafico dei Temi (27 temi)" -ForegroundColor Gray
    Write-Host "  Alt + W               " -NoNewline -ForegroundColor White; Write-Host "Cicla al prossimo sfondo" -ForegroundColor Gray
    Write-Host "  Alt + Shift + W       " -NoNewline -ForegroundColor White; Write-Host "Selettore sfondi (Dialog)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + Z       " -NoNewline -ForegroundColor White; Write-Host "Riavvia / Mostra Barra Zebar" -ForegroundColor Gray
    Write-Host "  Alt + Shift + U       " -NoNewline -ForegroundColor White; Write-Host "Aggiorna Sistema 43PR Rice" -ForegroundColor Gray
    Write-Host "  Alt + Shift + R       " -NoNewline -ForegroundColor White; Write-Host "Ricarica configurazione GlazeWM al volo" -ForegroundColor Gray
    Write-Host "  Alt + F1 / Alt+Shift+?" -NoNewline -ForegroundColor White; Write-Host "Apri questa guida a schermo (Popup GUI)" -ForegroundColor Gray
    Write-Host ""
    return
}

# WPF GUI Popup
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Read accent color from Zebar styles
$accentColor = "#7AA2F7"
$styleFile = Join-Path $HOME ".glzr\zebar\starter\styles.css"
if (-not (Test-Path $styleFile)) {
    $styleFile = Join-Path (Split-Path -Parent $PSScriptRoot) "config\zebar\starter\styles.css"
}
if (Test-Path $styleFile) {
    $content = Get-Content $styleFile -Raw
    if ($content -match '--accent:\s*(#[0-9a-fA-F]{6})') {
        $accentColor = $matches[1]
    }
}

$xamlText = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Cheatsheet"
        Width="840"
        SizeToContent="Height"
        MinHeight="440"
        MaxHeight="820"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False">
    <Window.Resources>
        <Style x:Key="IconFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"/>
        </Style>
        <Style x:Key="TextFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI, Consolas"/>
        </Style>
        <Style x:Key="KeyStyle" TargetType="TextBlock" BasedOn="{StaticResource TextFont}">
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="$accentColor"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style x:Key="DescStyle" TargetType="TextBlock" BasedOn="{StaticResource TextFont}">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
    </Window.Resources>

    <Border Background="#F20B0D13"
            CornerRadius="16"
            BorderThickness="1.5"
            BorderBrush="$accentColor"
            Padding="24"
            Margin="10">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" Opacity="0.8" ShadowDepth="4"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <DockPanel Grid.Row="0" Margin="0,0,0,16">
                <Button Name="CloseBtn" DockPanel.Dock="Right" Background="Transparent" BorderThickness="0" Cursor="Hand" Width="28" Height="28" FocusVisualStyle="{x:Null}">
                    <TextBlock Text="&#xE711;" Style="{StaticResource IconFont}" FontSize="12" Foreground="#9AA5CE" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Button>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="43PR" FontSize="20" FontWeight="Bold" Foreground="$accentColor" Style="{StaticResource TextFont}" VerticalAlignment="Center"/>
                    <TextBlock Text=" Desktop Cheatsheet" FontSize="18" FontWeight="SemiBold" Foreground="#CDD6F4" Style="{StaticResource TextFont}" VerticalAlignment="Center" Margin="6,0,0,0"/>
                </StackPanel>
            </DockPanel>

            <!-- Content Two-Column Grid with ScrollViewer -->
            <ScrollViewer Grid.Row="1" MaxHeight="660" VerticalScrollBarVisibility="Auto" FocusVisualStyle="{x:Null}">
                <Grid Margin="0,0,4,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="24"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Left Column: Windows, Workspaces & Customization -->
                    <StackPanel Grid.Column="0">
                        <!-- Finestre e Tiling -->
                        <TextBlock Text="FINESTRE E TILING" FontWeight="Bold" Foreground="#E0AF68" FontSize="12" Margin="0,0,0,8" Style="{StaticResource TextFont}"/>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Q" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Chiudi finestra" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + F" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Schermo intero (Fullscreen)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Space" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Finestra fluttuante (Float)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + S" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Alterna orizzontale/verticale" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + H/J/K/L" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Focus finestra (Vim / Frecce)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + Direz" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Sposta posizione finestra" Style="{StaticResource DescStyle}"/>
                        </DockPanel>

                        <!-- Workspaces -->
                        <TextBlock Text="WORKSPACES" FontWeight="Bold" Foreground="#E0AF68" FontSize="12" Margin="0,14,0,8" Style="{StaticResource TextFont}"/>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + 1 .. 9" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Vai al Workspace 1 .. 9" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + 1 .. 9" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Sposta finestra nel Workspace" Style="{StaticResource DescStyle}"/>
                        </DockPanel>

                        <!-- Personalizzazione e Sistema -->
                        <TextBlock Text="PERSONALIZZAZIONE &amp; BARRA" FontWeight="Bold" Foreground="#BB9AF7" FontSize="12" Margin="0,14,0,8" Style="{StaticResource TextFont}"/>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + T" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Theme Switcher (27 Temi)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + W" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Cicla al prossimo sfondo" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + W" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Selettore sfondi da file" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + Z" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Riavvia barra Zebar" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + U" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Aggiorna Sistema 43PR" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + R" Width="135" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Ricarica config GlazeWM" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                    </StackPanel>

                    <!-- Right Column: Applicazioni e Utility -->
                    <StackPanel Grid.Column="2">
                        <TextBlock Text="APPLICAZIONI E STRUMENTI" FontWeight="Bold" Foreground="#9ECE6A" FontSize="12" Margin="0,0,0,8" Style="{StaticResource TextFont}"/>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + T" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Terminale (Windows Terminal)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + U" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Quake Scratchpad Terminal" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + V" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Clipboard History Manager" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Tab / Alt + J" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Global Window Switcher" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + N" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Note &amp; Todo HUD (Attivita)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + A" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Quick Actions Hub (Azioni)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + C" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Calcolatrice Rapida &amp; Unita" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + C" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Color Picker Pipetta (HEX)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + M" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Hardware Sensors HUD" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + D" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Flow Launcher (Cerca)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + E" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Esplora Risorse" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + B" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Browser Web" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + S" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Cattura Schermo (Ritagli)" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + B" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Nascondi barra inferiore Win" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + A" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Cambia uscita audio" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + G" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Zen Mode / Gaming Mode" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + Shift + Esc" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Blocca sessione Windows" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                        <DockPanel Margin="0,2.5">
                            <TextBlock Text="Alt + P / Alt + \" Width="140" Style="{StaticResource KeyStyle}"/>
                            <TextBlock Text="Wlogout Power Menu" Style="{StaticResource DescStyle}"/>
                        </DockPanel>
                    </StackPanel>
                </Grid>
            </ScrollViewer>

            <!-- Footer Hint (Clicking on it also dismisses) -->
            <Border Name="HintBar" Grid.Row="2" Margin="0,16,0,0" Padding="10,8" Background="#16FFFFFF" CornerRadius="8" Cursor="Hand">
                <DockPanel>
                    <TextBlock Text="Suggerimento:" FontWeight="Bold" Foreground="$accentColor" FontSize="11" Style="{StaticResource TextFont}"/>
                    <TextBlock Text=" Premi ESC o clicca all'esterno della finestra per chiuderla." Foreground="#A9B1D6" FontSize="11" Margin="6,0,0,0" Style="{StaticResource TextFont}"/>
                </DockPanel>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlText))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Close handlers
$closeBtn = $window.FindName("CloseBtn")
$closeBtn.Add_Click({ $window.Close() })

$hintBar = $window.FindName("HintBar")
$hintBar.Add_MouseLeftButtonDown({ $window.Close() })

# Close immediately when clicking outside (window loses focus)
$window.Add_Deactivated({
    $window.Close()
})

$window.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Escape) {
        $window.Close()
    }
})

$window.ShowDialog() | Out-Null
