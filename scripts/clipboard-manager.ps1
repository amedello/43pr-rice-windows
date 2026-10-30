# 43PR Clipboard Manager (WPF + In-memory/File Cache)
# Searchable history of copied texts, links, code snippets
# Hotkey: Alt + V

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$historyFile = Join-Path $env:TEMP "43pr_clip_history.json"
$accentColor = "#7AA2F7"
$styleFile = "D:\Progetto\config\zebar\starter\styles.css"
if (Test-Path $styleFile) {
    $content = Get-Content $styleFile -Raw
    if ($content -match '--accent:\s*(#[0-9a-fA-F]{6})') {
        $accentColor = $matches[1]
    }
}

# 1. Update clipboard history with current clipboard content
$currentClip = [System.Windows.Clipboard]::GetText()
$clips = [System.Collections.Generic.List[PSCustomObject]]::new()

if (Test-Path $historyFile) {
    try {
        $raw = Get-Content $historyFile -Raw
        $loaded = $raw | ConvertFrom-Json
        foreach ($item in $loaded) {
            if ($item.Text) {
                $clips.Add($item)
            }
        }
    } catch {}
}

if (-not [string]::IsNullOrWhiteSpace($currentClip)) {
    # Remove existing duplicate
    for ($i = $clips.Count - 1; $i -ge 0; $i--) {
        if ($clips[$i].Text -eq $currentClip) {
            $clips.RemoveAt($i)
        }
    }
    # Add to beginning
    $type = "Testo"
    if ($currentClip -match '^https?://') { $type = "Link" }
    elseif ($currentClip -match '[{}();=><]') { $type = "Codice" }

    $clips.Insert(0, [PSCustomObject]@{
        Text = $currentClip
        Time = (Get-Date).ToString("HH:mm")
        Type = $type
        Preview = if ($currentClip.Length -gt 120) { $currentClip.Substring(0, 117) + "..." } else { $currentClip.Replace("`r", " ").Replace("`n", " ") }
    })
}

# Keep max 50 items
while ($clips.Count -gt 50) {
    $clips.RemoveAt($clips.Count - 1)
}

try {
    $clips | ConvertTo-Json -Depth 5 | Set-Content -Path $historyFile -Force
} catch {}

