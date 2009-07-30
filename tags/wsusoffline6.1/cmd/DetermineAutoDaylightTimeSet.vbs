' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Private Const strRegKeyTimeZoneInformation  = "HKLM\System\CurrentControlSet\Control\TimeZoneInformation\"
Private Const strRegValDisableAutoDTS       = "DisableAutoDaylightTimeSet"

Dim wshShell, objFileSystem, objCmdFile
Dim strTempFolder, strCmdFileName

Private Function RegRead(objShell, strValueName)
  On Error Resume Next  'Turn error reporting off
  RegRead = objShell.RegRead(strValueName)
  If Err <> 0 Then
    RegRead = ""
    Err.Clear
  End If
  On Error GoTo 0       'Turn error reporting on
End Function

Set wshShell = WScript.CreateObject("WScript.Shell")
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strCmdFileName = strTempFolder & "\SetAutoDTS.cmd"
If RegRead(wshShell, strRegKeyTimeZoneInformation & strRegValDisableAutoDTS) <> "1" Then
  Set objFileSystem = CreateObject("Scripting.FileSystemObject")
  Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)
  objCmdFile.WriteLine("set OS_AUTODTS=1")
  objCmdFile.Close
End If
WScript.Quit(0)
