' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Private Const strRegKeyIE                     = "HKLM\Software\Microsoft\Internet Explorer\"
Private Const strRegKeyMDAC                   = "HKLM\Software\Microsoft\DataAccess\"
Private Const strRegKeyDirectX                = "HKLM\Software\Microsoft\DirectX\"
Private Const strRegKeyDotNet35               = "HKLM\Software\Microsoft\NET Framework Setup\NDP\v3.5\"
Private Const strRegKeyPowerShell             = "HKLM\Software\Microsoft\PowerShell\1\PowerShellEngine\"
Private Const strRegValVersion                = "Version"
Private Const strRegValPShVersion             = "PowerShellVersion"
Private Const strRegKeyOfficePrefix_Mx86      = "HKLM\Software\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_Mx64      = "HKLM\Software\Wow6432Node\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_User      = "HKCU\Software\Microsoft\Office\"
Private Const strRegKeyOfficeInfixes_Version  = "10.0,11.0,12.0"
Private Const strRegKeyOfficeSuffix_InstRoot  = "\Common\InstallRoot\"
Private Const strRegKeyOfficeSuffix_Language  = "\Common\LanguageResources\"
Private Const strRegKeyOfficeSuffix_Version   = "\Common\ProductVersion\"
Private Const strRegValOfficePath             = "Path"
Private Const strRegValOfficeLanguage_Inst    = "SKULanguage"
Private Const strRegValOfficeLanguage_User    = "InstallLanguage"
Private Const strRegValOfficeVersion          = "LastProduct"
Private Const strOfficeNames                  = "oxp,o2k3,o2k7"
Private Const strOfficeAppNames               = "Word,Excel,Outlook,Powerpoint,Access,FrontPage"
Private Const strOfficeExeNames               = "WINWORD.EXE,EXCEL.EXE,OUTLOOK.EXE,POWERPNT.EXE,MSACCESS.EXE,FRONTPG.EXE"
Private Const strBuildNumbers_Oxp             = "2627,2614,2627,2623,2627,2623;3416,3506,3416,3506,3409,3402;4219,4302,4024,4205,4302,4128;6612,6501,6626,6501,6501,6308"
Private Const strBuildNumbers_O2k3            = "5604,5612,5510,5529,5614,5516;6359,6355,6353,6361,6355,6356;6568,6560,6565,6564,6566,6552;8169,8169,8169,8169,8166,8164"
Private Const strBuildNumbers_O2k7            = "4518,4518,4518,4518,4518,4518;6211,6214,6212,6211,6211,6211;6425,6425,6423,6425,6423,6423"
Private Const idxBuild                        = 2

Dim wshShell, objFileSystem, objCmdFile, objWMIService, objWMIQuery, arrayOfficeNames, arrayOfficeVersions, arrayOfficeAppNames, arrayOfficeExeNames
Dim strSystemFolder, strTempFolder, strWUAFileName, strMSIFileName, strWSHFileName, strRDPFileName, strWMPFileName, strCmdFileName, strOSVersion, strOfficeInstallPath, strOfficeExeVersion, strProduct, languageCode, i, j

Private Function RegRead(objShell, strValueName)
  On Error Resume Next  'Turn error reporting off
  RegRead = objShell.RegRead(strValueName)
  If Err <> 0 Then
    RegRead = ""
    Err.Clear
  End If
  On Error GoTo 0       'Turn error reporting on
End Function

