; *** WSUS Offline Update 6.8.6 - Installer ***
; ***      Author: T. Wittrock, Kiel        ***
; ***  Dialog scaling added by Th. Baisch   ***

#include <GUIConstants.au3>
#RequireAdmin

Dim Const $caption                    = "WSUS Offline Update 6.8.6 - Installer"

; Registry constants
Dim Const $reg_key_wsh_hklm           = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Script Host\Settings"
Dim Const $reg_key_wsh_hkcu           = "HKEY_CURRENT_USER\Software\Microsoft\Windows Script Host\Settings"
Dim Const $reg_key_ie                 = "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer"
Dim Const $reg_key_dotnet35           = "HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v3.5"
Dim Const $reg_key_dotnet4            = "HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v4\Full"
Dim Const $reg_key_powershell         = "HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1\PowerShellEngine"
Dim Const $reg_key_msev2              = "HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Security Client"
Dim Const $reg_key_wd                 = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Defender"
Dim Const $reg_key_fontdpi            = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontDPI"
Dim Const $reg_key_windowmetrics      = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
Dim Const $reg_key_windowsupdate      = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate"

Dim Const $reg_val_default            = ""
Dim Const $reg_val_enabled            = "Enabled"
Dim Const $reg_val_version            = "Version"
Dim Const $reg_val_pshversion         = "PowerShellVersion"
Dim Const $reg_val_logpixels          = "LogPixels"
Dim Const $reg_val_applieddpi         = "AppliedDPI"
Dim Const $reg_val_wustatusserver     = "WUStatusServer"

; Defaults
Dim Const $default_logpixels          = 96
Dim Const $target_version_dotnet35    = "3.5.30729.01"
Dim Const $target_version_dotnet4     = "4.0.30319"
Dim Const $target_version_powershell  = "2.0"

; INI file constants
Dim Const $ini_section_installation   = "Installation"
Dim Const $ini_value_backup           = "backup"
Dim Const $ini_value_ie7              = "instie7"
Dim Const $ini_value_ie8              = "instie8"
Dim Const $ini_value_ie9              = "instie9"
Dim Const $ini_value_cpp              = "updatecpp"
Dim Const $ini_value_dx               = "updatedx"
Dim Const $ini_value_wmp              = "updatewmp"
Dim Const $ini_value_tsc              = "updatetsc"
Dim Const $ini_value_dotnet35         = "instdotnet35"
Dim Const $ini_value_dotnet4          = "instdotnet4"
Dim Const $ini_value_powershell       = "instpsh"
Dim Const $ini_value_wd               = "instwd"
Dim Const $ini_value_msse             = "instmsse"
Dim Const $ini_value_converters       = "instofccnvs"

Dim Const $ini_section_control        = "Control"
Dim Const $ini_value_verify           = "verify"
Dim Const $ini_value_autoreboot       = "autoreboot"
Dim Const $ini_value_shutdown         = "shutdown"

Dim Const $ini_section_messaging      = "Messaging"
Dim Const $ini_value_showlog          = "showlog"

Dim Const $ini_section_misc           = "Miscellaneous"
Dim Const $ini_value_wustatusserver   = "WUStatusServer"

Dim Const $enabled                    = "Enabled"
Dim Const $disabled                   = "Disabled"

; Paths
Dim Const $path_max_length            = 128
Dim Const $path_invalid_chars         = "%&()^+,;=" 
Dim Const $path_rel_builddate         = "\builddate.txt"
Dim Const $path_rel_hashes            = "\md\"
Dim Const $path_rel_autologon         = "\bin\Autologon.exe"
Dim Const $path_rel_cpp               = "\cpp\"
Dim Const $path_rel_instdirectx       = "\win\glb\directx_*_redist.exe"
Dim Const $path_rel_instdotnet35      = "\dotnet\dotnetfx35.exe"
Dim Const $path_rel_instdotnet4       = "\dotnet\dotNetFx40_Full_x86_x64.exe"
Dim Const $path_rel_instconverters    = "\ofc\glb\ork.exe"
Dim Const $path_rel_msse              = "\msse\"

