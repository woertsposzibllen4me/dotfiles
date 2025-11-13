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

global currentKeyboard := ""

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

DetectSpecificKeyboard() {
  keyboards := GetKeyboardInfo()
  detectedKeyboards := []
  for keyboard in keyboards {
    keyboardType := "Unknown"
    ; Check VID/PID in Device ID
    if InStr(keyboard.DeviceID, "VID_3434&PID_0121") {
      keyboardType := "Keychron Q3"
    }
    else if InStr(keyboard.DeviceID, "VID_16C0&PID_27DB") {
      keyboardType := "Glove80"
    }
    ; Only add unique keyboards (avoid duplicates from multiple interfaces)
    found := false
    for existing in detectedKeyboards {
      if (existing = keyboardType) {
        found := true
        break
      }
    }
    if (!found && keyboardType != "Unknown") {
      detectedKeyboards.Push(keyboardType)
    }
  }
  return detectedKeyboards
}

; Get keyboard information via WMI
GetKeyboardInfo() {
  keyboards := []
  for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Keyboard") {
    keyboards.Push({
      Name: objItem.Name,
      Description: objItem.Description,
      DeviceID: objItem.DeviceID,
      PNPDeviceID: objItem.PNPDeviceID
    })
  }
  return keyboards
}

; Run detection once at startup
detectedNames := DetectSpecificKeyboard()

; Show detected keyboard names
for keyboard in detectedNames {
  MsgBox("Detected: " . keyboard)
}

; Set current keyboard variable for hotkeys
for keyboard in detectedNames {
  if (keyboard = "Keychron Q3") {
    currentKeyboard := "keychronQ3"
    break
  }
  else if (keyboard = "Glove80") {
    currentKeyboard := "glove"
    break
  }
}

; Write full details to file
keyboards := GetKeyboardInfo()
outputFile := "keyboard_info.txt"
if FileExist(outputFile) {
  FileDelete(outputFile)
}

for keyboard in keyboards {
  content := "Name: " . keyboard.Name . "`n"
    . "Description: " . keyboard.Description . "`n"
    . "Device ID: " . keyboard.DeviceID . "`n"
    . "PNP Device ID: " . keyboard.PNPDeviceID . "`n"
    . "----------------------------------------`n"
  FileAppend(content, outputFile)
}

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

; Capture Current Chrome Window
CaptureCurrentChromeWindow(slot) {
  global Browser1_ID, Browser2_ID, Browser3_ID

  ; Get the currently active window
  activeID := WinGetID("A")

  ; Check if it's a Chrome window
  try {
    activeExe := WinGetProcessName("ahk_id " activeID)
    if (activeExe != "chrome.exe") {
      MsgBox("❌ Active window is not Chrome (" activeExe ")")
      return false
    }
  } catch {
    MsgBox("❌ Could not identify active window")
    return false
  }

  ; Assign to the requested slot
  if (slot = 1) {
    Browser1_ID := activeID
    slotName := "Browser1"
  } else if (slot = 2) {
    Browser2_ID := activeID
    slotName := "Browser2"
  } else if (slot = 3) {
    Browser3_ID := activeID
    slotName := "Browser3"
  } else {
    MsgBox("❌ Invalid slot: " slot)
    return false
  }

  ; Add to Chrome window list if not already there
  AddToChromeWindowList(activeID)

  ; Save the changes
  WriteWindowIDs()

  ; Show confirmation
  ToolTip("✅ Captured Chrome window to " slotName " (ID: " activeID ")")
  SetTimer(() => ToolTip(), -2000)

  return true
}

; =======================================
; LEADER‑KEY DEFINITIONS
; =======================================

