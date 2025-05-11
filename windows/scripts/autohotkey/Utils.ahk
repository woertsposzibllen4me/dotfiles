#SingleInstance Force
A_MaxHotkeysPerInterval := 3000
SendMode "Input"
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
TraySetIcon "icons\utils.png"

; Ctrl + Shift + Alt + \ to replace backslashes with forward slashes
^+!\:: {
  A_Clipboard := ClipboardAll() ; Save the original clipboard content
  Sleep 50 ; Small delay to ensure clipboard content is ready
  A_Clipboard := RegExReplace(A_Clipboard, "\\", "/") ; Replace backslashes with forward slashes
}

;Alt + Ctrl + Shift + I to send a left mouse click
!^+i:: {
  Click ; Sends a left mouse click at the current mouse position (using with tobi eye tracker)
}

; Ctrl + Alt + Shift + G to switch to an open Git Bash window
^!+g:: {
  if WinExist("ahk_class mintty") {
    WinActivate
  } else {
    Run "C:\Program Files\Git\git-bash.exe"
  }
}

; Ctrl + Alt + Shift + P to get to a PowerShell window
^!+p:: {
  SetTitleMatchMode 2  ; Allows partial matching of window titles
  ; Try to find an existing PowerShell window
  if WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS") {
    WinActivate
    return
  }
  ; If no PowerShell window is found, start a new one
  Run "pwsh"
}

; Ctrl + Alt + Shift + A to open or focus an admin PowerShell window
^!+a:: {
  adminTitle := "Administrator: C:\Program Files\PowerShell\7\pwsh.exe"
  selectAdminTitle := "Select " . adminTitle

  ; Check if the regular window exists
  if WinExist(adminTitle) {
    WinActivate adminTitle
  }
  ; Check if the window exists in selection mode
  else if WinExist(selectAdminTitle) {
    WinActivate selectAdminTitle
  }
  ; If neither exists, open a new admin PowerShell
  else {
    Run "*RunAs pwsh.exe"
  }
}

; Ctrl + Alt + Shift + L to switch to an open WSL window or start a new one
^!+l:: {
  SetTitleMatchMode 2
  if WinExist("crazyfrogdog@DEKSTOP-69URSS") {
    WinActivate
  } else {
    ; If no WSL terminal is open, start a new one
    Run "bash.exe"
  }
}

; Ctrl + Alt + Shift + J to switch to an open Chrome window or start a new one
^!+j:: {
  SetTitleMatchMode 2
  if WinExist("ahk_exe chrome.exe") {
    WinActivate "ahk_exe chrome.exe"
  } else {
    Run "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  }
}

; Rebind Alt+J, Alt+K, Alt+H, and Alt+L to arrow keys
!j::Down
!k::Up
!h::Left
!l::Right

; Rebind C-; to c-\ in wezterm
#HotIf WinActive("Wezterm")
^;::^\
#HotIf

; Ctrl + Alt + Shift + K to switch to an open WezTerm window or start a new one
^!+k:: {
  SetTitleMatchMode 3 ; Exact match mode to avoid issues with browser tab names etc.
  primaryPath := "C:\Users\ville\scoop\apps\wezterm-nightly\current\wezterm-gui.exe"
  fallbackPath := "C:\Users\ville\scoop\shims\wezterm - gui.exe"
  if WinExist("Wezterm") {
    WinActivate
  } else {
    if FileExist(primaryPath) {
      Run primaryPath
    } else if FileExist(fallbackPath) {
      Run fallbackPath
    } else {
      MsgBox "Could not find WezTerm executable at either path."
    }
  }
}

; Ctrl + Alt + Shift + V to switch to an open VS Code window or start a new one
^!+v:: {
  SetTitleMatchMode 2
  if WinExist("ahk_exe Code.exe") {
    WinActivate
  } else {
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
  }
}

; Ctrl + Alt + Shift + X to switch to an open Explorer window or start a new one
^!+x:: {
  if WinExist("ahk_class CabinetWClass") {
    WinActivate
  } else {
    Run "explorer.exe"
  }
}

; Ctrl + Alt + Shift + N to switch to an open Neo4j window or start a new one
^!+n:: {
  SetTitleMatchMode 2
  if WinExist("neo4j@bolt://localhost:7687") {
    WinActivate
  } else {
    Run "C:\Users\ville\AppData\Local\Programs\Neo4j Desktop\Neo4j Desktop.exe"
  }
}

; Ctrl + Alt + Shift + M to send a messages
^!+m:: {
  nextKey := InputHook("L1")
  nextKey.Start()
  nextKey.Wait()
  if (nextKey.Input = "m") {
    SendText "Please only send back a minimal amount of code"
  }
}

; Unbind esc and use capslock for it instead as long as not in specific games
#HotIf !WinActive("ahk_exe dota2.exe") and !WinActive("Warcraft III")
; and !WinActive("ahk_exe SC2.exe") and !WinActive("Deadlock") (comment out unplayed games for efficiency)
CapsLock::Esc
Esc::CapsLock
#HotIf
