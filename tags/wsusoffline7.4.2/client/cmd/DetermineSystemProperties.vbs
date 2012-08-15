' *** Author: T. Wittrock, Kiel ***

Option Explicit

Private Const strWOUTempAdminName             = "WOUTempAdmin"
Private Const strRegKeyRootCerts              = "HKLM\Software\Microsoft\Active Setup\Installed Components\{EF289A85-8E57-408d-BE47-73B55609861A}\"
Private Const strRegKeyIE                     = "HKLM\Software\Microsoft\Internet Explorer\"
Private Const strRegKeyMDAC                   = "HKLM\Software\Microsoft\DataAccess\"
Private Const strRegKeyDirectX                = "HKLM\Software\Microsoft\DirectX\"
Private Const strRegKeyMSSL                   = "HKLM\Software\Microsoft\Silverlight\"
Private Const strRegKeyDotNet35               = "HKLM\Software\Microsoft\NET Framework Setup\NDP\v3.5\"
Private Const strRegKeyDotNet4                = "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\Full\"
Private Const strRegKeyPowerShell             = "HKLM\Software\Microsoft\PowerShell\1\PowerShellEngine\"
Private Const strRegKeyMSSE                   = "HKLM\Software\Microsoft\Microsoft Security Client\"
Private Const strRegKeyMSSEUninstall          = "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Security Client\"
Private Const strRegKeyMSSEDefs               = "HKLM\Software\Microsoft\Microsoft Antimalware\Signature Updates\"
Private Const strRegKeyWD                     = "HKLM\Software\Microsoft\Windows Defender\"
Private Const strRegKeyWDDefs                 = "HKLM\Software\Microsoft\Windows Defender\Signature Updates\"
Private Const strRegKeyPowerCfg               = "HKCU\Control Panel\PowerCfg\"
Private Const strRegValVersion                = "Version"
Private Const strRegValDisplayVersion         = "DisplayVersion"
Private Const strRegValPShVersion             = "PowerShellVersion"
Private Const strRegValAVSVersion             = "AVSignatureVersion"
Private Const strRegValASSVersion             = "ASSignatureVersion"
Private Const strRegValDisableAntiSpyware     = "DisableAntiSpyware"
Private Const strRegValCurrentPowerPolicy     = "CurrentPowerPolicy"
Private Const strRegKeyOfficePrefix_Mx86      = "HKLM\Software\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_Mx64      = "HKLM\Software\Wow6432Node\Microsoft\Office\"
Private Const strRegKeyOfficePrefix_User      = "HKCU\Software\Microsoft\Office\"
Private Const strRegKeyOfficeInfixes_Version  = "11.0,12.0,14.0"
Private Const strRegKeyOfficeSuffix_InstRoot  = "\Common\InstallRoot\"
Private Const strRegKeyOfficeSuffix_Language  = "\Common\LanguageResources\"
Private Const strRegKeyOfficeSuffix_Outlook   = "\Outlook\"
Private Const strRegValOfficePath             = "Path"
Private Const strRegValOfficeLanguage_Inst    = "SKULanguage"
Private Const strRegValOfficeLanguage_User    = "InstallLanguage"
Private Const strRegValOfficeVersion          = "LastProduct"
Private Const strRegValOfficeArchitecture     = "Bitness"
Private Const strVersionSuffixes              = "MAJOR,MINOR,REVIS,BUILD"
Private Const strOfficeNames                  = "o2k3,o2k7,o2k10"
Private Const strOfficeAppNames               = "Word,Excel,Outlook,Powerpoint,Access,FrontPage"
Private Const strOfficeExeNames               = "WINWORD.EXE,EXCEL.EXE,OUTLOOK.EXE,POWERPNT.EXE,MSACCESS.EXE,FRONTPG.EXE"
Private Const strBuildNumbers_O2k3            = "5604,5612,5510,5529,5614,5516;6359,6355,6353,6361,6355,6356;6568,6560,6565,6564,6566,6552;8169,8169,8169,8169,8166,8164"
Private Const strBuildNumbers_O2k7            = "4518,4518,4518,4518,4518,4518;6211,6214,6212,6211,6211,6211;6425,6425,6423,6425,6423,6423;6612,6611,6607,6600,6606,6600"
Private Const strBuildNumbers_O2k10           = "4762,4756,4760,4754,4750,4750;6024,6024,6025,6009,6024,6024"
Private Const idxBuild                        = 2

