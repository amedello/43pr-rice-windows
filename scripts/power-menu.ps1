# 43PR Wlogout-style Frosted Power Menu for Windows
# High performance, keyboard-driven WPF overlay using native Windows Segoe MDL2 / Fluent icons

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Read accent color from Zebar styles if available
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
        Title="43PR Power Menu"
        WindowState="Maximized"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="#D00B0D13"
        Topmost="True"
        ShowInTaskbar="False"
        Focusable="True">
    <Window.Resources>
        <Style x:Key="PowerCard" TargetType="Button">
            <Setter Property="Width" Value="140"/>
            <Setter Property="Height" Value="160"/>
            <Setter Property="Margin" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#33FFFFFF"/>
            <Setter Property="Background" Value="#221A202C"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="20"
                                Padding="16">
                            <Border.Effect>
                                <DropShadowEffect Color="#000000" BlurRadius="20" ShadowDepth="4" Opacity="0.5"/>
                            </Border.Effect>
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#442D3748"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="$accentColor"/>
                                <Setter TargetName="border" Property="Effect">
                                    <Setter.Value>
                                        <DropShadowEffect Color="$accentColor" BlurRadius="28" ShadowDepth="0" Opacity="0.6"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#662D3748"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid x:Name="RootGrid" Background="Transparent">
        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
            <!-- Header -->
            <StackPanel HorizontalAlignment="Center" Margin="0,0,0,40">
                <TextBlock Text="43PR POWER CONTROL"
                           FontSize="24"
                           FontWeight="Bold"
                           Foreground="$accentColor"
                           FontFamily="Segoe UI Variable Display, JetBrainsMono Nerd Font, Consolas"
                           HorizontalAlignment="Center"/>
                <TextBlock Text="Seleziona un'azione o premi il tasto rapido (Esc per uscire)"
                           FontSize="13"
                           Foreground="#9AA5CE"
                           FontFamily="Segoe UI Variable Text, JetBrainsMono Nerd Font, Consolas"
                           HorizontalAlignment="Center"
                           Margin="0,6,0,0"/>
            </StackPanel>

            <!-- Buttons Row -->
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <!-- Lock -->
                <Button x:Name="BtnLock" Style="{StaticResource PowerCard}">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <TextBlock Text="&#xE72E;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol" FontSize="44" Foreground="#E0AF68" HorizontalAlignment="Center" Margin="0,0,0,12"/>
                        <TextBlock Text="Blocca" FontSize="15" FontWeight="SemiBold" Foreground="#CDD6F4" HorizontalAlignment="Center"/>
                        <TextBlock Text="[ L ]" FontSize="11" FontWeight="Bold" Foreground="#7982A9" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                    </StackPanel>
                </Button>

                <!-- Sleep -->
                <Button x:Name="BtnSleep" Style="{StaticResource PowerCard}">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <TextBlock Text="&#xE708;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol" FontSize="44" Foreground="#7AA2F7" HorizontalAlignment="Center" Margin="0,0,0,12"/>
                        <TextBlock Text="Sospendi" FontSize="15" FontWeight="SemiBold" Foreground="#CDD6F4" HorizontalAlignment="Center"/>
                        <TextBlock Text="[ S ]" FontSize="11" FontWeight="Bold" Foreground="#7982A9" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                    </StackPanel>
                </Button>

                <!-- Restart -->
                <Button x:Name="BtnRestart" Style="{StaticResource PowerCard}">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <TextBlock Text="&#xE777;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol" FontSize="44" Foreground="#9ECE6A" HorizontalAlignment="Center" Margin="0,0,0,12"/>
                        <TextBlock Text="Riavvia" FontSize="15" FontWeight="SemiBold" Foreground="#CDD6F4" HorizontalAlignment="Center"/>
                        <TextBlock Text="[ R ]" FontSize="11" FontWeight="Bold" Foreground="#7982A9" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                    </StackPanel>
                </Button>

                <!-- Shutdown -->
                <Button x:Name="BtnShutdown" Style="{StaticResource PowerCard}">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <TextBlock Text="&#xE7E8;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol" FontSize="44" Foreground="#F7768E" HorizontalAlignment="Center" Margin="0,0,0,12"/>
                        <TextBlock Text="Spegni" FontSize="15" FontWeight="SemiBold" Foreground="#CDD6F4" HorizontalAlignment="Center"/>
                        <TextBlock Text="[ P ]" FontSize="11" FontWeight="Bold" Foreground="#7982A9" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                    </StackPanel>
                </Button>

                <!-- Sign Out -->
                <Button x:Name="BtnLogoff" Style="{StaticResource PowerCard}">
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <TextBlock Text="&#xE8F8;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol" FontSize="44" Foreground="#BB9AF7" HorizontalAlignment="Center" Margin="0,0,0,12"/>
                        <TextBlock Text="Disconnetti" FontSize="15" FontWeight="SemiBold" Foreground="#CDD6F4" HorizontalAlignment="Center"/>
                        <TextBlock Text="[ O ]" FontSize="11" FontWeight="Bold" Foreground="#7982A9" HorizontalAlignment="Center" Margin="0,6,0,0"/>
                    </StackPanel>
                </Button>
            </StackPanel>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnLock = $window.FindName("BtnLock")
$btnSleep = $window.FindName("BtnSleep")
$btnRestart = $window.FindName("BtnRestart")
$btnShutdown = $window.FindName("BtnShutdown")
$btnLogoff = $window.FindName("BtnLogoff")
$rootGrid = $window.FindName("RootGrid")

$ctl = "D:\Progetto\scripts\media-ctl.exe"

$actLock = {
    $window.Close()
    & $ctl lock
}

$actSleep = {
    $window.Close()
    & $ctl sleep
}

$actRestart = {
    $window.Close()
    & $ctl restart_pc
}

$actShutdown = {
    $window.Close()
    & $ctl shutdown_pc
}

$actLogoff = {
    $window.Close()
    & $ctl logoff
}

$btnLock.Add_Click({ & $actLock })
$btnSleep.Add_Click({ & $actSleep })
$btnRestart.Add_Click({ & $actRestart })
$btnShutdown.Add_Click({ & $actShutdown })
$btnLogoff.Add_Click({ & $actLogoff })

# Click on backdrop closes
$rootGrid.Add_MouseLeftButtonDown({
    if ($args[1].OriginalSource -eq $rootGrid) {
        $window.Close()
    }
})

# Hotkeys
$window.Add_KeyDown({
    param($sender, $e)
    switch ($e.Key) {
        "Escape" { $window.Close() }
        "L"      { & $actLock }
        "S"      { & $actSleep }
        "R"      { & $actRestart }
        "P"      { & $actShutdown }
        "O"      { & $actLogoff }
    }
})

$window.ShowDialog() | Out-Null
