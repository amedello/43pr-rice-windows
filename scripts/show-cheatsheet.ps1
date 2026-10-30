# 43PR Cheatsheet Controller (CLI + WPF GUI)
# Displays all keyboard shortcuts and commands for GlazeWM, Zebar and 43PR

param (
    [switch]$Cli
)

# CLI output if requested
if ($Cli) {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                      43PR DESKTOP CHEATSHEET & SHORTCUTS                       " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan

    Write-Host "`n  -- FINESTRE E TILING --------------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + Q               " -NoNewline -ForegroundColor White; Write-Host "Chiudi finestra attiva" -ForegroundColor Gray
    Write-Host "  Alt + F               " -NoNewline -ForegroundColor White; Write-Host "Schermo intero (Fullscreen on/off)" -ForegroundColor Gray
    Write-Host "  Alt + Space           " -NoNewline -ForegroundColor White; Write-Host "Alterna modalita Fluttuante (Floating on/off)" -ForegroundColor Gray
    Write-Host "  Alt + S               " -NoNewline -ForegroundColor White; Write-Host "Alterna direzione tiling (Orizzontale / Verticale)" -ForegroundColor Gray
    Write-Host "  Alt + H / J / K / L   " -NoNewline -ForegroundColor White; Write-Host "Sposta focus: Sinistra, Basso, Alto, Destra" -ForegroundColor Gray
    Write-Host "  Alt + Shift + H/J/K/L " -NoNewline -ForegroundColor White; Write-Host "Sposta finestra nella direzione" -ForegroundColor Gray

    Write-Host "`n  -- WORKSPACES E DESKTOP -----------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + 1 .. 9          " -NoNewline -ForegroundColor White; Write-Host "Passa al Workspace 1 .. 9" -ForegroundColor Gray
    Write-Host "  Alt + Shift + 1 .. 9  " -NoNewline -ForegroundColor White; Write-Host "Sposta finestra attiva nel Workspace 1 .. 9" -ForegroundColor Gray

    Write-Host "`n  -- APPLICAZIONI E SISTEMA ---------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + T               " -NoNewline -ForegroundColor White; Write-Host "Apri Terminale (Windows Terminal)" -ForegroundColor Gray
    Write-Host "  Alt + U               " -NoNewline -ForegroundColor White; Write-Host "Quake Scratchpad Terminal (Mostra / Nascondi al volo)" -ForegroundColor Cyan
    Write-Host "  Alt + V               " -NoNewline -ForegroundColor White; Write-Host "Clipboard History Manager (Cronologia appunti)" -ForegroundColor Cyan
    Write-Host "  Alt + Tab / Alt + J   " -NoNewline -ForegroundColor White; Write-Host "Window Switcher (Cerca e salta tra finestre)" -ForegroundColor Cyan
    Write-Host "  Alt + C               " -NoNewline -ForegroundColor White; Write-Host "Calcolatrice Rapida & Convertitore al volo" -ForegroundColor Cyan
    Write-Host "  Alt + Shift + C       " -NoNewline -ForegroundColor White; Write-Host "Pipetta Color Picker (Copia HEX pixel schermo)" -ForegroundColor Cyan
    Write-Host "  Alt + Shift + M       " -NoNewline -ForegroundColor White; Write-Host "Hardware Sensors HUD (CPU/RAM/Dischi in tempo reale)" -ForegroundColor Cyan
    Write-Host "  Alt + D               " -NoNewline -ForegroundColor White; Write-Host "Flow Launcher (Cerca app, file, comandi)" -ForegroundColor Gray
    Write-Host "  Alt + E               " -NoNewline -ForegroundColor White; Write-Host "Esplora Risorse (File Manager)" -ForegroundColor Gray
    Write-Host "  Alt + B               " -NoNewline -ForegroundColor White; Write-Host "Browser Web predefinito" -ForegroundColor Gray
    Write-Host "  Alt + Shift + S       " -NoNewline -ForegroundColor White; Write-Host "Cattura Schermo (Ritagli / Snipping Tool)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + B       " -NoNewline -ForegroundColor White; Write-Host "Mostra / Nascondi barra inferiore Windows" -ForegroundColor Gray
    Write-Host "  Alt + Shift + A       " -NoNewline -ForegroundColor White; Write-Host "Cambia uscita audio (Cuffie / Casse / Monitor)" -ForegroundColor Gray
    Write-Host "  Alt + Shift + G       " -NoNewline -ForegroundColor White; Write-Host "Zen Mode / Gaming Mode (Toggle Tiling & Barra)" -ForegroundColor Cyan
    Write-Host "  Alt + Shift + Esc     " -NoNewline -ForegroundColor White; Write-Host "Blocca sessione Windows" -ForegroundColor Gray
    Write-Host "  Alt + P / Alt + \     " -NoNewline -ForegroundColor White; Write-Host "Wlogout Power Menu (Blocca/Sospendi/Riavvia/Spegni)" -ForegroundColor Gray

    Write-Host "`n  -- TEMI, SFONDI E BARRA -----------------------------------------------" -ForegroundColor Yellow
    Write-Host "  Alt + Shift + T       " -NoNewline -ForegroundColor White; Write-Host "Theme Switcher & Giorno/Notte (GUI)" -ForegroundColor Cyan
    Write-Host "  Alt + W               " -NoNewline -ForegroundColor White; Write-Host "Cicla al prossimo sfondo coordinato" -ForegroundColor Gray
    Write-Host "  Alt + Shift + W       " -NoNewline -ForegroundColor White; Write-Host "Apri finestra selettore sfondi" -ForegroundColor Gray
    Write-Host "  Alt + Shift + Z       " -NoNewline -ForegroundColor White; Write-Host "Riavvia / Mostra la Barra Zebar" -ForegroundColor Gray
    Write-Host "  Alt + Shift + R       " -NoNewline -ForegroundColor White; Write-Host "Ricarica configurazione GlazeWM al volo" -ForegroundColor Gray
    Write-Host "  Alt + Shift + Q       " -NoNewline -ForegroundColor White; Write-Host "Chiudi GlazeWM" -ForegroundColor Gray
    Write-Host "  Alt + F1 / Alt+Shift+?" -NoNewline -ForegroundColor White; Write-Host "Apri questa guida a schermo (Popup GUI)" -ForegroundColor Gray

    Write-Host "`n  -- COMANDI RAPIDI TERMINALE -------------------------------------------" -ForegroundColor Yellow
    Write-Host '  theme -List           ' -NoNewline -ForegroundColor Cyan; Write-Host 'Mostra i 27 temi disponibili' -ForegroundColor Gray
    Write-Host '  theme -Theme [nome]   ' -NoNewline -ForegroundColor Cyan; Write-Host 'Applica tema coordinato su tutto il sistema' -ForegroundColor Gray
    Write-Host '  wallpaper             ' -NoNewline -ForegroundColor Cyan; Write-Host 'Passa al prossimo sfondo (o -Select)' -ForegroundColor Gray
    Write-Host '  toggle-taskbar        ' -NoNewline -ForegroundColor Cyan; Write-Host 'Nasconde/mostra barra inferiore di Windows' -ForegroundColor Gray
    Write-Host '  switch-audio          ' -NoNewline -ForegroundColor Cyan; Write-Host 'Scambia al volo uscita audio (Cuffie/Casse)' -ForegroundColor Gray
    Write-Host '  ls / ll / tree        ' -NoNewline -ForegroundColor Cyan; Write-Host 'Visualizzazione cartelle moderna con Eza' -ForegroundColor Gray
    Write-Host '  top / ff              ' -NoNewline -ForegroundColor Cyan; Write-Host 'Btop monitor di sistema / Fastfetch banner' -ForegroundColor Gray
    Write-Host '  keys                  ' -NoNewline -ForegroundColor Cyan; Write-Host 'Mostra questa guida comandi rapida' -ForegroundColor Gray
    Write-Host ""
    return
}

