#Persistent
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
#IfWinActive, osu!
#MaxHotkeysPerInterval 500

; Configuration
global RequireMouseMode := 1      ; 1=Mouse4+A/D mode, 0=direct keys
global UseAutoSwitch := 1         ; 1=auto switch, 0=stay in one mode
global MinTime := 4000
global MaxTime := 8000

; Start auto-switching if enabled
if (UseAutoSwitch)
    SetTimer, SwitchMode, % Random(MinTime, MaxTime)

; Hotkeys
a::
    if (!RequireMouseMode)
        SendEvent {a DownTemp}
    return
a up::
    if (!RequireMouseMode)
        SendEvent {a up}
    return

d::
    if (!RequireMouseMode)
        SendEvent {d DownTemp}
    return
d up::
    if (!RequireMouseMode)
        SendEvent {d up}
    return

XButton1 & a::
    if (RequireMouseMode)
        SendEvent {a DownTemp}
    return
XButton1 & a up::
    if (RequireMouseMode)
        SendEvent {a up}
    return

XButton1 & d::
    if (RequireMouseMode)
        SendEvent {d DownTemp}
    return
XButton1 & d up::
    if (RequireMouseMode)
        SendEvent {d up}
    return

XButton1::return

; Toggle auto-switching with F12
F12::
    UseAutoSwitch := !UseAutoSwitch
    if (UseAutoSwitch) {
        SetTimer, SwitchMode, % Random(MinTime, MaxTime)
        SoundPlay, %A_WinDir%\Media\Windows Notify Calendar.wav
    } else {
        SetTimer, SwitchMode, Off
        RequireMouseMode := 1  ; Force to mouse mode when disabling auto-switch
        SoundPlay, %A_WinDir%\Media\Windows Notify.wav
    }
    return

SwitchMode:
    RequireMouseMode := !RequireMouseMode
    if (RequireMouseMode)
        SoundPlay, %A_WinDir%\Media\Windows Notify System Generic.wav
    else
        SoundPlay, %A_WinDir%\Media\Windows Notify Email.wav
    SetTimer, SwitchMode, % Random(MinTime, MaxTime)
return

Random(min, max) {
    Random, value, min, max
    return value
}

