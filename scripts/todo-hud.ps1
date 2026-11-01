# 43PR Native WPF Todo & Notes HUD for Windows
# Port of 43PR/dotfiles Quickshell Todo.qml
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

$stateFile = Join-Path $HOME ".glzr\todo-state.json"
if (-not (Test-Path (Split-Path -Parent $stateFile))) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $stateFile) | Out-Null
}

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Todo &amp; Notes HUD"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        Focusable="True"
        Width="540"
        SizeToContent="Height"
        MinHeight="260"
        MaxHeight="680">
    <Window.Resources>
        <Style x:Key="IconFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"/>
        </Style>
        <Style x:Key="TextFont" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI Variable Text, Segoe UI, Consolas"/>
        </Style>
    </Window.Resources>

    <Border Background="#EE0B0D13"
            BorderBrush="$accentColor"
            BorderThickness="1.5"
            CornerRadius="16"
            Padding="22"
            Margin="12">
        <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="28" ShadowDepth="4" Opacity="0.75"/>
        </Border.Effect>

        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/> <!-- Header -->
                <RowDefinition Height="Auto"/> <!-- Input -->
                <RowDefinition Height="*"/>    <!-- Tasks List -->
                <RowDefinition Height="Auto"/> <!-- Footer / Summary -->
            </Grid.RowDefinitions>

            <!-- Header -->
            <Grid Grid.Row="0" Margin="0,0,0,16">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Column="0" Width="36" Height="36" CornerRadius="10" Background="#26FFFFFF" Margin="0,0,12,0">
                    <TextBlock Text="&#xE70F;" Style="{StaticResource IconFont}" FontSize="18" Foreground="$accentColor" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>

                <StackPanel Grid.Column="1" VerticalAlignment="Center">
                    <TextBlock Text="43PR NOTES &amp; TASKS" Style="{StaticResource TextFont}" FontSize="16" FontWeight="Bold" Foreground="#CDD6F4"/>
                    <TextBlock Text="Premi Invio per aggiungere &#x2022; Esc per chiudere" Style="{StaticResource TextFont}" FontSize="11" Foreground="#7982A9" Margin="0,2,0,0"/>
                </StackPanel>

                <Button x:Name="BtnClose" Grid.Column="2" Width="30" Height="30" Cursor="Hand" Background="Transparent" BorderThickness="0" FocusVisualStyle="{x:Null}">
                    <TextBlock Text="&#xE711;" Style="{StaticResource IconFont}" FontSize="14" Foreground="#9AA5CE" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Button>
            </Grid>

            <!-- Input Box -->
            <Border Grid.Row="1" Background="#1E1E2E" CornerRadius="10" BorderThickness="1" BorderBrush="#33FFFFFF" Padding="8,6" Margin="0,0,0,14">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <Grid Grid.Column="0">
                        <TextBlock x:Name="TxtPlaceholder" Text="Aggiungi una nuova nota o attivita rapida..." Style="{StaticResource TextFont}" FontSize="13" Foreground="#585B70" VerticalAlignment="Center" Margin="6,0,0,0" IsHitTestVisible="False"/>
                        <TextBox x:Name="InputTask" Background="Transparent" Foreground="#CDD6F4" BorderThickness="0" FontSize="13" FontFamily="Segoe UI, Consolas" VerticalAlignment="Center" Margin="4,0,0,0" FocusVisualStyle="{x:Null}"/>
                    </Grid>

                    <Button x:Name="BtnAdd" Grid.Column="1" Width="32" Height="32" Cursor="Hand" Background="$accentColor" BorderThickness="0" FocusVisualStyle="{x:Null}">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border Background="{TemplateBinding Background}" CornerRadius="8">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Button.Template>
                        <TextBlock Text="&#xE710;" Style="{StaticResource IconFont}" FontSize="14" Foreground="#0B0D13" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Button>
                </Grid>
            </Border>

            <!-- Tasks List Container with ScrollViewer -->
            <ScrollViewer Grid.Row="2" MaxHeight="360" VerticalScrollBarVisibility="Auto" Margin="0,0,0,12" FocusVisualStyle="{x:Null}">
                <StackPanel x:Name="TaskListPanel" Margin="0,2,4,2">
                    <!-- Dynamic task cards added via PowerShell code -->
                </StackPanel>
            </ScrollViewer>

            <!-- Empty State Display -->
            <StackPanel x:Name="EmptyStatePanel" Grid.Row="2" VerticalAlignment="Center" HorizontalAlignment="Center" Margin="0,24,0,24">
                <TextBlock Text="&#xE73E;" Style="{StaticResource IconFont}" FontSize="32" Foreground="#45475A" HorizontalAlignment="Center"/>
                <TextBlock Text="Nessuna nota presente. Aggiungine una sopra!" Style="{StaticResource TextFont}" FontSize="13" Foreground="#7982A9" Margin="0,8,0,0" HorizontalAlignment="Center"/>
            </StackPanel>

            <!-- Footer: Summary & Clean Action -->
            <Grid Grid.Row="3" Margin="0,4,0,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock x:Name="TxtStats" Grid.Column="0" Text="0 note attive" Style="{StaticResource TextFont}" FontSize="12" Foreground="#9AA5CE" VerticalAlignment="Center"/>

                <Button x:Name="BtnClearDone" Grid.Column="1" Background="Transparent" BorderThickness="0" Cursor="Hand" FocusVisualStyle="{x:Null}" Padding="6,2">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="&#xE74D;" Style="{StaticResource IconFont}" FontSize="12" Foreground="#F7768E" Margin="0,0,6,0" VerticalAlignment="Center"/>
                        <TextBlock Text="Rimuovi completate" Style="{StaticResource TextFont}" FontSize="11" Foreground="#9AA5CE" VerticalAlignment="Center"/>
                    </StackPanel>
                </Button>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnClose = $window.FindName("BtnClose")
