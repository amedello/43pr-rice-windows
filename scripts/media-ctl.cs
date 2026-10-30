using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;

/// <summary>
/// 43PR Native Desktop & Media Controller for Windows
/// Handles audio switching, volume, media keys, taskbar toggle, and dialogs
/// with 0ms latency and ZERO console window popup.
/// 
/// Compile with:
/// C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /out:media-ctl.exe media-ctl.cs
/// </summary>
class Program {
    [DllImport("user32.dll")]
    static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("shell32.dll")]
    static extern uint SHAppBarMessage(uint dwMessage, ref APPBARDATA pData);

    [DllImport("user32.dll", SetLastError = true)]
    static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);

    [StructLayout(LayoutKind.Sequential)]
    struct APPBARDATA {
        public uint cbSize;
        public IntPtr hWnd;
        public uint uCallbackMessage;
        public uint uEdge;
        public RECT rc;
        public int lParam;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct RECT {
        public int left, top, right, bottom;
    }

    static void PressKey(byte vk) {
        keybd_event(vk, 0, 0, UIntPtr.Zero);
        keybd_event(vk, 0, 2, UIntPtr.Zero);
    }

    static void OpenAudioSettings() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("ms-settings:sound") { UseShellExecute = true };
            Process.Start(psi);
        } catch {
            try {
                ProcessStartInfo psi2 = new ProcessStartInfo("control.exe", "mmsys.cpl,,0") { UseShellExecute = true };
                Process.Start(psi2);
            } catch {}
        }
    }

    static void OpenShutdownDialog() {
        try {
            Type shellAppType = Type.GetTypeFromProgID("Shell.Application");
            if (shellAppType != null) {
                object shell = Activator.CreateInstance(shellAppType);
                shellAppType.InvokeMember("ShutdownWindows", System.Reflection.BindingFlags.InvokeMethod, null, shell, null);
            }
        } catch {}
    }

    static void ToggleTaskbar() {
        try {
            using (var key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3", true)) {
                if (key != null) {
                    byte[] settings = (byte[])key.GetValue("Settings");
                    if (settings != null && settings.Length > 8) {
                        bool isAuto = (settings[8] == 3);
                        byte newVal = isAuto ? (byte)2 : (byte)3;
                        settings[8] = newVal;
                        key.SetValue("Settings", settings);

                        APPBARDATA abd = new APPBARDATA();
                        abd.cbSize = (uint)Marshal.SizeOf(typeof(APPBARDATA));
                        abd.hWnd = FindWindow("Shell_TrayWnd", null);
                        abd.lParam = (!isAuto) ? 1 : 2; // 1 = ABS_AUTOHIDE, 2 = ABS_ALWAYSONTOP
                        SHAppBarMessage(10, ref abd);
                    }
                }
            }
        } catch {}
    }

    static List<string> ParseCsvLine(string line) {
        List<string> result = new List<string>();
        bool inQuotes = false;
        System.Text.StringBuilder current = new System.Text.StringBuilder();

        for (int i = 0; i < line.Length; i++) {
            char c = line[i];
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                result.Add(current.ToString());
                current.Clear();
            } else {
                current.Append(c);
            }
        }
        result.Add(current.ToString());
        return result;
    }

    static string GetSoundVolumeViewPath() {
        try {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string pkgPath = Path.Combine(localAppData, @"Microsoft\WinGet\Packages\NirSoft.SoundVolumeView_Microsoft.Winget.Source_8wekyb3d8bbwe\SoundVolumeView.exe");
            if (File.Exists(pkgPath)) return pkgPath;
            string linkPath = Path.Combine(localAppData, @"Microsoft\WinGet\Links\SoundVolumeView.exe");
            if (File.Exists(linkPath)) return linkPath;
        } catch {}
        return "SoundVolumeView.exe";
    }

    static void SwitchAudioDevice() {
        try {
            string svvPath = GetSoundVolumeViewPath();
            string tempFile = Path.Combine(Path.GetTempPath(), "43pr_svv_audio.csv");
            if (File.Exists(tempFile)) {
                try { File.Delete(tempFile); } catch {}
            }

            ProcessStartInfo psi = new ProcessStartInfo(svvPath, string.Format("/scomma \"{0}\"", tempFile)) {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            using (Process p = Process.Start(psi)) {
                if (p != null) p.WaitForExit(3000);
            }

            if (!File.Exists(tempFile)) return;

            string[] lines = File.ReadAllLines(tempFile);
            try { File.Delete(tempFile); } catch {}

            if (lines.Length <= 1) return;

            List<string> headers = ParseCsvLine(lines[0]);
            int typeIdx = headers.IndexOf("Type");
            int dirIdx = headers.IndexOf("Direction");
            int stateIdx = headers.IndexOf("Device State");
            int defaultIdx = headers.IndexOf("Default");
            int defaultMultiIdx = headers.IndexOf("Default Multimedia");
            int idIdx = headers.IndexOf("Command-Line Friendly ID");

            if (typeIdx == -1 || dirIdx == -1 || defaultIdx == -1 || idIdx == -1) return;

            List<string> activeDevices = new List<string>();
            int currentIndex = -1;

            for (int i = 1; i < lines.Length; i++) {
                List<string> cols = ParseCsvLine(lines[i]);
                if (cols.Count <= Math.Max(typeIdx, Math.Max(dirIdx, Math.Max(defaultIdx, idIdx)))) continue;

                if (cols[typeIdx] == "Device" && cols[dirIdx] == "Render" && (stateIdx == -1 || cols[stateIdx] == "Active")) {
                    string friendlyId = cols[idIdx];
                    activeDevices.Add(friendlyId);
                    bool isDefault = (cols[defaultIdx] == "Render") || (defaultMultiIdx != -1 && cols.Count > defaultMultiIdx && cols[defaultMultiIdx] == "Render");
                    if (isDefault) {
                        currentIndex = activeDevices.Count - 1;
                    }
                }
            }

            if (activeDevices.Count > 1) {
                int nextIndex = (currentIndex + 1) % activeDevices.Count;
                string targetId = activeDevices[nextIndex];
                ProcessStartInfo setPsi = new ProcessStartInfo(svvPath, string.Format("/SetDefault \"{0}\" all", targetId)) {
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                using (Process setP = Process.Start(setPsi)) {
                    if (setP != null) setP.WaitForExit(2000);
                }
            }
        } catch {}
    }

    static void OpenCheatsheet() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File \"D:\\Progetto\\scripts\\show-cheatsheet.ps1\"") {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            Process.Start(psi);
        } catch {}
    }

    static void LaunchZebarDirectly() {
        try {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string gwmCli = Path.Combine(localAppData, @"Programs\glzr\bin\cli\glazewm.exe");
            if (File.Exists(gwmCli)) {
                ProcessStartInfo gwmPsi = new ProcessStartInfo(gwmCli, "command shell-exec zebar") {
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                using (var p = Process.Start(gwmPsi)) {
                    if (p != null) p.WaitForExit(3000);
                }
                return;
            }

            string binDir = Path.Combine(localAppData, @"Programs\glzr\bin");
            string zebarPath = Path.Combine(binDir, "zebar.exe");
            ProcessStartInfo startPsi = new ProcessStartInfo(File.Exists(zebarPath) ? zebarPath : "zebar.exe") {
                WorkingDirectory = binDir,
                UseShellExecute = true
            };
            Process.Start(startPsi);
        } catch {}
    }

    static void StartupZebar() {
        // Allow Windows logon, DWM, and WebView2 runtime to initialize before launching Zebar
        System.Threading.Thread.Sleep(1500);

        // Apply Day/Night theme first if configured so CSS is in sync (synchronous to avoid race condition)
        AutoDayNightTheme(true);

        try {
            foreach (var p in Process.GetProcessesByName("zebar")) {
                try { p.Kill(); } catch {}
            }
        } catch {}

        System.Threading.Thread.Sleep(600);
        LaunchZebarDirectly();

        // Check for updates asynchronously in background (every 7 days, non-blocking)
        CheckAndRefreshDependenciesAsync();
    }

    static void UpdateDependencies(bool force = false) {
        try {
            string userProfile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            string starterDir = Path.Combine(userProfile, @".glzr\zebar\starter");
            string stampFile = Path.Combine(starterDir, ".last_update_check");

            if (!Directory.Exists(starterDir)) return;

            // Check if last check was less than 7 days ago
            if (!force && File.Exists(stampFile)) {
                DateTime lastCheck = File.GetLastWriteTime(stampFile);
                if ((DateTime.Now - lastCheck).TotalDays < 7) {
                    return; // Already up-to-date within the last 7 days
                }
            }

            // Update timestamp
            try { File.WriteAllText(stampFile, DateTime.Now.ToString("o")); } catch {}

            // Configure TLS 1.2 for modern CDN endpoints
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;

            using (var wc = new WebClient()) {
                wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZebarUpdate/1.0");

                // 1. Download latest babel.min.js
                string babelTmp = Path.Combine(starterDir, "babel.min.js.tmp");
                string babelDst = Path.Combine(starterDir, "babel.min.js");
                try {
                    wc.DownloadFile("https://unpkg.com/@babel/standalone/babel.min.js", babelTmp);
                    FileInfo fi = new FileInfo(babelTmp);
                    if (fi.Length > 500000) {
                        if (File.Exists(babelDst)) File.Delete(babelDst);
                        File.Move(babelTmp, babelDst);

                        string repoBabel = @"D:\Progetto\config\zebar\starter\babel.min.js";
                        try {
                            if (File.Exists(repoBabel)) File.Copy(babelDst, repoBabel, true);
                        } catch {}
                    } else {
                        try { File.Delete(babelTmp); } catch {}
                    }
                } catch {}

                // 2. Download latest webfont.css and update local font path
                string fontsDir = Path.Combine(starterDir, "fonts");
                if (Directory.Exists(fontsDir)) {
                    string cssTmp = Path.Combine(fontsDir, "webfont.css.tmp");
                    string cssDst = Path.Combine(fontsDir, "webfont.css");
                    try {
                        wc.DownloadFile("https://www.nerdfonts.com/assets/css/webfont.css", cssTmp);
                        FileInfo fi = new FileInfo(cssTmp);
                        if (fi.Length > 1000) {
                            string cssContent = File.ReadAllText(cssTmp);
                            cssContent = System.Text.RegularExpressions.Regex.Replace(cssContent, @"src:url\([^)]+\)", "src:url('./Symbols-Nerd-Font.woff2')");
                            File.WriteAllText(cssDst, cssContent);
                            try { File.Delete(cssTmp); } catch {}

                            string repoCss = @"D:\Progetto\config\zebar\starter\fonts\webfont.css";
                            try {
                                if (File.Exists(repoCss)) File.Copy(cssDst, repoCss, true);
                            } catch {}
                        } else {
                            try { File.Delete(cssTmp); } catch {}
                        }
                    } catch {}
                }
            }
        } catch {}
    }

    static void CheckAndRefreshDependenciesAsync() {
        System.Threading.ThreadPool.QueueUserWorkItem(state => {
            // Wait 25 seconds after boot so Windows network and Wi-Fi connection stabilize
            System.Threading.Thread.Sleep(25000);
            UpdateDependencies(false);
        });
    }

    static void RestartZebar() {
        try {
            foreach (var p in Process.GetProcessesByName("zebar")) {
                try { p.Kill(); } catch {}
            }
        } catch {}

        try {
            System.Threading.Thread.Sleep(800);
            LaunchZebarDirectly();
        } catch {}
    }

    static void OpenScreenshot() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("ms-screenclip:") { UseShellExecute = true };
            Process.Start(psi);
        } catch {}
    }

    static void LockScreen() {
        try {
            Process.Start("rundll32.exe", "user32.dll,LockWorkStation");
        } catch {}
    }

    static void SleepPC() {
        try {
            Process.Start("rundll32.exe", "powrprof.dll,SetSuspendState 0,1,0");
        } catch {}
    }

    static void RestartPC() {
        try {
            Process.Start(new ProcessStartInfo("shutdown.exe", "/r /t 0") { CreateNoWindow = true, UseShellExecute = false });
        } catch {}
    }

    static void ShutdownPC() {
        try {
            Process.Start(new ProcessStartInfo("shutdown.exe", "/s /t 0") { CreateNoWindow = true, UseShellExecute = false });
        } catch {}
    }

    static void LogoffUser() {
        try {
            Process.Start(new ProcessStartInfo("shutdown.exe", "/l") { CreateNoWindow = true, UseShellExecute = false });
        } catch {}
    }

    static void OpenPowerMenu() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File \"D:\\Progetto\\scripts\\power-menu.ps1\"") {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            Process.Start(psi);
        } catch {
            OpenShutdownDialog();
        }
    }

    static void ToggleScratchpad() {
        try {
            IntPtr targetHwnd = IntPtr.Zero;
            EnumWindows((hWnd, lParam) => {
                if (!IsWindowVisible(hWnd)) return true;
                int len = GetWindowTextLength(hWnd);
                if (len == 0) return true;
                var sb = new System.Text.StringBuilder(len + 1);
                GetWindowText(hWnd, sb, sb.Capacity);
                string title = sb.ToString();
                if (title.IndexOf("43PR Scratchpad", StringComparison.OrdinalIgnoreCase) >= 0) {
                    targetHwnd = hWnd;
                    return false;
                }
                return true;
            }, IntPtr.Zero);

            if (targetHwnd != IntPtr.Zero) {
                IntPtr fore = GetForegroundWindow();
                if (fore == targetHwnd) {
                    ShowWindow(targetHwnd, 6); // SW_MINIMIZE
                } else {
                    BringWindowToFront(targetHwnd);
                }
            } else {
                string localApp = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string wtPath = Path.Combine(localApp, @"Microsoft\WindowsApps\wt.exe");
                ProcessStartInfo psi;
                if (File.Exists(wtPath)) {
                    psi = new ProcessStartInfo(wtPath, "--title \"43PR Scratchpad\" -p \"PowerShell\"") {
                        UseShellExecute = false
                    };
                } else {
                    psi = new ProcessStartInfo("powershell.exe", "-NoExit -Command \"$host.UI.RawUI.WindowTitle='43PR Scratchpad'\"") {
                        UseShellExecute = true
                    };
                }
                Process.Start(psi);
            }
        } catch {}
    }

    static void ToggleZenMode() {
        try {
            string flagPath = Path.Combine(Path.GetTempPath(), "43pr_zen_mode.flag");
            bool isZenMode = File.Exists(flagPath);

            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string gwmCli = Path.Combine(localAppData, @"Programs\glzr\bin\cli\glazewm.exe");

            if (isZenMode) {
                try { File.Delete(flagPath); } catch {}
                if (File.Exists(gwmCli)) {
                    ProcessStartInfo gwmPsi = new ProcessStartInfo(gwmCli, "command wm-toggle-pause") {
                        CreateNoWindow = true,
                        UseShellExecute = false
                    };
                    using (Process p = Process.Start(gwmPsi)) { if (p != null) p.WaitForExit(1500); }
                }
                LaunchZebarDirectly();
            } else {
                try { File.WriteAllText(flagPath, DateTime.UtcNow.ToString("o")); } catch {}
                if (File.Exists(gwmCli)) {
                    ProcessStartInfo gwmPsi = new ProcessStartInfo(gwmCli, "command wm-toggle-pause") {
                        CreateNoWindow = true,
                        UseShellExecute = false
                    };
                    using (Process p = Process.Start(gwmPsi)) { if (p != null) p.WaitForExit(1500); }
                }
                foreach (var p in Process.GetProcessesByName("zebar")) {
                    try { p.Kill(); } catch {}
                }
            }
        } catch {}
    }

    static void AutoDayNightTheme(bool waitForExit = false) {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("powershell.exe", "-ExecutionPolicy Bypass -WindowStyle Hidden -File \"D:\\Progetto\\scripts\\theme.ps1\" -Auto") {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            var proc = Process.Start(psi);
            if (waitForExit && proc != null) {
                proc.WaitForExit(10000);
            }
        } catch {}
    }

    static void RunScript(string scriptName) {
        try {
            string scriptPath = Path.Combine(@"D:\Progetto\scripts", scriptName);
            ProcessStartInfo psi = new ProcessStartInfo("powershell.exe", string.Format("-ExecutionPolicy Bypass -WindowStyle Hidden -File \"{0}\"", scriptPath)) {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            Process.Start(psi);
        } catch {}
    }

    static void OpenTaskManager() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("taskmgr.exe") { UseShellExecute = true };
            Process.Start(psi);
        } catch {}
    }

    static void OpenCalendar() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("ms-clock:") { UseShellExecute = true };
            Process.Start(psi);
        } catch {
            try {
                ProcessStartInfo psi2 = new ProcessStartInfo("ms-settings:dateandtime") { UseShellExecute = true };
                Process.Start(psi2);
            } catch {}
        }
    }

    static void BringWindowToFront(IntPtr hWnd) {
        if (hWnd == IntPtr.Zero) return;
        if (IsIconic(hWnd)) {
            ShowWindow(hWnd, 9); // SW_RESTORE
        } else {
            ShowWindow(hWnd, 5); // SW_SHOW
        }
        uint dummy;
        uint foreThread = GetWindowThreadProcessId(GetForegroundWindow(), out dummy);
        uint appThread = GetWindowThreadProcessId(hWnd, out dummy);
        if (foreThread != appThread) {
            AttachThreadInput(foreThread, appThread, true);
            SetForegroundWindow(hWnd);
            AttachThreadInput(foreThread, appThread, false);
        } else {
            SetForegroundWindow(hWnd);
        }
    }

    static void FocusMediaApp(string query) {
        try {
            IntPtr foundHwnd = IntPtr.Zero;

            if (!string.IsNullOrEmpty(query)) {
                string cleanQuery = Uri.UnescapeDataString(query).Trim().ToLower();
                if (!string.IsNullOrEmpty(cleanQuery)) {
                    EnumWindows((hWnd, lParam) => {
                        if (!IsWindowVisible(hWnd)) return true;
                        int len = GetWindowTextLength(hWnd);
                        if (len == 0) return true;
                        var sb = new System.Text.StringBuilder(len + 1);
                        GetWindowText(hWnd, sb, sb.Capacity);
                        string title = sb.ToString().ToLower();
                        if (title.Contains(cleanQuery)) {
                            foundHwnd = hWnd;
                            return false;
                        }
                        return true;
                    }, IntPtr.Zero);
                }
            }

            if (foundHwnd == IntPtr.Zero) {
                string[] knownProcesses = new string[] { "spotify", "vlc", "applemusic", "musicbee", "foobar2000", "tidal", "deezer", "aimp" };
                foreach (var pName in knownProcesses) {
                    var procs = Process.GetProcessesByName(pName);
                    foreach (var proc in procs) {
                        if (proc.MainWindowHandle != IntPtr.Zero && IsWindowVisible(proc.MainWindowHandle)) {
                            foundHwnd = proc.MainWindowHandle;
                            break;
                        }
                    }
                    if (foundHwnd != IntPtr.Zero) break;
                }
            }

            if (foundHwnd == IntPtr.Zero) {
                string[] browserProcesses = new string[] { "duckduckgo", "msedge", "chrome", "firefox", "brave", "opera", "vivaldi" };
                foreach (var bName in browserProcesses) {
                    var procs = Process.GetProcessesByName(bName);
                    foreach (var proc in procs) {
                        if (proc.MainWindowHandle != IntPtr.Zero && IsWindowVisible(proc.MainWindowHandle)) {
                            int len = GetWindowTextLength(proc.MainWindowHandle);
                            if (len > 0) {
                                var sb = new System.Text.StringBuilder(len + 1);
                                GetWindowText(proc.MainWindowHandle, sb, sb.Capacity);
                                string t = sb.ToString().ToLower();
                                if (t.Contains("youtube") || t.Contains("music") || t.Contains("sound") || t.Contains("spotify") || t.Contains("video")) {
                                    foundHwnd = proc.MainWindowHandle;
                                    break;
                                }
                            }
                        }
                    }
                    if (foundHwnd != IntPtr.Zero) break;
                }
            }

            if (foundHwnd != IntPtr.Zero) {
                BringWindowToFront(foundHwnd);
            }
        } catch {}
    }

    static void OpenNetworkSettings() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("ms-settings:network") { UseShellExecute = true };
            Process.Start(psi);
        } catch {}
    }

    static void OpenWeather() {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("https://www.google.com/search?q=meteo") { UseShellExecute = true };
            Process.Start(psi);
        } catch {}
    }

    static void Main(string[] args) {
        if (args.Length == 0) return;
        string action = args[0].ToLower();

        switch (action) {
            case "play":
            case "pause":
            case "toggle":
                PressKey(0xB3); // VK_MEDIA_PLAY_PAUSE
                break;
            case "next":
                PressKey(0xB0); // VK_MEDIA_NEXT_TRACK
                break;
            case "prev":
                PressKey(0xB1); // VK_MEDIA_PREV_TRACK
                break;
            case "focus_media":
            case "focus_player":
                string query = args.Length > 1 ? args[1] : "";
                FocusMediaApp(query);
                break;
            case "vol_up":
                PressKey(0xAF); // VK_VOLUME_UP
                break;
            case "vol_down":
                PressKey(0xAE); // VK_VOLUME_DOWN
                break;
            case "mute":
                PressKey(0xAD); // VK_VOLUME_MUTE
                break;
            case "sound_panel":
            case "sound_settings":
                OpenAudioSettings();
                break;
            case "switch_audio":
            case "cycle_audio":
                SwitchAudioDevice();
                break;
            case "toggle_taskbar":
                ToggleTaskbar();
                break;
            case "shutdown_dialog":
            case "power":
                OpenShutdownDialog();
                break;
            case "power_menu":
            case "wlogout":
                OpenPowerMenu();
                break;
            case "sleep":
            case "suspend":
                SleepPC();
                break;
            case "restart_pc":
            case "reboot":
                RestartPC();
                break;
            case "shutdown_pc":
            case "poweroff":
                ShutdownPC();
                break;
            case "logoff":
            case "signout":
                LogoffUser();
                break;
            case "toggle_scratchpad":
            case "scratchpad":
                ToggleScratchpad();
                break;
            case "zen_mode":
            case "gaming_mode":
            case "toggle_zen":
                ToggleZenMode();
                break;
            case "auto_theme":
            case "day_night":
                AutoDayNightTheme();
                break;
            case "clipboard":
            case "clip":
                RunScript("clipboard-manager.ps1");
                break;
            case "window_switcher":
            case "windows":
            case "switcher":
                RunScript("window-switcher.ps1");
                break;
            case "color_picker":
            case "picker":
            case "eyedropper":
                RunScript("color-picker.ps1");
                break;
            case "calc":
            case "calculator":
                RunScript("calc-launcher.ps1");
                break;
            case "sensors":
            case "hud":
                RunScript("sensors-hud.ps1");
                break;
            case "cheatsheet":
                OpenCheatsheet();
                break;
            case "startup":
            case "startup_bar":
                StartupZebar();
                break;
            case "update_deps":
            case "update_bar_deps":
                UpdateDependencies(true);
                break;
            case "restart_bar":
            case "restart_zebar":
                RestartZebar();
                break;
            case "screenshot":
            case "screenclip":
            case "snipping":
                OpenScreenshot();
                break;
            case "lock":
            case "lock_screen":
                LockScreen();
                break;
            case "taskmgr":
            case "task_manager":
                OpenTaskManager();
                break;
            case "calendar":
            case "clock":
                OpenCalendar();
                break;
            case "network":
            case "network_settings":
                OpenNetworkSettings();
                break;
            case "weather":
            case "meteo":
                OpenWeather();
                break;
        }
    }
}
