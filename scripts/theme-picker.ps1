# 43PR Theme Switcher & Auto Day/Night Manager (WPF Native)
# High performance, keyboard-driven theme browser for Windows 10/11
# Hotkey: Alt + Shift + T

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$repoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$themesDir = Join-Path $repoDir "config\43pr\themes"
$currentThemeFile = Join-Path $HOME ".43pr_current_theme"
$autoThemeFile = Join-Path $HOME ".43pr_auto_theme"
$themeScript = Join-Path $repoDir "scripts\theme.ps1"

# 1. Read Current Active Theme
$currentTheme = "tokyo-night"
if (Test-Path $currentThemeFile) {
    try {
        $c = (Get-Content $currentThemeFile -Raw -ErrorAction SilentlyContinue).Trim()
        if (-not [string]::IsNullOrWhiteSpace($c)) { $currentTheme = $c }
    } catch {}
}

# 2. Read Auto Day/Night status
$isAutoEnabled = $true
if (Test-Path $autoThemeFile) {
    try {
        $a = (Get-Content $autoThemeFile -Raw -ErrorAction SilentlyContinue).Trim()
        if ($a -eq "0" -or $a -eq "false" -or $a -eq "disabled") {
            $isAutoEnabled = $false
        }
    } catch {}
}

# 3. Read Current Accent Color from CSS
$accentColor = "#7AA2F7"
$styleFile = Join-Path $repoDir "config\zebar\starter\styles.css"
if (Test-Path $styleFile) {
    try {
        $css = Get-Content $styleFile -Raw -ErrorAction SilentlyContinue
        if ($css -match '--accent:\s*(#[0-9a-fA-F]{6})') {
            $accentColor = $matches[1]
        }
    } catch {}
}

# 4. Parse all 27 Themes from TOML files
$themeItems = [System.Collections.Generic.List[PSCustomObject]]::new()
if (Test-Path $themesDir) {
    $tomlFiles = Get-ChildItem -Path $themesDir -Filter "*.toml" | Sort-Object Name
    foreach ($file in $tomlFiles) {
        $themeName = $file.BaseName
        $appearance = "dark"
        $description = "$themeName theme"
        $acc = "#7AA2F7"
        $bg = "#16161E"
        $fg = "#C0CAF5"

        try {
            $lines = Get-Content $file.FullName -ErrorAction SilentlyContinue
            foreach ($line in $lines) {
                if ($line -match '^\s*appearance\s*=\s*"([^"]+)"') { $appearance = $matches[1] }
                elseif ($line -match '^\s*description\s*=\s*"([^"]+)"') { $description = $matches[1] }
                elseif ($line -match '^\s*accent\s*=\s*"([^"]+)"') { $acc = $matches[1] }
                elseif ($line -match '^\s*bg\s*=\s*"([^"]+)"') { $bg = $matches[1] }
                elseif ($line -match '^\s*fg\s*=\s*"([^"]+)"') { $fg = $matches[1] }
            }
        } catch {}

        $isLight = ($appearance -eq "light")
        $isActive = ($themeName -eq $currentTheme)

        $themeItems.Add([PSCustomObject]@{
            Name            = $themeName
            Appearance      = $appearance
            Description     = $description
            AccentColor     = $acc
            BgColor         = $bg
            FgColor         = $fg
            IsActive        = $isActive
            ActiveVisibility= if ($isActive) { "Visible" } else { "Collapsed" }
            TypeIcon        = if ($isLight) { [char]0xE706 } else { [char]0xE708 } # Sun or Moon
            TypeLabel       = if ($isLight) { "CHIARO" } else { "SCURO" }
            TypeBadgeColor  = if ($isLight) { "#E0AF68" } else { "#BB9AF7" }
            SearchIndex     = "$themeName $appearance $description".ToLower()
        })
    }
}

