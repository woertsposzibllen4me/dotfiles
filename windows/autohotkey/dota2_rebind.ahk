#SingleInstance Force
A_MaxHotkeysPerInterval := 99999
SettitleMatchMode 1
SendMode "Event"
SetWorkingDir A_ScriptDir
TraySetIcon "icons\dota2.png"

#HotIf WinActive("Dota 2")
`::=
CapsLock::-
LWin::0

; Keep vim style up/down navigtion for the shop
!j:: Send "{Down}"
!k:: Send "{Up}"

; !q::9
; !w::Backspace

; Cam pos
!e::!Ins ; mid
!d::!Home ; safe
!f::!PgUp ; off
!v::!End ; fountain

; Illu rune
!z::!5
!x::!6

; Shop
!q::F11
