# 43PR Global Window Switcher & Quick Jump (WPF)
# Shows all open windows with search, jump directly with Enter
# Hotkey: Alt + Tab / Alt + J

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$csharpWin32 = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public class Win32WindowHelper {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);

    [DllImport("kernel32.dll")]
    public static extern uint GetCurrentThreadId();

    public class WindowInfo {
        public IntPtr Handle { get; set; }
        public string Title { get; set; }
        public string ProcessName { get; set; }
    }

    public static List<WindowInfo> GetOpenWindows() {
        var list = new List<WindowInfo>();
        IntPtr currentFg = GetForegroundWindow();

        EnumWindows((hWnd, lParam) => {
            if (!IsWindowVisible(hWnd)) return true;
            int len = GetWindowTextLength(hWnd);
            if (len == 0) return true;

            StringBuilder sb = new StringBuilder(len + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            string title = sb.ToString();

            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);
            string pName = "";
            try {
                pName = Process.GetProcessById((int)pid).ProcessName;
            } catch {}

            // Filter out system utility and overlay windows
            if (pName.Equals("ShellExperienceHost", StringComparison.OrdinalIgnoreCase) ||
                pName.Equals("SearchHost", StringComparison.OrdinalIgnoreCase) ||
                pName.Equals("StartMenuExperienceHost", StringComparison.OrdinalIgnoreCase) ||
                pName.Equals("TextInputHost", StringComparison.OrdinalIgnoreCase) ||
                pName.Equals("zebar", StringComparison.OrdinalIgnoreCase) ||
                pName.Equals("glazewm", StringComparison.OrdinalIgnoreCase) ||
                title.Equals("Program Manager", StringComparison.OrdinalIgnoreCase) ||
                title.Equals("43PR Window Switcher", StringComparison.OrdinalIgnoreCase)) {
                return true;
            }

            list.Add(new WindowInfo {
                Handle = hWnd,
                Title = title,
                ProcessName = pName
            });
            return true;
        }, IntPtr.Zero);

        return list;
    }

    public static void ActivateWindow(IntPtr hWnd) {
        if (hWnd == IntPtr.Zero) return;
        if (IsIconic(hWnd)) {
            ShowWindow(hWnd, 9); // SW_RESTORE
        } else {
            ShowWindow(hWnd, 5); // SW_SHOW
        }
        uint dummy;
        uint foreThread = GetWindowThreadProcessId(GetForegroundWindow(), out dummy);
        uint appThread = GetCurrentThreadId();
        if (foreThread != appThread) {
            AttachThreadInput(foreThread, appThread, true);
            SetForegroundWindow(hWnd);
            AttachThreadInput(foreThread, appThread, false);
        } else {
            SetForegroundWindow(hWnd);
        }
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'Win32WindowHelper').Type) {
    Add-Type -TypeDefinition $csharpWin32
}

$accentColor = "#7AA2F7"
$styleFile = "D:\Progetto\config\zebar\starter\styles.css"
if (Test-Path $styleFile) {
    $content = Get-Content $styleFile -Raw
    if ($content -match '--accent:\s*(#[0-9a-fA-F]{6})') {
        $accentColor = $matches[1]
    }
}

