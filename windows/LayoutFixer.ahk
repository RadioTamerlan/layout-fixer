; Layout Fixer — QWERTY <-> ЙЦУКЕН converter for the currently selected text.
; Hotkey: Ctrl+Shift+S (Windows equivalent of Cmd+S on the Mac build).
;
; Requires AutoHotkey v2.0  (https://www.autohotkey.com/)
; Compile to .exe via Ahk2Exe (bundled with AutoHotkey).
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ---------------------------------------------------------------------------
; Keyboard mapping (QWERTY -> ЙЦУКЕН). Reverse is generated automatically.
; ---------------------------------------------------------------------------
enToRu := Map(
    "q","й", "w","ц", "e","у", "r","к", "t","е", "y","н", "u","г",
    "i","ш", "o","щ", "p","з", "[","х", "]","ъ",
    "a","ф", "s","ы", "d","в", "f","а", "g","п", "h","р", "j","о",
    "k","л", "l","д", ";","ж", "'","э",
    "z","я", "x","ч", "c","с", "v","м", "b","и", "n","т", "m","ь",
    ",","б", ".","ю",
    "Q","Й", "W","Ц", "E","У", "R","К", "T","Е", "Y","Н", "U","Г",
    "I","Ш", "O","Щ", "P","З", "{","Х", "}","Ъ",
    "A","Ф", "S","Ы", "D","В", "F","А", "G","П", "H","Р", "J","О",
    "K","Л", "L","Д", ":","Ж", "`"","Э",
    "Z","Я", "X","Ч", "C","С", "V","М", "B","И", "N","Т", "M","Ь",
    "<","Б", ">","Ю"
)
ruToEn := Map()
for k, v in enToRu
    ruToEn[v] := k

; ---------------------------------------------------------------------------
; Tray menu + auto-start on login
; ---------------------------------------------------------------------------
A_IconTip := "Layout Fixer — Ctrl+Shift+S to convert selection"

tray := A_TrayMenu
tray.Delete()
tray.Add("Layout Fixer", (*) => "")
tray.Disable("Layout Fixer")
tray.Add()
tray.Add("Convert Selection`tCtrl+Shift+S", (*) => ConvertSelection())
tray.Add()
tray.Add("Launch at Startup", (*) => ToggleStartup())
tray.Add()
tray.Add("Quit", (*) => ExitApp())
UpdateStartupCheck()

; Seed the startup shortcut on first launch so the app runs on boot.
if !FileExist(StartupPath()) && !FileExist(A_AppData "\LayoutFixer.seeded") {
    EnableStartup()
    FileAppend "1", A_AppData "\LayoutFixer.seeded"
    UpdateStartupCheck()
}

; ---------------------------------------------------------------------------
; Hotkey
; ---------------------------------------------------------------------------
^+s::ConvertSelection()

ConvertSelection() {
    global enToRu, ruToEn

    oldClip := ClipboardAll()
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(0.3) {
        A_Clipboard := oldClip
        return
    }

    sel := A_Clipboard
    if sel = "" {
        A_Clipboard := oldClip
        return
    }

    converted := AutoConvert(sel, enToRu, ruToEn)
    if converted = sel {
        A_Clipboard := oldClip
        return
    }

    A_Clipboard := converted
    Send "^v"
    Sleep 120
    A_Clipboard := oldClip
}

AutoConvert(text, enToRu, ruToEn) {
    latin := 0, cyr := 0
    Loop Parse, text {
        c := Ord(A_LoopField)
        if (c >= 0x41 && c <= 0x7A)
            latin++
        else if (c >= 0x0400 && c <= 0x04FF)
            cyr++
    }
    if latin = 0 && cyr = 0
        return text
    map := (latin >= cyr) ? enToRu : ruToEn
    out := ""
    Loop Parse, text {
        ch := A_LoopField
        out .= map.Has(ch) ? map[ch] : ch
    }
    return out
}

; ---------------------------------------------------------------------------
; Startup shortcut helpers
; ---------------------------------------------------------------------------
StartupPath() {
    return A_Startup "\LayoutFixer.lnk"
}

EnableStartup() {
    target := A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    args := A_IsCompiled ? "" : '"' A_ScriptFullPath '"'
    FileCreateShortcut target, StartupPath(), A_ScriptDir, args, "Layout Fixer"
}

DisableStartup() {
    path := StartupPath()
    if FileExist(path)
        FileDelete path
}

ToggleStartup() {
    if FileExist(StartupPath())
        DisableStartup()
    else
        EnableStartup()
    UpdateStartupCheck()
}

UpdateStartupCheck() {
    if FileExist(StartupPath())
        A_TrayMenu.Check("Launch at Startup")
    else
        A_TrayMenu.Uncheck("Launch at Startup")
}
