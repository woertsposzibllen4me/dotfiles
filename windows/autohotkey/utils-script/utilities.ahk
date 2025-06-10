; ==================================================
; Leader‑Key Window Manager with Chrome Window Tracking
; (AutoHotkey v2)
; ==================================================

#SingleInstance Force
A_MaxHotkeysPerInterval := 3000
SendMode "Input"
SetWorkingDir A_ScriptDir        ; Consistent starting directory
TraySetIcon "..\\icons\\utils.png"

; =======================================
; GLOBALS
; =======================================
; Leader‑key system
global LeaderKeyActive := false
global LeaderKeyBuffer := ""
global LeaderKeyTimeout := 2000

; Window IDs (persisted individually)
global Browser1_ID := 0
global Browser2_ID := 0
global Browser3_ID := 0
global SpotifyWindow_ID := 0

; Chrome‑tracking (persisted as a list)
global ChromeWindowList := []
global ChromeWindowsFile := A_ScriptDir "\\chrome_windows.ini"

; Config file for single‑value IDs
global ConfigFile := A_ScriptDir "\\window_ids.ini"

; =======================================
; STARTUP / SHUTDOWN
; =======================================
LoadWindowIDs()
LoadChromeWindowList()
VerifyWindowIDs()

OnExit((*) => (
  WriteWindowIDs(),
  SaveChromeWindowList()
))

; =======================================
; PERSISTENCE HELPERS
; =======================================
WriteWindowIDs() {
  global Browser1_ID, Browser2_ID, Browser3_ID, SpotifyWindow_ID, ConfigFile
  IniWrite(Browser1_ID, ConfigFile, "WindowIDs", "Browser1_ID")
  IniWrite(Browser2_ID, ConfigFile, "WindowIDs", "Browser2_ID")
  IniWrite(Browser3_ID, ConfigFile, "WindowIDs", "Browser3_ID")
  IniWrite(SpotifyWindow_ID, ConfigFile, "WindowIDs", "Spotify")
}

VerifyWindowIDs() {
  global Browser1_ID, Browser2_ID, Browser3_ID, SpotifyWindow_ID
  windowsLost := []
  idMap := Map()

  ; First check for invalid windows and build an ID map
  windowVars := [&Browser1_ID, &Browser2_ID, &Browser3_ID, &SpotifyWindow_ID]
  varNames := ["Browser1_ID", "Browser2_ID", "Browser3_ID", "SpotifyWindow_ID"]

  for i, v in windowVars {
    if (%v%) {
      if (!WinExist("ahk_id " . %v%)) {
        %v% := 0
        windowsLost.Push(varNames[i] . " (lost)")
      } else {
        ; Track which variables point to which window IDs
        if (!idMap.Has(%v%)) {
          idMap[%v%] := [i]
        } else {
          idMap[%v%].Push(i)
        }
      }
    }
  }

  ; Handle duplicates - keep only the first variable with each ID
  for id, indexList in idMap {
    if (indexList.Length > 1) {
      ; Keep the first variable, reset the rest
      Loop indexList.Length - 1 {
        dupIndex := indexList[A_Index + 1]
        varName := varNames[dupIndex]

        ; Reset the duplicate using the actual variable name
        if (varName = "Browser1_ID")
          Browser1_ID := 0
        else if (varName = "Browser2_ID")
          Browser2_ID := 0
        else if (varName = "Browser3_ID")
          Browser3_ID := 0
        else if (varName = "SpotifyWindow_ID")
          SpotifyWindow_ID := 0

        windowsLost.Push(varName . " (duplicate)")
      }
    }
  }

  if (windowsLost.Length) {
    lostList := ""
    for idx, name in windowsLost {
      lostList .= (idx > 1 ? ", " : "") . name
    }
    MsgBox("Lost/duplicate window(s): " . lostList)
  }

  WriteWindowIDs()
}

LoadWindowIDs() {
  global Browser1_ID, Browser2_ID, Browser3_ID, SpotifyWindow_ID, ConfigFile
  ; Default to 0 if not found
  Browser1_ID := IniRead(ConfigFile, "WindowIDs", "Browser1_ID", 0)
  Browser2_ID := IniRead(ConfigFile, "WindowIDs", "Browser2_ID", 0)
  Browser3_ID := IniRead(ConfigFile, "WindowIDs", "Browser3_ID", 0)
  SpotifyWindow_ID := IniRead(ConfigFile, "WindowIDs", "Spotify", 0)
}

