; screen-mask helper untuk Windows (AutoHotkey v2)
;
; - Ganti ikon jendela Claude (title bar, taskbar, Alt+Tab) dengan chat.ico
; - Ganti judul jendela jadi "Chat"
; - Ctrl+Shift+Spasi : minimize / munculkan lagi jendela Claude
; - Ctrl+Shift+H     : sembunyikan total (hilang dari taskbar) / munculkan lagi
;
; Aplikasinya tetap berjalan; tidak ada yang ditutup.
; Taruh file ini satu folder dengan chat.ico, lalu klik dua kali.

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TARGET := "ahk_exe claude.exe"
NEW_TITLE := "Chat"
ICON_FILE := A_ScriptDir "\chat.ico"

WM_SETICON := 0x80
hidden := []

if !FileExist(ICON_FILE) {
    MsgBox "chat.ico tidak ditemukan di " A_ScriptDir
    ExitApp
}

hSmall := LoadPicture(ICON_FILE, "Icon1 w16 h16", &t1)
hBig := LoadPicture(ICON_FILE, "Icon1 w32 h32", &t2)

TraySetIcon ICON_FILE
A_IconTip := "Chat helper"

ApplyMask() {
    global hSmall, hBig
    for id in WinGetList(TARGET) {
        try {
            if WinGetTitle("ahk_id " id) = ""
                continue
            SendMessage WM_SETICON, 0, hSmall, , "ahk_id " id
            SendMessage WM_SETICON, 1, hBig, , "ahk_id " id
            if WinGetTitle("ahk_id " id) != NEW_TITLE
                WinSetTitle NEW_TITLE, "ahk_id " id
        }
    }
}

; Claude bisa mengembalikan judul/ikonnya, jadi dipasang ulang tiap detik.
SetTimer ApplyMask, 1000
ApplyMask()

; Ctrl+Shift+Spasi: minimize / restore
^+Space:: {
    if !WinExist(TARGET)
        return
    if WinGetMinMax(TARGET) = -1 {
        WinRestore TARGET
        WinActivate TARGET
    } else {
        WinMinimize TARGET
    }
}

; Ctrl+Shift+H: sembunyikan total / munculkan
^+h:: {
    global hidden
    if hidden.Length {
        ShowHidden()
        return
    }
    for id in WinGetList(TARGET) {
        if WinGetTitle("ahk_id " id) = ""
            continue
        WinHide "ahk_id " id
        hidden.Push(id)
    }
}

ShowHidden() {
    global hidden
    DetectHiddenWindows true
    for id in hidden {
        try {
            WinShow "ahk_id " id
            WinActivate "ahk_id " id
        }
    }
    DetectHiddenWindows false
    hidden := []
}

; Kalau script ditutup, jendela yang disembunyikan dimunculkan lagi.
OnExit (*) => ShowHidden()
