' *** Author: T. Wittrock, Kiel ***

Option Explicit

Private Const LOGOFF          = 0
Private Const SHUTDOWN        = 1
Private Const REBOOT          = 2
Private Const POWEROFF        = 8

Private Const FORCED_LOGOFF   = 4
Private Const FORCED_SHUTDOWN = 5
Private Const FORCED_REBOOT   = 6
Private Const FORCED_POWEROFF = 12

Dim objNetwork, objWMIService, objOperatingSystem, strArgument

If WScript.Arguments.Count = 0 Then
  strArgument = ""
Else
  strArgument = WScript.Arguments(0)
End If
Set objNetwork = WScript.CreateObject("WScript.Network")
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & objNetwork.ComputerName & "\root\cimv2")
For Each objOperatingSystem in objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
  If LCase(strArgument) = "/reboot" Then
    objOperatingSystem.Win32Shutdown(FORCED_REBOOT)
  Else
    objOperatingSystem.Win32Shutdown(FORCED_SHUTDOWN)
  End If
  Exit For
Next
WScript.Quit(0)
