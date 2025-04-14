#SingleInstance force
#MaxHotkeysPerInterval 50000
SetTitleMatchMode, 3
#ifWinActive, Warcraft III
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, icons\wc3.png
SendMode Event

; Disable Mouse Wheel zoom and use it to scrub replays ( Pause/Play with Shift+Space )
WheelUp::=
WheelDown::-
+Space::p

; Disable some alt combos temporarily
!q::return
!a::return
!s::return
!d::return
!f::return
!c::return
!v::return
^s::return

; Inactive peons/Town hall navigation
`::F8
CapsLock::BackSpace

; Control groups
XButton1 & a::5
XButton1 & s::6
XButton1 & d::7
XButton1 & f::8
XButton1 & c::9
XButton1 & v::0
g::0
XButton2::l


; Custom game quick cheats setup
Home::
{
    Send, {Enter}
    Send, greedisgood 900000
    Send, {Enter}

    Send, {Enter}
    Send, pointbreak
    Send, {Enter}

    Send, {Enter}
    Send, warpten
    Send, {Enter}

    Send, {Enter}
    Send, synergy
    Send, {Enter}

    Send, {Enter}
    Send, iocainepowder
    Send, {Enter}

    Send, {Enter}
    Send, Thereisnospoon
    Send, {Enter}
    return
}

!Home::
{
    Send, {Enter}
    Send, whosyourdaddy
    Send, {Enter}
    return
}

+Home::
{
    Send, {Enter}
    Send, warpten
    Send, {Enter}
    return
}

^Home::
{
    Send, {Enter}
    Send, thedudeabides
    Send, {Enter}

    Send, {Enter}
    Send, thedudeabides
    Send, {Enter}
    return
}

^+Home::
{
    Send, {Enter}
    Send, daylightsavings
    Send, {Space}
    return
}
