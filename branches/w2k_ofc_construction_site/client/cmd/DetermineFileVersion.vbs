' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Dim wshShell, objFileSystem, objCmdFile
Dim strFileName, strPrefix, strTempFolder, strCmdFileName

Sub WriteVersionToFile(cmdFile, prefix, strVersion)
Dim versionArray, i

  If Len(strVersion) > 0 Then
    versionArray = Split(strVersion, ".")
    For i = 0 To UBound(versionArray)
      Select Case i
        Case 0
          cmdFile.WriteLine("set " & prefix & "_MAJOR=" & versionArray(i))         
        Case 1
          cmdFile.WriteLine("set " & prefix & "_MINOR=" & versionArray(i))         
        Case 2
          cmdFile.WriteLine("set " & prefix & "_BUILD=" & versionArray(i))         
        Case 3
          cmdFile.WriteLine("set " & prefix & "_REVISION=" & versionArray(i))         
      End Select
    Next
  Else
    cmdFile.WriteLine("set " & prefix & "_MAJOR=0")         
  End If
End Sub

If WScript.Arguments.Count < 2 Then
  WScript.Echo("ERROR: Missing argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <file name> <variable prefix>")
  WScript.Quit(1)
End If

Set wshShell = WScript.CreateObject("WScript.Shell")
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strCmdFileName = strTempFolder & "\SetFileVersion.cmd"
strFileName = WScript.Arguments(0)
strPrefix = WScript.Arguments(1)

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

WriteVersionToFile objCmdFile, strPrefix, objFileSystem.GetFileVersion(strFileName)

objCmdFile.Close
WScript.Quit(0)
