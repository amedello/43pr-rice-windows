# Toggle Windows Taskbar Auto-Hide
# Sets taskbar to auto-hide or always visible

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"

if (-not (Test-Path $regPath)) {
    Write-Warning "StuckRects3 registry key not found."
    return
}

$bytes = (Get-ItemProperty -Path $regPath).Settings
$current = $bytes[8]

# 2 = Always visible, 3 = Auto-hide
$newVal = if ($current -eq 3) { 2 } else { 3 }
$bytes[8] = $newVal
Set-ItemProperty -Path $regPath -Name Settings -Value $bytes

$code = @"
using System;
using System.Runtime.InteropServices;

public class TaskbarToggleUtil {
    [StructLayout(LayoutKind.Sequential)]
    public struct APPBARDATA {
        public uint cbSize;
        public IntPtr hWnd;
        public uint uCallbackMessage;
        public uint uEdge;
        public RECT rc;
        public int lParam;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int left, top, right, bottom;
    }

    [DllImport("shell32.dll")]
    public static extern uint SHAppBarMessage(uint dwMessage, ref APPBARDATA pData);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    public static void SetAutoHide(bool enable) {
        APPBARDATA abd = new APPBARDATA();
        abd.cbSize = (uint)Marshal.SizeOf(typeof(APPBARDATA));
        abd.hWnd = FindWindow("Shell_TrayWnd", null);
        abd.lParam = enable ? 1 : 2; // 1 = ABS_AUTOHIDE, 2 = ABS_ALWAYSONTOP
        SHAppBarMessage(10, ref abd); // 10 = ABM_SETSTATE
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'TaskbarToggleUtil').Type) {
    Add-Type -TypeDefinition $code
}

$isAutoHide = ($newVal -eq 3)
[TaskbarToggleUtil]::SetAutoHide($isAutoHide)

if ($isAutoHide) {
    Write-Host "Windows Taskbar set to: AUTO-HIDE (Hidden)" -ForegroundColor Green
} else {
    Write-Host "Windows Taskbar set to: ALWAYS VISIBLE" -ForegroundColor Yellow
}

