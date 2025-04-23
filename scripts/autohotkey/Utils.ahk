#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#MaxHotkeysPerInterval 3000
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Menu, Tray, Icon, icons\utils.png

^+!\:: ; Ctrl + Shift + Alt + \ to replace backslashes with forward slashes
Clipboard := ClipboardAll ; Save the original clipboard content
Sleep 50 ; Small delay to ensure clipboard content is ready
StringReplace, Clipboard, Clipboard, \, /, All ; Replace backslashes with forward slashes
return

!^+i::
Click ; Sends a left mouse click at the current mouse position (using with tobi eye tracker)
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
    WinActivate
    return
}
; If no PowerShell window is found, start a new one
Run, pwsh.exe
return

; Ctrl + Alt + Shift + A to open or focus an admin PowerShell window
^!+a::
{
    adminTitle := "Administrator: C:\Program Files\PowerShell\7\pwsh.exe"
    selectAdminTitle := "Select " . adminTitle

    ; Check if the regular window exists
    if WinExist(adminTitle)
    {
        WinActivate, %adminTitle%
    }
    ; Check if the window exists in selection mode
    else if WinExist(selectAdminTitle)
    {
        WinActivate, %selectAdminTitle%
    }
    ; If neither exists, open a new admin PowerShell
    else
    {
        Run *RunAs pwsh.exe
    }
}
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
    Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}
return

; Rebind Alt+J, Alt+K, Alt+H, and Alt+L to arrow keys
!j::Send {Down}
!k::Send {Up}
!h::Send {Left}
!l::Send {Right}


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


; Ctrl + Alt + Shift + X to switch to an open Explorer window or start a new one
^!+x::
if WinExist("ahk_class CabinetWClass")
{
    WinActivate
}
else
{
    Run, explorer.exe
}
return


; Ctrl + Alt + Shift + N to switch to an open Neo4j window or start a new one
^!+n::
SetTitleMatchMode, 2
IfWinExist neo4j@bolt://localhost:7687
{
    WinActivate
}
else
{
    Run, "C:\Users\ville\AppData\Local\Programs\Neo4j Desktop\Neo4j Desktop.exe"
}
return

; Unbind esc and use capslock for it instead as long as not in Dota or some game where I bind caps.
#If !WinActive("ahk_exe dota2.exe")and !WinActive("Warcraft III")
; and !WinActive("ahk_exe SC2.exe") and !WinActive("Deadlock") (comment out unplayed games for efficiency)
CapsLock::Esc
Esc::CapsLock
#If