# 5. Build WPF UI in pure ASCII with Segoe native icons
$autoStatusText = if ($isAutoEnabled) { "Auto: ATTIVO" } else { "Auto: SOSPESO" }
$autoStatusColor = if ($isAutoEnabled) { "#9ECE6A" } else { "#E0AF68" }
$autoStatusBorder = if ($isAutoEnabled) { "#339ECE6A" } else { "#33E0AF68" }

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Theme Switcher"
        Width="640"
        SizeToContent="Height"
        MinHeight="300" MaxHeight="600"
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
            Padding="18">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" ShadowDepth="4" Opacity="0.65"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header with Title & Quick Controls -->
            <Grid Grid.Row="0" Margin="0,0,0,14">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Left: Title -->
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="&#xE771;"
                               FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"
                               FontSize="18" Foreground="$accentColor"
                               VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <TextBlock Text="43PR Theme Switcher"
                               FontSize="16" FontWeight="SemiBold"
                               Foreground="#CDD6F4"
                               FontFamily="Segoe UI Variable Display, Consolas"
                               VerticalAlignment="Center"/>
                </StackPanel>

                <!-- Right: Quick Day/Night & Auto Switch Buttons -->
                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                    <!-- Day Button -->
                    <Button x:Name="BtnDay"
                            Content="&#xE706; Giorno"
                            FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Variable Text"
                            FontSize="11" FontWeight="SemiBold"
                            Foreground="#E0AF68" Background="#26E0AF68"
                            BorderBrush="#44E0AF68" BorderThickness="1"
                            Padding="10,4" Margin="0,0,6,0" Cursor="Hand"
                            FocusVisualStyle="{x:Null}">
                        <Button.Resources>
                            <Style TargetType="Border">
                                <Setter Property="CornerRadius" Value="8"/>
                            </Style>
                        </Button.Resources>
                    </Button>

                    <!-- Night Button -->
                    <Button x:Name="BtnNight"
                            Content="&#xE708; Notte"
                            FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Variable Text"
                            FontSize="11" FontWeight="SemiBold"
                            Foreground="#7AA2F7" Background="#267AA2F7"
                            BorderBrush="#447AA2F7" BorderThickness="1"
                            Padding="10,4" Margin="0,0,6,0" Cursor="Hand"
                            FocusVisualStyle="{x:Null}">
                        <Button.Resources>
                            <Style TargetType="Border">
                                <Setter Property="CornerRadius" Value="8"/>
                            </Style>
                        </Button.Resources>
                    </Button>

                    <!-- Auto Day/Night Toggle Button -->
                    <Button x:Name="BtnAuto"
                            Content="&#xE777; $autoStatusText"
                            FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Variable Text"
                            FontSize="11" FontWeight="SemiBold"
                            Foreground="$autoStatusColor" Background="$autoStatusBorder"
                            BorderBrush="$autoStatusColor" BorderThickness="1"
                            Padding="10,4" Margin="0,0,8,0" Cursor="Hand"
                            FocusVisualStyle="{x:Null}">
                        <Button.Resources>
                            <Style TargetType="Border">
                                <Setter Property="CornerRadius" Value="8"/>
                            </Style>
                        </Button.Resources>
                    </Button>

                    <!-- Close Button -->
                    <Button x:Name="BtnClose" Content="&#xE711;"
                            FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                            FontSize="12" Foreground="#9AA5CE" Background="Transparent"
                            BorderThickness="0" Cursor="Hand" Width="26" Height="26"
                            FocusVisualStyle="{x:Null}">
                        <Button.Style>
                            <Style TargetType="Button">
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="Button">
                                            <Border Background="{TemplateBinding Background}" CornerRadius="6">
                                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            </Border>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#292E42"/>
                                        <Setter Property="Foreground" Value="#F7768E"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>
                    </Button>
                </StackPanel>
            </Grid>

            <!-- Search Box with Placeholder -->
            <Border Grid.Row="1" Background="#191D28" BorderBrush="#282F45" BorderThickness="1"
                    CornerRadius="10" Padding="12,7" Margin="0,0,0,12">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="&#xE721;"
                               FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                               FontSize="13" Foreground="#7982A9"
                               VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <Grid Grid.Column="1">
                        <TextBlock x:Name="TxtSearchPlaceholder"
                                   Text="Cerca tra i 27 temi (es. tokyo, catppuccin, nord, gruvbox, dark, light)..."
                                   FontSize="13" Foreground="#556488"
                                   FontFamily="Segoe UI Variable Text, Consolas"
                                   VerticalAlignment="Center" IsHitTestVisible="False"/>
                        <TextBox x:Name="TxtSearch"
                                 Background="Transparent" Foreground="#CDD6F4"
                                 BorderThickness="0" FontSize="13"
                                 FontFamily="Segoe UI Variable Text, Consolas"
                                 CaretBrush="$accentColor" VerticalAlignment="Center"
                                 FocusVisualStyle="{x:Null}"/>
                    </Grid>
                </Grid>
            </Border>

            <!-- Theme List -->
            <ListBox Grid.Row="2" x:Name="LstThemes"
                     Background="Transparent" BorderThickness="0"
                     ScrollViewer.HorizontalScrollBarVisibility="Disabled"
                     ScrollViewer.VerticalScrollBarVisibility="Auto"
                     FocusVisualStyle="{x:Null}"
                     MaxHeight="380">
                <ListBox.ItemContainerStyle>
                    <Style TargetType="ListBoxItem">
                        <Setter Property="Padding" Value="0"/>
                        <Setter Property="Margin" Value="0,0,0,6"/>
                        <Setter Property="Background" Value="Transparent"/>
                        <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ListBoxItem">
                                    <Border x:Name="ItemBorder" Background="#161A24"
                                            BorderBrush="#242B3D" BorderThickness="1"
                                            CornerRadius="10" Padding="12,9" Cursor="Hand">
                                        <ContentPresenter/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="ItemBorder" Property="Background" Value="#222938"/>
                                            <Setter TargetName="ItemBorder" Property="BorderBrush" Value="$accentColor"/>
                                        </Trigger>
                                        <Trigger Property="IsSelected" Value="True">
                                            <Setter TargetName="ItemBorder" Property="Background" Value="#283246"/>
                                            <Setter TargetName="ItemBorder" Property="BorderBrush" Value="$accentColor"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </ListBox.ItemContainerStyle>
                <ListBox.ItemTemplate>
                    <DataTemplate>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Theme Icon (Sun / Moon) -->
                            <Border Grid.Column="0" Background="#10141D" CornerRadius="8"
                                    Width="36" Height="36" Margin="0,0,12,0" VerticalAlignment="Center">
                                <TextBlock Text="{Binding TypeIcon}"
                                           FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"
                                           FontSize="16" Foreground="{Binding TypeBadgeColor}"
                                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>

                            <!-- Theme Details -->
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="{Binding Name}" FontSize="14" FontWeight="SemiBold"
                                               Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text, Consolas"/>

                                    <!-- Appearance Tag -->
                                    <Border Background="#1F2432" CornerRadius="5" Padding="6,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                        <TextBlock Text="{Binding TypeLabel}" FontSize="9" FontWeight="Bold"
                                                   Foreground="{Binding TypeBadgeColor}" FontFamily="Consolas"/>
                                    </Border>

                                    <!-- Active Badge -->
                                    <Border Visibility="{Binding ActiveVisibility}"
                                            Background="#269ECE6A" BorderBrush="#9ECE6A" BorderThickness="1"
                                            CornerRadius="5" Padding="6,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                        <TextBlock Text="ATTIVO" FontSize="9" FontWeight="Bold"
                                                   Foreground="#9ECE6A" FontFamily="Consolas"/>
                                    </Border>
                                </StackPanel>
                                <TextBlock Text="{Binding Description}" FontSize="11" Foreground="#7982A9"
                                           FontFamily="Segoe UI Variable Text, Consolas" Margin="0,2,0,0"/>
                            </StackPanel>

                            <!-- Color Preview Swatches (Accent, Bg, Fg) -->
                            <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center" Margin="10,0,0,0">
                                <!-- Accent Color Swatch -->
                                <Border Background="{Binding AccentColor}" CornerRadius="10"
                                        Width="20" Height="20" Margin="0,0,6,0"
                                        BorderBrush="#FFFFFF" BorderThickness="1"
                                        ToolTip="Colore Accento">
                                    <Border.Effect>
                                        <DropShadowEffect Color="{Binding AccentColor}" BlurRadius="8" ShadowDepth="0" Opacity="0.5"/>
                                    </Border.Effect>
                                </Border>
                                <!-- Background Color Swatch -->
                                <Border Background="{Binding BgColor}" CornerRadius="10"
                                        Width="20" Height="20" Margin="0,0,6,0"
                                        BorderBrush="#444C66" BorderThickness="1"
                                        ToolTip="Colore Sfondo"/>
                                <!-- Foreground Color Swatch -->
                                <Border Background="{Binding FgColor}" CornerRadius="10"
                                        Width="20" Height="20"
                                        BorderBrush="#444C66" BorderThickness="1"
                                        ToolTip="Colore Testo"/>
                            </StackPanel>
                        </Grid>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>

            <!-- Footer Hint -->
            <TextBlock Grid.Row="3"
                       Text="[F2] Giorno  &#x2022;  [F3] Notte  &#x2022;  [F4] Toggle Auto  &#x2022;  [Invio] Applica  &#x2022;  [Esc] Chiudi"
                       FontSize="11" Foreground="#7982A9"
                       FontFamily="Segoe UI Variable Text, Consolas"
                       Margin="0,14,0,0" HorizontalAlignment="Center"/>
        </Grid>
    </Border>