$inputTask = $window.FindName("InputTask")
$txtPlaceholder = $window.FindName("TxtPlaceholder")
$btnAdd = $window.FindName("BtnAdd")
$taskListPanel = $window.FindName("TaskListPanel")
$emptyStatePanel = $window.FindName("EmptyStatePanel")
$txtStats = $window.FindName("TxtStats")
$btnClearDone = $window.FindName("BtnClearDone")

# Task items data structure
$taskList = [System.Collections.ArrayList]::new()

if (Test-Path $stateFile) {
    try {
        $raw = Get-Content $stateFile -Raw | ConvertFrom-Json
        if ($raw) {
            foreach ($item in $raw) {
                [void]$taskList.Add([PSCustomObject]@{
                    Id = if ($item.Id) { $item.Id } else { [Guid]::NewGuid().ToString() }
                    Text = [string]$item.Text
                    Done = [bool]$item.Done
                    CreatedAt = if ($item.CreatedAt) { [string]$item.CreatedAt } else { (Get-Date).ToString("yyyy-MM-dd HH:mm") }
                })
            }
        }
    } catch {}
}

function Save-Tasks {
    try {
        $json = $taskList | ConvertTo-Json -Depth 4
        Set-Content -Path $stateFile -Value $json -Encoding UTF8
    } catch {}
}

