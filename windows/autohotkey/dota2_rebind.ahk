#SingleInstance Force
A_MaxHotkeysPerInterval := 500
SetWorkingDir A_ScriptDir
TraySetIcon "icons\dota2.png"

#HotIf WinActive("Dota 2")
LWin::=
CapsLock::-

; XButton1 + specific keys = Alt + those keys
XButton1 & z::!z
XButton1 & x::!x
XButton1 & c::!c
XButton1 & v::!v
XButton1 & b::!b
XButton1 & g::!g
XButton1 & 1::!1
XButton1 & 2::!2
XButton1 & 3::!3
XButton1 & 4::!4
XButton1 & 5::!5
XButton1 & 6::!6
XButton1 & `::!`
XButton1 & F1::!F1
XButton1::XButton1
