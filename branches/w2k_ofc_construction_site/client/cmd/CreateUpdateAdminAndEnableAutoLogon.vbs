' *** Author: T. Wittrock, Kiel ***

Option Explicit

Private Const strWSUSUpdateAdminName  = "WSUSUpdateAdmin"
Private Const strKeyDesktopPolicies   = "HKLM\Software\Policies\Microsoft\Windows\Control Panel\Desktop\"
Private Const strValScreenSaveActive  = "ScreenSaveActive"
Private Const strKeyAutologon         = "HKCU\Software\Sysinternals\A\"
Private Const strValAcceptEula        = "EulaAccepted"

Dim wshShell, strComputerName, objComputer, objUser, strPassword, found

Private Function CreateUpdateAdmin(objComp)
Dim objWMIService, objWSUSUpdateAdmin, objGroup, objItem, strResult

  On Error Resume Next 'Turn error reporting off
  Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
  Set objWSUSUpdateAdmin = objComp.Create("user", strWSUSUpdateAdminName)
  Randomize
  strResult = "Wou" & Int(90000 * Rnd) + 10000
  objWSUSUpdateAdmin.SetPassword strResult
  objWSUSUpdateAdmin.SetInfo
  For Each objItem in objWMIService.ExecQuery("Select * from Win32_Group Where SID = 'S-1-5-32-544'")
    objComp.Filter = Array("group")
    For Each objGroup In objComp
      If objGroup.Name = objItem.Name Then
        objGroup.Add(objWSUSUpdateAdmin.ADsPath)
      End If
    Next
  Next
  ' Clear objects memory
  Set objWSUSUpdateAdmin = Nothing
  Set objWMIService = Nothing
  CreateUpdateAdmin = strResult   
  On Error GoTo 0 'Turn error reporting on
End Function

Private Sub EnableAutoLogon(shell, strUserName, strDomain, strPassword)
  On Error Resume Next 'Turn error reporting off
  shell.RegWrite strKeyAutologon & strValAcceptEula, 1, "REG_DWORD"
  shell.Run "..\bin\Autologon.exe " & strUserName & " " & strDomain & " " & strPassword, 0, True
  shell.RegWrite strKeyDesktopPolicies & strValScreenSaveActive, 0, "REG_DWORD"
  On Error GoTo 0 'Turn error reporting on
End Sub

Set wshShell = WScript.CreateObject("WScript.Shell")
strComputerName = WScript.CreateObject("WScript.Network").ComputerName
Set objComputer = GetObject("WinNT://" & strComputerName)

objComputer.Filter = Array("user")
found = false
For Each objUser In objComputer
  If LCase(objUser.Name) = LCase(strWSUSUpdateAdminName) Then
    found = true
    Exit For
  End If    
Next
If found Then
  WScript.Echo("ERROR: User account '" & strWSUSUpdateAdminName & "' already exists.")
  WScript.Quit(1)
End If
strPassword = CreateUpdateAdmin(objComputer)
EnableAutoLogon wshShell, strWSUSUpdateAdminName, strComputerName, strPassword   
WScript.Quit(0)
