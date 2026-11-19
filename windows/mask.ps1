# screen-mask helper untuk Windows, tanpa AutoHotkey dan tanpa admin.
#
# - Ganti ikon jendela Claude (title bar, taskbar, Alt+Tab) dengan settings.ico
# - Ganti judul jendela jadi "Settings"
# - Ctrl+Shift+Spasi : minimize / munculkan lagi jendela Claude
# - Ctrl+Shift+H     : sembunyikan total (hilang dari taskbar) / munculkan lagi
# - Ctrl+Shift+Q     : matikan helper ini (jendela yang disembunyikan muncul lagi)
#
# Jalankan: klik kanan > Run with PowerShell
# atau tanpa jendela: powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File mask.ps1

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$icon = Join-Path $here 'settings.ico'
if (-not (Test-Path $icon)) { throw "settings.ico tidak ditemukan di $here" }

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public static class ScreenMask
{
    [StructLayout(LayoutKind.Sequential)]
    struct MSG { public IntPtr hwnd; public uint message; public IntPtr wParam; public IntPtr lParam; public uint time; public int x; public int y; }

    delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr hWnd, int id, uint mods, uint vk);
    [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr hWnd, int id);
    [DllImport("user32.dll")] static extern int GetMessage(out MSG msg, IntPtr hWnd, uint min, uint max);
    [DllImport("user32.dll")] static extern IntPtr SetTimer(IntPtr hWnd, IntPtr id, uint ms, IntPtr fn);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc fn, IntPtr lParam);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] static extern IntPtr GetWindow(IntPtr hWnd, uint cmd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr hWnd, StringBuilder s, int max);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern bool SetWindowText(IntPtr hWnd, string s);
    [DllImport("user32.dll")] static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr hWnd, int cmd);
    [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr LoadImage(IntPtr hInst, string name, uint type, int cx, int cy, uint flags);

    const uint MOD_CONTROL = 0x2, MOD_SHIFT = 0x4, MOD_NOREPEAT = 0x4000;
    const uint WM_HOTKEY = 0x0312, WM_TIMER = 0x0113, WM_SETICON = 0x80;
    const int SW_HIDE = 0, SW_SHOW = 5, SW_MINIMIZE = 6, SW_RESTORE = 9;

    static IntPtr small, big;
    static string title;
    static List<IntPtr> hidden = new List<IntPtr>();

    static string TextOf(IntPtr h)
    {
        StringBuilder sb = new StringBuilder(256);
        GetWindowText(h, sb, 256);
        return sb.ToString();
    }

    static List<IntPtr> ClaudeWindows()
    {
        HashSet<uint> pids = new HashSet<uint>();
        foreach (Process p in Process.GetProcessesByName("claude")) pids.Add((uint)p.Id);
        List<IntPtr> found = new List<IntPtr>();
        EnumWindows(delegate (IntPtr h, IntPtr l)
        {
            uint pid;
            GetWindowThreadProcessId(h, out pid);
            if (pids.Contains(pid) && IsWindowVisible(h) && GetWindow(h, 4) == IntPtr.Zero && TextOf(h).Length > 0)
                found.Add(h);
            return true;
        }, IntPtr.Zero);
        return found;
    }

    static void Apply()
    {
        foreach (IntPtr h in ClaudeWindows())
        {
            SendMessage(h, WM_SETICON, (IntPtr)0, small);
            SendMessage(h, WM_SETICON, (IntPtr)1, big);
            if (TextOf(h) != title) SetWindowText(h, title);
        }
    }

    static void ToggleMinimize()
    {
        foreach (IntPtr h in ClaudeWindows())
        {
            if (IsIconic(h)) { ShowWindow(h, SW_RESTORE); SetForegroundWindow(h); }
            else ShowWindow(h, SW_MINIMIZE);
        }
    }

    static void ToggleHide()
    {
        if (hidden.Count > 0) { ShowHidden(); return; }
        foreach (IntPtr h in ClaudeWindows()) { ShowWindow(h, SW_HIDE); hidden.Add(h); }
    }

    public static void ShowHidden()
    {
        foreach (IntPtr h in hidden) { ShowWindow(h, SW_SHOW); SetForegroundWindow(h); }
        hidden.Clear();
    }

    public static void Run(string iconPath, string newTitle)
    {
        title = newTitle;
        small = LoadImage(IntPtr.Zero, iconPath, 1, 16, 16, 0x10);
        big = LoadImage(IntPtr.Zero, iconPath, 1, 32, 32, 0x10);

        uint mods = MOD_CONTROL | MOD_SHIFT | MOD_NOREPEAT;
        if (!RegisterHotKey(IntPtr.Zero, 1, mods, 0x20)) Console.WriteLine("Ctrl+Shift+Spasi sudah dipakai aplikasi lain.");
        if (!RegisterHotKey(IntPtr.Zero, 2, mods, 0x48)) Console.WriteLine("Ctrl+Shift+H sudah dipakai aplikasi lain.");
        RegisterHotKey(IntPtr.Zero, 3, mods, 0x51);
        SetTimer(IntPtr.Zero, IntPtr.Zero, 1000, IntPtr.Zero);
        Apply();

        try
        {
            MSG msg;
            while (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0)
            {
                if (msg.message == WM_TIMER) Apply();
                else if (msg.message == WM_HOTKEY)
                {
                    int id = msg.wParam.ToInt32();
                    if (id == 1) ToggleMinimize();
                    else if (id == 2) ToggleHide();
                    else if (id == 3) break;
                }
            }
        }
        finally
        {
            ShowHidden();
            UnregisterHotKey(IntPtr.Zero, 1);
            UnregisterHotKey(IntPtr.Zero, 2);
            UnregisterHotKey(IntPtr.Zero, 3);
        }
    }
}
'@

Write-Host "Helper aktif. Ctrl+Shift+Spasi = minimize, Ctrl+Shift+H = sembunyikan, Ctrl+Shift+Q = keluar."
[ScreenMask]::Run($icon, 'Settings')