Dim wshShell, objNetwork, objFileSystem, objCmdFile, objWMIService, objQueryItem, objInstaller, arrayOfficeNames, arrayOfficeVersions, arrayOfficeAppNames, arrayOfficeExeNames
Dim strSystemFolder, strTempFolder, strWUAFileName, strMSIFileName, strWSHFileName, strTSCFileName, strWMPFileName, strCmdFileName, strOSVersion, strOfficeInstallPath, strOfficeExeVersion, strProduct, strPatch, languageCode, i, j
Dim cpp2005_x86_old, cpp2005_x86_new, cpp2005_x64_old, cpp2005_x64_new, cpp2008_x86_old, cpp2008_x86_new, cpp2008_x64_old, cpp2008_x64_new, cpp2010_x86_old, cpp2010_x86_new, cpp2010_x64_old, cpp2010_x64_new

Private Function RegExists(objShell, strName)
Dim dummy
  On Error Resume Next
  dummy = objShell.RegRead(strName)
  RegExists = (Err >= 0)
  Err.Clear
End Function

Private Function RegRead(objShell, strName)
  On Error Resume Next
  RegRead = objShell.RegRead(strName)
  If Err <> 0 Then
    RegRead = ""
    Err.Clear
  End If
End Function

Private Function GetFileVersion(objFS, strName)
  On Error Resume Next
  GetFileVersion = objFS.GetFileVersion(strName)
  If Err <> 0 Then
    WScript.Quit(1)
  End If
End Function

Private Sub WriteLanguageToFile(cmdFile, varName, langCode, writeShortLang, writeExtLang)
  Select Case langCode
' supported languages
    Case &H0009, &H0409, &H0809, &H0C09, &H1009, &H1409, &H1809, &H1C09, &H2009, &H2409, &H2809, &H2C09, &H3009, &H3409, &H4009, &H4409, &H4809
      cmdFile.WriteLine("set " & varName & "=enu")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=en")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=en-us")
    Case &H000C, &H040C, &H080C, &H0C0C, &H100C, &H140C, &H180C
      cmdFile.WriteLine("set " & varName & "=fra")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=fr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fr-fr")
    Case &H000A, &H080A, &H0C0A, &H100A, &H140A, &H180A, &H1C0A, &H200A, &H240A, &H280A, &H2C0A, &H300A, &H340A, &H380A, &H3C0A, &H400A, &H440A, &H480A, &H4C0A, &H500A, &H540A
      cmdFile.WriteLine("set " & varName & "=esn")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=es")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=es-es")
    Case &H0019, &H0419
      cmdFile.WriteLine("set " & varName & "=rus")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ru")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ru-ru")
    Case &H0816
      cmdFile.WriteLine("set " & varName & "=ptg")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pt")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pt-pt")
    Case &H0416
      cmdFile.WriteLine("set " & varName & "=ptb")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pt")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pt-br")
    Case &H0007, &H0407, &H0807, &H0C07, &H1007, &H1407
      cmdFile.WriteLine("set " & varName & "=deu")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=de")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=de-de")
    Case &H0013, &H0413, &H0813
      cmdFile.WriteLine("set " & varName & "=nld")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=nl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=nl-nl")
    Case &H0010, &H0410, &H0810
      cmdFile.WriteLine("set " & varName & "=ita")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=it")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=it-it")
    Case &H0015, &H0415
      cmdFile.WriteLine("set " & varName & "=plk")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=pl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pl-pl")
    Case &H000E, &H040E
      cmdFile.WriteLine("set " & varName & "=hun")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=hu")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hu-hu")
    Case &H0005, &H0405
      cmdFile.WriteLine("set " & varName & "=csy")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=cs")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=cs-cz")
    Case &H001D, &H041D, &H081D
      cmdFile.WriteLine("set " & varName & "=sve")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=sv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sv-se")
    Case &H001F, &H041F
      cmdFile.WriteLine("set " & varName & "=trk")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=tr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=tr-tr")
    Case &H0008, &H0408
      cmdFile.WriteLine("set " & varName & "=ell")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=el")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=el-gr")
    Case &H0006, &H0406
      cmdFile.WriteLine("set " & varName & "=dan")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=da")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=da-dk")
    Case &H0014, &H0414, &H7C14, &H0814, &H7814
      cmdFile.WriteLine("set " & varName & "=nor")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=no")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=nb-no")
    Case &H000B, &H040B
      cmdFile.WriteLine("set " & varName & "=fin")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=fi")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fi-fi")
    Case &H0004, &H0804, &H1004, &H7804
      cmdFile.WriteLine("set " & varName & "=chs")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=zh")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=zh-cn")
    Case &H0404, &H0C04, &H1404, &H7C04
      cmdFile.WriteLine("set " & varName & "=cht")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=zh")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=zh-tw")
    Case &H0011, &H0411
      cmdFile.WriteLine("set " & varName & "=jpn")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ja")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ja-jp")
    Case &H0012, &H0412
      cmdFile.WriteLine("set " & varName & "=kor")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ko")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ko-kr")
    Case &H0001, &H0401, &H0801, &H0C01, &H1001, &H1401, &H1801, &H1C01, &H2001, &H2401, &H2801, &H2C01, &H3001, &H3401, &H3801, &H3C01, &H4001
      cmdFile.WriteLine("set " & varName & "=ara")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=ar")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ar-sa")
    Case &H000D, &H040D
      cmdFile.WriteLine("set " & varName & "=heb")
      If writeShortLang Then cmdFile.WriteLine("set " & varName & "_SHORT=he")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=he-il")