function Render-Tasks {
    $taskListPanel.Children.Clear()

    if ($taskList.Count -eq 0) {
        $emptyStatePanel.Visibility = [System.Windows.Visibility]::Visible
    } else {
        $emptyStatePanel.Visibility = [System.Windows.Visibility]::Collapsed
    }

    $completedCount = 0
    foreach ($task in $taskList) {
        if ($task.Done) { $completedCount++ }

        # Outer card Border
        $card = New-Object System.Windows.Controls.Border
        $card.CornerRadius = New-Object System.Windows.CornerRadius(10)
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.Margin = New-Object System.Windows.Thickness(0, 0, 0, 6)
        $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        if ($task.Done) {
            $card.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#181825")
            $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#22FFFFFF")
        } else {
            $card.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E1E2E")
            $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#33FFFFFF")
        }

        $grid = New-Object System.Windows.Controls.Grid
        $c1 = New-Object System.Windows.Controls.ColumnDefinition; $c1.Width = [System.Windows.GridLength]::Auto
        $c2 = New-Object System.Windows.Controls.ColumnDefinition; $c2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $c3 = New-Object System.Windows.Controls.ColumnDefinition; $c3.Width = [System.Windows.GridLength]::Auto
        $grid.ColumnDefinitions.Add($c1)
        $grid.ColumnDefinitions.Add($c2)
        $grid.ColumnDefinitions.Add($c3)

        # Toggle Button / Icon
        $btnToggle = New-Object System.Windows.Controls.Button
        $btnToggle.Background = [System.Windows.Media.Brushes]::Transparent
        $btnToggle.BorderThickness = New-Object System.Windows.Thickness(0)
        $btnToggle.Cursor = [System.Windows.Input.Cursors]::Hand
        $btnToggle.Margin = New-Object System.Windows.Thickness(0, 0, 10, 0)
        $btnToggle.FocusVisualStyle = $null

        $iconCheck = New-Object System.Windows.Controls.TextBlock
        $iconCheck.FontFamily = New-Object System.Windows.Media.FontFamily("Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol")
        $iconCheck.FontSize = 14
        $iconCheck.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        if ($task.Done) {
            $iconCheck.Text = [char]0xE73E # Checkmark
            $iconCheck.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#9ECE6A")
        } else {
            $iconCheck.Text = [char]0xEA3B # Empty circle
            $iconCheck.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#7982A9")
        }
        $btnToggle.Content = $iconCheck
        [System.Windows.Controls.Grid]::SetColumn($btnToggle, 0)
        $grid.Children.Add($btnToggle)

        # Content Text
        $contentStack = New-Object System.Windows.Controls.StackPanel
        $contentStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        $txtTitle = New-Object System.Windows.Controls.TextBlock
        $txtTitle.Text = $task.Text
        $txtTitle.FontFamily = New-Object System.Windows.Media.FontFamily("Segoe UI, Consolas")
        $txtTitle.FontSize = 13
        $txtTitle.TextWrapping = [System.Windows.TextWrapping]::Wrap

        if ($task.Done) {
            $txtTitle.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#6C7086")
            $txtTitle.TextDecorations = [System.Windows.TextDecorations]::Strikethrough
        } else {
            $txtTitle.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#CDD6F4")
        }
        $contentStack.Children.Add($txtTitle)

        $txtDate = New-Object System.Windows.Controls.TextBlock
        $txtDate.Text = $task.CreatedAt
        $txtDate.FontFamily = New-Object System.Windows.Media.FontFamily("Segoe UI, Consolas")
        $txtDate.FontSize = 10
        $txtDate.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#585B70")
        $txtDate.Margin = New-Object System.Windows.Thickness(0, 2, 0, 0)
        $contentStack.Children.Add($txtDate)

        [System.Windows.Controls.Grid]::SetColumn($contentStack, 1)
        $grid.Children.Add($contentStack)

        # Delete Button
        $btnDel = New-Object System.Windows.Controls.Button
        $btnDel.Background = [System.Windows.Media.Brushes]::Transparent
        $btnDel.BorderThickness = New-Object System.Windows.Thickness(0)
        $btnDel.Cursor = [System.Windows.Input.Cursors]::Hand
        $btnDel.Padding = New-Object System.Windows.Thickness(6, 4, 6, 4)
        $btnDel.FocusVisualStyle = $null

        $iconDel = New-Object System.Windows.Controls.TextBlock
        $iconDel.Text = [char]0xE74D # Trash
        $iconDel.FontFamily = New-Object System.Windows.Media.FontFamily("Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol")
        $iconDel.FontSize = 13
        $iconDel.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#7982A9")
        $btnDel.Content = $iconDel

        [System.Windows.Controls.Grid]::SetColumn($btnDel, 2)
        $grid.Children.Add($btnDel)

        $card.Child = $grid

        # Event Handlers
        $currTask = $task
        $toggleAction = {
            $currTask.Done = -not $currTask.Done
            Save-Tasks
            Render-Tasks
        }

        $btnToggle.Add_Click($toggleAction)
        $card.Add_MouseLeftButtonDown({
            if ($args[1].OriginalSource -is [System.Windows.Controls.TextBlock] -and $args[1].OriginalSource.Text -eq [char]0xE74D) {
                return
            }
            & $toggleAction
        })

        $btnDel.Add_Click({
            [void]$taskList.Remove($currTask)
            Save-Tasks
            Render-Tasks
        })

        [void]$taskListPanel.Children.Add($card)
    }

    # Update summary text
    $total = $taskList.Count
    $txtStats.Text = "$completedCount completate su $total note"
}

# Add Task logic
$actionAdd = {
    $text = $inputTask.Text.Trim()
    if (-not [string]::IsNullOrWhiteSpace($text)) {
        [void]$taskList.Insert(0, [PSCustomObject]@{
            Id = [Guid]::NewGuid().ToString()
            Text = $text
            Done = $false
            CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm")
        })
        $inputTask.Text = ""
        Save-Tasks
        Render-Tasks
    }
}

$btnAdd.Add_Click($actionAdd)

$inputTask.Add_TextChanged({
    if ([string]::IsNullOrEmpty($inputTask.Text)) {
        $txtPlaceholder.Visibility = [System.Windows.Visibility]::Visible
    } else {
        $txtPlaceholder.Visibility = [System.Windows.Visibility]::Collapsed
    }
})

$inputTask.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
        & $actionAdd
        $e.Handled = $true
    }
})

$btnClearDone.Add_Click({
    $toKeep = [System.Collections.ArrayList]::new()
    foreach ($t in $taskList) {
        if (-not $t.Done) { [void]$toKeep.Add($t) }
    }
    $taskList.Clear()
    foreach ($item in $toKeep) { [void]$taskList.Add($item) }
    Save-Tasks
    Render-Tasks
})

$btnClose.Add_Click({ $window.Close() })

$window.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Escape) {
        $window.Close()
    }
})

# Drag window by background
$window.Add_MouseLeftButtonDown({
    if ($args[1].ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        $window.DragMove()
    }
})

Render-Tasks
$inputTask.Focus() | Out-Null
$window.ShowDialog() | Out-Null

