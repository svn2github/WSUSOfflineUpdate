' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Private Const FORCED_REBOOT = 6

Dim objNetwork, objWMIService, objOperatingSystem

Set objNetwork = WScript.CreateObject("WScript.Network")
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & objNetwork.ComputerName & "\root\cimv2")
For Each objOperatingSystem in objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
  objOperatingSystem.Win32Shutdown(FORCED_REBOOT)
Exit For
Next
WScript.Quit(0)