# 2. Build WPF UI
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Clipboard"
        Width="580"
        SizeToContent="Height"
        MinHeight="220" MaxHeight="520"
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
            <DropShadowEffect Color="#000000" BlurRadius="28" ShadowDepth="4" Opacity="0.6"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <DockPanel Grid.Row="0" Margin="0,0,0,14">
                <Button x:Name="BtnClose" DockPanel.Dock="Right" Content="&#xE711;"
                        FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                        FontSize="12" Foreground="#9AA5CE" Background="Transparent"
                        BorderThickness="0" Cursor="Hand" Width="26" Height="26">
                    <Button.Style>
                        <Style TargetType="Button">
                            <Setter Property="Template">
                                <Setter.Value>
                                    <ControlTemplate TargetType="Button">
                                        <Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="6">
                                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                        <ControlTemplate.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True">
                                                <Setter TargetName="b" Property="Background" Value="#33FFFFFF"/>
                                                <Setter Property="Foreground" Value="#FFFFFF"/>
                                            </Trigger>
                                        </ControlTemplate.Triggers>
                                    </ControlTemplate>
                                </Setter.Value>
                            </Setter>
                        </Style>
                    </Button.Style>
                </Button>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="&#xE77F;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="18" Foreground="$accentColor" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBlock Text="43PR Clipboard" FontSize="16" FontWeight="Bold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Display, Consolas" VerticalAlignment="Center"/>
                </StackPanel>
            </DockPanel>

            <!-- Search Box with Placeholder -->
            <Border Grid.Row="1" Background="#1C2333" CornerRadius="10" Padding="12,8" Margin="0,0,0,12" BorderThickness="1" BorderBrush="#33FFFFFF">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="&#xE721;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="14" Foreground="#9AA5CE" VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <Grid Grid.Column="1">
                        <TextBlock x:Name="TxtSearchPlaceholder" Text="Cerca negli appunti..." FontSize="14" Foreground="#556488" FontFamily="Segoe UI Variable Text, Consolas" VerticalAlignment="Center" IsHitTestVisible="False"/>
                        <TextBox x:Name="TxtSearch" Background="Transparent" Foreground="#CDD6F4"
                                 BorderThickness="0" FontSize="14" FontFamily="Segoe UI Variable Text, Consolas"
                                 CaretBrush="$accentColor" VerticalAlignment="Center"
                                 FocusVisualStyle="{x:Null}"/>
                    </Grid>
                </Grid>
            </Border>

            <!-- List or Empty View -->
            <Grid Grid.Row="2" MinHeight="100" MaxHeight="340">
                <!-- Empty Message -->
                <StackPanel x:Name="EmptyView" VerticalAlignment="Center" HorizontalAlignment="Center" Visibility="Collapsed" Margin="0,20">
                    <TextBlock Text="&#xE77F;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="36" Foreground="#445577" HorizontalAlignment="Center" Margin="0,0,0,8"/>
                    <TextBlock Text="Nessun elemento negli appunti" FontSize="14" FontWeight="SemiBold" Foreground="#9AA5CE" HorizontalAlignment="Center"/>
                    <TextBlock Text="Copia del testo o link (Ctrl + C) per iniziare" FontSize="12" Foreground="#627294" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                </StackPanel>

                <!-- List of clips -->
                <ListBox x:Name="ListClips" Background="Transparent" BorderThickness="0"
                         ScrollViewer.HorizontalScrollBarVisibility="Disabled"
                         ScrollViewer.VerticalScrollBarVisibility="Auto">
                    <ListBox.ItemContainerStyle>
                        <Style TargetType="ListBoxItem">
                            <Setter Property="Margin" Value="0,2"/>
                            <Setter Property="Padding" Value="10,8"/>
                            <Setter Property="Cursor" Value="Hand"/>
                            <Setter Property="Template">
                                <Setter.Value>
                                    <ControlTemplate TargetType="ListBoxItem">
                                        <Border x:Name="itemBorder" Background="#182030" BorderThickness="1" BorderBrush="#20FFFFFF" CornerRadius="8" Padding="{TemplateBinding Padding}">
                                            <ContentPresenter/>
                                        </Border>
                                        <ControlTemplate.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True">
                                                <Setter TargetName="itemBorder" Property="Background" Value="#253044"/>
                                                <Setter TargetName="itemBorder" Property="BorderBrush" Value="$accentColor"/>
                                            </Trigger>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter TargetName="itemBorder" Property="Background" Value="#2A3850"/>
                                                <Setter TargetName="itemBorder" Property="BorderBrush" Value="$accentColor"/>
                                                <Setter TargetName="itemBorder" Property="BorderThickness" Value="1.5"/>
                                            </Trigger>
                                        </ControlTemplate.Triggers>
                                    </ControlTemplate>
                                </Setter.Value>
                            </Setter>
                        </Style>
                    </ListBox.ItemContainerStyle>
                    <ListBox.ItemTemplate>
                        <DataTemplate>
                            <DockPanel LastChildFill="True">
                                <Border DockPanel.Dock="Right" Background="#141A26" CornerRadius="4" Padding="6,2" Margin="8,0,0,0" VerticalAlignment="Center">
                                    <TextBlock Text="{Binding Time}" FontSize="11" Foreground="#7AA2F7" FontFamily="Consolas"/>
                                </Border>
                                <Border DockPanel.Dock="Right" Background="#26334A" CornerRadius="4" Padding="6,2" Margin="6,0,0,0" VerticalAlignment="Center">
                                    <TextBlock Text="{Binding Type}" FontSize="11" Foreground="#9AA5CE"/>
                                </Border>
                                <TextBlock Text="{Binding Preview}" FontSize="13" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text, Consolas" TextTrimming="CharacterEllipsis"/>
                            </DockPanel>
                        </DataTemplate>
                    </ListBox.ItemTemplate>
                </ListBox>
            </Grid>

            <!-- Footer Hint with XML bullet entities -->
            <TextBlock Grid.Row="3" Text="[Invio] Copia e Chiudi  &#x2022;  [Canc] Elimina elemento  &#x2022;  [Esc] Chiudi"
                       FontSize="11" Foreground="#7982A9" FontFamily="Segoe UI Variable Text, Consolas" Margin="0,14,0,0" HorizontalAlignment="Center"/>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnClose = $window.FindName("BtnClose")
