#SingleInstance Force
A_MaxHotkeysPerInterval := 500
#HotIf WinActive("Dota 2")
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
TraySetIcon "icons\dota2.png"
LWin::=
CapsLock::-
`::0
XButton1::Alt ; to be improved tbh with some better combo based implementation
XButton2::XButton1 ; This is to keep backwards menu navigation working, using mouse 5 instead of mouse 4
