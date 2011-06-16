' *** Author: T. Wittrock, Kiel ***

Option Explicit

Dim objFileSystem, inputFile, outputFile, strInputFileName, strOutputFileName

Private Function IsTextFile(objFS, strFileName)
  IsTextFile = (objFS.FileExists(strFileName)) And ( (LCase(objFS.GetExtensionName(strFileName)) = "txt") Or (LCase(objFS.GetExtensionName(strFileName)) = "csv") )
End Function

Private Function ExtractIdAndFileName(strURL)
  ExtractIdAndFileName = Left(strURL, InStr(strURL, ",")) & Right(strURL, Len(strURL) - InStrRev(strURL, "/"))
End Function

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
If WScript.Arguments.Count < 2 Then
  WScript.Echo("ERROR: Missing argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <Input file> <Output file>")
  WScript.Quit(1)
End If
strInputFileName = WScript.Arguments(0)
If Not IsTextFile(objFileSystem, strInputFileName) Then
  WScript.Echo("ERROR: Invalid argument '" & strInputFileName & "'")
  WScript.Echo("Usage: " & WScript.ScriptName & " <Input file> <Output file>")
  WScript.Quit(1)
End If
strOutputFileName = WScript.Arguments(1)

Set inputFile = objFileSystem.OpenTextFile(strInputFileName, 1)
Set outputFile = objFileSystem.CreateTextFile(strOutputFileName, True)
Do While Not inputFile.AtEndOfStream
  outputFile.WriteLine(ExtractIdAndFileName(inputFile.ReadLine()))
Loop
inputFile.Close()
outputFile.Close()
WScript.Quit(0)
