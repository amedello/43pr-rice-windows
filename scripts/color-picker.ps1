# 43PR Screen Color Picker (Hyprpicker style for Windows)
# Captures pixel color under cursor, copies HEX to clipboard
# Hotkey: Alt + Shift + C

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing, System.Windows.Forms

# Capture entire virtual screen into Bitmap
$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bmp.Size)
$graphics.Dispose()

# Convert Bitmap to WPF BitmapSource for backdrop
$hBitmap = $bmp.GetHbitmap()
$source = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHBitmap(
    $hBitmap,
    [IntPtr]::Zero,
    [System.Windows.Int32Rect]::Empty,
    [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
)

if (-not ([System.Management.Automation.PSTypeName]'GdiUtil').Type) {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class GdiUtil {
        [DllImport("gdi32.dll")]
        public static extern bool DeleteObject(IntPtr hObject);
    }
"@
}
[GdiUtil]::DeleteObject($hBitmap) | Out-Null

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="43PR Color Picker"
        WindowStyle="None"
        AllowsTransparency="False"
        Topmost="True"
        ShowInTaskbar="False"
        Cursor="Cross"
        Left="$($bounds.X)" Top="$($bounds.Y)"
        Width="$($bounds.Width)" Height="$($bounds.Height)">
    <Grid>
        <Image x:Name="BgImage" Stretch="Fill"/>
        <Canvas x:Name="OverlayCanvas">
            <!-- Loupe / Magnifier Card -->
            <Border x:Name="Loupe" Width="170" Height="90" CornerRadius="12"
                    Background="#EE141822" BorderThickness="1.5" BorderBrush="#7AA2F7"
                    Padding="10">
                <Border.Effect>
                    <DropShadowEffect Color="#000000" BlurRadius="16" ShadowDepth="3" Opacity="0.7"/>
                </Border.Effect>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="50"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    
                    <!-- Color Swatch -->
                    <Border x:Name="Swatch" Grid.Column="0" CornerRadius="8" BorderThickness="1" BorderBrush="#44FFFFFF" Margin="0,0,10,0"/>

                    <!-- Details -->
                    <StackPanel Grid.Column="1" VerticalAlignment="Center">
                        <TextBlock x:Name="TxtHex" Text="#FFFFFF" FontWeight="Bold" FontSize="15" Foreground="#CDD6F4" FontFamily="Consolas"/>
                        <TextBlock x:Name="TxtRgb" Text="rgb(255, 255, 255)" FontSize="10" Foreground="#9AA5CE" FontFamily="Consolas" Margin="0,4,0,0"/>
                        <TextBlock Text="Click: Copia" FontSize="9" Foreground="#7982A9" FontFamily="Segoe UI Variable Text, Segoe UI, Consolas" Margin="0,4,0,0"/>
                    </StackPanel>
                </Grid>
            </Border>
        </Canvas>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$bgImage = $window.FindName("BgImage")
$bgImage.Source = $source
$loupe = $window.FindName("Loupe")
$swatch = $window.FindName("Swatch")
$txtHex = $window.FindName("TxtHex")
$txtRgb = $window.FindName("TxtRgb")

$selectedColorHex = ""

$window.Add_MouseMove({
    param($s, $e)
    $pos = $e.GetPosition($window)
    $x = [int][Math]::Min([Math]::Max($pos.X, 0), $bmp.Width - 1)
    $y = [int][Math]::Min([Math]::Max($pos.Y, 0), $bmp.Height - 1)

    $c = $bmp.GetPixel($x, $y)
    $hex = "#{0:X2}{1:X2}{2:X2}" -f $c.R, $c.G, $c.B
    $selectedColorHex = $hex

    $txtHex.Text = $hex
    $txtRgb.Text = "rgb($($c.R), $($c.G), $($c.B))"
    $swatch.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb($c.R, $c.G, $c.B))
    $loupe.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb($c.R, $c.G, $c.B))

    # Position loupe offset from cursor so it doesn't block pixel
    $offsetX = if ($pos.X + 190 -gt $window.Width) { $pos.X - 185 } else { $pos.X + 20 }
    $offsetY = if ($pos.Y + 110 -gt $window.Height) { $pos.Y - 105 } else { $pos.Y + 20 }

    [System.Windows.Controls.Canvas]::SetLeft($loupe, $offsetX)
    [System.Windows.Controls.Canvas]::SetTop($loupe, $offsetY)
})

$window.Add_MouseLeftButtonDown({
    param($s, $e)
    $pos = $e.GetPosition($window)
    $x = [int][Math]::Min([Math]::Max($pos.X, 0), $bmp.Width - 1)
    $y = [int][Math]::Min([Math]::Max($pos.Y, 0), $bmp.Height - 1)
    $c = $bmp.GetPixel($x, $y)
    $hex = "#{0:X2}{1:X2}{2:X2}" -f $c.R, $c.G, $c.B

    [System.Windows.Clipboard]::SetText($hex)
    [System.Media.SystemSounds]::Asterisk.Play()
    $window.Close()
})

$window.Add_MouseRightButtonDown({
    $window.Close()
})

$window.Add_KeyDown({
    param($s, $e)
    if ($e.Key -eq "Escape") {
        $window.Close()
    }
})

$window.Add_Closed({
    $bmp.Dispose()
})

$window.ShowDialog() | Out-Null
