' *** Author: T. Wittrock, Kiel ***

Option Explicit

Private Const strUserName = "WSUSUpdateAdmin"

Dim objNetwork, objComputer, objUser, found

Set objNetwork = WScript.CreateObject("WScript.Network")
Set objComputer = GetObject("WinNT://" & objNetwork.ComputerName)

objComputer.Filter = Array("user")
found = false
For Each objUser In objComputer
  If LCase(objUser.Name) = LCase(strUserName) Then
    found = true
    Exit For
  End If    
Next
If found Then
  objComputer.Delete "user", strUserName
  WScript.Quit(0)
Else
  WScript.Echo("ERROR: User account '" & strWSUSUpdateAdminName & "' not found.")
  WScript.Quit(1)
End If
