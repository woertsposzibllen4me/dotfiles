#SingleInstance Force
A_MaxHotkeysPerInterval := 99999
SettitleMatchMode 1
SendMode "Event"
SetWorkingDir A_ScriptDir
TraySetIcon "icons\dota2.png"


#HotIf WinActive("ahk_exe Dota 2.exe") or WinActive("ahk_exe deadlock.exe")
`::=
CapsLock::-
LWin::0

; Keep vim style up/down navigtion
!j:: Send "{Down}"
!k:: Send "{Up}"

waitshort() {
  Sleep 80
}

waitlong() {
  Sleep 250
}

!Up:: {
  ; open settings menu
  Send "{Escape}"
  MouseMove 220, 870
  waitshort()
  Click

  ; goto keybinds
  MouseMove 880, 100
  waitshort()
  Click

  ; scroll down to quickbuy setting
  MouseMove 850, 570
  waitshort()
  MouseClick "WheelDown", , , 15
  waitlong()

  ; bind 1
  Click
  waitshort()
  Send "{Alt down}"
  waitshort()
  MouseClick "WheelUp"
  waitshort()
  Send "{Alt up}"
  waitshort()

  ; move to alt bind
  MouseMove 1070, 570
  MouseClick "WheelDown", , , 1
  waitlong()

  ; bind 2
  Click
  Send "{Alt down}"
  waitshort()
  MouseClick "WheelDown"
  waitshort()
  Send "{Alt up}"

  ; exit
  waitshort()
  Send "{Escape}"
  Send "{Escape}"
}

#HotIf WinActive('Dota 2')
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

#HotIf
