#SingleInstance force
#MaxHotkeysPerInterval 50000
SetTitleMatchMode, 3
#ifWinActive, Warcraft III
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, icons\wc3.png
SendMode Event

; Configure togglable mouse wheel binding for +/- keys for ez replay scrubbing (Toggle off to avoid changing game speed in customs)
WheelEnabled := false
+Space::Send, p
WheelUp::
    if WheelEnabled
        Send, =
    else
        return
return

WheelDown::
    if WheelEnabled
        Send, -
    else
        return
return

End::
    WheelEnabled := !WheelEnabled
    if WheelEnabled
        ToolTip, Wheel Enabled: Bound to +/- keys, 0, 0
    else
        ToolTip, Wheel Disabled, 0, 0
    SetTimer, RemoveToolTip, 2000
return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

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
g::0
XButton2::l


; This whole mess is to fix an issue with keypress displayers when pressing and releasing the mouse button and the letter key in a weird unusual order
MButton::
  SendInput {a up}{s up}{d up}{f up}{c up}
  SendInput {MButton down}
return

MButton up::
  SendInput {MButton up}
return

a up::
  SendInput {5 up}
  SendInput {a up}
return

s up::
  SendInput {6 up}
  SendInput {s up}
return

d up::
  SendInput {7 up}
  SendInput {d up}
return

f up::
  SendInput {8 up}
  SendInput {f up}
return

c up::
  SendInput {9 up}
  SendInput {c up}
return

a::a
s::s
d::d
f::f
c::c

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