' unsupported languages, detection only
    Case &H002B, &H042B
      cmdFile.WriteLine("set " & varName & "=hye")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hy-am")
    Case &H002D, &H042D
      cmdFile.WriteLine("set " & varName & "=euq")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=eu-es")
    Case &H0023, &H0423
      cmdFile.WriteLine("set " & varName & "=bel")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=be-by")
    Case &H007E, &H047E
      cmdFile.WriteLine("set " & varName & "=bre")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=br-fr")
    Case &H0002, &H0402
      cmdFile.WriteLine("set " & varName & "=bgr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=bg-bg")
    Case &H0003, &H0403
      cmdFile.WriteLine("set " & varName & "=cat")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ca-es")
    Case &H0083, &H0483
      cmdFile.WriteLine("set " & varName & "=cos")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=co-fr")
    Case &H001A, &H041A, &H101A
      cmdFile.WriteLine("set " & varName & "=hrv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hr-hr")
    Case &H0025, &H0425
      cmdFile.WriteLine("set " & varName & "=eti")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=et-ee")
    Case &H0038, &H0438
      cmdFile.WriteLine("set " & varName & "=fos")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fo-fo")
    Case &H0062, &H0462
      cmdFile.WriteLine("set " & varName & "=fyn")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fy-nl")
    Case &H0056, &H0456
      cmdFile.WriteLine("set " & varName & "=glc")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=gl-es")
    Case &H0037, &H0437
      cmdFile.WriteLine("set " & varName & "=kat")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ka-ge")
    Case &H006F, &H046F
      cmdFile.WriteLine("set " & varName & "=kal")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=kl-gl")
    Case &H0039, &H0439
      cmdFile.WriteLine("set " & varName & "=hin")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=hi-in")
    Case &H000F, &H040F
      cmdFile.WriteLine("set " & varName & "=isl")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=is-is")
    Case &H003C, &H083C
      cmdFile.WriteLine("set " & varName & "=ire")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ga-ie")
    Case &H0026, &H0426
      cmdFile.WriteLine("set " & varName & "=lvi")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=lv-lv")
    Case &H0027, &H0427
      cmdFile.WriteLine("set " & varName & "=lth")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=lt-lt")
    Case &H0029, &H0429
      cmdFile.WriteLine("set " & varName & "=far")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=fa-ir")
    Case &H0046, &H0446
      cmdFile.WriteLine("set " & varName & "=pan")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=pa-in")
    Case &H0018, &H0418
      cmdFile.WriteLine("set " & varName & "=rom")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=ro-ro")
    Case &H004F, &H044F
      cmdFile.WriteLine("set " & varName & "=san")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sa-in")
    Case &H001B, &H041B
      cmdFile.WriteLine("set " & varName & "=sky")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sk-sk")
    Case &H0024, &H0424
      cmdFile.WriteLine("set " & varName & "=slv")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=sl-si")
    Case &H001E, &H041E
      cmdFile.WriteLine("set " & varName & "=tha")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=th-th")
    Case &H0022, &H0422
      cmdFile.WriteLine("set " & varName & "=ukr")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=uk-ua")
    Case &H002A, &H042A
      cmdFile.WriteLine("set " & varName & "=vit")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=vi-vn")
    Case &H0052, &H0452
      cmdFile.WriteLine("set " & varName & "=cym")
      If writeExtLang Then cmdFile.WriteLine("set " & varName & "_EXT=cy-gb")
  End Select