</Window>
"@

# 6. Parse XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$txtSearch = $window.FindName("TxtSearch")
$txtPlaceholder = $window.FindName("TxtSearchPlaceholder")
$lstThemes = $window.FindName("LstThemes")
$btnClose = $window.FindName("BtnClose")
$btnDay = $window.FindName("BtnDay")
$btnNight = $window.FindName("BtnNight")
$btnAuto = $window.FindName("BtnAuto")

# Bind Items
$viewSource = [System.Windows.Data.CollectionViewSource]::new()
$viewSource.Source = $themeItems
$lstThemes.ItemsSource = $viewSource.View

# Pre-select currently active theme or first item
$activeItem = $themeItems | Where-Object { $_.IsActive } | Select-Object -First 1
if ($activeItem) {
    $lstThemes.SelectedItem = $activeItem
    $lstThemes.ScrollIntoView($activeItem)
} elseif ($themeItems.Count -gt 0) {
    $lstThemes.SelectedIndex = 0
}

# Helper to apply theme and close
$applyThemeAction = {
    param([string]$targetName)
    if ([string]::IsNullOrWhiteSpace($targetName)) { return }
    $window.Close()

    # Launch theme.ps1 in background without console window
    $psi = [System.Diagnostics.ProcessStartInfo]::new("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$themeScript`" -Theme `"$targetName`"")
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

$applyDayAction = {
    $window.Close()
    $psi = [System.Diagnostics.ProcessStartInfo]::new("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$themeScript`" -Day")
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

$applyNightAction = {
    $window.Close()
    $psi = [System.Diagnostics.ProcessStartInfo]::new("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$themeScript`" -Night")
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

$toggleAutoAction = {
    $isCurrentlyOn = $true
    if (Test-Path $autoThemeFile) {
        $val = (Get-Content $autoThemeFile -Raw -ErrorAction SilentlyContinue).Trim()
        if ($val -eq "0" -or $val -eq "false" -or $val -eq "disabled") {
            $isCurrentlyOn = $false
        }
    }
    $newOn = -not $isCurrentlyOn
    $saveVal = if ($newOn) { "1" } else { "0" }
    Set-Content -Path $autoThemeFile -Value $saveVal -Force

    # Update Button Visuals
    $newText = if ($newOn) { [char]0xE777 + " Auto: ATTIVO" } else { [char]0xE777 + " Auto: SOSPESO" }
    $newColorHex = if ($newOn) { "#9ECE6A" } else { "#E0AF68" }
    $newBgHex = if ($newOn) { "#269ECE6A" } else { "#26E0AF68" }

    $btnAuto.Content = $newText
    $btnAuto.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($newColorHex)
    $btnAuto.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($newBgHex)
    $btnAuto.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($newColorHex)
}

# Search Filter Logic
$txtSearch.Add_TextChanged({
    $query = $txtSearch.Text.Trim().ToLower()
    $txtPlaceholder.Visibility = if ([string]::IsNullOrEmpty($query)) { "Visible" } else { "Collapsed" }

    $viewSource.View.Filter = [System.Predicate[Object]]{
        param($obj)
        if ([string]::IsNullOrWhiteSpace($query)) { return $true }
        return $obj.SearchIndex.Contains($query)
    }

    if ($lstThemes.Items.Count -gt 0) {
        $lstThemes.SelectedIndex = 0
    }
})

# Keyboard Navigation
$window.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Escape) {
        $window.Close()
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::Enter) {
        if ($lstThemes.SelectedItem) {
            & $applyThemeAction $lstThemes.SelectedItem.Name
        }
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::F2) {
        & $applyDayAction
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::F3) {
        & $applyNightAction
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::F4) {
        & $toggleAutoAction
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::Down) {
        if ($lstThemes.SelectedIndex -lt ($lstThemes.Items.Count - 1)) {
            $lstThemes.SelectedIndex++
            $lstThemes.ScrollIntoView($lstThemes.SelectedItem)
        }
        $e.Handled = $true
    }
    elseif ($e.Key -eq [System.Windows.Input.Key]::Up) {
        if ($lstThemes.SelectedIndex -gt 0) {
            $lstThemes.SelectedIndex--
            $lstThemes.ScrollIntoView($lstThemes.SelectedItem)
        }
        $e.Handled = $true
    }
})

# Button Events
$btnClose.Add_Click({ $window.Close() })
$btnDay.Add_Click({ & $applyDayAction })
$btnNight.Add_Click({ & $applyNightAction })
$btnAuto.Add_Click({ & $toggleAutoAction })

$lstThemes.Add_MouseDoubleClick({
    if ($lstThemes.SelectedItem) {
        & $applyThemeAction $lstThemes.SelectedItem.Name
    }
})

# Allow dragging window from title area
$window.Add_MouseLeftButtonDown({
    param($sender, $e)
    if ($e.ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        $window.DragMove()
    }
})

# Auto focus search box on launch
$window.Add_Loaded({
    $txtSearch.Focus()
})

$window.ShowDialog() | Out-Null
