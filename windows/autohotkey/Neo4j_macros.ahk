#SingleInstance Force
A_MaxHotkeysPerInterval := 500
SetTitleMatchMode 2  ; Allows for partial matching of the window title
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory
TraySetIcon "icons\neo4j.png"
#HotIf WinActive("neo4j@bolt://localhost:7687/neo4j - Neo4j Browser")

MatchNode() {
  SendInput "MATCH("
  userInput := InputHook("L1")
  userInput.Start()
  userInput.Wait()
  SendInput userInput.Input ")" "{Shift down}{Enter}{Shift up}WHERE apoc.node.id(" userInput.Input ")="
}

MatchNodeGroup() {
  SendInput "MATCH(a:)-[r]-(b)"
  SendInput "{Shift down}{Enter}{Shift up}RETURN a,r,b"
  Send "{Up}{Left 4}"
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput HandleNodeInput(input1.Input)
}

CreateNode() {
  SendInput "Create("
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput input1.Input ":"
  input2 := InputHook("L1")
  input2.Start()
  input2.Wait()
  SendInput HandleNodeInput(input2.Input)
  SendText '{text:""}'
  Send "{Left 2}"
}

MatchRelationship() {
  SendInput "MATCH("
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput input1.Input ")-["
  input2 := InputHook("L1")
  input2.Start()
  input2.Wait()
  SendInput input2.Input "]->("
  input3 := InputHook("L1")
  input3.Start()
  input3.Wait()
  SendInput input3.Input ")"
  SendInput "{Shift down}{Enter}{Shift up}WHERE apoc.rel.id(" input2.Input ")="
}

MatchRelationshipGroup() {
  SendInput "MATCH(a)-[r:]-(b)"
  SendInput "{Shift down}{Enter}{Shift up}RETURN a,r,b"
  Send "{Up}"
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput HandleRelationshipInput(input1.Input)
}

CreateRelationship() {
  SendInput "create("
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput input1.Input ")-["
  input2 := InputHook("L1")
  input2.Start()
  input2.Wait()
  SendInput input2.Input ":]->("
  input3 := InputHook("L1")
  input3.Start()
  input3.Wait()
  SendInput input3.Input ")"
  Send "{Left 6}"
  input4 := InputHook("L1")
  input4.Start()
  input4.Wait()
  SendInput HandleRelationshipInput(input4.Input)
}

MatchPropertyKey() {
  SendInput "MATCH (a)-[r]->(b)"
  SendInput "{Shift down}{Enter}{Shift up}WHERE any(key IN keys(r) WHERE key = " ")"
  SendInput "{Shift down}{Enter}{Shift up}RETURN a,r,b"
  SendInput "{Up}{End}{Left 2}"
}

SetText() {
  SendInput "set "
  input1 := InputHook("L1")
  input1.Start()
  input1.Wait()
  SendInput input1.Input '.text=""'
  Send "{Left}"
}

HandleRelationshipInput(input) {
  if GetKeyState("Shift", "P") {
    if (input = "a")
      return "ALLOWS"
  } else {
    if (input = "a")
      return "ATTEMPTS"
    if (input = "c")
      return "CHECKS"
    if (input = "d")
      return "DEFAULTS"
    if (input = "e")
      return "EXPECTS"
    if (input = "i")
      return "INITIATES"
    if (input = "l")
      return "LOCKS"
    if (input = "p")
      return "PRIMES"
    if (input = "t")
      return "TRIGGERS"
    if (input = "u")
      return "UNLOCKS"
    return input
  }
}

HandleNodeInput(input) {
  if GetKeyState("Shift", "P") {
    if (input = "r")
      return "Request"
  } else {
    if (input = "a")
      return "Answer"
    if (input = "e")
      return "Error"
    if (input = "p")
      return "Prompt"
    if (input = "q")
      return "Response:Question"
    if (input = "r")
      return "Response"
    if (input = "t")
      return "Transmission"
    return input
  }
}

; Matches Hotkey: Ctrl+Shift+M, then G for Group, N for Node, R for Relationship, P for Property Key
^+m:: {
  nextKey := InputHook("L1")
  nextKey.Start()
  nextKey.Wait()

  if (nextKey.Input = "n") {
    MatchNode()
  } else if (nextKey.Input = "r") {
    MatchRelationship()
  } else if (nextKey.Input = "p") {
    MatchPropertyKey()
  } else if (nextKey.Input = "g") {
    nextKey2 := InputHook("L1")
    nextKey2.Start()
    nextKey2.Wait()

    if (nextKey2.Input = "n") {
      MatchNodeGroup()
    } else if (nextKey2.Input = "r") {
      MatchRelationshipGroup()
    }
  }
}

; Create Hotkey: Ctrl+Shift+C
^+c:: {
  nextKey := InputHook("L1")
  nextKey.Start()
  nextKey.Wait()

  if (nextKey.Input = "n") {
    CreateNode()
  } else if (nextKey.Input = "r") {
    CreateRelationship()
  }
}

; Set Hotkey: Ctrl+Shift+S
^+s:: {
  nextKey := InputHook("L1")
  nextKey.Start()
  nextKey.Wait()

  if (nextKey.Input = "t") {
    SetText()
  }
}

; Return all Hotkey: Ctrl+Shift+\
^+\:: {
  SendInput "MATCH(a){Shift down}{Enter}{Shift up}RETURN a"
}