# WPF GUI Popup
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$xamlText = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Cheatsheet" Width="780" Height="570"
        WindowStartupLocation="CenterScreen" WindowStyle="None"
        AllowsTransparency="True" Background="Transparent"
        Topmost="True" ShowInTaskbar="False">
    <Border Background="#EE16161E" CornerRadius="16" BorderThickness="1.5" BorderBrush="#7AA2F7" Padding="24">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" Opacity="0.65" ShadowDepth="4"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <DockPanel Grid.Row="0" Margin="0,0,0,16">
                <Button Name="CloseBtn" DockPanel.Dock="Right" Content="&#xE711;"
                        FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                        Background="Transparent" Foreground="#9AA5CE" BorderThickness="0"
                        FontSize="12" Cursor="Hand" Width="28" Height="28"/>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="43PR" FontSize="20" FontWeight="Bold" Foreground="#7AA2F7" FontFamily="Segoe UI Variable Display, JetBrainsMono Nerd Font, Consolas" VerticalAlignment="Center"/>
                    <TextBlock Text=" Desktop Cheatsheet" FontSize="18" FontWeight="SemiBold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text, JetBrainsMono Nerd Font, Consolas" VerticalAlignment="Center" Margin="6,0,0,0"/>
                </StackPanel>
            </DockPanel>

            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="20"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0">
                    <TextBlock Text="FINESTRE E TILING" FontWeight="Bold" Foreground="#E0AF68" FontSize="13" Margin="0,0,0,8"/>
                    
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Q" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Chiudi finestra" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + F" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Schermo intero (Fullscreen)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Space" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Finestra fluttuante (Float)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + S" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Alterna orizzontale/verticale" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + H/J/K/L" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Focus finestra (Vim / Frecce)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + Direz" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Sposta posizione finestra" Foreground="#9AA5CE"/>
                    </DockPanel>

                    <TextBlock Text="WORKSPACES" FontWeight="Bold" Foreground="#E0AF68" FontSize="13" Margin="0,16,0,8"/>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + 1 .. 9" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Vai al Workspace 1 .. 9" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + 1 .. 9" FontWeight="Bold" Foreground="#CDD6F4" Width="130"/>
                        <TextBlock Text="Sposta finestra nel Workspace" Foreground="#9AA5CE"/>
                    </DockPanel>
                </StackPanel>

                <StackPanel Grid.Column="2">
                    <TextBlock Text="APPLICAZIONI E SISTEMA" FontWeight="Bold" Foreground="#9ECE6A" FontSize="13" Margin="0,0,0,8"/>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + T" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Terminale (Windows Terminal)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + U" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Quake Scratchpad Terminal" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + V" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Clipboard History Manager" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Tab / Alt + J" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Global Window Switcher" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + C" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Calcolatrice Rapida &amp; Unita" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + C" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Color Picker Pipetta" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + M" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Hardware Sensors HUD" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + D" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Flow Launcher (Cerca app/file)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + E" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Esplora Risorse" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + B" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Browser Web" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + S" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Cattura Schermo (Ritagli)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + B" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Nascondi barra inferiore Win" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + A" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Cambia uscita audio (Cuffie/Casse)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + G" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Zen Mode / Gaming Mode" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + Esc" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Blocca sessione Windows" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + P / Alt + \" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Wlogout Power Menu" Foreground="#9AA5CE"/>
                    </DockPanel>

                    <TextBlock Text="PERSONALIZZAZIONE &amp; BARRA" FontWeight="Bold" Foreground="#BB9AF7" FontSize="13" Margin="0,16,0,8"/>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + T" FontWeight="Bold" Foreground="#7AA2F7" Width="140"/>
                        <TextBlock Text="Theme Switcher &amp; Giorno/Notte" Foreground="#CDD6F4"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + W" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Cicla al prossimo sfondo" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + W" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Selettore sfondi (Dialog)" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + Z" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Riavvia / Mostra Barra Zebar" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + Shift + R" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Ricarica configurazione GlazeWM" Foreground="#9AA5CE"/>
                    </DockPanel>
                    <DockPanel Margin="0,3">
                        <TextBlock Text="Alt + F1 / Alt+Shift+?" FontWeight="Bold" Foreground="#CDD6F4" Width="140"/>
                        <TextBlock Text="Guida rapida a schermo" Foreground="#9AA5CE"/>
                    </DockPanel>
                </StackPanel>
            </Grid>

            <Border Grid.Row="2" Margin="0,16,0,0" Padding="8,6" Background="#20FFFFFF" CornerRadius="8">
                <DockPanel>
                    <TextBlock Text="Suggerimento:" FontWeight="Bold" Foreground="#7AA2F7" FontSize="11"/>
                    <TextBlock Text=" Premi ESC o clicca ovunque per chiudere questa finestra." Foreground="#A9B1D6" FontSize="11" Margin="4,0,0,0"/>
                </DockPanel>
            </Border>
        </Grid>
    </Border>
</Window>
'@

[xml]$xaml = $xamlText
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Close handlers
$closeBtn = $window.FindName("CloseBtn")
$closeBtn.Add_Click({ $window.Close() })

$window.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq [Windows.Input.Key]::Escape) {
        $window.Close()
    }
})

$window.Add_MouseDown({
    param($s, $e)
    if ($e.ChangedButton -eq [Windows.Input.MouseButton]::Left) {
        $window.DragMove()
    }
})

$window.ShowDialog() | Out-Null