Dim $maindlg, $scriptdir, $mapped, $inifilename, $backup, $converters, $ie7, $ie8, $ie9, $cpp, $dx, $wmp, $tsc, $dotnet35, $dotnet4, $psh, $msse, $wd, $verify, $autoreboot, $shutdown, $showlog, $btn_start, $btn_exit, $options, $builddate 
Dim $dlgheight, $groupwidth, $txtwidth, $txtheight, $btnwidth, $btnheight, $txtxoffset, $txtyoffset, $txtxpos, $txtypos

Func ShowGUIInGerman()
  If ($CmdLine[0] > 0) Then
    Switch StringLower($CmdLine[1])
      Case "enu"
        Return False
      Case "deu"
        Return True
    EndSwitch
  EndIf
  Return ( (@OSLang = "0007") OR (@OSLang = "0407") OR (@OSLang = "0807") OR (@OSLang = "0C07") OR (@OSLang = "1007") OR (@OSLang = "1407") )
EndFunc

; Returns script directory, also sets global variable $mapped
Func AssignScriptDirectory()
Dim $result, $netdrives, $i
  
  ; Check if script directory is a network share, map if unmapped 
  $result = ""
  $mapped = False  
  If DriveGetType(@ScriptDir) = "Network" Then
    If StringInStr(@ScriptDir, "\\") = 0 Then
      $result = @ScriptDir
    Else
      $netdrives = DriveGetDrive("NETWORK")
      If NOT @error Then
        For $i = 1 to $netdrives[0]
          If StringInStr(@ScriptDir, DriveMapGet($netdrives[$i])) > 0 Then
            $result = $netdrives[$i] & StringRight(@ScriptDir, StringLen(@ScriptDir) - StringLen(DriveMapGet($netdrives[$i])))
            ExitLoop
          EndIf
        Next
      EndIf
      If $result = "" Then
        $result = DriveMapAdd("*", @ScriptDir)
        If @error Then
          $result = "" 
        Else
          $mapped = True  
        EndIf
      EndIf
    EndIf
  Else
    $result = @ScriptDir
  EndIf
  Return $result
EndFunc

Func PathValid($basepath)
Dim $result, $arr_invalid, $i

  If StringLen($basepath) > $path_max_length Then
    $result = False
  Else
    $result = True
    $arr_invalid = StringSplit($path_invalid_chars, "")
    For $i = 1 to $arr_invalid[0]
      If StringInStr($basepath, $arr_invalid[$i]) > 0 Then
        $result = False
        ExitLoop
      EndIf
    Next
  EndIf
  Return $result
EndFunc

Func MediumBuildDate($basepath)
Dim $result

  $result = FileReadLine($basepath & $path_rel_builddate)
  If @error Then
    $result = ""
  EndIf
  Return $result
EndFunc

Func WSHAvailable()
Dim $reg_val

  $reg_val = RegRead($reg_key_wsh_hklm, $reg_val_enabled)
  If ($reg_val = "0") Then
    Return 0
  EndIf
  $reg_val = RegRead($reg_key_wsh_hkcu, $reg_val_enabled)
  If ($reg_val = "0") Then
    Return 0
  EndIf
  Return 1
EndFunc

Func IEVersion()
Dim $reg_val

  $reg_val = RegRead($reg_key_ie, $reg_val_version)
  Return StringLeft($reg_val, StringInStr($reg_val, ".") - 1)
EndFunc

Func DotNet35Version()
  Return RegRead($reg_key_dotnet35, $reg_val_version)
EndFunc

Func DotNet4Version()
  Return RegRead($reg_key_dotnet4, $reg_val_version)
EndFunc

Func PowerShellVersion()
  Return RegRead($reg_key_powershell, $reg_val_pshversion)
EndFunc

Func MSSEInstalled()
Dim $dummy

  $dummy = RegRead($reg_key_msev2, $reg_val_default)
  Return (@error <= 0)
EndFunc

Func WDInstalled()
Dim $dummy

  $dummy = RegRead($reg_key_wd, $reg_val_default)
  Return (@error <= 0)
EndFunc

Func HashFilesPresent($basepath)
  Return FileExists($basepath & $path_rel_hashes)
EndFunc

Func AutologonPresent($basepath)
  Return FileExists($basepath & $path_rel_autologon)
EndFunc

Func CPPPresent($basepath)
  Return FileExists($basepath & $path_rel_cpp)
EndFunc

Func DirectXInstPresent($basepath)
  Return FileExists($basepath & $path_rel_instdirectx)