Private Sub WriteLanguage2File(objTextFile, varName, langCode)

  Select Case langCode
    Case 9, 1033, 2057, 3081, 4105, 5129, 6153, 7177, 8201, 10249, 11273
      objTextFile.WriteLine("set " & varName & "=enu")
    Case 1036, 2060, 3084, 4108, 5132
      objTextFile.WriteLine("set " & varName & "=fra")
    Case 1034, 2058, 3082, 4106, 5130, 6154, 7178, 8202, 9226, 10250, 11274, _
         12298, 13322, 14346, 15370, 16394, 17418, 18442, 19466, 20490
      objTextFile.WriteLine("set " & varName & "=esn")
    Case 1049, 2073
      objTextFile.WriteLine("set " & varName & "=rus")
    Case 2070
      objTextFile.WriteLine("set " & varName & "=ptg")
    Case 1046
      objTextFile.WriteLine("set " & varName & "=ptb")
    Case 1031, 2055, 3079, 4103, 5127
      objTextFile.WriteLine("set " & varName & "=deu")
    Case 1043, 2067
      objTextFile.WriteLine("set " & varName & "=nld")
    Case 1040, 2064
      objTextFile.WriteLine("set " & varName & "=ita")
    Case 1045
      objTextFile.WriteLine("set " & varName & "=plk")
    Case 1038
      objTextFile.WriteLine("set " & varName & "=hun")
    Case 1029
      objTextFile.WriteLine("set " & varName & "=csy")
    Case 1053, 2077
      objTextFile.WriteLine("set " & varName & "=sve")
    Case 1055
      objTextFile.WriteLine("set " & varName & "=trk")
    Case 1032
      objTextFile.WriteLine("set " & varName & "=ell")
    Case 1030
      objTextFile.WriteLine("set " & varName & "=dan")
    Case 1044, 2068
      objTextFile.WriteLine("set " & varName & "=nor")
    Case 1035
      objTextFile.WriteLine("set " & varName & "=fin")
    Case 4, 2052, 3076, 4100
      objTextFile.WriteLine("set " & varName & "=chs")
    Case 1028
      objTextFile.WriteLine("set " & varName & "=cht")
    Case 1041
      objTextFile.WriteLine("set " & varName & "=jpn")
    Case 1042
      objTextFile.WriteLine("set " & varName & "=kor")
    Case 1, 1025, 2049, 3073, 4097, 5121, 6145, 7169, 8193, 9217, 10241, _
         11265, 12289, 13313, 14337, 15361, 16385
      objTextFile.WriteLine("set " & varName & "=ara")
    Case 1037
      objTextFile.WriteLine("set " & varName & "=heb")
  End Select
End Sub

Private Sub WriteVersion2File(objTextFile, strPrefix, strVersion)
Dim arrayVersion, i

  If Len(strVersion) > 0 Then
    arrayVersion = Split(strVersion, ".")
    For i = 0 To UBound(arrayVersion)
      Select Case i
        Case 0
          objTextFile.WriteLine("set " & strPrefix & "_MAJOR=" & arrayVersion(i))         
        Case 1
          objTextFile.WriteLine("set " & strPrefix & "_MINOR=" & arrayVersion(i))         
        Case 2
          objTextFile.WriteLine("set " & strPrefix & "_BUILD=" & arrayVersion(i))         
        Case 3
          objTextFile.WriteLine("set " & strPrefix & "_REVISION=" & arrayVersion(i))         
      End Select
    Next
  Else
    objTextFile.WriteLine("set " & strPrefix & "_MAJOR=0")         
  End If
End Sub

Private Sub WriteDXName2File(objTextFile, strDXVersion)

  Select Case strDXVersion
    Case "4.02.0095"
      objTextFile.WriteLine("set DIRECTX_NAME=1.0")
    Case "4.03.00.1096"
      objTextFile.WriteLine("set DIRECTX_NAME=2.0")
    Case "4.04.0068"
      objTextFile.WriteLine("set DIRECTX_NAME=3.0")
    Case "4.04.0069"
      objTextFile.WriteLine("set DIRECTX_NAME=3.0")
    Case "4.05.00.0155"
      objTextFile.WriteLine("set DIRECTX_NAME=5.0")
    Case "4.05.01.1721"
      objTextFile.WriteLine("set DIRECTX_NAME=5.0")
    Case "4.05.01.1998"
      objTextFile.WriteLine("set DIRECTX_NAME=5.0")
    Case "4.06.02.0436"
      objTextFile.WriteLine("set DIRECTX_NAME=6.0")
    Case "4.07.00.0700"
      objTextFile.WriteLine("set DIRECTX_NAME=7.0")
    Case "4.07.00.0716"
      objTextFile.WriteLine("set DIRECTX_NAME=7.0a")
    Case "4.08.00.0400"
      objTextFile.WriteLine("set DIRECTX_NAME=8.0")
    Case "4.08.01.0881"
      objTextFile.WriteLine("set DIRECTX_NAME=8.1")
    Case "4.08.01.0810"
      objTextFile.WriteLine("set DIRECTX_NAME=8.1")
    Case "4.09.00.0900"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0")
    Case "4.09.0000.0900"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0")
    Case "4.09.00.0901"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0a")
    Case "4.09.0000.0901"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0a")
    Case "4.09.00.0902"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0b")
    Case "4.09.0000.0902"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0b")
    Case "4.09.00.0904"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0c")
    Case "4.09.0000.0904"
      objTextFile.WriteLine("set DIRECTX_NAME=9.0c")
  End Select
End Sub

Private Function OfficeInstallPath(objShell, strVersionInfix)
Dim strRegVal

  OfficeInstallPath = ""
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_InstRoot & strRegValOfficePath)
  If strRegVal <> "" Then 
    OfficeInstallPath = strRegVal
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx64 & strVersionInfix & strRegKeyOfficeSuffix_InstRoot & strRegValOfficePath)
  If strRegVal <> "" Then 
    OfficeInstallPath = strRegVal
    Exit Function
  End If
