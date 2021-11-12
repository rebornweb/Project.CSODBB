Option Explicit
Dim oShell, appCmd, htaPath, htaEngine  
Set oShell  = CreateObject("WScript.Shell")
 
htaPath   = Replace(WScript.ScriptFullName, ".vbs", ".hta")
htaEngine = oShell.ExpandEnvironmentStrings("%WinDir%") & "\system32\mshta.exe "
appCmd    = htaEngine & Chr(34) & htaPath & Chr(34)

oShell.Run appCmd, 4, false
