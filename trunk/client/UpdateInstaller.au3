; *** WSUS Offline Update 6.2 - Installer ***
; ***  Author: T. Wittrock, RZ Uni Kiel   ***

#include <GUIConstants.au3>
#RequireAdmin

Dim Const $caption                  = "WSUS Offline Update 6.2 - Installer"

; Registry constants
Dim Const $reg_key_wsh_hklm         = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Script Host\Settings"
Dim Const $reg_key_wsh_hkcu         = "HKEY_CURRENT_USER\Software\Microsoft\Windows Script Host\Settings"
Dim Const $reg_key_ie               = "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer"
Dim Const $reg_key_dotnet35         = "HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v3.5"
Dim Const $reg_key_powershell1      = "HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1"
Dim Const $reg_val_enabled          = "Enabled"
Dim Const $reg_val_version          = "Version"
Dim Const $reg_val_install          = "Install"
Dim Const $target_version_dotnet35  = "3.5.30729.01"

; INI file constants
Dim Const $ini_section_installation = "Installation"
Dim Const $ini_section_control      = "Control"
Dim Const $ini_section_messaging    = "Messaging"
Dim Const $ini_value_backup         = "backup"
Dim Const $ini_value_ie8            = "instie8"
Dim Const $ini_value_dotnet         = "instdotnet"
Dim Const $ini_value_powershell     = "instpsh"
Dim Const $ini_value_office         = "updateoffice"
Dim Const $ini_value_converters     = "instofccnvs"
Dim Const $ini_value_autoreboot     = "autoreboot"
Dim Const $ini_value_showlog        = "showlog"
Dim Const $enabled                  = "Enabled"
Dim Const $disabled                 = "Disabled"

; Paths
Dim Const $path_rel_instdotnet      = "\dotnet\dotnetfx35.exe"

Dim Const $txtwidth = 240, $txtheight = 20, $txtxoffset = 10, $btnwidth = 80, $btnheight = 25

Dim $maindlg, $scriptdir, $netdrives, $i, $strpos, $inifilename, $backup, $ie8, $dotnet, $powershell, $office, $converters, $autoreboot, $showlog, $btn_start, $btn_exit, $options, $txtypos

Func ShowGUIInGerman()
  If ($CmdLine[0] > 0) Then
    Switch StringLower($CmdLine[1])
      Case "enu"
        Return False
      Case "deu"
        Return True
      Case Else
        Return ( (@OSLang = "0407") OR (@OSLang = "0807") OR (@OSLang = "0c07") OR (@OSLang = "1007") OR (@OSLang = "1407") )
    EndSwitch
  Else
    Return ( (@OSLang = "0407") OR (@OSLang = "0807") OR (@OSLang = "0c07") OR (@OSLang = "1007") OR (@OSLang = "1407") )
  EndIf
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

Func DotNet35InstPresent()
  Return FileExists(@ScriptDir & $path_rel_instdotnet)
EndFunc

Func PowerShellInstalled()
  Return RegRead($reg_key_powershell1, $reg_val_install) = "1"
EndFunc


; Main Dialog
AutoItSetOption("GUICloseOnESC", 0)
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayIconHide", 1)
$maindlg = GUICreate($caption, $txtwidth + 2 * $txtxoffset, 255)
GUISetFont(8.5, 400, 0, "Sans Serif")

$scriptdir = "" 
If DriveGetType(@ScriptDir) = "Network" Then
  If StringInStr(@ScriptDir, "\\") = 0 Then
    $scriptdir = @ScriptDir
  Else
    $netdrives = DriveGetDrive("NETWORK")
    If NOT @error Then
      For $i = 1 to $netdrives[0]
        $strpos = StringInStr(@ScriptDir, DriveMapGet($netdrives[$i])) 
        If $strpos > 0 Then
          $scriptdir = $netdrives[$i] & StringRight(@ScriptDir, StringLen(@ScriptDir) - StringLen(DriveMapGet($netdrives[$i])))
          ExitLoop
        EndIf
      Next
    EndIf
  EndIf
Else
  $scriptdir = @ScriptDir
EndIf
$inifilename = $scriptdir & "\" & StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0, -1)) & "ini"

;  Label
$txtypos = 10
If ShowGUIInGerman() Then
  GUICtrlCreateLabel("Klicken Sie auf 'Start', um die Microsoft-Updates" & @LF & "auf Ihrem System zu installieren.", $txtxoffset, $txtypos, $txtwidth, 2 * $txtheight)
Else
  GUICtrlCreateLabel("Select options and click 'Start' to install" & @LF & "Microsoft updates on your computer.", $txtxoffset, $txtypos, $txtwidth, 2 * $txtheight)
EndIf

