' *** Author: T. Wittrock, Kiel ***

Option Explicit

Dim intMilliSeconds

If WScript.Arguments.Count = 0 Then
  WScript.Echo("ERROR: Missing argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <milliseconds>")
  WScript.Quit(1)
End If
On Error Resume Next  'Turn error reporting off
intMilliSeconds = CInt(WScript.Arguments(0))
If Err <> 0 Then
  WScript.Echo("ERROR: Invalid argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <milliseconds>")
  WScript.Quit(1)
End If
On Error GoTo 0       'Turn error reporting on
WScript.Sleep(intMilliSeconds)
WScript.Quit(0)