$windows = [Win32WindowHelper]::GetOpenWindows()
$winList = [System.Collections.Generic.List[PSCustomObject]]::new()
foreach ($w in $windows) {
    $winList.Add([PSCustomObject]@{
        Handle = $w.Handle
        ProcessName = $w.ProcessName
        Title = $w.Title
    })
}

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Window Switcher"
        Width="640" Height="480"
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
            <DockPanel Grid.Row="0" Margin="0,0,0,12">
                <Button x:Name="BtnClose" DockPanel.Dock="Right" Content="&#xE711;"
                        FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets"
                        FontSize="12" Foreground="#9AA5CE" Background="Transparent"
                        BorderThickness="0" Cursor="Hand" Width="26" Height="26"/>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="&#xE737;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="18" Foreground="$accentColor" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBlock Text="43PR Window Switcher" FontSize="16" FontWeight="Bold" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Display, Consolas" VerticalAlignment="Center"/>
                </StackPanel>
            </DockPanel>

            <!-- Search Box -->
            <Border Grid.Row="1" Background="#222838" CornerRadius="8" Padding="10,6" Margin="0,0,0,12" BorderThickness="1" BorderBrush="#33FFFFFF">
                <DockPanel>
                    <TextBlock Text="&#xE721;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="14" Foreground="#9AA5CE" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBox x:Name="TxtSearch" Background="Transparent" Foreground="#CDD6F4"
                             BorderThickness="0" FontSize="14" FontFamily="Segoe UI Variable Text, Consolas"
                             CaretBrush="$accentColor" VerticalAlignment="Center"/>
                </DockPanel>
            </Border>

            <!-- Windows List -->
            <ListBox x:Name="ListWindows" Grid.Row="2" Background="Transparent" BorderThickness="0"
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
                                    <Border x:Name="itemBorder" Background="Transparent" CornerRadius="8" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="itemBorder" Property="Background" Value="#252F42"/>
                                        </Trigger>
                                        <Trigger Property="IsSelected" Value="True">
                                            <Setter TargetName="itemBorder" Property="Background" Value="#313E56"/>
                                            <Setter TargetName="itemBorder" Property="BorderBrush" Value="$accentColor"/>
                                            <Setter TargetName="itemBorder" Property="BorderThickness" Value="1"/>
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
                            <Border DockPanel.Dock="Right" Background="#1D2436" CornerRadius="4" Padding="6,2" Margin="8,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="{Binding ProcessName}" FontSize="11" Foreground="#7AA2F7" FontWeight="SemiBold" FontFamily="Consolas"/>
                            </Border>
                            <TextBlock Text="{Binding Title}" FontSize="13" Foreground="#CDD6F4" FontFamily="Segoe UI Variable Text, Consolas" TextTrimming="CharacterEllipsis"/>
                        </DockPanel>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>

            <!-- Footer Hint -->
            <TextBlock Grid.Row="3" Text="[Invio] Metti a fuoco finestra  •  [Frecce Su/Giu] Scorri  •  [Esc] Chiudi"
                       FontSize="11" Foreground="#7982A9" FontFamily="Consolas" Margin="0,10,0,0" HorizontalAlignment="Center"/>
        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$btnClose = $window.FindName("BtnClose")
$txtSearch = $window.FindName("TxtSearch")
$listWindows = $window.FindName("ListWindows")

$listWindows.ItemsSource = [System.Collections.ObjectModel.ObservableCollection[PSCustomObject]]::new($winList)
if ($winList.Count -gt 0) {
    $listWindows.SelectedIndex = 0
}

$btnClose.Add_Click({ $window.Close() })

$txtSearch.Add_TextChanged({
    $q = $txtSearch.Text.Trim().ToLower()
    $filtered = if ([string]::IsNullOrEmpty($q)) {
        $winList
    } else {
        $winList | Where-Object {
            ($_.Title -and $_.Title.ToLower().Contains($q)) -or
            ($_.ProcessName -and $_.ProcessName.ToLower().Contains($q))
        }
    }
    $listWindows.ItemsSource = [System.Collections.ObjectModel.ObservableCollection[PSCustomObject]]::new($filtered)
    if ($listWindows.Items.Count -gt 0) {
        $listWindows.SelectedIndex = 0
    }
})

$activateSelected = {
    $sel = $listWindows.SelectedItem
    if ($sel -and $sel.Handle) {
        $window.Close()
        [Win32WindowHelper]::ActivateWindow($sel.Handle)
    }
}

$listWindows.Add_MouseDoubleClick({ & $activateSelected })

$window.Add_KeyDown({
    param($s, $e)
    switch ($e.Key) {
        "Escape" { $window.Close() }
        "Enter"  { & $activateSelected }
        "Down" {
            if (-not $listWindows.IsKeyboardFocusWithin) {
                if ($listWindows.SelectedIndex -lt $listWindows.Items.Count - 1) {
                    $listWindows.SelectedIndex++
                }
            }
        }
        "Up" {
            if (-not $listWindows.IsKeyboardFocusWithin) {
                if ($listWindows.SelectedIndex -gt 0) {
                    $listWindows.SelectedIndex--
                }
            }
        }
    }
})

$window.Add_Loaded({
    $txtSearch.Focus()
})

$window.ShowDialog() | Out-Null