; Back up files
$txtypos = $txtypos + 2 * $txtheight
If ShowGUIInGerman() Then
  $backup = GUICtrlCreateCheckbox("Existierende Systemdateien sichern", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $backup = GUICtrlCreateCheckbox("Back up existing system files", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") ) Then
  GUICtrlSetState(-1, $GUI_CHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else
  If IniRead($inifilename, $ini_section_installation, $ini_value_backup, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install IE8
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $ie8 = GUICtrlCreateCheckbox("Internet Explorer 8 installieren", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $ie8 = GUICtrlCreateCheckbox("Install Internet Explorer 8", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (IEVersion() = "8") ) Then  
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_ie8, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install .NET Framework 3.5 SP1
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $dotnet = GUICtrlCreateCheckbox(".NET Framework 3.5 SP1 installieren", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $dotnet = GUICtrlCreateCheckbox("Install .NET Framework 3.5 SP1", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (DotNet35Version() = $target_version_dotnet35) OR (NOT DotNet35InstPresent()) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_dotnet, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Install Windows PowerShell 1.0
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $powershell = GUICtrlCreateCheckbox("PowerShell 1.0 installieren", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $powershell = GUICtrlCreateCheckbox("Install PowerShell 1.0", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If ( (@OSVersion = "WIN_2000") OR (@OSVersion = "WIN_2008") _
  OR ( (DotNet35Version() <> $target_version_dotnet35) AND (BitAND(GUICtrlRead($dotnet), $GUI_CHECKED) <> $GUI_CHECKED) ) _
  OR (PowerShellInstalled()) ) Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_installation, $ini_value_powershell, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Update Office products
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $office = GUICtrlCreateCheckbox("Office-Produkte aktualisieren", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $office = GUICtrlCreateCheckbox("Update Office products", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_installation, $ini_value_office, $enabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

; Install file format converters for Office
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $converters = GUICtrlCreateCheckbox("Dateiformat-Konverter installieren", 3 * $txtxoffset, $txtypos, $txtwidth - 2 * $txtxoffset, $txtheight)
Else
  $converters = GUICtrlCreateCheckbox("Install file format converters", 3 * $txtxoffset, $txtypos, $txtwidth - 2 * $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_installation, $ini_value_converters, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Automatic reboot and recall
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") ) Then
    $autoreboot = GUICtrlCreateCheckbox("Automatisch neu starten", $txtxoffset, $txtypos, $txtwidth, $txtheight)
  Else
    $autoreboot = GUICtrlCreateCheckbox("Automatisch neu starten und fortsetzen", $txtxoffset, $txtypos, $txtwidth, $txtheight)
  EndIf
Else
  If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") ) Then
    $autoreboot = GUICtrlCreateCheckbox("Automatic reboot", $txtxoffset, $txtypos, $txtwidth, $txtheight)
  Else
    $autoreboot = GUICtrlCreateCheckbox("Automatic reboot and recall", $txtxoffset, $txtypos, $txtwidth, $txtheight)
  EndIf
EndIf
If DriveGetType(@ScriptDir) = "Network" Then
  GUICtrlSetState(-1, $GUI_UNCHECKED)
  GUICtrlSetState(-1, $GUI_DISABLE)
Else  
  If IniRead($inifilename, $ini_section_control, $ini_value_autoreboot, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

; Show log file
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $showlog = GUICtrlCreateCheckbox("Protokolldatei anzeigen", $txtxoffset, $txtypos, $txtwidth, $txtheight)
Else
  $showlog = GUICtrlCreateCheckbox("Show log file", $txtxoffset, $txtypos, $txtwidth, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_messaging, $ini_value_showlog, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Start button
$txtypos = $txtypos + 1.5 * $txtheight
$btn_start = GUICtrlCreateButton("Start", $txtxoffset, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing (-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM)

;  Exit button
If ShowGUIInGerman() Then
  $btn_exit = GUICtrlCreateButton("Ende", $txtwidth - $btnwidth + $txtxoffset, $txtypos, $btnwidth, $btnheight)
Else
  $btn_exit = GUICtrlCreateButton("Exit", $txtwidth - $btnwidth + $txtxoffset, $txtypos, $btnwidth, $btnheight)
EndIf
GUICtrlSetResizing (-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM)

; GUI message loop
$options = ""
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
    MsgBox(0x2010, "Fehler", "Die Update-Installation kann nicht" _
                     & @LF & "von einer Netzwerk-Freigabe gestartet werden," _
                     & @LF & "der kein Laufwerksbuchstabe zugewiesen ist.")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "The installation process cannot be run" _
                    & @LF & "from a network share without an assigned drive letter.")
    Exit(1)
  EndIf
EndIf
If StringRight(EnvGet("TEMP"), 1) = "\" Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Die Umgebungsvariable TEMP" _
                     & @LF & "enthält einen abschließenden Backslash ('\').")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "The environment variable TEMP" _
                    & @LF & "contains a trailing backslash ('\').")
    Exit(1)
  EndIf
EndIf
If ( (@OSVersion = "WIN_XP") AND (@OSServicePack = "") ) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Unter Windows XP müssen Sie das Service Pack 1a oder 2" _
                     & @LF & "vor der automatischen Aktualisierung manuell installieren.")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "Under Windows XP, you have to manually install" _
                    & @LF & "Service Pack 1a or 2 before automatic updating.")
    Exit(1)
  EndIf
EndIf
If ( ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") ) AND (@OSServicePack <> "Service Pack 2") ) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2040, "Information", "Unter Windows Vista / Server 2008 müssen Sie" _
                          & @LF & "nach der Installation der Service Packs 1 und 2" _
                          & @LF & "und dem obligaten Neustart" _
                          & @LF & "die Installation der Updates manuell wiederaufnehmen.")
  Else
    MsgBox(0x2040, "Information", "Under Windows Vista / Server 2008, you have to manually resume" _
                          & @LF & "the installation of updates after installation" _
                          & @LF & "of Service Packs 1 and 2 and mandatory reboot.")
  EndIf
  GUICtrlSetState($ie8, $GUI_UNCHECKED)
  GUICtrlSetState($ie8, $GUI_DISABLE)
  GUICtrlSetState($dotnet, $GUI_UNCHECKED)
  GUICtrlSetState($dotnet, $GUI_DISABLE)
  GUICtrlSetState($powershell, $GUI_UNCHECKED)
  GUICtrlSetState($powershell, $GUI_DISABLE)
  GUICtrlSetState($office, $GUI_UNCHECKED)
  GUICtrlSetState($office, $GUI_DISABLE)
  GUICtrlSetState($converters, $GUI_UNCHECKED)
  GUICtrlSetState($converters, $GUI_DISABLE)
  GUICtrlSetState($autoreboot, $GUI_CHECKED)
  GUICtrlSetState($autoreboot, $GUI_DISABLE)
  GUICtrlSetState($showlog, $GUI_UNCHECKED)
  GUICtrlSetState($showlog, $GUI_DISABLE)
EndIf
While 1
  Switch GUIGetMsg()
    Case $GUI_EVENT_CLOSE    ; Window closed
      ExitLoop

    Case $btn_exit           ; Exit Button pressed
      ExitLoop

    Case $office             ; Update Office products check box toggled
      If BitAND(GUICtrlRead($office), $GUI_CHECKED) = $GUI_CHECKED Then
        GUICtrlSetState($converters, $GUI_ENABLE)
      Else
        GUICtrlSetState($converters, $GUI_UNCHECKED)
        GUICtrlSetState($converters, $GUI_DISABLE)
      EndIf

    Case $dotnet             ; .NET check box toggled
      If ( (BitAND(GUICtrlRead($dotnet), $GUI_CHECKED) = $GUI_CHECKED) _
       AND (@OSVersion <> "WIN_2008") AND (NOT PowerShellInstalled()) ) Then  
        GUICtrlSetState($powershell, $GUI_ENABLE)
      Else
        GUICtrlSetState($powershell, $GUI_UNCHECKED)
        GUICtrlSetState($powershell, $GUI_DISABLE)
      EndIf

    Case $autoreboot         ; Automatic reboot check box toggled
      If ( (BitAND(GUICtrlRead($autoreboot), $GUI_CHECKED) = $GUI_CHECKED) _
       AND (@OSVersion <> "WIN_VISTA") AND (@OSVersion <> "WIN_2008") ) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Die Option 'Automatisch neu starten und fortsetzen' verursachte auf manchen Systemen Probleme." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($autoreboot, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The option 'automatic reboot and recall' caused problems on some systems." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($autoreboot, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $btn_start          ; Start Button pressed
      If BitAND(GUICtrlRead($backup), $GUI_CHECKED) <> $GUI_CHECKED Then
        $options = $options & " /nobackup"
      EndIf
      If BitAND(GUICtrlRead($ie8), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instie8"
      EndIf
      If BitAND(GUICtrlRead($dotnet), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instdotnet"
      EndIf
      If BitAND(GUICtrlRead($powershell), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instpsh"
      EndIf
      If BitAND(GUICtrlRead($office), $GUI_CHECKED) <> $GUI_CHECKED Then
        $options = $options & " /ignoreoffice"
      EndIf
      If BitAND(GUICtrlRead($converters), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /instofccnvs"
      EndIf
      If BitAND(GUICtrlRead($autoreboot), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /autoreboot"
      EndIf
      If BitAND(GUICtrlRead($showlog), $GUI_CHECKED) = $GUI_CHECKED Then
        $options = $options & " /showlog"
      EndIf
      If (@OSArch <> "X86") Then
        DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1)
      EndIf
      If Run(@ComSpec & " /D /C Update.cmd" & $options, $scriptdir, @SW_HIDE) = 0 Then
        If ShowGUIInGerman() Then
          MsgBox(0x2010, "Fehler", "Fehler #" & @error & " beim Aufruf von" _
                           & @LF & @ComSpec & " /D /C Update.cmd" & $options & " in" _
                           & @LF & $scriptdir & ".")
        Else
          MsgBox(0x2010, "Error", "Error #" & @error & " when calling" _
                          & @LF & @ComSpec & " /D /C Update.cmd" & $options & " in" _
                          & @LF & $scriptdir & ".")
        EndIf
      Else
        ExitLoop
      EndIf
  EndSwitch
WEnd
Exit