EndFunc

Func DotNet35InstPresent($basepath)
  Return FileExists($basepath & $path_rel_instdotnet35)
EndFunc

Func DotNet4InstPresent($basepath)
  Return FileExists($basepath & $path_rel_instdotnet4)
EndFunc

Func ConvertersInstPresent($basepath)
  Return FileExists($basepath & $path_rel_instconverters)
EndFunc

Func MSSEPresent($basepath)
  Return FileExists($basepath & $path_rel_msse)
EndFunc

Func SP1Present()
  Return StringInStr(@OSServicePack, "Service Pack 1") > 0
EndFunc

Func CalcGUISize()
  Dim $reg_val
  
  $reg_val = RegRead($reg_key_windowmetrics, $reg_val_applieddpi)
  If ($reg_val = "") Then
    $reg_val = RegRead($reg_key_fontdpi, $reg_val_logpixels)
  EndIf
  If ($reg_val = "") Then
    $reg_val = $default_logpixels
  EndIf
  $dlgheight = 305 * $reg_val / $default_logpixels
  If ShowGUIInGerman() Then
    $txtwidth = 230 * $reg_val / $default_logpixels
  Else
    $txtwidth = 200 * $reg_val / $default_logpixels
  EndIf
  $txtheight = 20 * $reg_val / $default_logpixels
  $btnwidth = 80 * $reg_val / $default_logpixels
  $btnheight = 25 * $reg_val / $default_logpixels
  $txtxoffset = 10 * $reg_val / $default_logpixels
  $txtyoffset = 10 * $reg_val / $default_logpixels
  Return 0
EndFunc	

; Main Dialog
AutoItSetOption("GUICloseOnESC", 0)
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayIconHide", 1)
CalcGUISize()
$groupwidth = 2 * $txtwidth + 2 * $txtxoffset
$maindlg = GUICreate($caption, $groupwidth + 2 * $txtxoffset, $dlgheight)
GUISetFont(8.5, 400, 0, "Sans Serif")

$scriptdir = AssignScriptDirectory()
$inifilename = $scriptdir & "\" & StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0, -1)) & "ini"

;  Label
$txtxpos = $txtxoffset
$txtypos = $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateLabel("Wählen Sie die gewünschten Optionen und klicken Sie auf 'Start'," & @LF & "um die fehlenden Microsoft-Updates auf Ihrem System zu installieren.", $txtxpos, $txtypos, 3 * $groupwidth / 4, 2 * $txtheight)
Else
  GUICtrlCreateLabel("Select desired options and click 'Start'" & @LF & "to install missing Microsoft updates on your computer.", $txtxpos, $txtypos, 3 * $groupwidth / 4, 2 * $txtheight)
EndIf

;  Medium info group
$builddate = MediumBuildDate($scriptdir)
If ($builddate <> "") Then
  $txtxpos = $txtxoffset + 3 * $groupwidth / 4
  $txtypos = 0
  GUICtrlCreateGroup("Medium info", $txtxpos, $txtypos, $groupwidth / 4, 2 * $txtheight)
  $txtxpos = $txtxpos + $txtxoffset
  $txtypos = $txtypos + 1.5 * $txtyoffset + 2
  GUICtrlCreateLabel("Build: " & $builddate, $txtxpos, $txtypos, $groupwidth / 4 - 2 * $txtxoffset, $txtheight)
EndIf

;  Installation group
$txtxpos = $txtxoffset
$txtypos = $txtyoffset + 1.5 * $txtheight
GUICtrlCreateGroup("Installation", $txtxpos, $txtypos, $groupwidth, 8 * $txtheight)

