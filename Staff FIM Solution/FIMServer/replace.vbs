' Script borrowed from http://blogs.technet.com/b/heyscriptingguy/archive/2005/02/08/how-can-i-find-and-replace-text-in-a-text-file.aspx

Const ForReading = 1
Const ForWriting = 2

strFileName = Wscript.Arguments(0)
strOldText = Wscript.Arguments(1)
strNewText = Wscript.Arguments(2)

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(strFileName, ForReading)

strText = objFile.ReadAll
objFile.Close
strNewText = Replace(strText, strOldText, strNewText)

Set objFile = objFSO.OpenTextFile(strFileName, ForWriting)
objFile.WriteLine strNewText
objFile.Close
Set objFile = Nothing
Set objFSO = Nothing