End Function

Private Function OfficeLanguageCode(objShell, strVersionInfix)
Dim strRegVal

  OfficeLanguageCode = 0
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_Inst)
  If strRegVal <> "" Then 
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx64 & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_Inst)
  If strRegVal <> "" Then 
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_User & strVersionInfix & strRegKeyOfficeSuffix_Language & strRegValOfficeLanguage_User)
  If strRegVal <> "" Then 
    OfficeLanguageCode = CInt(strRegVal)
    Exit Function
  End If
End Function

Private Function OfficeSPVersion(strExeVersion, idxApp)
Dim arrayVersion, arraySPs, arrayBuilds, i

  OfficeSPVersion = 0
  arrayVersion = Split(strExeVersion, ".")
  Select Case CInt(arrayVersion(0))
    Case 10
      arraySPs = Split(strBuildNumbers_Oxp, ";")
    Case 11
      arraySPs = Split(strBuildNumbers_O2k3, ";")
    Case 12
      arraySPs = Split(strBuildNumbers_O2k7, ";")
    Case Else
      arraySPs = Split("0,0,0,0,0,0", ";")
  End Select
  If UBound(arrayVersion) < idxBuild Then
    Exit Function
  End If
  For i = 0 To UBound(arraySPs)
    arrayBuilds = Split(arraySPs(i), ",")
    If UBound(arrayBuilds) < idxApp Then
      Exit Function
    End If
    If CInt(arrayVersion(idxBuild)) >= CInt(arrayBuilds(idxApp)) Then
      OfficeSPVersion = i
    End If
  Next
End Function

' Main
Set wshShell = WScript.CreateObject("WScript.Shell")
strSystemFolder = wshShell.ExpandEnvironmentStrings("%SystemRoot%") & "\system32"
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strWUAFileName = strSystemFolder & "\wuaueng.dll"
strMSIFileName = strSystemFolder & "\msi.dll"
strWSHFileName = strSystemFolder & "\vbscript.dll"
strWMPFileName = strSystemFolder & "\wmp.dll"
strRDPFileName = strSystemFolder & "\mstsc.exe"
strCmdFileName = strTempFolder & "\SetSystemEnvVars.cmd"

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

' Determine Windows system properties
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
For Each objWMIQuery in objWMIService.ExecQuery("Select * from Win32_OperatingSystem") 
  objCmdFile.WriteLine("set OS_CAPTION=" & objWMIQuery.Caption)
  WriteVersion2File objCmdFile, "OS_VERSION", objWMIQuery.Version
  strOSVersion = Left(objWMIQuery.Version, 3) ' For determination of Windows activation state - see below
  objCmdFile.WriteLine("set OS_SP_VERSION_MAJOR=" & objWMIQuery.ServicePackMajorVersion)
  objCmdFile.WriteLine("set OS_SP_VERSION_MINOR=" & objWMIQuery.ServicePackMinorVersion)
  objCmdFile.WriteLine("set OS_LANGUAGE_CODE=" & objWMIQuery.OSLanguage)
  WriteLanguage2File objCmdFile, "OS_LANGUAGE", objWMIQuery.OSLanguage
  objCmdFile.WriteLine("set SystemDirectory=" & objWMIQuery.SystemDirectory)
Next
For Each objWMIQuery in objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
  objCmdFile.WriteLine("set OS_ARCHITECTURE=" & LCase(Left(objWMIQuery.SystemType, 3)))
  objCmdFile.WriteLine("set DOMAIN_ROLE=" & objWMIQuery.DomainRole)
Next

' Determine Windows Update Agent version 
If objFileSystem.FileExists(strWUAFileName) Then
  WriteVersion2File objCmdFile, "WUA_VERSION", objFileSystem.GetFileVersion(strWUAFileName)
Else
  WriteVersion2File objCmdFile, "WUA_VERSION", ""
End If

' Determine Microsoft Installer version
If objFileSystem.FileExists(strMSIFileName) Then
  WriteVersion2File objCmdFile, "MSI_VERSION", objFileSystem.GetFileVersion(strMSIFileName)
Else
  WriteVersion2File objCmdFile, "MSI_VERSION", ""
End If

' Determine Windows Script Host version
If objFileSystem.FileExists(strWSHFileName) Then
  WriteVersion2File objCmdFile, "WSH_VERSION", objFileSystem.GetFileVersion(strWSHFileName)
Else
  WriteVersion2File objCmdFile, "WSH_VERSION", ""
End If

