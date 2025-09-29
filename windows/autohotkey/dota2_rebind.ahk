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

; Cam pos
!q::!Ins ; mid
!d::!Home ; top
!c::!PgUp ; bot
!e::!End ; fountain

; Armlet toggle
!a:: {
  Send "{Alt up}"
  Send "{g}"
}
!s:: {
  Send "{Alt up}"
  Send "{g}"
}

; Illu rune
!z::!5
!x::!6

; Shop
!w::F11