End Sub

Private Sub WriteVersionToFile(cmdFile, strPrefix, strVersion)
Dim arraySuffixes, arrayVersion, i

  arraySuffixes = Split(strVersionSuffixes, ",")
  If Len(strVersion) > 0 Then
    arrayVersion = Split(strVersion, ".")
  Else
    arrayVersion = Split("0", ".")
  End If
  For i = 0 To UBound(arraySuffixes)
    If i > UBound(arrayVersion) Then
      cmdFile.WriteLine("set " & strPrefix & "_" & arraySuffixes(i) & "=0")
    Else
      cmdFile.WriteLine("set " & strPrefix & "_" & arraySuffixes(i) & "=" & arrayVersion(i))
    End If
  Next
End Sub

Private Sub WriteDXNameToFile(cmdFile, strDXVersion)
  Select Case strDXVersion
    Case "4.02.0095"
      cmdFile.WriteLine("set DX_NAME=1.0")
    Case "4.03.00.1096"
      cmdFile.WriteLine("set DX_NAME=2.0")
    Case "4.04.0068", "4.04.0069"
      cmdFile.WriteLine("set DX_NAME=3.0")
    Case "4.05.00.0155", "4.05.01.1721", "4.05.01.1998"
      cmdFile.WriteLine("set DX_NAME=5.0")
    Case "4.06.02.0436"
      cmdFile.WriteLine("set DX_NAME=6.0")
    Case "4.07.00.0700"
      cmdFile.WriteLine("set DX_NAME=7.0")
    Case "4.07.00.0716"
      cmdFile.WriteLine("set DX_NAME=7.0a")
    Case "4.08.00.0400"
      cmdFile.WriteLine("set DX_NAME=8.0")
    Case "4.08.01.0881", "4.08.01.0810"
      cmdFile.WriteLine("set DX_NAME=8.1")
    Case "4.09.00.0900", "4.09.0000.0900"
      cmdFile.WriteLine("set DX_NAME=9.0")
    Case "4.09.00.0901", "4.09.0000.0901"
      cmdFile.WriteLine("set DX_NAME=9.0a")
    Case "4.09.00.0902", "4.09.0000.0902"
      cmdFile.WriteLine("set DX_NAME=9.0b")
    Case "4.09.00.0904", "4.09.0000.0904"
      cmdFile.WriteLine("set DX_NAME=9.0c")
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

Private Function OfficeArchitecture(objShell, strVersionInfix)
Dim strRegVal

  OfficeArchitecture = "x86"
  strRegVal = RegRead(objShell, strRegKeyOfficePrefix_Mx86 & strVersionInfix & strRegKeyOfficeSuffix_Outlook & strRegValOfficeArchitecture)
  If strRegVal <> "" Then
    OfficeArchitecture = strRegVal
  End If
End Function

