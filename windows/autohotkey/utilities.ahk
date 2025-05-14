#SingleInstance Force
A_MaxHotkeysPerInterval := 3000
SendMode "Input"
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
TraySetIcon "icons\utils.png"

; =======================================
; LEADER KEY SYSTEM
; =======================================
; Variables for leader key system
global LeaderKeyActive := false
global LeaderKeyBuffer := ""
global LeaderKeyTimeout := 2000  ; 2 seconds

; Variables for windows
global ChromeAI_ID := 0  ; Window for AI sites (GPT + Claude)
global GoogleWindow_ID := 0

; Shift+Space activates leader key mode
+Space:: ActivateLeaderKey()

; Process keystrokes while in leader mode
#HotIf LeaderKeyActive
a:: AppendLeaderKey("a")
+a:: AppendLeaderKey("a")
b:: AppendLeaderKey("b")
+b:: AppendLeaderKey("b")
c:: AppendLeaderKey("c")
+c:: AppendLeaderKey("c")
d:: AppendLeaderKey("d")
+d:: AppendLeaderKey("d")
e:: AppendLeaderKey("e")
+e:: AppendLeaderKey("e")
f:: AppendLeaderKey("f")
+f:: AppendLeaderKey("f")
g:: AppendLeaderKey("g")
+g:: AppendLeaderKey("g")
h:: AppendLeaderKey("h")
+h:: AppendLeaderKey("h")
i:: AppendLeaderKey("i")
+i:: AppendLeaderKey("i")
j:: AppendLeaderKey("j")
+j:: AppendLeaderKey("j")
k:: AppendLeaderKey("k")
+k:: AppendLeaderKey("k")
l:: AppendLeaderKey("l")
+l:: AppendLeaderKey("l")
m:: AppendLeaderKey("m")
+m:: AppendLeaderKey("m")
n:: AppendLeaderKey("n")
+n:: AppendLeaderKey("n")
o:: AppendLeaderKey("o")
+o:: AppendLeaderKey("o")
p:: AppendLeaderKey("p")
+p:: AppendLeaderKey("p")
q:: AppendLeaderKey("q")
+q:: AppendLeaderKey("q")
r:: AppendLeaderKey("r")
+r:: AppendLeaderKey("r")
s:: AppendLeaderKey("s")
+s:: AppendLeaderKey("s")
t:: AppendLeaderKey("t")
+t:: AppendLeaderKey("t")
u:: AppendLeaderKey("u")
+u:: AppendLeaderKey("u")
v:: AppendLeaderKey("v")
+v:: AppendLeaderKey("v")
w:: AppendLeaderKey("w")
+w:: AppendLeaderKey("w")
x:: AppendLeaderKey("x")
+x:: AppendLeaderKey("x")
y:: AppendLeaderKey("y")
+y:: AppendLeaderKey("y")
z:: AppendLeaderKey("z")
+z:: AppendLeaderKey("z")
Space:: AppendLeaderKey("Space")
+Space:: AppendLeaderKey("Space")
1:: AppendLeaderKey("1")
2:: AppendLeaderKey("2")
3:: AppendLeaderKey("3")
4:: AppendLeaderKey("4")
5:: AppendLeaderKey("5")
6:: AppendLeaderKey("6")
7:: AppendLeaderKey("7")
8:: AppendLeaderKey("8")
9:: AppendLeaderKey("9")
0:: AppendLeaderKey("0")
; Using CapsLock for canceling since you rebind Escape
CapsLock:: CancelLeaderKeyFunc()
#HotIf

; Activates leader key mode
ActivateLeaderKey() {
  global LeaderKeyActive, LeaderKeyBuffer, LeaderKeyTimeout
  LeaderKeyActive := true
  LeaderKeyBuffer := ""

  ; Cancel any existing timer
  SetTimer(CancelLeaderKeyFunc, 0)

  ; Set new timer
  SetTimer(CancelLeaderKeyFunc, LeaderKeyTimeout)

  ToolTip("Leader mode active")
}

; Timer function to cancel leader key mode
CancelLeaderKeyFunc() {
  CancelLeaderKey()
}

; Append key to leader sequence and process commands
AppendLeaderKey(key) {
  global LeaderKeyBuffer
  LeaderKeyBuffer .= key

  ; Process leader key combinations
  if (LeaderKeyBuffer = "a") {
    ActivateOrCreateAIWindow()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "c") {
    ActivateVSCode()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "w") {
    ActivateWezTerm()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "p") {
    ActivatePowerShell()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "x") {
    ActivateExplorer()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "mm") {
    SendCodeMessage()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "Spacep") {
    ActivateAdminPowerShell()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "n") {
    ActivateNeo4j()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "\") {
    ReplaceBackslashes()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "s") {
    ActivateOrCreateGoogleWindow()
    CancelLeaderKey()
  } else if (LeaderKeyBuffer = "mc") {
    Click  ; Mouse click for eye tracker
    CancelLeaderKey()
  } else {
    ; Optional: Update tooltip to show current sequence
    ToolTip("Leader mode: " LeaderKeyBuffer)
  }
}