$txtSearch = $window.FindName("TxtSearch")
$txtPlaceholder = $window.FindName("TxtSearchPlaceholder")
$listClips = $window.FindName("ListClips")
$emptyView = $window.FindName("EmptyView")

$refreshList = {
    param($items)
    if ($items.Count -eq 0) {
        $emptyView.Visibility = [System.Windows.Visibility]::Visible
        $listClips.Visibility = [System.Windows.Visibility]::Collapsed
    } else {
        $emptyView.Visibility = [System.Windows.Visibility]::Collapsed
        $listClips.Visibility = [System.Windows.Visibility]::Visible
        $listClips.ItemsSource = [System.Collections.ObjectModel.ObservableCollection[PSCustomObject]]::new($items)
        if ($listClips.SelectedIndex -lt 0) {
            $listClips.SelectedIndex = 0
        }
    }
}

& $refreshList $clips

# Close button
$btnClose.Add_Click({ $window.Close() })

# Search filtering & placeholder toggle
$txtSearch.Add_TextChanged({
    $q = $txtSearch.Text.Trim().ToLower()
    $txtPlaceholder.Visibility = if ([string]::IsNullOrEmpty($txtSearch.Text)) {
        [System.Windows.Visibility]::Visible
    } else {
        [System.Windows.Visibility]::Collapsed
    }

    $filtered = if ([string]::IsNullOrEmpty($q)) {
        $clips
    } else {
        $clips | Where-Object { $_.Text -and $_.Text.ToLower().Contains($q) }
    }
    & $refreshList $filtered
})

# Copy action
$copySelected = {
    $sel = $listClips.SelectedItem
    if ($sel -and $sel.Text) {
        [System.Windows.Clipboard]::SetText($sel.Text)
        $window.Close()
    }
}

# Delete action
$deleteSelected = {
    $sel = $listClips.SelectedItem
    if ($sel) {
        for ($i = 0; $i -lt $clips.Count; $i++) {
            if ($clips[$i].Text -eq $sel.Text) {
                $clips.RemoveAt($i)
                break
            }
        }
        try {
            $clips | ConvertTo-Json -Depth 5 | Set-Content -Path $historyFile -Force
        } catch {}
        & $refreshList $clips
    }
}

$listClips.Add_MouseDoubleClick({ & $copySelected })

# Key events
$window.Add_KeyDown({
    param($s, $e)
    switch ($e.Key) {
        "Escape" { $window.Close() }
        "Enter"  { & $copySelected }
        "Delete" { & $deleteSelected }
        "Down" {
            if (-not $listClips.IsKeyboardFocusWithin) {
                if ($listClips.SelectedIndex -lt $listClips.Items.Count - 1) {
                    $listClips.SelectedIndex++
                }
            }
        }
        "Up" {
            if (-not $listClips.IsKeyboardFocusWithin) {
                if ($listClips.SelectedIndex -gt 0) {
                    $listClips.SelectedIndex--
                }
            }
        }
    }
})

$window.Add_Loaded({
    $txtSearch.Focus()
})

$window.ShowDialog() | Out-Null