Private Function OfficeSPVersion(strExeVersion, idxApp)
Dim arrayVersion, arraySPs, arrayBuilds, i

  OfficeSPVersion = 0
  arrayVersion = Split(strExeVersion, ".")
  Select Case CInt(arrayVersion(0))
    Case 11
      arraySPs = Split(strBuildNumbers_O2k3, ";")
    Case 12
      arraySPs = Split(strBuildNumbers_O2k7, ";")
    Case 14
      arraySPs = Split(strBuildNumbers_O2k10, ";")
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
strTSCFileName = strSystemFolder & "\mstsc.exe"
strCmdFileName = strTempFolder & "\SetSystemEnvVars.cmd"

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
Set objCmdFile = objFileSystem.CreateTextFile(strCmdFileName, True)

' Determine basic system properties
Set objNetwork = WScript.CreateObject("WScript.Network")
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
' Documentation: http://msdn.microsoft.com/en-us/library/aa394239(VS.85).aspx
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
  objCmdFile.WriteLine("set OS_CAPTION=" & objQueryItem.Caption)
  WriteVersionToFile objCmdFile, "OS_VER", objQueryItem.Version
  strOSVersion = Left(objQueryItem.Version, 3) ' For determination of Windows activation state - see below
  objCmdFile.WriteLine("set OS_SP_VER_MAJOR=" & objQueryItem.ServicePackMajorVersion)
  objCmdFile.WriteLine("set OS_SP_VER_MINOR=" & objQueryItem.ServicePackMinorVersion)
  objCmdFile.WriteLine("set OS_LANG_CODE=0x" & Hex(objQueryItem.OSLanguage))
  WriteLanguageToFile objCmdFile, "OS_LANG", objQueryItem.OSLanguage, True, False
  If Left(strOSVersion, 1) = "6" Then
    If (objQueryItem.OperatingSystemSKU = 12) Or (objQueryItem.OperatingSystemSKU = 13) Or (objQueryItem.OperatingSystemSKU = 14) Then
      objCmdFile.WriteLine("set OS_CORE=1")
    End If
  End If
  objCmdFile.WriteLine("set SystemDirectory=" & objQueryItem.SystemDirectory)
Next
' Documentation: http://msdn.microsoft.com/en-us/library/aa394102(VS.85).aspx
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
  objCmdFile.WriteLine("set OS_ARCH=" & LCase(Left(objQueryItem.SystemType, 3)))
  objCmdFile.WriteLine("set OS_DOMAIN_ROLE=" & objQueryItem.DomainRole)
Next
If objNetwork.UserName = strWOUTempAdminName Then
  ' Documentation: http://msdn.microsoft.com/en-us/library/aa394507(VS.85).aspx
  For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_UserAccount Where Domain = '" & objNetwork.ComputerName & "' And Name = '" & objNetwork.UserName & "'")
    objCmdFile.WriteLine("set USERSID=" & objQueryItem.SID)
  Next
End If
' Documentation: http://msdn.microsoft.com/en-us/library/hww8txat(v=VS.85).aspx
objCmdFile.WriteLine("set FS_TYPE=" & objFileSystem.GetDrive(objFileSystem.GetDriveName(wshShell.CurrentDirectory)).FileSystem)
' Determine current power policy
objCmdFile.WriteLine("set PWR_POL_IDX=" & RegRead(wshShell, strRegKeyPowerCfg & strRegValCurrentPowerPolicy))

' Determine Windows Update Agent version
If objFileSystem.FileExists(strWUAFileName) Then
  WriteVersionToFile objCmdFile, "WUA_VER", GetFileVersion(objFileSystem, strWUAFileName)
Else
  WriteVersionToFile objCmdFile, "WUA_VER", ""
End If

' Determine Microsoft Installer version
If objFileSystem.FileExists(strMSIFileName) Then
  WriteVersionToFile objCmdFile, "MSI_VER", GetFileVersion(objFileSystem, strMSIFileName)
Else
  WriteVersionToFile objCmdFile, "MSI_VER", ""
End If

' Determine Windows Script Host version
If objFileSystem.FileExists(strWSHFileName) Then
  WriteVersionToFile objCmdFile, "WSH_VER", GetFileVersion(objFileSystem, strWSHFileName)