; Cancel leader key mode
CancelLeaderKey() {
  global LeaderKeyActive, LeaderKeyBuffer
  LeaderKeyActive := false
  LeaderKeyBuffer := ""

  ; Turn off the timer
  SetTimer(CancelLeaderKeyFunc, 0)

  ToolTip("")  ; Clear the tooltip
}

; =======================================
; WINDOWS ACTIVATION AND UTILITY FUNCTIONS
; =======================================

ActivateOrCreateWindow(&windowID, runCommand, windowClass, windowTitle := "", urls := "") {
  ; Check if the window ID is still valid
  if (IsSet(windowID) && windowID && WinExist("ahk_id " windowID)) {
    ; Window exists, so activate it
    WinActivate("ahk_id " windowID)
    return true
  }

  ; Create a new window
  ; Modify the run command if we have URLs (for Chrome or other browsers)
  if (urls) {
    runCommand := runCommand " --new-window " urls
  }

  ; Launch the application
  Run(runCommand)
  Sleep(1000)  ; Wait for the application to start

  ; Get the ID of the new window
  if (windowTitle) {
    ; If we have a title, try to find the window with both class and title
    newWindowID := WinWait("ahk_class " windowClass " " windowTitle, , 5)
    if (newWindowID) {
      windowID := newWindowID
      WinActivate("ahk_id " windowID)
      return true
    }
  }

  ; Try to get the most recent window of this class
  windows := WinGetList("ahk_class " windowClass)
  if (windows.Length > 0) {
    windowID := windows[1]
    WinActivate("ahk_id " windowID)
    return true
  }

  return false
}

ActivateOrCreateAIWindow() {
  global ChromeAI_ID
  return ActivateOrCreateWindow(
    &ChromeAI_ID,
    "chrome.exe",
    "Chrome_WidgetWin_1",
    "",
    "https://claude.ai https://chat.openai.com"
  )
}

ActivateOrCreateGoogleWindow() {
  global GoogleWindow_ID
  return ActivateOrCreateWindow(
    &GoogleWindow_ID,
    "chrome.exe",
    "Chrome_WidgetWin_1",
    "",
  )
}

ActivateVSCode() {
  SetTitleMatchMode 2
  if WinExist("ahk_exe Code.exe") {
    WinActivate
  } else {
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
  }
}

ActivateWezTerm() {
  SetTitleMatchMode 3
  primaryPath := "C:\Users\ville\scoop\apps\wezterm-nightly\current\wezterm-gui.exe"
  fallbackPath := "C:\Users\ville\scoop\shims\wezterm-gui.exe"

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

ActivatePowerShell() {
  SetTitleMatchMode 2
  if WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS") {
    WinActivate
  } else {
    Run "pwsh"
  }
}

ActivateAdminPowerShell() {
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

ActivateExplorer() {
  if WinExist("ahk_class CabinetWClass") {
    WinActivate
  } else {
    Run "explorer.exe"
  }
}

ActivateNeo4j() {
  SetTitleMatchMode 2
  if WinExist("neo4j@bolt://localhost:7687") {
    WinActivate
  } else {
    Run "C:\Users\ville\AppData\Local\Programs\Neo4j Desktop\Neo4j Desktop.exe"
  }
}

SendCodeMessage() {
  SendText "Please only send back only as much code as is really needed, avoid being too verbose."
}

ReplaceBackslashes() {
  A_Clipboard := ClipboardAll()  ; Save the original clipboard content
  Sleep 50  ; Small delay to ensure clipboard content is ready
  A_Clipboard := RegExReplace(A_Clipboard, "\", "/")  ; Replace backslashes with forward slashes
}

; =======================================
; ADDITIONAL UTILITY HOTKEYS
; =======================================

; Rebind Alt+J, Alt+K, Alt+H, and Alt+L to arrow keys
!j::Down
!k::Up
!h::Left
!l::Right

; Rebind C-; to c-\ in wezterm
#HotIf WinActive("Wezterm")
^;::^
#HotIf

; Unbind esc and use capslock for it instead as long as not in specific games
#HotIf !WinActive("ahk_exe dota2.exe") and !WinActive("Warcraft III")
CapsLock::Esc
Esc::CapsLock
#HotIf
