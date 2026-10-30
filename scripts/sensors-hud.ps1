# 43PR Hardware Sensors Overlay / Mini HUD (WPF)
# Real-time hardware telemetry: CPU, RAM, Disks, Network, Uptime, Battery
# Hotkey: Alt + Shift + M

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
        Title="43PR Hardware HUD"
        Width="500" Height="420"
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
            Padding="20">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" ShadowDepth="4" Opacity="0.65"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <DockPanel Grid.Row="0" Margin="0,0,0,16">
                <Button x:Name="BtnClose" DockPanel.Dock="Right" Content="&#xE711;"
                        FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                        FontSize="12" Foreground="#9AA5CE" Background="Transparent"
                        BorderThickness="0" Cursor="Hand" Width="26" Height="26"/>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="&#xE950;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="18" Foreground="$accentColor" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBlock Text="43PR HARDWARE SENSORS" FontSize="16" FontWeight="Bold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Display, Consolas" VerticalAlignment="Center"/>
                </StackPanel>
            </DockPanel>

            <!-- Sensors Grid -->
            <StackPanel Grid.Row="1">
                <!-- CPU -->
                <Border Background="#1C2232" CornerRadius="10" Padding="12" Margin="0,0,0,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <DockPanel Grid.Row="0" Margin="0,0,0,6">
                            <TextBlock x:Name="TxtCpuVal" DockPanel.Dock="Right" Text="0%" FontWeight="Bold" Foreground="#F7768E" FontFamily="Consolas" FontSize="13"/>
                            <TextBlock Text="PROCESSORE (CPU)" FontSize="12" FontWeight="SemiBold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text"/>
                        </DockPanel>
                        <ProgressBar x:Name="ProgCpu" Grid.Row="1" Height="6" Maximum="100" Value="0" Foreground="#F7768E" Background="#2B3448" BorderThickness="0"/>
                    </Grid>
                </Border>

                <!-- RAM -->
                <Border Background="#1C2232" CornerRadius="10" Padding="12" Margin="0,0,0,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <DockPanel Grid.Row="0" Margin="0,0,0,6">
                            <TextBlock x:Name="TxtRamVal" DockPanel.Dock="Right" Text="0 / 0 GB (0%)" FontWeight="Bold" Foreground="#E0AF68" FontFamily="Consolas" FontSize="13"/>
                            <TextBlock Text="MEMORIA (RAM)" FontSize="12" FontWeight="SemiBold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text"/>
                        </DockPanel>
                        <ProgressBar x:Name="ProgRam" Grid.Row="1" Height="6" Maximum="100" Value="0" Foreground="#E0AF68" Background="#2B3448" BorderThickness="0"/>
                    </Grid>
                </Border>

                <!-- Disks -->
                <Border Background="#1C2232" CornerRadius="10" Padding="12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="DISCHI E ARCHIVIAZIONE" FontSize="12" FontWeight="SemiBold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text" Margin="0,0,0,8"/>
                        <!-- C: -->
                        <DockPanel Margin="0,2,0,4">
                            <TextBlock x:Name="TxtDiskC" DockPanel.Dock="Right" Text="-- GB liberi" FontSize="11" Foreground="#9AA5CE" FontFamily="Consolas"/>
                            <TextBlock Text="Disco C: [Sistema]" FontSize="11" Foreground="#CDD6F4" Width="130"/>
                        </DockPanel>
                        <ProgressBar x:Name="ProgDiskC" Height="4" Maximum="100" Value="0" Foreground="$accentColor" Background="#2B3448" BorderThickness="0" Margin="0,0,0,8"/>
                        
                        <!-- D: -->
                        <DockPanel Margin="0,2,0,4">
                            <TextBlock x:Name="TxtDiskD" DockPanel.Dock="Right" Text="-- GB liberi" FontSize="11" Foreground="#9AA5CE" FontFamily="Consolas"/>
                            <TextBlock Text="Disco D: [Dati / Progetto]" FontSize="11" Foreground="#CDD6F4" Width="130"/>
                        </DockPanel>
                        <ProgressBar x:Name="ProgDiskD" Height="4" Maximum="100" Value="0" Foreground="#9ECE6A" Background="#2B3448" BorderThickness="0"/>
                    </StackPanel>
                </Border>

                <!-- System Info (Uptime & Battery) -->
                <Border Background="#1C2232" CornerRadius="10" Padding="12">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0">
                            <TextBlock Text="UPTIME SISTEMA" FontSize="11" FontWeight="SemiBold" Foreground="#7982A9"/>
                            <TextBlock x:Name="TxtUptime" Text="--:--" FontSize="13" FontWeight="Bold" Foreground="#CDD6F4" FontFamily="Consolas" Margin="0,4,0,0"/>
                        </StackPanel>
                        <StackPanel Grid.Column="1">
                            <TextBlock Text="BATTERIA / STATO" FontSize="11" FontWeight="SemiBold" Foreground="#7982A9"/>
                            <TextBlock x:Name="TxtBattery" Text="Alimentazione Rete" FontSize="13" FontWeight="Bold" Foreground="#7AA2F7" FontFamily="Consolas" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </StackPanel>

            <!-- Footer -->
            <TextBlock Grid.Row="2" Text="Aggiornamento in tempo reale (1.5s) • [Esc] Chiudi"
                       FontSize="11" Foreground="#7982A9" FontFamily="Consolas" Margin="0,12,0,0" HorizontalAlignment="Center"/>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnClose = $window.FindName("BtnClose")
