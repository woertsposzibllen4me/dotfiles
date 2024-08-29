#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Menu, Tray, Icon, icons\utils.png

^+!\:: ; Ctrl + Shift + Alt + \ to replace backslashes with forward slashes
Clipboard := ClipboardAll ; Save the original clipboard content
Sleep 50 ; Small delay to ensure clipboard content is ready
StringReplace, Clipboard, Clipboard, \, /, All ; Replace backslashes with forward slashes
return

; Ctrl + Alt + Shift + G to switch to an open Git Bash window
^!+g::
IfWinExist, ahk_class mintty
{
    WinActivate
}
else
{
    Run, "C:\Program Files\Git\git-bash.exe"
}
return


; Ctrl + Alt + Shift + P to get to a PowerShell window
+^!p::
SetTitleMatchMode, 2  ; Allows partial matching of window titles
; Try to find an existing PowerShell window
IfWinExist, ahk_class CASCADIA_HOSTING_WINDOW_CLASS
{
    WinActivate  ; Activate the found window
    return
}
; If no PowerShell window is found, start a new one
Run, pwsh.exe
return

; Ctrl + Alt + Shift + A to open a PowerShell window w/ admin mode
+^!a::
Run *RunAs pwsh.exe
return

; Ctrl + Alt + Shift + L to switch to an open WSL window or start a new one
^!+l::
SetTitleMatchMode, 2

IfWinExist, crazyfrogdog@DEKSTOP-69URSS
{
    WinActivate
}
else
{
    ; If no WSL terminal is open, start a new one
    Run, bash.exe
}
return

; Ctrl + Alt + Shift + J to switch to an open Chrome window or start a new one
^!+j::
SetTitleMatchMode, 2
IfWinExist, ahk_exe chrome.exe
{
    WinActivate, ahk_exe chrome.exe
}
else
{
    Run, "C:\Program Files\Google\Chrome\Application\chrome.exe"
}
return


; Ctrl + Alt + Shift + K to switch to an open WezTerm window or start a new one
^!+k::
SetTitleMatchMode, 1

IfWinExist, Wezterm
{
    WinActivate
}
else
{
    Run, "C:\Program Files\WezTerm\wezterm-gui.exe"
}
return

; Ctrl + Alt + Shift + V to switch to an open VS Code window or start a new one
^!+v::
SetTitleMatchMode, 2
IfWinExist, ahk_exe Code.exe
{
    WinActivate
}
else
{
    Run, "C:\Users\%A_UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe"
}
return


^!+e::
; Check if an Explorer window exists
if WinExist("ahk_class CabinetWClass")
{
    ; If it exists, activate (focus) it
    WinActivate
}
else
{
    ; If no Explorer window is found, open a new one
    Run, explorer.exe
}
return


; Unbind esc and use capslock for it instead as long as not in Dota or some game where I bind caps.
#If !WinActive("ahk_exe dota2.exe")
CapsLock::Esc
Esc::CapsLock
#If
