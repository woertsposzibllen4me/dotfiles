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

; Scoreboard
!f::!j

!x:: {
  Send "{Alt up}"
  Send "{u}"
}

; Illu rune
!a::!5
!s::!6

!^Right:: {
  Send "{Enter}"
  Send "-teleport"
  Send "{Enter}"
}

!^Left:: {
  Send "{Enter}"
  Send "-startgame"
  Send "{Enter}"
}

!^Down:: {
  Send "{Enter}"
  Send "-item obs"
  Send "{Enter}"
}

; Shop
!w::F11