SaveChromeWindowList() {
  global ChromeWindowList, ChromeWindowsFile
  ; wipe existing section
  IniDelete(ChromeWindowsFile, "ChromeWindows")
  ids := ""
  for _, id in ChromeWindowList
    ids .= id . ","
  if ids
    ids := SubStr(ids, 1, StrLen(ids) - 1)
  IniWrite(ids, ChromeWindowsFile, "ChromeWindows", "IDs")
}

LoadChromeWindowList() {
  global ChromeWindowList, ChromeWindowsFile
  ChromeWindowList := []
  if !FileExist(ChromeWindowsFile)
    return

  ids := IniRead(ChromeWindowsFile, "ChromeWindows", "IDs", "")
  if ids {
    Loop Parse, ids, ","
      ChromeWindowList.Push(A_LoopField + 0)
  }
}

AddToChromeWindowList(winID) {
  global ChromeWindowList
  for _, id in ChromeWindowList
    if (id = winID)
      return             ; already tracked
  ChromeWindowList.Push(winID)
  SaveChromeWindowList()
}

ResetChromeWindowList() {
  global ChromeWindowList
  for idx, id in ChromeWindowList {
    if (WinExist("ahk_id " id))
      WinClose("ahk_id " id)
  }
  ChromeWindowList := []
  SaveChromeWindowList()
}