Else
  WriteVersionToFile objCmdFile, "WSH_VER", ""
End If

' Determine Internet Explorer version
WriteVersionToFile objCmdFile, "IE_VER", RegRead(wshShell, strRegKeyIE & strRegValVersion)

' Determine Microsoft Data Access Components version
WriteVersionToFile objCmdFile, "MDAC_VER", RegRead(wshShell, strRegKeyMDAC & strRegValVersion)

' Determine Microsoft DirectX version
WriteVersionToFile objCmdFile, "DX_CORE_VER", RegRead(wshShell, strRegKeyDirectX & strRegValVersion)
WriteDXNameToFile objCmdFile, RegRead(wshShell, strRegKeyDirectX & strRegValVersion)

' Determine Microsoft Silverlight version
WriteVersionToFile objCmdFile, "MSSL_VER", RegRead(wshShell, strRegKeyMSSL & strRegValVersion)

' Determine Microsoft .NET Framework 3.5 SP1 installation state
WriteVersionToFile objCmdFile, "DOTNET35_VER", RegRead(wshShell, strRegKeyDotNet35 & strRegValVersion)
WriteVersionToFile objCmdFile, "DOTNET4_VER", RegRead(wshShell, strRegKeyDotNet4 & strRegValVersion)

' Determine Windows PowerShell version
WriteVersionToFile objCmdFile, "PSH_VER", RegRead(wshShell, strRegKeyPowerShell & strRegValPShVersion)

' Determine Microsoft Security Essentials installation state
If RegExists(wshShell, strRegKeyMSSE) Then
  objCmdFile.WriteLine("set MSSE_INSTALLED=1")
Else
  objCmdFile.WriteLine("set MSSE_INSTALLED=0")
End If

' Determine Microsoft Security Essentials' version
WriteVersionToFile objCmdFile, "MSSE_VER", RegRead(wshShell, strRegKeyMSSEUninstall & strRegValDisplayVersion)

' Determine Microsoft Antimalware signatures' version
WriteVersionToFile objCmdFile, "MSSEDEFS_VER", RegRead(wshShell, strRegKeyMSSEDefs & strRegValAVSVersion)

' Determine Windows Defender installation state
If RegExists(wshShell, strRegKeyWD) Then
  objCmdFile.WriteLine("set WD_INSTALLED=1")
Else
  objCmdFile.WriteLine("set WD_INSTALLED=0")
End If

' Determine Windows Defender state
objCmdFile.WriteLine("set WD_DISABLED=" & RegRead(wshShell, strRegKeyWD & strRegValDisableAntiSpyware))

' Determine Microsoft Antispyware signatures' version
WriteVersionToFile objCmdFile, "WDDEFS_VER", RegRead(wshShell, strRegKeyWDDefs & strRegValASSVersion)

' Determine Microsoft Root Certificates' version
WriteVersionToFile objCmdFile, "RCERTS_VER", Replace(RegRead(wshShell, strRegKeyRootCerts & strRegValVersion), ",", ".")

' Determine Remote Desktop Connection (Terminal Services Client) version
If objFileSystem.FileExists(strTSCFileName) Then
  WriteVersionToFile objCmdFile, "TSC_VER", GetFileVersion(objFileSystem, strTSCFileName)
Else
  WriteVersionToFile objCmdFile, "TSC_VER", ""
End If

' Determine Windows Media Player version
If objFileSystem.FileExists(strWMPFileName) Then
  WriteVersionToFile objCmdFile, "WMP_VER", GetFileVersion(objFileSystem, strWMPFileName)
Else
  WriteVersionToFile objCmdFile, "WMP_VER", ""
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
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_VER_APP=" & arrayOfficeAppNames(j))
        strOfficeExeVersion = GetFileVersion(objFileSystem, strOfficeInstallPath & arrayOfficeExeNames(j))
        WriteVersionToFile objCmdFile, UCase(arrayOfficeNames(i)) & "_VER", strOfficeExeVersion
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_SP_VER=" & OfficeSPVersion(strOfficeExeVersion, j))
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_ARCH=" & OfficeArchitecture(wshShell, arrayOfficeVersions(i)))
        languageCode = OfficeLanguageCode(wshShell, arrayOfficeVersions(i))
        objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANG_CODE=0x" & Hex(languageCode))
        If languageCode = 0 Then
          objCmdFile.WriteLine("set " & UCase(arrayOfficeNames(i)) & "_LANG=%OS_LANG%")
        Else
          WriteLanguageToFile objCmdFile, UCase(arrayOfficeNames(i)) & "_LANG", languageCode, False, False
        End If
        Exit For
      End If
    Next
  End If