$txtCpuVal = $window.FindName("TxtCpuVal")
$progCpu = $window.FindName("ProgCpu")
$txtRamVal = $window.FindName("TxtRamVal")
$progRam = $window.FindName("ProgRam")
$txtDiskC = $window.FindName("TxtDiskC")
$progDiskC = $window.FindName("ProgDiskC")
$txtDiskD = $window.FindName("TxtDiskD")
$progDiskD = $window.FindName("ProgDiskD")
$txtUptime = $window.FindName("TxtUptime")
$txtBattery = $window.FindName("TxtBattery")

$btnClose.Add_Click({ $window.Close() })

$updateSensors = {
    # RAM
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalRamGB = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeRamGB = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $usedRamGB = [Math]::Round($totalRamGB - $freeRamGB, 1)
        $pctRam = [int][Math]::Round(($usedRamGB / $totalRamGB) * 100)
        $txtRamVal.Text = "$usedRamGB / $totalRamGB GB ($pctRam%)"
        $progRam.Value = $pctRam
        
        # Uptime
        $uptime = (Get-Date) - $os.LastBootUpTime
        $txtUptime.Text = "$($uptime.Days)g $($uptime.Hours)h $($uptime.Minutes)m"
    } catch {}

    # Disks
    try {
        $drives = Get-PSDrive -PSProvider FileSystem
        $driveC = $drives | Where-Object { $_.Name -eq "C" }
        if ($driveC) {
            $usedC = [Math]::Round(($driveC.Used / 1GB), 1)
            $freeC = [Math]::Round(($driveC.Free / 1GB), 1)
            $totalC = $usedC + $freeC
            $pctC = [int][Math]::Round(($usedC / $totalC) * 100)
            $txtDiskC.Text = "$freeC GB liberi su $totalC GB ($pctC% usato)"
            $progDiskC.Value = $pctC
        }
        $driveD = $drives | Where-Object { $_.Name -eq "D" }
        if ($driveD) {
            $usedD = [Math]::Round(($driveD.Used / 1GB), 1)
            $freeD = [Math]::Round(($driveD.Free / 1GB), 1)
            $totalD = $usedD + $freeD
            $pctD = [int][Math]::Round(($usedD / $totalD) * 100)
            $txtDiskD.Text = "$freeD GB liberi su $totalD GB ($pctD% usato)"
            $progDiskD.Value = $pctD
        } else {
            $txtDiskD.Text = "Non presente"
            $progDiskD.Value = 0
        }
    } catch {}

    # Battery
    try {
        $batt = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
        if ($batt) {
            $txtBattery.Text = "$($batt.EstimatedChargeRemaining)% ($($batt.BatteryStatus))"
        } else {
            $txtBattery.Text = "Alimentatore AC"
        }
    } catch {}

    # CPU
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        if ($cpu -ne $null) {
            $txtCpuVal.Text = "$([int]$cpu)%"
            $progCpu.Value = [int]$cpu
        }
    } catch {}
}

# Initial update
& $updateSensors

# Timer
$timer = [System.Windows.Threading.DispatcherTimer]::new()
$timer.Interval = [TimeSpan]::FromSeconds(1.5)
$timer.Add_Tick({ & $updateSensors })
$timer.Start()

$window.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq "Escape") {
        $timer.Stop()
        $window.Close()
    }
})

$window.Add_Closed({
    $timer.Stop()
})

$window.ShowDialog() | Out-Null
