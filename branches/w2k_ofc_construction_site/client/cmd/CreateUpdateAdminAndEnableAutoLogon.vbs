' *** Author: T. Wittrock, Kiel ***

Option Explicit

Private Const strKeyPathLogon             = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\"
Private Const strKeyNameDomainName        = "DefaultDomainName"
Private Const strKeyNameUserName          = "DefaultUserName"
Private Const strKeyNamePassword          = "DefaultPassword"
Private Const strKeyNameAutoAdminLogon    = "AutoAdminLogon"
Private Const strKeyNameForceAutoLogon    = "ForceAutoLogon"
Private Const strWSUSUpdateAdminName      = "WSUSUpdateAdmin"
Private Const strKeyPathDesktopPolicies   = "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop\"
Private Const strKeyNameScreenSaveActive  = "ScreenSaveActive"

Dim wshShell, objWMIService, objNetwork, objComputer, objUser, strPassword, found

Private Function AdministratorsGroupName(computer, wmiService)
Dim colItems, objItem, objGroup

  Set colItems = wmiService.ExecQuery("Select * from Win32_Group Where SID = 'S-1-5-32-544'")
  For Each objItem in colItems
    computer.Filter = Array("group")
    For Each objGroup In computer
      If objItem.Name = objGroup.Name Then
        AdministratorsGroupName = objItem.Name
      End If
    Next
  Next
End Function

Private Sub CreateUpdateAdmin(computer, strAdminGroupName)
Dim objWSUSUpdateAdmin, objGroup

  On Error Resume Next 'Turn error reporting off
  Set objWSUSUpdateAdmin = computer.Create("user", strWSUSUpdateAdminName)
  Randomize
  strPassword = "WSUSua" & Int(9000 * Rnd) + 1000
  objWSUSUpdateAdmin.SetPassword strPassword
  objWSUSUpdateAdmin.SetInfo
  computer.Filter = Array("group")
  For Each objGroup In computer
    If objGroup.Name = strAdminGroupName Then
      objGroup.Add(objWSUSUpdateAdmin.ADsPath)
    End If
  Next
  On Error GoTo 0 'Turn error reporting on
End Sub

Private Sub EnableAutoLogon(shell)
  On Error Resume Next 'Turn error reporting off
  shell.RegWrite strKeyPathLogon & strKeyNameDomainName, objNetwork.ComputerName, "REG_SZ"
  shell.RegWrite strKeyPathLogon & strKeyNameUserName, strWSUSUpdateAdminName, "REG_SZ"
  shell.RegWrite strKeyPathLogon & strKeyNamePassword, strPassword, "REG_SZ"
  shell.RegWrite strKeyPathLogon & strKeyNameAutoAdminLogon, "1", "REG_SZ"
  shell.RegWrite strKeyPathLogon & strKeyNameForceAutoLogon, "1", "REG_SZ"
  shell.RegWrite strKeyPathDesktopPolicies & strKeyNameScreenSaveActive, 0, "REG_DWORD"
  On Error GoTo 0 'Turn error reporting on
End Sub

Set wshShell = WScript.CreateObject("WScript.Shell")
Set objNetwork = WScript.CreateObject("WScript.Network")
Set objComputer = GetObject("WinNT://" & objNetwork.ComputerName)
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")

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
Else
  CreateUpdateAdmin objComputer, AdministratorsGroupName(objComputer, objWMIService)
  EnableAutoLogon wshShell
  WScript.Quit(0)
End If
