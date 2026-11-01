# 43PR Native Windows Action Center Toast Notification
# Registers 43PR Rice as a first-class Windows notification sender
# Posts notifications directly to Windows Action Center (Centro Notifiche)
# Pure 7-bit ASCII encoded for 100% mojibake prevention

[CmdletBinding()]
param (
    [string]$Title = "43PR Rice Windows",
    [Parameter(Mandatory=$true)]
    [string]$Message,
    [string]$Type = "Info",
    [int]$HoursToLive = 4
)

$ErrorActionPreference = "Continue"

try {
    # Ensure 43PR Rice is registered in Windows AppUserModelId registry
    $appId = "43PR.Rice.Windows"
    $regKey = "HKCU:\Software\Classes\AppUserModelId\$appId"
    if (-not (Test-Path $regKey)) {
        New-Item -Path $regKey -Force | Out-Null
    }
    Set-ItemProperty -Path $regKey -Name "DisplayName" -Value "43PR Rice"
    Set-ItemProperty -Path $regKey -Name "ShowInSettings" -Value 1 -Type DWord

    # Load Windows Runtime WinRT notification assemblies
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

    $escapedTitle = [System.Security.SecurityElement]::Escape($Title)
    $escapedMsg = [System.Security.SecurityElement]::Escape($Message)

    $toastXmlString = @"
<toast duration="long">
    <visual>
        <binding template="ToastGeneric">
            <text>$escapedTitle</text>
            <text>$escapedMsg</text>
        </binding>
    </visual>
</toast>
"@

    $xmlDoc = [Windows.Data.Xml.Dom.XmlDocument]::new()
    $xmlDoc.LoadXml($toastXmlString)
    
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xmlDoc)
    # Allows notification to persist in the Action Center notification list
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddHours($HoursToLive)

    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
    $notifier.Show($toast)
} catch {
    # Fallback to Tray Balloon if WinRT fails
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        $notify = New-Object System.Windows.Forms.NotifyIcon
        $notify.Icon = [System.Drawing.SystemIcons]::Information
        $notify.Visible = $true
        $notify.ShowBalloonTip(5000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Milliseconds 500
        $notify.Dispose()
    } catch {}
}