' Determine Internet Explorer version
WriteVersion2File objCmdFile, "IE_VERSION", RegRead(wshShell, strRegKeyIE & strRegValVersion)

' Determine Microsoft Data Access Components version
WriteVersion2File objCmdFile, "MDAC_VERSION", RegRead(wshShell, strRegKeyMDAC & strRegValVersion)

' Determine Microsoft DirectX version
WriteVersion2File objCmdFile, "DIRECTX_VERSION", RegRead(wshShell, strRegKeyDirectX & strRegValVersion)
WriteDXName2File objCmdFile, RegRead(wshShell, strRegKeyDirectX & strRegValVersion)

' Determine Microsoft .NET Framework 3.5 SP1 installation state
WriteVersion2File objCmdFile, "DOTNET_VERSION", RegRead(wshShell, strRegKeyDotNet35 & strRegValVersion)

' Determine Windows PowerShell version
WriteVersion2File objCmdFile, "PSH_VERSION", RegRead(wshShell, strRegKeyPowerShell & strRegValPShVersion)

' Determine Remote Desktop Connection (Terminal Services Client) version
If objFileSystem.FileExists(strRDPFileName) Then
  WriteVersion2File objCmdFile, "RDP_VERSION", objFileSystem.GetFileVersion(strRDPFileName)
Else
  WriteVersion2File objCmdFile, "RDP_VERSION", ""
End If

' Determine Windows Media Player version
If objFileSystem.FileExists(strWMPFileName) Then
  WriteVersion2File objCmdFile, "WMP_VERSION", objFileSystem.GetFileVersion(strWMPFileName)
Else
  WriteVersion2File objCmdFile, "WMP_VERSION", ""
End If

' Determine Office version
arrayOfficeNames = Split(strOfficeNames, ",")
arrayOfficeVersions = Split(strRegKeyOfficeInfixes_Version, ",")
arrayOfficeAppNames = Split(strOfficeAppNames, ",")
arrayOfficeExeNames = Split(strOfficeExeNames, ",")
For i = 0 To UBound(arrayOfficeNames)
  strOfficeInstallPath = OfficeInstallPath(wshShell, arrayOfficeVersions(i)) 
  If strOfficeInstallPath <> "" Then
    For j = 0 To UBound(arrayOfficeExeNames)
      If objFileSystem.FileExists(strOfficeInstallPath & arrayOfficeExeNames(j)) Then
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_VERSION_APP=" & arrayOfficeAppNames(j))
        strOfficeExeVersion = objFileSystem.GetFileVersion(strOfficeInstallPath & arrayOfficeExeNames(j)) 
        WriteVersion2File objCmdFile, UCase(arrayOfficeNames(i)) & "_VERSION", strOfficeExeVersion  
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_SP_VERSION=" & OfficeSPVersion(strOfficeExeVersion, j))
        languageCode = OfficeLanguageCode(wshShell, arrayOfficeVersions(i))
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANGUAGE_CODE=" & languageCode)
        If languageCode = 0 Then
          objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANGUAGE=%OS_LANGUAGE%")
        Else
          WriteLanguage2File objCmdFile, UCase(arrayOfficeNames(i)) & "_LANGUAGE", languageCode
        End If
        Exit For
      End If
    Next
  End If
Next
For Each strProduct In CreateObject("WindowsInstaller.Installer").Products
  If UCase(strProduct) = "{6EECB283-E65F-40EF-86D3-D51BF02A8D43}" Then
    objCmdFile.WriteLine("set OFFICE_CONVERTER_PACK=1")
  End If
  If UCase(strProduct) = "{90120000-0020-0407-0000-0000000FF1CE}" Then
    objCmdFile.WriteLine("set OFFICE_COMPATIBILITY_PACK=1")
  End If
Next

'
' Perform the following WMI queries last, since they might fail if WMI is damaged 
'

' Determine state of automatic updates service 
For Each objWMIQuery in objWMIService.ExecQuery("Select * from Win32_Service Where Name = 'wuauserv'")
  objCmdFile.WriteLine("set AU_SERVICE_STATE_INITIAL=" & objWMIQuery.State)
  objCmdFile.WriteLine("set AU_SERVICE_START_MODE=" & objWMIQuery.StartMode)
Next

' Determine Windows activation state - not available on Windows 2000 and Vista systems 
If (strOSVersion = "5.1") Or (strOSVersion = "5.2") Then
  For Each objWMIQuery in objWMIService.ExecQuery("Select * from Win32_WindowsProductActivation")
    objCmdFile.WriteLine("set OS_ACTIVATION_REQUIRED=" & objWMIQuery.ActivationRequired)
  Next
End If

objCmdFile.Close
WScript.Quit(0)