Next

' Determine installed products
cpp2005_x86_old = False
cpp2005_x86_new = False
cpp2005_x64_old = False
cpp2005_x64_new = False
cpp2008_x86_old = False
cpp2008_x86_new = False
cpp2008_x64_old = False
cpp2008_x64_new = False
cpp2010_x86_old = False
cpp2010_x86_new = False
cpp2010_x64_old = False
cpp2010_x64_new = False
Set objInstaller = CreateObject("WindowsInstaller.Installer")
For Each strProduct In objInstaller.Products
  Select Case UCase(strProduct)
    Case "{90120000-0020-0407-0000-0000000FF1CE}"
      objCmdFile.WriteLine("set OFC_COMP_PACK=1")
    Case "{90140000-2005-0000-0000-0000000FF1CE}"
      objCmdFile.WriteLine("set OFC_FILE_VALID=1")
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2007/01/16/mailbag-how-to-detect-the-presence-of-the-vc-8-0-runtime-redistributable-package.aspx
    Case "{A49F249F-0C91-497F-86DF-B2585E8E76B7}", "{7299052B-02A4-4627-81F2-1818DA5D550D}", "{837B34E3-7C30-493C-8F6A-2B0F04E2912C}"
      cpp2005_x86_old = True
    Case "{710F4C1C-CC18-4C49-8CBF-51240C89A1A2}"
      cpp2005_x86_new = True
    Case "{6E8E85E8-CE4B-4FF5-91F7-04999C9FAE6A}", "{071C9B48-7C32-4621-A0AC-3F809523288F}", "{6CE5BAE9-D3CA-4B99-891A-1DC6C118A5FC}"
      cpp2005_x64_old = True
    Case "{AD8A2FA1-06E7-4B0D-927D-6E54B3D31028}"
      cpp2005_x64_new = True
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2009/01/29/9384143.aspx
    Case "{09298F26-A95C-31E2-9D95-2C60F586F075}", "{09C0A8D5-EEC1-369D-8C7A-2E2DD17DCA5E}", "{31B44A9A-7CFE-3039-AEAE-A664F3C5F7BD}", "{402ED4A1-8F5B-387A-8688-997ABF58B8F2}", _
         "{527BBE2F-1FED-3D8B-91CB-4DB0F838E69E}", "{57660847-B1F7-35BD-9118-F62EB863A598}", "{6AFCA4E1-9B78-3640-8F72-A7BF33448200}", "{820B6609-4C97-3A2B-B644-573B06A0F0CC}", _
         "{86CE1746-9EFF-3C9C-8755-81EA8903AC34}", "{887868A2-D6DE-3255-AA92-AA0B5A59B874}", "{9A25302D-30C0-39D9-BD6F-21E6EC160475}", "{9B775AA1-7B10-379A-9B16-7E373790568C}", _
         "{A09D5493-0D9F-3211-B3BF-DD7ABBB318C1}", "{CA8A885F-E95B-3FC6-BB91-F4D9377C7686}", "{CC1DB186-550F-3CFE-A2A9-EBA5E5A34BC1}", "{DCB46B42-723F-350E-B18A-449BC6C21636}", _
         "{F03CB3EF-DC16-35CE-B3C1-C68EA09E5E97}", "{F2E0402D-AA60-32E3-8480-39AD5CE79DF2}", "{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}", "{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}"
      cpp2008_x86_old = True
    Case "{9BE518E6-ECC6-35A9-88E4-87755C07200F}"
      cpp2008_x86_new = True
    Case "{02A39130-2CF3-30CA-8623-30F6071A4221}", "{092EE08C-60DE-3FE6-B113-90076EC06D0D}", "{0A157668-EDB7-34C8-8C51-6A914CAC1EA6}", "{14297226-E0A0-3781-8911-E9D529552663}", _
         "{2DFD8316-9EF1-3210-908C-4CB61961C1AC}", "{32A08044-0CFA-3758-902C-5D97746BA9A9}", "{350AA351-21FA-3270-8B7A-835434E766AD}", "{484D36AC-327E-390E-85C8-9F2B176BA2B6}", _
         "{56F27690-F6EA-3356-980A-02BA379506EE}", "{6F29F195-B11C-3EAD-B883-997BB29DFA17}", "{8220EEFE-38CD-377E-8595-13398D740ACE}", "{92B8FD1F-C1AE-3750-8577-631B0AA85DF5}", _
         "{9B3F0A88-790D-3AD9-9F96-B19CF2746452}", "{9EDBA064-0381-3D1F-9096-CD1710366647}", "{A96702F7-EFC8-3EED-BE46-22C809D4EBE5}", "{D04659D1-EB2D-3DE5-A833-837A623CCCF7}", _
         "{D285FC5F-3021-32E9-9C59-24CA325BDC5C}", "{E34002C7-8CE7-3F76-B36C-09FA973BC4F6}", "{F1685080-A18F-39F7-87CC-1FC1C5357364}", "{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}"
      cpp2008_x64_old = True
    Case "{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}"
      cpp2008_x64_new = True
    ' Documentation: http://blogs.msdn.com/b/astebner/archive/2010/05/05/10008146.aspx
    Case "{196BB40D-1578-3D01-B289-BEFC77A11A1E}", "{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}"
      cpp2010_x86_old = True
      For Each strPatch In objInstaller.Patches(strProduct)
        If UCase(strPatch) = "{6F8500D2-A80F-3347-9081-B41E71C8592B}" Then cpp2010_x86_new = True
      Next
    Case "{DA5E371C-6333-3D8A-93A4-6FD5B20BCC6E}", "{1D8E6291-B0D5-35EC-8441-6616F567A0F7}"
      cpp2010_x64_old = True
      For Each strPatch In objInstaller.Patches(strProduct)
        If UCase(strPatch) = "{C67045D4-F4DE-3AB5-B2DB-E3F5DAC14D9C}" Then cpp2010_x64_new = True
      Next
  End Select
