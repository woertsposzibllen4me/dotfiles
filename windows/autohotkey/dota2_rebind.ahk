#SingleInstance Force
A_MaxHotkeysPerInterval := 99999
SendMode "Event"
SetWorkingDir A_ScriptDir
TraySetIcon "icons\dota2.png"

#HotIf WinActive("Dota 2")
`::Insert
CapsLock::Home
LWin::Delete

; Keep vim style up/down navigtion for the shop
!j:: Send "{Down}"
!k:: Send "{Up}"

;==========================================
;Camera experimental combos start
;==========================================
!q::!F10
!w::!F11
!e::!F13
!a::!F14
!s::!F15
!d::!F16
!z::!F17
!x::!F18
!c::!F19
!CapsLock::!F20

; To be able to actually create the mappings in the IG menu
Ins::F13
Home::F14
PGUp::F15
Del::F16
End::F17
PgDn::F18

; We do not bind up/down arrows to avoid conflict with shop navigation
Left::F19
Right::F20
;==========================================
;Camera experimental combos end
;==========================================
