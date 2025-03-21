#SingleInstance force
#MaxHotkeysPerInterval 500
#ifWinActive, Dota 2
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Menu, Tray, Icon, icons\dota2.png


LWin::=
CapsLock::-
`::0
XButton1::Alt
XButton2::XButton1 ; This is to keep backwards menu navigation working, using mouse 5 instead of mouse 4