Next

If (cpp2005_x86_old) And (Not cpp2005_x86_new) Then objCmdFile.WriteLine("set CPP_2005_x86=1")
If (cpp2005_x64_old) And (Not cpp2005_x64_new) Then objCmdFile.WriteLine("set CPP_2005_x64=1")
If (cpp2008_x86_old) And (Not cpp2008_x86_new) Then objCmdFile.WriteLine("set CPP_2008_x86=1")
If (cpp2008_x64_old) And (Not cpp2008_x64_new) Then objCmdFile.WriteLine("set CPP_2008_x64=1")
If (cpp2010_x86_old) And (Not cpp2010_x86_new) Then objCmdFile.WriteLine("set CPP_2010_x86=1")
If (cpp2010_x64_old) And (Not cpp2010_x64_new) Then objCmdFile.WriteLine("set CPP_2010_x64=1")

'
' Perform the following WMI queries last, since they might fail if WMI is damaged
'

' Determine state of Windows Update service
For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_Service Where Name = 'wuauserv'")
  objCmdFile.WriteLine("set AU_SVC_STATE_INITIAL=" & objQueryItem.State)
  objCmdFile.WriteLine("set AU_SVC_START_MODE=" & objQueryItem.StartMode)
Next

' Determine Windows activation state - not available on Windows 2000 and Vista systems
If (strOSVersion = "5.1") Or (strOSVersion = "5.2") Then
  For Each objQueryItem in objWMIService.ExecQuery("Select * from Win32_WindowsProductActivation")
    objCmdFile.WriteLine("set OS_ACTIVATION_REQUIRED=" & objQueryItem.ActivationRequired)
  Next
End If

objCmdFile.Close
WScript.Quit(0)
