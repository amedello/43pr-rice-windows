# 43PR Native WPF Quick Actions Panel for Windows
# Port of 43PR/dotfiles Quickshell QuickActions.qml
# Encoded in pure 7-bit ASCII to prevent mojibake

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

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Quick Actions"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        Focusable="True"
        Width="580"
        SizeToContent="Height"
        MinHeight="320"
        MaxHeight="680">
    <Window.Resources>
        <Style x:Key="IconFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"/>
        </Style>
        <Style x:Key="TextFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI Variable Text, Segoe UI, Consolas"/>
        </Style>
        <Style x:Key="ActionCard" TargetType="Button">
            <Setter Property="Height" Value="86"/>
            <Setter Property="Margin" Value="6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#2AFFFFFF"/>
            <Setter Property="Background" Value="#1E1E2E"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="12"
                                Padding="12,10">
                            <ContentPresenter VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#313244"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="$accentColor"/>
                                <Setter TargetName="border" Property="Effect">
                                    <Setter.Value>
                                        <DropShadowEffect Color="$accentColor" BlurRadius="16" ShadowDepth="0" Opacity="0.5"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#45475A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="#F00B0D13"
            BorderBrush="$accentColor"
            BorderThickness="1.5"
            CornerRadius="16"
            Padding="22"
            Margin="12">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" ShadowDepth="4" Opacity="0.8"/>
        </Border.Effect>

        <StackPanel>
            <!-- Header -->
            <Grid Margin="0,0,0,18">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Column="0" Width="36" Height="36" CornerRadius="10" Background="#26FFFFFF" Margin="0,0,12,0">
                    <TextBlock Text="&#xE713;" Style="{StaticResource IconFont}" FontSize="18" Foreground="$accentColor" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>

                <StackPanel Grid.Column="1" VerticalAlignment="Center">
                    <TextBlock Text="43PR QUICK ACTIONS" Style="{StaticResource TextFont}" FontSize="16" FontWeight="Bold" Foreground="#CDD6F4"/>
                    <TextBlock Text="Seleziona un'azione rapida o premi il tasto rapido (Esc per uscire)" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                </StackPanel>

                <Button x:Name="BtnClose" Grid.Column="2" Width="30" Height="30" Cursor="Hand" Background="Transparent" BorderThickness="0" FocusVisualStyle="{x:Null}">
                    <TextBlock Text="&#xE711;" Style="{StaticResource IconFont}" FontSize="14" Foreground="#9AA5CE" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Button>
            </Grid>

            <!-- Action Grid (2 columns x 4 rows) -->
            <UniformGrid Columns="2" Rows="4" Margin="0,0,0,6">
                <!-- 1. Day / Night Theme Toggle -->
                <Button x:Name="BtnTheme" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE708;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#E0AF68" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Giorno / Notte" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Alterna tema di sistema" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ T ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 2. Notes & Tasks -->
                <Button x:Name="BtnTodo" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE70F;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#BB9AF7" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Note &amp; Todo" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Attivita e promemoria" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ N ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 3. Hardware Sensors HUD -->
                <Button x:Name="BtnSensors" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE950;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#7AA2F7" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Sensori HUD" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="CPU, GPU, RAM, Rete" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ M ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 4. Clipboard Manager -->
                <Button x:Name="BtnClip" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE77F;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#7DCFFF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Appunti" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Cronologia e snippet" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ V ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 5. Wallpaper Next -->
                <Button x:Name="BtnWall" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xEB9F;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#9ECE6A" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Cambia Sfondo" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Prossimo wallpaper" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ W ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 6. Window Switcher -->
                <Button x:Name="BtnSwitch" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE737;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#2AC3DE" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Finestre Aperte" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Trova o passa ad app" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ J ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 7. Calculator -->
                <Button x:Name="BtnCalc" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE8EF;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#FF9E64" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Calcolatrice" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Calcolo ed unita" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ C ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>

                <!-- 8. Upgrade System -->
                <Button x:Name="BtnUpgrade" Style="{StaticResource ActionCard}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <Border Grid.Column="0" Width="40" Height="40" CornerRadius="8" Background="#26FFFFFF" Margin="0,0,12,0">
                            <TextBlock Text="&#xE895;" Style="{StaticResource IconFont}" FontSize="20" Foreground="#F7768E" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <StackPanel Grid.Column="1" VerticalAlignment="Center">
                            <TextBlock Text="Aggiorna 43PR" Style="{StaticResource TextFont}" FontSize="13" FontWeight="SemiBold" Foreground="#CDD6F4"/>
                            <TextBlock Text="Upgrade e verifica" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                        </StackPanel>
                        <TextBlock Grid.Column="2" Text="[ U ]" Style="{StaticResource TextFont}" FontSize="11" FontWeight="Bold" Foreground="#585B70" VerticalAlignment="Center"/>
                    </Grid>
                </Button>
            </UniformGrid>
        </StackPanel>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnClose = $window.FindName("BtnClose")
$btnTheme = $window.FindName("BtnTheme")
$btnTodo = $window.FindName("BtnTodo")
$btnSensors = $window.FindName("BtnSensors")
$btnClip = $window.FindName("BtnClip")
$btnWall = $window.FindName("BtnWall")
$btnSwitch = $window.FindName("BtnSwitch")
$btnCalc = $window.FindName("BtnCalc")
$btnUpgrade = $window.FindName("BtnUpgrade")

$ctl = Join-Path $PSScriptRoot "media-ctl.exe"
if (-not (Test-Path $ctl)) { $ctl = "media-ctl.exe" }

$actTheme = { $window.Close(); & $ctl auto_theme }
$actTodo = { $window.Close(); & $ctl todo }
$actSensors = { $window.Close(); & $ctl sensors }
$actClip = { $window.Close(); & $ctl clipboard }
$actWall = { $window.Close(); & $ctl wallpaper }
$actSwitch = { $window.Close(); & $ctl window_switcher }
$actCalc = { $window.Close(); & $ctl calc }
$actUpgrade = { $window.Close(); & $ctl upgrade }

$btnTheme.Add_Click({ & $actTheme })
$btnTodo.Add_Click({ & $actTodo })
$btnSensors.Add_Click({ & $actSensors })
$btnClip.Add_Click({ & $actClip })
$btnWall.Add_Click({ & $actWall })
$btnSwitch.Add_Click({ & $actSwitch })
$btnCalc.Add_Click({ & $actCalc })
$btnUpgrade.Add_Click({ & $actUpgrade })

$btnClose.Add_Click({ $window.Close() })

# Keyboard navigation
$window.Add_KeyDown({
    param($s, $e)
    switch ($e.Key) {
        "Escape" { $window.Close() }
        "T"      { & $actTheme }
        "N"      { & $actTodo }
        "M"      { & $actSensors }
        "V"      { & $actClip }
        "W"      { & $actWall }
        "J"      { & $actSwitch }
        "C"      { & $actCalc }
        "U"      { & $actUpgrade }
    }
})

# Drag window by background
$window.Add_MouseLeftButtonDown({
    if ($args[1].ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        $window.DragMove()
    }
})

$window.ShowDialog() | Out-Null