; =======================================
; LEADER‑KEY DEFINITIONS
; =======================================
; Ctrl+Space activates leader key mode
$^Space:: ActivateLeaderKey()

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
^Space:: AppendLeaderKey("Space")
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
/:: AppendLeaderKey("/")
\:: AppendLeaderKey("\")
]:: AppendLeaderKey("]")
[:: AppendLeaderKey("[")
; Using CapsLock for canceling since you rebind Escape
CapsLock:: CancelLeaderKeyFunc()
#HotIf

; Activates leader key mode
ActivateLeaderKey() {
  global LeaderKeyActive, LeaderKeyBuffer, LeaderKeyTimeout
  LeaderKeyActive := true
  LeaderKeyBuffer := ""
  SetTimer(CancelLeaderKeyFunc, 0)            ; reset existing
  SetTimer(CancelLeaderKeyFunc, LeaderKeyTimeout)
  ToolTip("Leader mode active")
  SoundPlay("C:\\Windows\\Media\\Windows Balloon.wav")
}

CancelLeaderKeyFunc() {
  CancelLeaderKey()
}

AppendLeaderKey(key) {
  global LeaderKeyBuffer
  LeaderKeyBuffer .= key

  if (LeaderKeyBuffer = "a") {
    ActivateOrCreateBrowser1Window()
  } else if (LeaderKeyBuffer = "s") {
    ActivateOrCreateBrowser2Window()
  } else if (LeaderKeyBuffer = "d") {
    ActivateOrCreateBrowser3Window()
  } else if (LeaderKeyBuffer = "c") {
    ActivateVSCode()
  } else if (LeaderKeyBuffer = "w") {
    ActivateWezTerm()
  } else if (LeaderKeyBuffer = "p") {
    ActivatePowerShell()
  } else if (LeaderKeyBuffer = "g") {
    ActivateSpotify()
  } else if (LeaderKeyBuffer = "x") {
    ActivateExplorer()
  } else if (LeaderKeyBuffer = "mm") {
    SendCodeMessage()
  } else if (LeaderKeyBuffer = "Spacep") {
    ActivateAdminPowerShell()
  } else if (LeaderKeyBuffer = "n") {
    ActivateNeo4j()
  } else if (LeaderKeyBuffer = "\") {
    ReplaceSlashes("\")
  } else if (LeaderKeyBuffer = "/") {
    ReplaceSlashes("/")
  } else if (LeaderKeyBuffer = "mc") {
    Click
  } else if (LeaderKeyBuffer = "Space]") {
    ResetChromeWindowList()
  } else {
    ToolTip("Leader mode: " LeaderKeyBuffer)   ; show progress
    return                                    ; wait for more keys
  }
  CancelLeaderKey()                             ; after any recognised command
}

CancelLeaderKey() {
  global LeaderKeyActive, LeaderKeyBuffer
  LeaderKeyActive := false
  LeaderKeyBuffer := ""
  SetTimer(CancelLeaderKeyFunc, 0)
  ToolTip()
}

; =======================================
; WINDOW HELPERS
; =======================================
ActivateOrCreateWindow(&windowID, runCommand, exeName, urls := "") {
  if (IsSet(windowID) && windowID) {
    VerifyWindowIDs()
    if WinExist("ahk_id " windowID) {
      WinActivate("ahk_id " windowID)
      return true
    }
  }

  if (urls)
    runCommand := runCommand " --new-window " urls

  beforeHWNDs := WinGetList("List", "ahk_exe " exeName)
  Run(runCommand)

  newHWND := 0
  Loop 50 {
    Sleep 100
    afterHWNDs := WinGetList("ahk_exe " . exeName)
    for _, hwnd in afterHWNDs {
      found := false
      for _, old in beforeHWNDs {
        if hwnd = old {
          found := true
          break
        }
      }
      if !found {
        newHWND := hwnd
        break 2
      }
    }
  }

  if !newHWND {
    MsgBox "❌ Could not detect the new Chrome window."
    return false
  }

  windowID := newHWND
  WinActivate("ahk_id " newHWND)
  if (exeName = "chrome.exe") {
    AddToChromeWindowList(windowID)
  }
  VerifyWindowIDs()
  return true
}

; ---------- SPECIFIC LAUNCHERS ----------
ActivateSpotify() {
  global SpotifyWindow_ID
  return ActivateOrCreateWindow(&SpotifyWindow_ID, "spotify.exe", "spotify.exe")
}

ActivateOrCreateBrowser1Window() {
  global Browser1_ID
  return ActivateOrCreateWindow(&Browser1_ID,
    "chrome.exe",
    "chrome.exe",
    "https://claude.ai https://chat.openai.com")
}

ActivateOrCreateBrowser2Window() {
  global Browser2_ID
  return ActivateOrCreateWindow(&Browser2_ID,
    "chrome.exe",
    "chrome.exe",
    "https://claude.ai https://chat.openai.com")
}

ActivateOrCreateBrowser3Window() {
  global Browser3_ID
  return ActivateOrCreateWindow(&Browser3_ID,
    "chrome.exe",
    "chrome.exe",
    "https://claude.ai https://chat.openai.com")
}

ActivateVSCode() {
  SetTitleMatchMode 2
  if WinExist("ahk_exe Code.exe")
    WinActivate
  else
    Run "C:\\Users\\" A_UserName "\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe"
}

ActivateWezTerm() {
  SetTitleMatchMode 3
  primaryPath := "C:\\Users\\ville\\scoop\\apps\\wezterm-nightly\\current\\wezterm-gui.exe"
  fallbackPath := "C:\\Users\\ville\\scoop\\shims\\wezterm-gui.exe"

  if WinExist("Wezterm")
    WinActivate
  else if FileExist(primaryPath)
    Run primaryPath
  else if FileExist(fallbackPath)
    Run fallbackPath
  else
    MsgBox "Could not find WezTerm executable at either path."
}

ActivatePowerShell() {
  SetTitleMatchMode 2
  if WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")
    WinActivate
  else
    Run "pwsh"
}

ActivateAdminPowerShell() {
  adminTitle := "Administrator: C:\\Program Files\\PowerShell\\7\\pwsh.exe"
  selectAdminTitle := "Select " adminTitle

  if WinExist(adminTitle)
    WinActivate adminTitle
  else if WinExist(selectAdminTitle)
    WinActivate selectAdminTitle
  else
    Run "*RunAs pwsh.exe"
}

ActivateExplorer() {
  if WinExist("ahk_class CabinetWClass")
    WinActivate
  else
    Run "explorer.exe"
}

ActivateNeo4j() {
  SetTitleMatchMode 2
  if WinExist("neo4j@bolt://localhost:7687")
    WinActivate
  else
    Run "C:\\Users\\ville\\AppData\\Local\\Programs\\Neo4j Desktop\\Neo4j Desktop.exe"
}

SendCodeMessage() {
  SendText "Please only send back only as much code as is really needed, avoid being too verbose."
}

ReplaceSlashes(direction := "/") {
  originalClip := ClipboardAll()
  ClipWait(1)
  currentText := A_Clipboard
  if (direction = "/") {
    newText := StrReplace(currentText, "\", "/")
    A_Clipboard := newText
  }
  else if (direction = "\") {
    newText := StrReplace(currentText, "/", "\")
    A_Clipboard := newText
  }
}

; =======================================
; ADDITIONAL HOTKEYS
; =======================================
!j::Down
!k::Up
!h::Left
!l::Right

#HotIf WinActive("Wezterm")
^;::F13
^,::+F13
#HotIf

#HotIf !WinActive("ahk_exe dota2.exe") && !WinActive("Warcraft III")
CapsLock::Esc
Esc::CapsLock
#HotIf
