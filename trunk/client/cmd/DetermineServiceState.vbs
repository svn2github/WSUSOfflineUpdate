' *** Author: T. Wittrock, Kiel ***

Option Explicit

Dim wshShell, objFileSystem, objCmdFile, objWMIService, objQueryItem 
Dim strServiceName, strPrefix, strTempFolder, strCmdFileName

If WScript.Arguments.Count < 2 Then
  WScript.Echo("ERROR: Missing argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <service name> <variable prefix>")
  WScript.Quit(1)
End If

Set wshShell = WScript.CreateObject("WScript.Shell")
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strCmdFileName = strTempFolder & "\SetServiceState.cmd"
strServiceName = WScript.Arguments(0)
strPrefix = WScript.Arguments(1)

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_Service Where Name = '" & strServiceName & "'")
  objCmdFile.WriteLine("set " & strPrefix & "_STATE=" & objQueryItem.State)
  objCmdFile.WriteLine("set " & strPrefix & "_SMODE=" & objQueryItem.StartMode)
Next

objCmdFile.Close
WScript.Quit(0)
