' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Dim wshShell, objFileSystem, objCmdFile
Dim strSystemFolder, strTempFolder, strRegFileName, strCmdFileName

Sub WriteFileVersions2File(textFile, prefix, strVersion)
Dim versionArray, i

  If Len(strVersion) > 0 Then
    versionArray = Split(strVersion, ".")
    For i = 0 To UBound(versionArray)
      Select Case i
        Case 0
          textFile.WriteLine("set " & prefix & "_MAJOR=" & versionArray(i))         
        Case 1
          textFile.WriteLine("set " & prefix & "_MINOR=" & versionArray(i))         
        Case 2
          textFile.WriteLine("set " & prefix & "_BUILD=" & versionArray(i))         
        Case 3
          textFile.WriteLine("set " & prefix & "_REVISION=" & versionArray(i))         
      End Select
    Next
  Else
    textFile.WriteLine("set " & prefix & "_MAJOR=0")         
  End If
End Sub

Set wshShell = WScript.CreateObject("WScript.Shell")
strSystemFolder = wshShell.ExpandEnvironmentStrings("%SystemRoot%") & "\system32"
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strRegFileName = strSystemFolder & "\reg.exe"
strCmdFileName = strTempFolder & "\SetRegVersion.cmd"

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

' Determine reg.exe version
WriteFileVersions2File objCmdFile, "REG_VERSION", objFileSystem.GetFileVersion(strRegFileName)

objCmdFile.Close
WScript.Quit(0)
