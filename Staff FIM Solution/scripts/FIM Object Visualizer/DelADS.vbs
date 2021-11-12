'------------------------------------------------------------------------------------
 Option Explicit
'------------------------------------------------------------------------------------
 Sub Traverse(oFolder)
    Dim oFso, curFolder
    Set oFso    = CreateObject("Scripting.FileSystemObject")
    For Each curFolder In oFolder.SubFolders
       Traverse curFolder
    Next 
       
    Dim curFile, fileName
    For Each curFile In oFolder.Files
       If(LCase(Right(curFile.Path, 3)) = "ps1") Then
          fileName = curFile.Path & ":Zone.Identifier"
          If(oFso.FileExists(fileName)) Then
             Dim oShell
             Set oShell = CreateObject("WScript.Shell")
             oShell.run "notepad.exe " & fileName
             'Set oFile = oFso.OpenTextFile(fileName, 2, True)
             'oFile.Close 
             'Set oFile = Nothing
           End If
       End If
    Next 
 End Sub
'------------------------------------------------------------------------------------
 Dim oShell, oFso, oFolder, curFile, appCmd, oFile
 Set oShell  = CreateObject("WScript.Shell")
 Set oFso    = CreateObject("Scripting.FileSystemObject")
 Set oFolder = oFso.GetFolder(oShell.CurrentDirectory)
 Traverse oFolder
'------------------------------------------------------------------------------------
 MsgBox "Command completed successfully", 64, Replace(WScript.ScriptName, ".vbs", "") 
'------------------------------------------------------------------------------------