; Process keystrokes while in leader mode
#HotIf LeaderKeyActive
a:: AppendLeaderKey("a")
^a:: AppendLeaderKey("a")
+a:: AppendLeaderKey("A")
b:: AppendLeaderKey("b")
^b:: AppendLeaderKey("b")
+b:: AppendLeaderKey("B")
c:: AppendLeaderKey("c")
^c:: AppendLeaderKey("c")
+c:: AppendLeaderKey("C")
d:: AppendLeaderKey("d")
^d:: AppendLeaderKey("d")
+d:: AppendLeaderKey("D")
e:: AppendLeaderKey("e")
^e:: AppendLeaderKey("e")
+e:: AppendLeaderKey("E")
f:: AppendLeaderKey("f")
^f:: AppendLeaderKey("f")
+f:: AppendLeaderKey("F")
g:: AppendLeaderKey("g")
^g:: AppendLeaderKey("g")
+g:: AppendLeaderKey("G")
h:: AppendLeaderKey("h")
^h:: AppendLeaderKey("h")
+h:: AppendLeaderKey("H")
i:: AppendLeaderKey("i")
^i:: AppendLeaderKey("i")
+i:: AppendLeaderKey("I")
j:: AppendLeaderKey("j")
^j:: AppendLeaderKey("j")
+j:: AppendLeaderKey("J")
k:: AppendLeaderKey("k")
^k:: AppendLeaderKey("k")
+k:: AppendLeaderKey("K")
l:: AppendLeaderKey("l")
^l:: AppendLeaderKey("l")
+l:: AppendLeaderKey("L")
m:: AppendLeaderKey("m")
^m:: AppendLeaderKey("m")
+m:: AppendLeaderKey("M")
n:: AppendLeaderKey("n")
^n:: AppendLeaderKey("n")
+n:: AppendLeaderKey("N")
o:: AppendLeaderKey("o")
^o:: AppendLeaderKey("o")
+o:: AppendLeaderKey("O")
p:: AppendLeaderKey("p")
^p:: AppendLeaderKey("p")
+p:: AppendLeaderKey("P")
q:: AppendLeaderKey("q")
^q:: AppendLeaderKey("q")
+q:: AppendLeaderKey("Q")
r:: AppendLeaderKey("r")
^r:: AppendLeaderKey("r")
+r:: AppendLeaderKey("R")
s:: AppendLeaderKey("s")
^s:: AppendLeaderKey("s")
+s:: AppendLeaderKey("S")
t:: AppendLeaderKey("t")
^t:: AppendLeaderKey("t")
+t:: AppendLeaderKey("T")
u:: AppendLeaderKey("u")
^u:: AppendLeaderKey("u")
+u:: AppendLeaderKey("U")
v:: AppendLeaderKey("v")
^v:: AppendLeaderKey("v")
+v:: AppendLeaderKey("V")
w:: AppendLeaderKey("w")
^w:: AppendLeaderKey("w")
+w:: AppendLeaderKey("W")
x:: AppendLeaderKey("x")
^x:: AppendLeaderKey("x")
+x:: AppendLeaderKey("X")
y:: AppendLeaderKey("y")
^y:: AppendLeaderKey("y")
+y:: AppendLeaderKey("Y")
z:: AppendLeaderKey("z")
^z:: AppendLeaderKey("z")
+z:: AppendLeaderKey("Z")
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
  if (LeaderKeyBuffer == "a") {
    ActivateBrowser1Window()
  } else if (LeaderKeyBuffer == "s") {
    ActivateBrowser2Window()
  } else if (LeaderKeyBuffer == "d") {
    ActivateBrowser3Window()
  } else if (LeaderKeyBuffer == "A") {
    CaptureCurrentChromeWindow(1)
  } else if (LeaderKeyBuffer == "S") {
    CaptureCurrentChromeWindow(2)
  } else if (LeaderKeyBuffer == "D") {
    CaptureCurrentChromeWindow(3)
  } else if (LeaderKeyBuffer == "v") {
    ActivateVSCode()
  } else if (LeaderKeyBuffer == "w") {
    ActivateWezTerm()
  } else if (LeaderKeyBuffer == "p") {
    ActivatePowerShell()
  } else if (LeaderKeyBuffer == "g") {
    ActivateSpotify()
  } else if (LeaderKeyBuffer == "x") {
    ActivateExplorer()
  } else if (LeaderKeyBuffer == "mm") {
    WriteMessageAvoidTooVerbose()
  } else if (LeaderKeyBuffer == "mw") {
    WriteMessageWorstUserName()
  } else if (LeaderKeyBuffer == "mx") {
    WriteMessageExplainCode()
  } else if (LeaderKeyBuffer == "Spacep") {
    ActivateAdminPowerShell()
  } else if (LeaderKeyBuffer == "n") {
    ActivateNeo4j()
  } else if (LeaderKeyBuffer == "\") {
    ReplaceSlashes("\")
  } else if (LeaderKeyBuffer == "/") {
    ReplaceSlashes("/")
  } else if (LeaderKeyBuffer == "o") {
    ActivateOBS()
  } else if (LeaderKeyBuffer == "c") {
    ActivateDiscord()
  } else if (LeaderKeyBuffer == "b") {
    ActivateBraveBrowser()
  } else if (LeaderKeyBuffer == "RR") {
    Reload
  } else if (LeaderKeyBuffer == "Space]") {
    ResetChromeWindowList()
  } else if (LeaderKeyBuffer == "y") {
    ActivatePyCharm()
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
ActivatePyCharm() {
  SetTitleMatchMode 2
  if WinExist("ahk_exe pycharm64.exe")
    WinActivate
  else {
    ; Try to find PyCharm with wildcard for version
    Loop Files, "C:\Program Files\JetBrains\PyCharm Community Edition*", "D"
    {
      batPath := A_LoopFileFullPath "\bin\pycharm64.exe"
      if FileExist(batPath) {
        Run batPath
        return
      }
    }
    MsgBox "Could not find PyCharm executable."
  }
}

ActivateOBS() {
  if WinExist("ahk_exe obs64.exe")
    WinActivate
  else
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OBS Studio\OBS Studio (64bit).lnk"
}

ActivateDiscord() {
  if WinExist("ahk_exe Discord.exe")
    WinActivate
  else
    Run "C:\Users\ville\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
}

ActivateBraveBrowser() {
  if WinExist("ahk_exe brave.exe")
    WinActivate
  else
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Brave.lnk"
}

ActivateSpotify() {
  global SpotifyWindow_ID
  return ActivateOrCreateWindow(&SpotifyWindow_ID, "spotify.exe", "spotify.exe")
}

ActivateBrowser1Window() {
  global Browser1_ID
  return ActivateOrCreateWindow(&Browser1_ID,
    "chrome.exe",
    "chrome.exe",
    ; "https://claude.ai https://chat.openai.com"
  )
}

ActivateBrowser2Window() {
  global Browser2_ID
  return ActivateOrCreateWindow(&Browser2_ID,
    "chrome.exe",
    "chrome.exe",
    ; "https://claude.ai https://chat.openai.com"
  )
}

ActivateBrowser3Window() {
  global Browser3_ID
  return ActivateOrCreateWindow(&Browser3_ID,
    "chrome.exe",
    "chrome.exe",
    ; "https://claude.ai https://chat.openai.com"
  )
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

WriteMessageAvoidTooVerbose() {
  SendText "Please only send back only as much code as is really needed, avoid being too verbose."
}

WriteMessageWorstUserName() {
  SendText "woertsposzibllen4me"
}

WriteMessageExplainCode() {
  SendText "Can you explain every single line in depth ? No need to review code which has similar logic twice, but for every new uncovered piece of logic explain it very thoroughly please. There should be little room for further questioning if at all."
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
; GENERAL HOTKEYS
; =======================================

#HotIf WinActive("Wezterm")
^;::F13
^,::+F13
#HotIf

; Leader key functionality - available on all keyboards except in games
#HotIf !WinActive("ahk_exe dota2.exe") && !WinActive("Warcraft III")
$^Space:: ActivateLeaderKey()
#HotIf

; Keyboard-specific hotkeys - only for Keychron Q3, also excluding games
#HotIf !WinActive("ahk_exe dota2.exe") && !WinActive("Warcraft III") && (currentKeyboard = "keychronQ3")
CapsLock::Esc
Esc::CapsLock
!j::Down
!k::Up
!h::Left
!l::Right
#HotIf