; Backup
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 1.5 * $txtyoffset
If ShowGUIInGerman() Then
  $backup = GUICtrlCreateCheckbox("Existierende Systemdateien sichern", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $backup = GUICtrlCreateCheckbox("Back up existing system files", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") ) Then
  GUICtrlSetState(-1, $GUI_CHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else
  If IniRead($inifilename, $ini_section_installation, $ini_value_backup, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install IE7
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $ie7 = GUICtrlCreateCheckbox("Internet Explorer 7 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $ie7 = GUICtrlCreateCheckbox("Install Internet Explorer 7", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
  OR (IEVersion() = "7") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If (IniRead($inifilename, $ini_section_installation, $ini_value_ie7, $disabled) = $enabled) Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install IE8
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $ie8 = GUICtrlCreateCheckbox("Internet Explorer 8 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $ie8 = GUICtrlCreateCheckbox("Install Internet Explorer 8", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then  
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else
  If (IniRead($inifilename, $ini_section_installation, $ini_value_ie8, $enabled) = $enabled) Then
    GUICtrlSetState(-1, $GUI_CHECKED)  
    GUICtrlSetState($ie7, $GUI_UNCHECKED)  
    GUICtrlSetState($ie7, $GUI_DISABLE)  
  Else  
    GUICtrlSetState(-1, $GUI_UNCHECKED)  
    If BitAND(GUICtrlRead($ie7), $GUI_CHECKED) = $GUI_CHECKED Then  
      GUICtrlSetState(-1, $GUI_DISABLE)  
    EndIf  
  EndIf  
EndIf

; Install IE9
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $ie9 = GUICtrlCreateCheckbox("Internet Explorer 9 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $ie9 = GUICtrlCreateCheckbox("Install Internet Explorer 9", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_XP") OR (@OSVersion = "WIN_2003") OR (IEVersion() = "9") ) Then  
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else
  If (IniRead($inifilename, $ini_section_installation, $ini_value_ie9, $disabled) = $enabled) Then
    GUICtrlSetState(-1, $GUI_CHECKED)  
    GUICtrlSetState($ie7, $GUI_UNCHECKED)  
    GUICtrlSetState($ie7, $GUI_DISABLE)  
    GUICtrlSetState($ie8, $GUI_UNCHECKED)  
    GUICtrlSetState($ie8, $GUI_DISABLE)  
  Else  
    GUICtrlSetState(-1, $GUI_UNCHECKED)  
    If ( (BitAND(GUICtrlRead($ie7), $GUI_CHECKED) = $GUI_CHECKED) OR (BitAND(GUICtrlRead($ie8), $GUI_CHECKED) = $GUI_CHECKED) ) Then  
      GUICtrlSetState(-1, $GUI_DISABLE)  
    EndIf  
  EndIf  
EndIf

; Update C++ runtime libraries
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $cpp = GUICtrlCreateCheckbox("C++-Laufzeitbibliotheken aktualisieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $cpp = GUICtrlCreateCheckbox("Update C++ runtime libraries", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If CPPPresent($scriptdir) Then
  If IniRead($inifilename, $ini_section_installation, $ini_value_cpp, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
Else  
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

; Update DirectX runtime libraries
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $dx = GUICtrlCreateCheckbox("DirectX-Laufzeitbibliotheken aktualisieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $dx = GUICtrlCreateCheckbox("Update DirectX runtime libraries", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If DirectXInstPresent($scriptdir) Then
  If IniRead($inifilename, $ini_section_installation, $ini_value_dx, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
Else  
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

; Update Windows Media Player
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $wmp = GUICtrlCreateCheckbox("Windows Media Player aktualisieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $wmp = GUICtrlCreateCheckbox("Update Windows Media Player", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2003") OR (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_wmp, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Update Windows Terminal Services Client
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $tsc = GUICtrlCreateCheckbox("Terminal Services Client aktualisieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $tsc = GUICtrlCreateCheckbox("Update Terminal Services Client", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_tsc, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install .NET Framework 3.5 SP1
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $dotnet35 = GUICtrlCreateCheckbox(".NET Framework 3.5 SP1 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $dotnet35 = GUICtrlCreateCheckbox("Install .NET Framework 3.5 SP1", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
  OR (DotNet35Version() = $target_version_dotnet35) OR (NOT DotNet35InstPresent($scriptdir)) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_dotnet35, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install .NET Framework 4
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $dotnet4 = GUICtrlCreateCheckbox(".NET Framework 4 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $dotnet4 = GUICtrlCreateCheckbox("Install .NET Framework 4", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (DotNet4Version() = $target_version_dotnet4) OR (NOT DotNet4InstPresent($scriptdir)) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_dotnet4, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install Windows PowerShell 2.0
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $psh = GUICtrlCreateCheckbox("PowerShell 2.0 installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $psh = GUICtrlCreateCheckbox("Install PowerShell 2.0", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
  OR ( (DotNet35Version() <> $target_version_dotnet35) AND (BitAND(GUICtrlRead($dotnet35), $GUI_CHECKED) <> $GUI_CHECKED) ) _
  OR (PowerShellVersion() = $target_version_powershell) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_powershell, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install Windows Defender
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $wd = GUICtrlCreateCheckbox("Windows Defender installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $wd = GUICtrlCreateCheckbox("Install Windows Defender", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
  OR WDInstalled() ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_wd, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install Microsoft Security Essentials
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $msse = GUICtrlCreateCheckbox("Microsoft Security Essentials installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $msse = GUICtrlCreateCheckbox("Install Microsoft Security Essentials", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_2003") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_2008R2") _
  OR MSSEInstalled() OR (NOT MSSEPresent($scriptdir)) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_msse, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install file format converters for Office
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $converters = GUICtrlCreateCheckbox("Office-Dateiformat-Konverter installieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $converters = GUICtrlCreateCheckbox("Install Office file format converters", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If NOT ConvertersInstPresent($scriptdir) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_converters, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

;  Control group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Steuerung", $txtxpos, $txtypos, $groupwidth, 3 * $txtheight)
Else
  GUICtrlCreateGroup("Control", $txtxpos, $txtypos, $groupwidth, 3 * $txtheight)
EndIf

; Verify
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 1.5 * $txtyoffset
If ShowGUIInGerman() Then
  $verify = GUICtrlCreateCheckbox("Installationspakete verifizieren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $verify = GUICtrlCreateCheckbox("Verify installation packages", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If HashFilesPresent($scriptdir) Then
  If IniRead($inifilename, $ini_section_control, $ini_value_verify, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Automatic reboot and recall
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $autoreboot = GUICtrlCreateCheckbox("Automatisch neu starten und fortsetzen", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $autoreboot = GUICtrlCreateCheckbox("Automatic reboot and recall", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (NOT AutologonPresent($scriptdir)) OR (DriveGetType(@ScriptDir) = "Network") ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_control, $ini_value_autoreboot, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

;  Automatic shutdown
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $shutdown = GUICtrlCreateCheckbox("Nach Aktualisierung herunterfahren", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $shutdown = GUICtrlCreateCheckbox("Shut down after updating", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_control, $ini_value_shutdown, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

; Show log file
$txtxpos = $txtxoffset + $groupwidth / 2
If ShowGUIInGerman() Then
  $showlog = GUICtrlCreateCheckbox("Protokolldatei anzeigen", $txtxpos, $txtypos, $txtwidth, $txtheight)
Else
  $showlog = GUICtrlCreateCheckbox("Show log file", $txtxpos, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (IniRead($inifilename, $ini_section_messaging, $ini_value_showlog, $disabled) = $enabled) _
 AND (BitAND(GUICtrlRead($shutdown), $GUI_CHECKED) <> $GUI_CHECKED) ) Then  
  GUICtrlSetState(-1, $GUI_CHECKED)  
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)  
  If BitAND(GUICtrlRead($shutdown), $GUI_CHECKED) = $GUI_CHECKED Then  
    GUICtrlSetState(-1, $GUI_DISABLE)  
  EndIf  
EndIf  

;  Start button
$txtypos = $txtypos + 3.5 * $txtyoffset
$btn_start = GUICtrlCreateButton("Start", $txtxoffset, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing (-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM)

;  Exit button
If ShowGUIInGerman() Then
  $btn_exit = GUICtrlCreateButton("Ende", $groupwidth - $btnwidth + $txtxoffset, $txtypos, $btnwidth, $btnheight)
Else
  $btn_exit = GUICtrlCreateButton("Exit", $groupwidth - $btnwidth + $txtxoffset, $txtypos, $btnwidth, $btnheight)
EndIf
GUICtrlSetResizing (-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM)

; GUI message loop
GUISetState()
If NOT WSHAvailable() Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Der Windows Script Host ist deaktiviert. Bitte prüfen Sie die Registrierungswerte" _
                     & @LF & "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Script Host\Settings\Enabled und" _
                     & @LF & "HKEY_CURRENT_USER\Software\Microsoft\Windows Script Host\Settings\Enabled")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "Windows Script Host is disabled on this machine. Please check registry values" _
                    & @LF & "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Script Host\Settings\Enabled and" _
                    & @LF & "HKEY_CURRENT_USER\Software\Microsoft\Windows Script Host\Settings\Enabled")
    Exit(1)
  EndIf
EndIf
If $scriptdir = "" Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Dem Skript-Pfad " & @ScriptDir _
                     & @LF & "konnte kein Laufwerksbuchstabe zugewiesen werden.")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "Unable to assign a drive letter" _
                    & @LF & "to the script path " & @ScriptDir)
    Exit(1)
  EndIf
EndIf
If NOT PathValid($scriptdir) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Der Skript-Pfad darf nicht mehr als " & $path_max_length & " Zeichen lang sein" _
                     & @LF & "und darf keines der folgenden Zeichen enthalten: " & $path_invalid_chars)
    Exit(1)
  Else
    MsgBox(0x2010, "Fehler", "The script path must not be more than " & $path_max_length & " characters long" _
                     & @LF & "and must not contain any of the following characters: " & $path_invalid_chars)
    Exit(1)
  EndIf
EndIf
If ( (StringRight(EnvGet("TEMP"), 1) = "\") OR (StringRight(EnvGet("TEMP"), 1) = ":") ) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Die Umgebungsvariable TEMP" & @LF & "enthält einen abschließenden Backslash ('\')" & @LF & "oder einen abschließenden Doppelpunkt (':').")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "The environment variable TEMP" & @LF & "contains a trailing backslash ('\')" & @LF & "or a trailing colon (':').")
    Exit(1)
  EndIf
EndIf
If ( ( ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") ) AND (@OSServicePack <> "Service Pack 2") ) _
  OR ( ( (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") ) AND (NOT SP1Present()) ) ) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2040, "Information", "Unter Windows Vista / 7 / Server 2008(R2) müssen Sie" _
                          & @LF & "die Installation der Updates" _
                          & @LF & "nach der Installation des/der Service Packs" _
                          & @LF & "und dem obligaten Neustart manuell wiederaufnehmen.")
  Else
    MsgBox(0x2040, "Information", "Under Windows Vista / 7 / Server 2008(R2), you have to" _
                          & @LF & "manually resume the installation of updates" _
                          & @LF & "after Service Pack installation and mandatory reboot.")
  EndIf
  GUICtrlSetState($converters, $GUI_UNCHECKED)
  GUICtrlSetState($converters, $GUI_DISABLE)
  GUICtrlSetState($ie8, $GUI_UNCHECKED)
  GUICtrlSetState($ie8, $GUI_DISABLE)
  GUICtrlSetState($ie9, $GUI_UNCHECKED)
  GUICtrlSetState($ie9, $GUI_DISABLE)
  GUICtrlSetState($dx, $GUI_UNCHECKED)
  GUICtrlSetState($dx, $GUI_DISABLE)
  GUICtrlSetState($wmp, $GUI_UNCHECKED)
  GUICtrlSetState($wmp, $GUI_DISABLE)
  GUICtrlSetState($tsc, $GUI_UNCHECKED)
  GUICtrlSetState($tsc, $GUI_DISABLE)
  GUICtrlSetState($dotnet35, $GUI_UNCHECKED)
  GUICtrlSetState($dotnet35, $GUI_DISABLE)
  GUICtrlSetState($dotnet4, $GUI_UNCHECKED)
  GUICtrlSetState($dotnet4, $GUI_DISABLE)
  GUICtrlSetState($psh, $GUI_UNCHECKED)
  GUICtrlSetState($psh, $GUI_DISABLE)
  GUICtrlSetState($msse, $GUI_UNCHECKED)
  GUICtrlSetState($msse, $GUI_DISABLE)
  GUICtrlSetState($autoreboot, $GUI_CHECKED)
  GUICtrlSetState($autoreboot, $GUI_DISABLE)
  GUICtrlSetState($shutdown, $GUI_UNCHECKED)
  GUICtrlSetState($shutdown, $GUI_DISABLE)
  GUICtrlSetState($showlog, $GUI_UNCHECKED)
  GUICtrlSetState($showlog, $GUI_DISABLE)
EndIf
While 1
  Switch GUIGetMsg()
    Case $GUI_EVENT_CLOSE    ; Window closed
      If $mapped Then
        DriveMapDel($scriptdir)
      EndIf
      ExitLoop

    Case $btn_exit           ; Exit Button pressed
      If $mapped Then
        DriveMapDel($scriptdir)
      EndIf
      ExitLoop

    Case $ie7                ; IE7 check box toggled  
      If (BitAND(GUICtrlRead($ie7), $GUI_CHECKED) = $GUI_CHECKED) Then    
        GUICtrlSetState($ie8, $GUI_UNCHECKED)  
        GUICtrlSetState($ie8, $GUI_DISABLE)  
        GUICtrlSetState($ie9, $GUI_UNCHECKED)  
        GUICtrlSetState($ie9, $GUI_DISABLE)  
      Else
        If ( (@OSVersion = "WIN_2000") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then  
          GUICtrlSetState($ie8, $GUI_UNCHECKED)  
          GUICtrlSetState($ie8, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie8, $GUI_ENABLE)  
        EndIf  
        If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_XP") OR (@OSVersion = "WIN_2003") OR (IEVersion() = "9") ) Then  
          GUICtrlSetState($ie9, $GUI_UNCHECKED)  
          GUICtrlSetState($ie9, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie9, $GUI_ENABLE)  
        EndIf  
      EndIf  
     
    Case $ie8                ; IE8 check box toggled  
      If (BitAND(GUICtrlRead($ie8), $GUI_CHECKED) = $GUI_CHECKED) Then
        GUICtrlSetState($ie7, $GUI_UNCHECKED)  
        GUICtrlSetState($ie7, $GUI_DISABLE)  
        GUICtrlSetState($ie9, $GUI_UNCHECKED)  
        GUICtrlSetState($ie9, $GUI_DISABLE)  
      Else  
        If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
          OR (IEVersion() = "7") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then
          GUICtrlSetState($ie7, $GUI_UNCHECKED)  
          GUICtrlSetState($ie7, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie7, $GUI_ENABLE)  
        EndIf  
        If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_XP") OR (@OSVersion = "WIN_2003") OR (IEVersion() = "9") ) Then  
          GUICtrlSetState($ie9, $GUI_UNCHECKED)  
          GUICtrlSetState($ie9, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie9, $GUI_ENABLE)  
        EndIf  
      EndIf  

    Case $ie9                ; IE9 check box toggled  
      If (BitAND(GUICtrlRead($ie9), $GUI_CHECKED) = $GUI_CHECKED) Then  
        GUICtrlSetState($ie7, $GUI_UNCHECKED)  
        GUICtrlSetState($ie7, $GUI_DISABLE)  
        GUICtrlSetState($ie8, $GUI_UNCHECKED)  
        GUICtrlSetState($ie8, $GUI_DISABLE)  
      Else  
        If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
          OR (IEVersion() = "7") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then
          GUICtrlSetState($ie7, $GUI_UNCHECKED)  
          GUICtrlSetState($ie7, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie7, $GUI_ENABLE)  
        EndIf  
        If ( (@OSVersion = "WIN_2000") OR (IEVersion() = "8") OR (IEVersion() = "9") ) Then  
          GUICtrlSetState($ie8, $GUI_UNCHECKED)  
          GUICtrlSetState($ie8, $GUI_DISABLE)  
        Else
          GUICtrlSetState($ie8, $GUI_ENABLE)  
        EndIf  
      EndIf  

    Case $dotnet35             ; .NET check box toggled
      If ( (BitAND(GUICtrlRead($dotnet35), $GUI_CHECKED) = $GUI_CHECKED) _
       AND (@OSVersion <> "WIN_7") AND (@OSVersion <> "WIN_2008R2") AND (PowerShellVersion() <> $target_version_powershell) ) Then  
        GUICtrlSetState($psh, $GUI_ENABLE)
      Else
        GUICtrlSetState($psh, $GUI_UNCHECKED)
        GUICtrlSetState($psh, $GUI_DISABLE)
      EndIf

    Case $msse                 ; Microsoft Security Essentials check box toggled
      If (BitAND(GUICtrlRead($msse), $GUI_CHECKED) = $GUI_CHECKED) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Bei der Installation der Microsoft Security Essentials wird eine" _
                               & @LF & "obligate 'Windows Genuine Advantage' (WGA)-Prüfung durchgeführt." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($msse, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The installation of Microsoft Security Essentials performs" _
                               & @LF & "a mandatory 'Windows Genuine Advantage' (WGA) check." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($msse, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $autoreboot         ; Automatic reboot check box toggled
      If ( (BitAND(GUICtrlRead($autoreboot), $GUI_CHECKED) = $GUI_CHECKED) _
       AND ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") ) ) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Die Option 'Automatisch neu starten und fortsetzen' deaktiviert temporär" _
                               & @LF & "die Benutzerkontensteuerung (UAC), falls erforderlich." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($autoreboot, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The option 'Automatic reboot and recall' temporarily disables" _
                               & @LF & "the User Account Control (UAC), if required." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($autoreboot, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $shutdown           ; Automatic shutdown check box toggled  
      If (BitAND(GUICtrlRead($shutdown), $GUI_CHECKED) = $GUI_CHECKED) Then    
        GUICtrlSetState($showlog, $GUI_UNCHECKED)  
        GUICtrlSetState($showlog, $GUI_DISABLE)  
      Else  
        GUICtrlSetState($showlog, $GUI_ENABLE)  
      EndIf  

    Case $btn_start          ; Start Button pressed
      $options = IniRead($inifilename, $ini_section_misc, $ini_value_wustatusserver, "")    ; Dummy use of $options
      If $options <> "" Then
        RegWrite($reg_key_windowsupdate, $reg_val_wustatusserver, "REG_SZ", $options)
      EndIf
      $options = ""
      If BitAND(GUICtrlRead($backup), $GUI_CHECKED) <> $GUI_CHECKED Then
        $options = $options & " /nobackup"
      EndIf
      If BitAND(GUICtrlRead($ie7), $GUI_CHECKED) = $GUI_CHECKED Then  
        $options = $options & " /instie7"  
      EndIf  
      If BitAND(GUICtrlRead($ie8), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instie8"
      EndIf
      If BitAND(GUICtrlRead($ie9), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instie9"
      EndIf
      If BitAND(GUICtrlRead($cpp), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /updatecpp"
      EndIf
      If BitAND(GUICtrlRead($dx), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /updatedx"
      EndIf
      If BitAND(GUICtrlRead($wmp), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /updatewmp"
      EndIf
      If BitAND(GUICtrlRead($tsc), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /updatetsc"
      EndIf
      If BitAND(GUICtrlRead($dotnet35), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instdotnet35"
      EndIf
      If BitAND(GUICtrlRead($dotnet4), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instdotnet4"
      EndIf
      If BitAND(GUICtrlRead($psh), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instpsh"
      EndIf
      If BitAND(GUICtrlRead($wd), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instwd"
      EndIf
      If BitAND(GUICtrlRead($msse), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instmsse"
      EndIf
      If BitAND(GUICtrlRead($converters), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instofccnvs"
      EndIf
      If BitAND(GUICtrlRead($verify), $GUI_CHECKED) = $GUI_CHECKED Then  
        $options = $options & " /verify"  
      EndIf  
      If ( (BitAND(GUICtrlRead($autoreboot), $GUI_DISABLE) <> $GUI_DISABLE) _
       AND (BitAND(GUICtrlRead($autoreboot), $GUI_CHECKED) = $GUI_CHECKED) ) Then
        $options = $options & " /autoreboot"
      EndIf
      If BitAND(GUICtrlRead($shutdown), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /shutdown"
      EndIf
      If BitAND(GUICtrlRead($showlog), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /showlog"
      EndIf
      If (@OSArch <> "X86") Then
        DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1)
      EndIf
      If Run(@ComSpec & " /E:32768 /D /C Update.cmd" & $options, $scriptdir, @SW_HIDE) = 0 Then
        If ShowGUIInGerman() Then
          MsgBox(0x2010, "Fehler", "Fehler #" & @error & " beim Aufruf von" _
                           & @LF & @ComSpec & " /E:32768 /D /C Update.cmd" & $options & " in" _
                           & @LF & $scriptdir & ".")
        Else
          MsgBox(0x2010, "Error", "Error #" & @error & " when calling" _
                          & @LF & @ComSpec & " /E:32768 /D /C Update.cmd" & $options & " in" _
                          & @LF & $scriptdir & ".")
        EndIf
      Else
        ExitLoop
      EndIf
  EndSwitch
WEnd
Exit
