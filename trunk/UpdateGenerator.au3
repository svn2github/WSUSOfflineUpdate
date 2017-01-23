; ***  WSUS Offline Update 10.9 - Generator  ***
; ***       Author: T. Wittrock, Kiel        ***
; ***     USB-Option added by Ch. Riedel     ***
; ***   Dialog scaling added by Th. Baisch   ***

#include <GUIConstants.au3>
#pragma compile(CompanyName, "T. Wittrock")
#pragma compile(FileDescription, "WSUS Offline Update Generator")
#pragma compile(FileVersion, 10.9.0.852)
#pragma compile(InternalName, "Generator")
#pragma compile(LegalCopyright, "GNU GPLv3")
#pragma compile(OriginalFilename, UpdateGenerator.exe)
#pragma compile(ProductName, "WSUS Offline Update")
#pragma compile(ProductVersion, 10.9.0)

Dim Const $caption                  = "WSUS Offline Update 10.9"
Dim Const $title                    = $caption & " - Generator"
Dim Const $donationURL              = "http://www.wsusoffline.net/donate.html"
Dim Const $downloadURL              = "http://download.wsusoffline.net/"
Dim Const $downloadLogFile          = "download.log"
Dim Const $runAllFile               = "RunAll.cmd"

; Registry constants
Dim Const $reg_key_hkcu_desktop     = "HKEY_CURRENT_USER\Control Panel\Desktop"
Dim Const $reg_key_hkcu_winmetrics  = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
Dim Const $reg_val_logpixels        = "LogPixels"
Dim Const $reg_val_applieddpi       = "AppliedDPI"

; Message box return codes
Dim Const $msgbox_btn_ok            = 1
Dim Const $msgbox_btn_cancel        = 2
Dim Const $msgbox_btn_abort         = 3
Dim Const $msgbox_btn_retry         = 4
Dim Const $msgbox_btn_ignore        = 5
Dim Const $msgbox_btn_yes           = 6
Dim Const $msgbox_btn_no            = 7
Dim Const $msgbox_btn_tryagain      = 10
Dim Const $msgbox_btn_continue      = 11

; Defaults
Dim Const $default_logpixels        = 96

; INI file constants
Dim Const $ini_section_w60          = "Windows Vista"
Dim Const $ini_section_w60_x64      = "Windows Vista x64"
Dim Const $ini_section_w61          = "Windows 7"
Dim Const $ini_section_w61_x64      = "Windows Server 2008 R2"
Dim Const $ini_section_w62_x64      = "Windows Server 2012"
Dim Const $ini_section_w63          = "Windows 8.1"
Dim Const $ini_section_w63_x64      = "Windows Server 2012 R2"
Dim Const $ini_section_w100         = "Windows 10"
Dim Const $ini_section_w100_x64     = "Windows Server 2016"
Dim Const $ini_section_o2k7         = "Office 2007"
Dim Const $ini_section_o2k10        = "Office 2010"
Dim Const $ini_section_o2k13        = "Office 2013"
Dim Const $ini_section_o2k16        = "Office 2016"
Dim Const $ini_section_iso          = "ISO Images"
Dim Const $ini_section_usb          = "USB Images"
Dim Const $ini_section_opts         = "Options"
Dim Const $ini_section_inst         = "Installation"
Dim Const $ini_section_misc         = "Miscellaneous"
Dim Const $enabled                  = "Enabled"
Dim Const $disabled                 = "Disabled"
Dim Const $lang_token_glb           = "glb"
Dim Const $lang_token_enu           = "enu"
Dim Const $lang_token_fra           = "fra"
Dim Const $lang_token_esn           = "esn"
Dim Const $lang_token_jpn           = "jpn"
Dim Const $lang_token_kor           = "kor"
Dim Const $lang_token_rus           = "rus"
Dim Const $lang_token_ptg           = "ptg"
Dim Const $lang_token_ptb           = "ptb"
Dim Const $lang_token_deu           = "deu"
Dim Const $lang_token_nld           = "nld"
Dim Const $lang_token_ita           = "ita"
Dim Const $lang_token_chs           = "chs"
Dim Const $lang_token_cht           = "cht"
Dim Const $lang_token_plk           = "plk"
Dim Const $lang_token_hun           = "hun"
Dim Const $lang_token_csy           = "csy"
Dim Const $lang_token_sve           = "sve"
Dim Const $lang_token_trk           = "trk"
Dim Const $lang_token_ell           = "ell"
Dim Const $lang_token_ara           = "ara"
Dim Const $lang_token_heb           = "heb"
Dim Const $lang_token_dan           = "dan"
Dim Const $lang_token_nor           = "nor"
Dim Const $lang_token_fin           = "fin"
Dim Const $iso_token_cd             = "single"
Dim Const $iso_token_dvd            = "cross-platform"
Dim Const $iso_token_skiphashes     = "skiphashes"
Dim Const $usb_token_copy           = "copy"
Dim Const $usb_token_path           = "path"
Dim Const $usb_token_cleanup        = "cleanup"
Dim Const $opts_token_includesp     = "includesp"
Dim Const $opts_token_allowsp       = "allowsp"
Dim Const $opts_token_includedotnet = "includedotnet"
Dim Const $opts_token_allowdotnet   = "allowdotnet"
Dim Const $opts_token_seconly       = "seconly"
Dim Const $opts_token_msse          = "includemsse"
Dim Const $opts_token_wddefs        = "includewddefs"
Dim Const $opts_token_includewinglb = "includewinglb"
Dim Const $opts_token_cleanup       = "cleanupdownloads"
Dim Const $opts_token_verify        = "verifydownloads"
Dim Const $misc_token_proxy         = "proxy"
Dim Const $misc_token_wsus          = "wsus"
Dim Const $misc_token_wsus_only     = "wsusonly"
Dim Const $misc_token_wsus_proxy    = "wsusbyproxy"
Dim Const $misc_token_wsus_trans    = "transferwsus"
Dim Const $misc_token_skipsdd       = "skipsdd"
Dim Const $misc_token_skiptz        = "skiptz"
Dim Const $misc_token_skipdownload  = "skipdownload"
Dim Const $misc_token_skipdynamic   = "skipdynamic"
Dim Const $misc_token_chkver        = "checkouversion"
Dim Const $misc_token_minimize      = "minimizeondownload"
Dim Const $misc_token_showshutdown  = "showshutdown"
Dim Const $misc_token_showdonate    = "showdonate"
Dim Const $misc_token_clt_wustat    = "WUStatusServer"

; Paths
Dim Const $path_max_length          = 192
Dim Const $path_invalid_chars       = "!%&()^+,;="
Dim Const $paths_rel_structure      = "\bin\,\client\bin\,\client\cmd\,\client\exclude\,\client\opt\,\client\static\,\cmd\,\exclude\,\iso\,\log\,\static\,\xslt\"
Dim Const $path_rel_builddate       = "\client\builddate.txt"
Dim Const $path_rel_clientini       = "\client\UpdateInstaller.ini"
Dim Const $path_rel_win_glb         = "\client\win\glb"

Dim $maindlg, $inifilename, $tabitemfocused, $includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, $cdiso, $dvdiso, $buildlbl
Dim $usbcopy, $usbpath, $usbfsf, $usbclean, $imageonly, $scripting, $shutdown, $btn_start, $btn_proxy, $btn_wsus, $btn_donate, $btn_exit, $proxy, $proxypwd, $wsus, $dummy
Dim $o2k7_enu, $o2k10_enu, $o2k13_enu   ; English
Dim $o2k7_fra, $o2k10_fra, $o2k13_fra   ; French
Dim $o2k7_esn, $o2k10_esn, $o2k13_esn   ; Spanish
Dim $o2k7_jpn, $o2k10_jpn, $o2k13_jpn   ; Japanese
Dim $o2k7_kor, $o2k10_kor, $o2k13_kor   ; Korean
Dim $o2k7_rus, $o2k10_rus, $o2k13_rus   ; Russian
Dim $o2k7_ptg, $o2k10_ptg, $o2k13_ptg   ; Portuguese
Dim $o2k7_ptb, $o2k10_ptb, $o2k13_ptb   ; Brazilian
Dim $o2k7_deu, $o2k10_deu, $o2k13_deu   ; German
Dim $o2k7_nld, $o2k10_nld, $o2k13_nld   ; Dutch
Dim $o2k7_ita, $o2k10_ita, $o2k13_ita   ; Italian
Dim $o2k7_chs, $o2k10_chs, $o2k13_chs   ; Chinese simplified
Dim $o2k7_cht, $o2k10_cht, $o2k13_cht   ; Chinese traditional
Dim $o2k7_plk, $o2k10_plk, $o2k13_plk   ; Polish
Dim $o2k7_hun, $o2k10_hun, $o2k13_hun   ; Hungarian
Dim $o2k7_csy, $o2k10_csy, $o2k13_csy   ; Czech
Dim $o2k7_sve, $o2k10_sve, $o2k13_sve   ; Swedish
Dim $o2k7_trk, $o2k10_trk, $o2k13_trk   ; Turkish
Dim $o2k7_ell, $o2k10_ell, $o2k13_ell   ; Greek
Dim $o2k7_ara, $o2k10_ara, $o2k13_ara   ; Arabic
Dim $o2k7_heb, $o2k10_heb, $o2k13_heb   ; Hebrew
Dim $o2k7_dan, $o2k10_dan, $o2k13_dan   ; Danish
Dim $o2k7_nor, $o2k10_nor, $o2k13_nor   ; Norwegian
Dim $o2k7_fin, $o2k10_fin, $o2k13_fin   ; Finnish
Dim $o2k16_glb                          ; Office 2016 (global)
Dim $w60_glb, $w60_x64_glb              ; Windows Vista / Server 2008 (global)
Dim $w61_glb, $w61_x64_glb              ; Windows 7 / Server 2008 R2 (global)
Dim $w62_x64_glb                        ; Windows Server 2012 (global)
Dim $w63_glb, $w63_x64_glb              ; Windows 8.1 / Server 2012 R2 (global)
Dim $w100_glb, $w100_x64_glb            ; Windows 10 / Server 2016 (global)

Dim $dlgheight, $groupwidth, $groupheight_lng, $groupheight_glb, $txtwidth, $txtheight, $slimheight, $btnwidth, $btnheight, $txtxoffset, $txtyoffset, $txtxpos, $txtypos, $runany

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

Func IsUNCPath($path)
  Return StringInStr($path, "\\") > 0
EndFunc

Func PathValid($path)
Dim $result, $arr_invalid, $i

  If StringLen($path) > $path_max_length Then
    $result = False
  Else
    $result = True
    $arr_invalid = StringSplit($path_invalid_chars, "")
    For $i = 1 to $arr_invalid[0]
      If StringInStr($path, $arr_invalid[$i]) > 0 Then
        $result = False
        ExitLoop
      EndIf
    Next
  EndIf
  Return $result
EndFunc

Func DirectoryStructureExists()
Dim $result, $arr_dirs, $i

  $result = True
  $arr_dirs = StringSplit($paths_rel_structure, ",")
  For $i = 1 to $arr_dirs[0]
    $result = $result AND FileExists(@ScriptDir & $arr_dirs[$i])
  Next
  Return $result
EndFunc

Func LastDownloadRun()
Dim $result

  $result = FileReadLine(@ScriptDir & $path_rel_builddate)
  If @error Then
    If ShowGUIInGerman() Then
      $result = "[Kein]"
    Else
      $result = "[None]"
    EndIf
  EndIf
  Return $result
EndFunc

Func ClientIniFileName()
  Return @ScriptDir & $path_rel_clientini
EndFunc

Func LanguageCaption($token, $german)
  Switch $token
    Case $lang_token_enu
      If $german Then
        Return "Englisch"
      Else
        Return "English"
      EndIf
    Case $lang_token_fra
      If $german Then
        Return "Französisch"
      Else
        Return "French"
      EndIf
    Case $lang_token_esn
      If $german Then
        Return "Spanisch"
      Else
        Return "Spanish"
      EndIf
    Case $lang_token_jpn
      If $german Then
        Return "Japanisch"
      Else
        Return "Japanese"
      EndIf
    Case $lang_token_kor
      If $german Then
        Return "Koreanisch"
      Else
        Return "Korean"
      EndIf
    Case $lang_token_rus
      If $german Then
        Return "Russisch"
      Else
        Return "Russian"
      EndIf
    Case $lang_token_ptg
      If $german Then
        Return "Portugiesisch"
      Else
        Return "Portuguese"
      EndIf
    Case $lang_token_ptb
      If $german Then
        Return "Brasilianisch"
      Else
        Return "Brazilian"
      EndIf
    Case $lang_token_deu
      If $german Then
        Return "Deutsch"
      Else
        Return "German"
      EndIf
    Case $lang_token_nld
      If $german Then
        Return "Niederländisch"
      Else
        Return "Dutch"
      EndIf
    Case $lang_token_ita
      If $german Then
        Return "Italienisch"
      Else
        Return "Italian"
      EndIf
    Case $lang_token_chs
      If $german Then
        Return "Chin. (simpl.)"
      Else
        Return "Chinese (s.)"
      EndIf
    Case $lang_token_cht
      If $german Then
        Return "Chin. (trad.)"
      Else
        Return "Chinese (tr.)"
      EndIf
    Case $lang_token_plk
      If $german Then
        Return "Polnisch"
      Else
        Return "Polish"
      EndIf
    Case $lang_token_hun
      If $german Then
        Return "Ungarisch"
      Else
        Return "Hungarian"
      EndIf
    Case $lang_token_csy
      If $german Then
        Return "Tschechisch"
      Else
        Return "Czech"
      EndIf
    Case $lang_token_sve
      If $german Then
        Return "Schwedisch"
      Else
        Return "Swedish"
      EndIf
    Case $lang_token_trk
      If $german Then
        Return "Türkisch"
      Else
        Return "Turkish"
      EndIf
    Case $lang_token_ell
      If $german Then
        Return "Griechisch"
      Else
        Return "Greek"
      EndIf
    Case $lang_token_ara
      If $german Then
        Return "Arabisch"
      Else
        Return "Arabic"
      EndIf
    Case $lang_token_heb
      If $german Then
        Return "Hebräisch"
      Else
        Return "Hebrew"
      EndIf
    Case $lang_token_dan
      If $german Then
        Return "Dänisch"
      Else
        Return "Danish"
      EndIf
    Case $lang_token_nor
      If $german Then
        Return "Norwegisch"
      Else
        Return "Norwegian"
      EndIf
    Case $lang_token_fin
      If $german Then
        Return "Finnisch"
      Else
        Return "Finnish"
      EndIf
    Case Else
      Return ""
  EndSwitch
EndFunc

Func IsCheckBoxChecked($chkbox)
  Return BitAND(GUICtrlRead($chkbox), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func CheckBoxStateToString($chkbox)
  If IsCheckBoxChecked($chkbox) Then
    Return $enabled
  Else
    Return $disabled
  EndIf
EndFunc

Func IsLangOfficeChecked()
  Return (IsCheckBoxChecked($o2k7_enu) OR IsCheckBoxChecked($o2k10_enu) OR IsCheckBoxChecked($o2k13_enu) _
       OR IsCheckBoxChecked($o2k7_fra) OR IsCheckBoxChecked($o2k10_fra) OR IsCheckBoxChecked($o2k13_fra) _
       OR IsCheckBoxChecked($o2k7_esn) OR IsCheckBoxChecked($o2k10_esn) OR IsCheckBoxChecked($o2k13_esn) _
       OR IsCheckBoxChecked($o2k7_jpn) OR IsCheckBoxChecked($o2k10_jpn) OR IsCheckBoxChecked($o2k13_jpn) _
       OR IsCheckBoxChecked($o2k7_kor) OR IsCheckBoxChecked($o2k10_kor) OR IsCheckBoxChecked($o2k13_kor) _
       OR IsCheckBoxChecked($o2k7_rus) OR IsCheckBoxChecked($o2k10_rus) OR IsCheckBoxChecked($o2k13_rus) _
       OR IsCheckBoxChecked($o2k7_ptg) OR IsCheckBoxChecked($o2k10_ptg) OR IsCheckBoxChecked($o2k13_ptg) _
       OR IsCheckBoxChecked($o2k7_ptb) OR IsCheckBoxChecked($o2k10_ptb) OR IsCheckBoxChecked($o2k13_ptb) _
       OR IsCheckBoxChecked($o2k7_deu) OR IsCheckBoxChecked($o2k10_deu) OR IsCheckBoxChecked($o2k13_deu) _
       OR IsCheckBoxChecked($o2k7_nld) OR IsCheckBoxChecked($o2k10_nld) OR IsCheckBoxChecked($o2k13_nld) _
       OR IsCheckBoxChecked($o2k7_ita) OR IsCheckBoxChecked($o2k10_ita) OR IsCheckBoxChecked($o2k13_ita) _
       OR IsCheckBoxChecked($o2k7_chs) OR IsCheckBoxChecked($o2k10_chs) OR IsCheckBoxChecked($o2k13_chs) _
       OR IsCheckBoxChecked($o2k7_cht) OR IsCheckBoxChecked($o2k10_cht) OR IsCheckBoxChecked($o2k13_cht) _
       OR IsCheckBoxChecked($o2k7_plk) OR IsCheckBoxChecked($o2k10_plk) OR IsCheckBoxChecked($o2k13_plk) _
       OR IsCheckBoxChecked($o2k7_hun) OR IsCheckBoxChecked($o2k10_hun) OR IsCheckBoxChecked($o2k13_hun) _
       OR IsCheckBoxChecked($o2k7_csy) OR IsCheckBoxChecked($o2k10_csy) OR IsCheckBoxChecked($o2k13_csy) _
       OR IsCheckBoxChecked($o2k7_sve) OR IsCheckBoxChecked($o2k10_sve) OR IsCheckBoxChecked($o2k13_sve) _
       OR IsCheckBoxChecked($o2k7_trk) OR IsCheckBoxChecked($o2k10_trk) OR IsCheckBoxChecked($o2k13_trk) _
       OR IsCheckBoxChecked($o2k7_ell) OR IsCheckBoxChecked($o2k10_ell) OR IsCheckBoxChecked($o2k13_ell) _
       OR IsCheckBoxChecked($o2k7_ara) OR IsCheckBoxChecked($o2k10_ara) OR IsCheckBoxChecked($o2k13_ara) _
       OR IsCheckBoxChecked($o2k7_heb) OR IsCheckBoxChecked($o2k10_heb) OR IsCheckBoxChecked($o2k13_heb) _
       OR IsCheckBoxChecked($o2k7_dan) OR IsCheckBoxChecked($o2k10_dan) OR IsCheckBoxChecked($o2k13_dan) _
       OR IsCheckBoxChecked($o2k7_nor) OR IsCheckBoxChecked($o2k10_nor) OR IsCheckBoxChecked($o2k13_nor) _
       OR IsCheckBoxChecked($o2k7_fin) OR IsCheckBoxChecked($o2k10_fin) OR IsCheckBoxChecked($o2k13_fin) )
EndFunc

Func SwitchDownloadTargets($state)

  GUICtrlSetState($w60_glb, $state)
  GUICtrlSetState($w60_x64_glb, $state)
  GUICtrlSetState($w61_glb, $state)
  GUICtrlSetState($w61_x64_glb, $state)
  GUICtrlSetState($w62_x64_glb, $state)
  GUICtrlSetState($w63_glb, $state)
  GUICtrlSetState($w63_x64_glb, $state)
  GUICtrlSetState($w100_glb, $state)
  GUICtrlSetState($w100_x64_glb, $state)

  GUICtrlSetState($o2k7_enu, $state)
  GUICtrlSetState($o2k10_enu, $state)
  GUICtrlSetState($o2k13_enu, $state)
  GUICtrlSetState($o2k7_fra, $state)
  GUICtrlSetState($o2k10_fra, $state)
  GUICtrlSetState($o2k13_fra, $state)
  GUICtrlSetState($o2k7_esn, $state)
  GUICtrlSetState($o2k10_esn, $state)
  GUICtrlSetState($o2k13_esn, $state)
  GUICtrlSetState($o2k7_jpn, $state)
  GUICtrlSetState($o2k10_jpn, $state)
  GUICtrlSetState($o2k13_jpn, $state)
  GUICtrlSetState($o2k7_kor, $state)
  GUICtrlSetState($o2k10_kor, $state)
  GUICtrlSetState($o2k13_kor, $state)
  GUICtrlSetState($o2k7_rus, $state)
  GUICtrlSetState($o2k10_rus, $state)
  GUICtrlSetState($o2k13_rus, $state)
  GUICtrlSetState($o2k7_ptg, $state)
  GUICtrlSetState($o2k10_ptg, $state)
  GUICtrlSetState($o2k13_ptg, $state)
  GUICtrlSetState($o2k7_ptb, $state)
  GUICtrlSetState($o2k10_ptb, $state)
  GUICtrlSetState($o2k13_ptb, $state)
  GUICtrlSetState($o2k7_deu, $state)
  GUICtrlSetState($o2k10_deu, $state)
  GUICtrlSetState($o2k13_deu, $state)
  GUICtrlSetState($o2k7_nld, $state)
  GUICtrlSetState($o2k10_nld, $state)
  GUICtrlSetState($o2k13_nld, $state)
  GUICtrlSetState($o2k7_ita, $state)
  GUICtrlSetState($o2k10_ita, $state)
  GUICtrlSetState($o2k13_ita, $state)
  GUICtrlSetState($o2k7_chs, $state)
  GUICtrlSetState($o2k10_chs, $state)
  GUICtrlSetState($o2k13_chs, $state)
  GUICtrlSetState($o2k7_cht, $state)
  GUICtrlSetState($o2k10_cht, $state)
  GUICtrlSetState($o2k13_cht, $state)
  GUICtrlSetState($o2k7_plk, $state)
  GUICtrlSetState($o2k10_plk, $state)
  GUICtrlSetState($o2k13_plk, $state)
  GUICtrlSetState($o2k7_hun, $state)
  GUICtrlSetState($o2k10_hun, $state)
  GUICtrlSetState($o2k13_hun, $state)
  GUICtrlSetState($o2k7_csy, $state)
  GUICtrlSetState($o2k10_csy, $state)
  GUICtrlSetState($o2k13_csy, $state)
  GUICtrlSetState($o2k7_sve, $state)
  GUICtrlSetState($o2k10_sve, $state)
  GUICtrlSetState($o2k13_sve, $state)
  GUICtrlSetState($o2k7_trk, $state)
  GUICtrlSetState($o2k10_trk, $state)
  GUICtrlSetState($o2k13_trk, $state)
  GUICtrlSetState($o2k7_ell, $state)
  GUICtrlSetState($o2k10_ell, $state)
  GUICtrlSetState($o2k13_ell, $state)
  GUICtrlSetState($o2k7_ara, $state)
  GUICtrlSetState($o2k10_ara, $state)
  GUICtrlSetState($o2k13_ara, $state)
  GUICtrlSetState($o2k7_heb, $state)
  GUICtrlSetState($o2k10_heb, $state)
  GUICtrlSetState($o2k13_heb, $state)
  GUICtrlSetState($o2k7_dan, $state)
  GUICtrlSetState($o2k10_dan, $state)
  GUICtrlSetState($o2k13_dan, $state)
  GUICtrlSetState($o2k7_nor, $state)
  GUICtrlSetState($o2k10_nor, $state)
  GUICtrlSetState($o2k13_nor, $state)
  GUICtrlSetState($o2k7_fin, $state)
  GUICtrlSetState($o2k10_fin, $state)
  GUICtrlSetState($o2k13_fin, $state)
  GUICtrlSetState($o2k16_glb, $state)
  Return 0
EndFunc

Func DisableGUI()
  SwitchDownloadTargets($GUI_DISABLE)

  GUICtrlSetState($verifydownloads, $GUI_DISABLE)
  GUICtrlSetState($includesp, $GUI_DISABLE)
  GUICtrlSetState($dotnet, $GUI_DISABLE)
  GUICtrlSetState($seconly, $GUI_DISABLE)
  GUICtrlSetState($msse, $GUI_DISABLE)
  GUICtrlSetState($wddefs, $GUI_DISABLE)

  GUICtrlSetState($cdiso, $GUI_DISABLE)
  GUICtrlSetState($dvdiso, $GUI_DISABLE)
  GUICtrlSetState($usbcopy, $GUI_DISABLE)
  GUICtrlSetState($usbpath, $GUI_DISABLE)
  GUICtrlSetState($usbfsf, $GUI_DISABLE)
  GUICtrlSetState($usbclean, $GUI_DISABLE)

  GUICtrlSetState($btn_start, $GUI_DISABLE)
  GUICtrlSetState($imageonly, $GUI_DISABLE)
  GUICtrlSetState($scripting, $GUI_DISABLE)
  GUICtrlSetState($shutdown, $GUI_DISABLE)
  GUICtrlSetState($btn_proxy, $GUI_DISABLE)
  GUICtrlSetState($btn_wsus, $GUI_DISABLE)
  GUICtrlSetState($btn_donate, $GUI_DISABLE)
  GUICtrlSetState($btn_exit, $GUI_DISABLE)

  Return 0
EndFunc

Func EnableGUI()
  SwitchDownloadTargets($GUI_ENABLE)
  GUICtrlSetState($dotnet, $GUI_ENABLE)
  If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
    If NOT IsCheckBoxChecked($imageonly) Then
      GUICtrlSetState($verifydownloads, $GUI_ENABLE)
      GUICtrlSetState($seconly, $GUI_ENABLE)
    EndIf
    GUICtrlSetState($includesp, $GUI_ENABLE)
    GUICtrlSetState($msse, $GUI_ENABLE)
    GUICtrlSetState($wddefs, $GUI_ENABLE)
    GUICtrlSetState($cdiso, $GUI_ENABLE)
    GUICtrlSetState($dvdiso, $GUI_ENABLE)
    GUICtrlSetState($usbcopy, $GUI_ENABLE)
    If IsCheckBoxChecked($usbcopy) Then
      GUICtrlSetState($usbpath, $GUI_ENABLE)
      GUICtrlSetState($usbfsf, $GUI_ENABLE)
      GUICtrlSetState($usbclean, $GUI_ENABLE)
    EndIf
  EndIf
  GUICtrlSetState($btn_start, $GUI_ENABLE)
  GUICtrlSetState($scripting, $GUI_ENABLE)
  If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
    GUICtrlSetState($imageonly, $GUI_ENABLE)
    If NOT IsCheckBoxChecked($imageonly) Then
      GUICtrlSetState($shutdown, $GUI_ENABLE)
    EndIf
  EndIf
  GUICtrlSetState($btn_proxy, $GUI_ENABLE)
  If ( (IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled) _
   AND (IniRead($inifilename, $ini_section_misc, $misc_token_skipdynamic, $disabled) = $disabled) ) Then
    GUICtrlSetState($btn_wsus, $GUI_ENABLE)
  EndIf
  GUICtrlSetState($btn_donate, $GUI_ENABLE)
  GUICtrlSetState($btn_exit, $GUI_ENABLE)
  Return 0
EndFunc

Func RFC1738EncodedString($str)
Dim $result, $i

  $result = ""
  For $i = 1 to StringLen($str)
    If StringIsAlNum(StringMid($str, $i, 1)) Then
      $result = $result & StringMid($str, $i, 1)
    Else
      $result = $result & "%" & Hex(Asc(StringMid($str, $i, 1)), 2)
    EndIf
  Next
  Return $result
EndFunc

Func AuthProxy($strproxy, $strproxypwd)
Dim $result, $pos

  $result = $strproxy
  $pos = StringInStr($strproxy, ":@")
  If ( ($pos > 0) AND ($strproxypwd <> "") ) Then
    $result = StringLeft($strproxy, $pos) & $strproxypwd & StringRight($strproxy, StringLen($strproxy) - $pos)
  EndIf
  Return $result
EndFunc

Func DetermineDownloadSwitches($chkbox_includesp, $chkbox_dotnet, $chkbox_seconly, $chkbox_msse, $chkbox_wddefs, $chkbox_verifydownloads, $strproxy, $strwsus)
Dim $result = ""

  If NOT IsCheckBoxChecked($chkbox_includesp) Then
    $result = $result & " /excludesp"
  EndIf
  If IsCheckBoxChecked($chkbox_dotnet) Then
    $result = $result & " /includedotnet"
  EndIf
  If IsCheckBoxChecked($chkbox_seconly) Then
    $result = $result & " /seconly"
  EndIf
  If IsCheckBoxChecked($chkbox_msse) Then
    $result = $result & " /includemsse"
  EndIf
  If IsCheckBoxChecked($chkbox_wddefs) Then
    $result = $result & " /includewddefs"
  EndIf
  If IniRead($inifilename, $ini_section_opts, $opts_token_includewinglb, $enabled) = $disabled Then
    $result = $result & " /excludewinglb"
  EndIf
  If IsCheckBoxChecked($chkbox_verifydownloads) Then
    $result = $result & " /verify"
  EndIf
  If NOT IsCheckBoxChecked($scripting) Then
    $result = $result & " /exitonerror"
  EndIf
  If IniRead($inifilename, $ini_section_opts, $opts_token_cleanup, $enabled) = $disabled Then
    $result = $result & " /nocleanup"
  EndIf
  If IniRead($inifilename, $ini_section_misc, $misc_token_skipsdd, $disabled) = $enabled Then
    $result = $result & " /skipsdd"
  EndIf
  If IniRead($inifilename, $ini_section_misc, $misc_token_skiptz, $disabled) = $enabled Then
    $result = $result & " /skiptz"
  EndIf
  If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
    $result = $result & " /skipdownload"
  Else
    If IniRead($inifilename, $ini_section_misc, $misc_token_skipdynamic, $disabled) = $enabled Then
      $result = $result & " /skipdynamic"
    EndIf
  EndIf
  If $strproxy <> "" Then
    $result = $result & " /proxy " & $strproxy
  EndIf
  If $strwsus <> "" Then
    $result = $result & " /wsus " & $strwsus
  EndIf
  If IniRead($inifilename, $ini_section_misc, $misc_token_wsus_only, $disabled) = $enabled Then
    $result = $result & " /wsusonly"
  EndIf
  If IniRead($inifilename, $ini_section_misc, $misc_token_wsus_proxy, $disabled) = $enabled Then
    $result = $result & " /wsusbyproxy"
  EndIf
  Return $result
EndFunc

Func DetermineISOSwitches($chkbox_includesp, $chkbox_dotnet, $chkbox_msse, $chkbox_wddefs, $chkbox_usbclean)
Dim $result = ""

  If NOT IsCheckBoxChecked($chkbox_includesp) Then
    $result = $result & " /excludesp"
  EndIf
  If IsCheckBoxChecked($chkbox_dotnet) Then
    $result = $result & " /includedotnet"
  EndIf
  If IsCheckBoxChecked($chkbox_msse) Then
    $result = $result & " /includemsse"
  EndIf
  If IsCheckBoxChecked($chkbox_wddefs) Then
    $result = $result & " /includewddefs"
  EndIf
  If IsCheckBoxChecked($chkbox_usbclean) Then
    $result = $result & " /cleanup"
  EndIf
  If NOT IsCheckBoxChecked($scripting) Then
    $result = $result & " /exitonerror"
  EndIf
  If IniRead($inifilename, $ini_section_iso, $iso_token_skiphashes, $disabled) = $enabled Then
    $result = $result & " /skiphashes"
  EndIf
  Return $result
EndFunc

Func ShowLogFile()
  Run("notepad.exe " & $downloadLogFile, @ScriptDir & "\log")
EndFunc

Func ShowRunAll()
  Run("notepad.exe " & $runAllFile, @ScriptDir & "\cmd\custom")
EndFunc

Func RunVersionCheck($strproxy)
Dim $result

  DisableGUI()
  If $strproxy = "" Then
    $result = RunWait(@ComSpec & " /D /C CheckOUVersion.cmd /exitonerror", @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  Else
    $result = RunWait(@ComSpec & " /D /C CheckOUVersion.cmd /exitonerror /proxy " & $strproxy, @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  EndIf
  If @error <> 0 Then
    If ShowGUIInGerman() Then
      MsgBox(0x2030, "Warnung", "Die Versionsprüfung (CheckOUVersion.cmd) konnte nicht ausgeführt werden.")
    Else
      MsgBox(0x2030, "Warning", "The version check (CheckOUVersion.cmd) could not be executed.")
    EndIf
    Return 0
  EndIf
  If $result <> 0 Then
    If ShowGUIInGerman() Then
      $result = MsgBox(0x2023, "Versionsprüfung", "Sie setzen " & $caption & " ein. Eine neuere Version ist verfügbar." _
                       & @LF & "Möchten Sie WSUS Offline Update nun aktualisieren?")
    Else
      $result = MsgBox(0x2023, "Version check", "You are using " & $caption & ". A newer version is available." _
                       & @LF & "Would you like to update WSUS Offline Update now?")
    EndIf
    Switch $result
      Case $msgbox_btn_yes
        $result = -1
      Case $msgbox_btn_no
        $result = 0
      Case Else
        $result = 1
    EndSwitch
  EndIf
  EnableGUI()
  Return $result
EndFunc

Func RunSelfUpdate($strproxy)
  If $strproxy = "" Then
    Run(@ComSpec & " /D /C UpdateOU.cmd /restartgenerator", @ScriptDir & "\cmd", @SW_SHOW)
  Else
    Run(@ComSpec & " /D /C UpdateOU.cmd /restartgenerator /proxy " & $strproxy, @ScriptDir & "\cmd", @SW_SHOW)
  EndIf
  Return 0
EndFunc

Func RunDownloadScript($stroptions, $strswitches)
Dim $result

  If IsCheckBoxChecked($scripting) Then
    If ($runany) Then
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 1)
    Else
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 2)
    EndIf
    If $result = -1 Then
      If ShowGUIInGerman() Then
        MsgBox(0x2010, "Fehler", "Fehler beim Öffnen der Datei " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      Else
        MsgBox(0x2010, "Error", "Error opening file " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      EndIf
      Return $result
    EndIf
    FileWriteLine($result, "@pushd ..")
    FileWriteLine($result, "call .\DownloadUpdates.cmd " & $stroptions & $strswitches)
    FileWriteLine($result, "@popd")
    FileClose($result)
    $runany = True
    Return 0
  EndIf

  If ShowGUIInGerman() Then
    WinSetTitle($maindlg, $maindlg, $caption & " - Lade Updates für " & $stroptions & "...")
  Else
    WinSetTitle($maindlg, $maindlg, $caption & " - Downloading updates for " & $stroptions & "...")
  EndIf
  DisableGUI()
  If IniRead($inifilename, $ini_section_misc, $misc_token_minimize, $disabled) = $enabled Then
    $result = RunWait(@ComSpec & " /D /C DownloadUpdates.cmd " & $stroptions & $strswitches, @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  Else
    $result = RunWait(@ComSpec & " /D /C DownloadUpdates.cmd " & $stroptions & $strswitches, @ScriptDir & "\cmd", @SW_SHOW)
  EndIf
  If $result = 0 Then
    $result = @error
  EndIf
  If $result = 0 Then
    $runany = True
    If ShowGUIInGerman() Then
      GUICtrlSetData($buildlbl, "Letzter Download: " & LastDownloadRun())
    Else
      GUICtrlSetData($buildlbl, "Last download: " & LastDownloadRun())
    EndIf
  Else
    WinSetState($maindlg, $maindlg, @SW_RESTORE)
    If ShowGUIInGerman() Then
      If MsgBox(0x2014, "Fehler", "Fehler beim Herunterladen / Verifizieren der Updates für " & $stroptions & "." _
                & @LF & "Möchten Sie nun die Protokolldatei ansehen?") = $msgbox_btn_yes Then
        ShowLogFile()
      EndIf
    Else
      If MsgBox(0x2014, "Error", "Error downloading / verifying updates for " & $stroptions & "." _
                & @LF & "Would you like to view the log file now?") = $msgbox_btn_yes Then
        ShowLogFile()
      EndIf
    EndIf
  EndIf
  WinSetTitle($maindlg, $maindlg, $title)
  EnableGUI()
  Return $result
EndFunc

Func RunISOCreationScript($stroptions, $strswitches)
Dim $result

  If IsCheckBoxChecked($scripting) Then
    If ($runany) Then
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 1)
    Else
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 2)
    EndIf
    If $result = -1 Then
      If ShowGUIInGerman() Then
        MsgBox(0x2010, "Fehler", "Fehler beim Öffnen der Datei " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      Else
        MsgBox(0x2010, "Error", "Error opening file " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      EndIf
      Return $result
    EndIf
    FileWriteLine($result, "@pushd ..")
    FileWriteLine($result, "call .\CreateISOImage.cmd " & $stroptions & $strswitches)
    FileWriteLine($result, "@popd")
    FileClose($result)
    $runany = True
    Return 0
  EndIf

  If ShowGUIInGerman() Then
    WinSetTitle($maindlg, $maindlg, $caption & " - Erstelle ISO-Image für " & $stroptions & "...")
  Else
    WinSetTitle($maindlg, $maindlg, $caption & " - Creating ISO image for " & $stroptions & "...")
  EndIf
  DisableGUI()
  If IniRead($inifilename, $ini_section_misc, $misc_token_minimize, $disabled) = $enabled Then
    $result = RunWait(@ComSpec & " /D /C CreateISOImage.cmd " & $stroptions & $strswitches, @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  Else
    $result = RunWait(@ComSpec & " /D /C CreateISOImage.cmd " & $stroptions & $strswitches, @ScriptDir & "\cmd", @SW_SHOW)
  EndIf
  If $result = 0 Then
    $result = @error
  EndIf
  If $result = 0 Then
    $runany = True
  Else
    WinSetState($maindlg, $maindlg, @SW_RESTORE)
    If ShowGUIInGerman() Then
      MsgBox(0x2010, "Fehler", "Fehler beim Erstellen des ISO-Images für " & $stroptions & ".")
    Else
      MsgBox(0x2010, "Error", "Error creating ISO image for " & $stroptions & ".")
    EndIf
  EndIf
  WinSetTitle($maindlg, $maindlg, $title)
  EnableGUI()
  Return $result
EndFunc

Func RunUSBCreationScript($stroptions, $strswitches, $strpath)
Dim $result

  If IsCheckBoxChecked($scripting) Then
    If ($runany) Then
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 1)
    Else
      $result = FileOpen(@ScriptDir & "\cmd\custom\" & $runAllFile, 2)
    EndIf
    If $result = -1 Then
      If ShowGUIInGerman() Then
        MsgBox(0x2010, "Fehler", "Fehler beim Öffnen der Datei " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      Else
        MsgBox(0x2010, "Error", "Error opening file " & @ScriptDir & "\cmd\custom\" & $runAllFile)
      EndIf
      Return $result
    EndIf
    FileWriteLine($result, "@pushd ..")
    FileWriteLine($result, "call .\CopyToTarget.cmd " & $stroptions & " """ & $strpath & """" & $strswitches)
    FileWriteLine($result, "@popd")
    FileClose($result)
    $runany = True
    Return 0
  EndIf

  $result = 0
  If NOT FileExists($strpath) Then
    If ShowGUIInGerman() Then
      MsgBox(0x2030, "Warnung", "Das Zielverzeichnis """ & $strpath & """ existiert nicht.")
    Else
      MsgBox(0x2030, "Warning", "The target directory """ & $strpath & """ does not exist.")
    EndIf
    Return $result
  EndIf
  If ShowGUIInGerman() Then
    WinSetTitle($maindlg, $maindlg, $caption & " - Kopiere Dateien für " & $stroptions & "...")
  Else
    WinSetTitle($maindlg, $maindlg, $caption & " - Copying files for " & $stroptions & "...")
  EndIf
  DisableGUI()
  If IniRead($inifilename, $ini_section_misc, $misc_token_minimize, $disabled) = $enabled Then
    $result = RunWait(@ComSpec & " /D /C CopyToTarget.cmd " & $stroptions & " """ & $strpath & """" & $strswitches, @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  Else
    $result = RunWait(@ComSpec & " /D /C CopyToTarget.cmd " & $stroptions & " """ & $strpath & """" & $strswitches, @ScriptDir & "\cmd", @SW_SHOW)
  EndIf
  If $result = 0 Then
    $result = @error
  EndIf
  If $result = 0 Then
    $runany = True
  Else
    WinSetState($maindlg, $maindlg, @SW_RESTORE)
    If ShowGUIInGerman() Then
      MsgBox(0x2010, "Fehler", "Fehler beim Kopieren der Dateien für " & $stroptions & ".")
    Else
      MsgBox(0x2010, "Error", "Error copying files for " & $stroptions & ".")
    EndIf
  EndIf
  WinSetTitle($maindlg, $maindlg, $title)
  EnableGUI()
  Return $result
EndFunc

Func RunScripts($stroptions, $skipdl, $strdownloadswitches, $runiso, $strisoswitches, $runusb, $strusbpath)
Dim $result

  If $skipdl Then
    $result = 0
  Else
    $result = RunDownloadScript($stroptions, $strdownloadswitches)
  EndIf
  If ( ($result = 0) AND $runiso ) Then
    $result = RunISOCreationScript($stroptions, $strisoswitches)
  EndIf
  If ( ($result = 0) AND $runusb AND FileExists($strusbpath) ) Then
    $result = RunUSBCreationScript($stroptions, $strisoswitches, $strusbpath)
  EndIf
  Return $result
EndFunc

Func SaveSettings()

;  Windows Vista / Server 2008 group
  IniWrite($inifilename, $ini_section_w60, $lang_token_glb, CheckBoxStateToString($w60_glb))
  IniWrite($inifilename, $ini_section_w60_x64, $lang_token_glb, CheckBoxStateToString($w60_x64_glb))

;  Windows 7 / Server 2008 R2 group
  IniWrite($inifilename, $ini_section_w61, $lang_token_glb, CheckBoxStateToString($w61_glb))
  IniWrite($inifilename, $ini_section_w61_x64, $lang_token_glb, CheckBoxStateToString($w61_x64_glb))

;  Windows Server 2012 group
  IniWrite($inifilename, $ini_section_w62_x64, $lang_token_glb, CheckBoxStateToString($w62_x64_glb))

;  Windows 8.1 / Server 2012 R2 group
  IniWrite($inifilename, $ini_section_w63, $lang_token_glb, CheckBoxStateToString($w63_glb))
  IniWrite($inifilename, $ini_section_w63_x64, $lang_token_glb, CheckBoxStateToString($w63_x64_glb))

;  Windows 10 / Server 2016 group
  IniWrite($inifilename, $ini_section_w100, $lang_token_glb, CheckBoxStateToString($w100_glb))
  IniWrite($inifilename, $ini_section_w100_x64, $lang_token_glb, CheckBoxStateToString($w100_x64_glb))

;  Office 2007 group
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_enu, CheckBoxStateToString($o2k7_enu))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_fra, CheckBoxStateToString($o2k7_fra))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_esn, CheckBoxStateToString($o2k7_esn))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_jpn, CheckBoxStateToString($o2k7_jpn))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_kor, CheckBoxStateToString($o2k7_kor))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_rus, CheckBoxStateToString($o2k7_rus))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ptg, CheckBoxStateToString($o2k7_ptg))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ptb, CheckBoxStateToString($o2k7_ptb))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_deu, CheckBoxStateToString($o2k7_deu))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_nld, CheckBoxStateToString($o2k7_nld))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ita, CheckBoxStateToString($o2k7_ita))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_chs, CheckBoxStateToString($o2k7_chs))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_cht, CheckBoxStateToString($o2k7_cht))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_plk, CheckBoxStateToString($o2k7_plk))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_hun, CheckBoxStateToString($o2k7_hun))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_csy, CheckBoxStateToString($o2k7_csy))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_sve, CheckBoxStateToString($o2k7_sve))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_trk, CheckBoxStateToString($o2k7_trk))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ell, CheckBoxStateToString($o2k7_ell))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ara, CheckBoxStateToString($o2k7_ara))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_heb, CheckBoxStateToString($o2k7_heb))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_dan, CheckBoxStateToString($o2k7_dan))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_nor, CheckBoxStateToString($o2k7_nor))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_fin, CheckBoxStateToString($o2k7_fin))

;  Office 2010 group
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_enu, CheckBoxStateToString($o2k10_enu))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_fra, CheckBoxStateToString($o2k10_fra))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_esn, CheckBoxStateToString($o2k10_esn))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_jpn, CheckBoxStateToString($o2k10_jpn))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_kor, CheckBoxStateToString($o2k10_kor))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_rus, CheckBoxStateToString($o2k10_rus))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_ptg, CheckBoxStateToString($o2k10_ptg))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_ptb, CheckBoxStateToString($o2k10_ptb))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_deu, CheckBoxStateToString($o2k10_deu))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_nld, CheckBoxStateToString($o2k10_nld))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_ita, CheckBoxStateToString($o2k10_ita))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_chs, CheckBoxStateToString($o2k10_chs))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_cht, CheckBoxStateToString($o2k10_cht))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_plk, CheckBoxStateToString($o2k10_plk))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_hun, CheckBoxStateToString($o2k10_hun))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_csy, CheckBoxStateToString($o2k10_csy))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_sve, CheckBoxStateToString($o2k10_sve))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_trk, CheckBoxStateToString($o2k10_trk))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_ell, CheckBoxStateToString($o2k10_ell))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_ara, CheckBoxStateToString($o2k10_ara))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_heb, CheckBoxStateToString($o2k10_heb))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_dan, CheckBoxStateToString($o2k10_dan))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_nor, CheckBoxStateToString($o2k10_nor))
  IniWrite($inifilename, $ini_section_o2k10, $lang_token_fin, CheckBoxStateToString($o2k10_fin))

;  Office 2013 group
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_enu, CheckBoxStateToString($o2k13_enu))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_fra, CheckBoxStateToString($o2k13_fra))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_esn, CheckBoxStateToString($o2k13_esn))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_jpn, CheckBoxStateToString($o2k13_jpn))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_kor, CheckBoxStateToString($o2k13_kor))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_rus, CheckBoxStateToString($o2k13_rus))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_ptg, CheckBoxStateToString($o2k13_ptg))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_ptb, CheckBoxStateToString($o2k13_ptb))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_deu, CheckBoxStateToString($o2k13_deu))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_nld, CheckBoxStateToString($o2k13_nld))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_ita, CheckBoxStateToString($o2k13_ita))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_chs, CheckBoxStateToString($o2k13_chs))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_cht, CheckBoxStateToString($o2k13_cht))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_plk, CheckBoxStateToString($o2k13_plk))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_hun, CheckBoxStateToString($o2k13_hun))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_csy, CheckBoxStateToString($o2k13_csy))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_sve, CheckBoxStateToString($o2k13_sve))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_trk, CheckBoxStateToString($o2k13_trk))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_ell, CheckBoxStateToString($o2k13_ell))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_ara, CheckBoxStateToString($o2k13_ara))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_heb, CheckBoxStateToString($o2k13_heb))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_dan, CheckBoxStateToString($o2k13_dan))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_nor, CheckBoxStateToString($o2k13_nor))
  IniWrite($inifilename, $ini_section_o2k13, $lang_token_fin, CheckBoxStateToString($o2k13_fin))

;  Office 2016 group
  IniWrite($inifilename, $ini_section_o2k16, $lang_token_glb, CheckBoxStateToString($o2k16_glb))

;  Image creation
  IniWrite($inifilename, $ini_section_iso, $iso_token_cd, CheckBoxStateToString($cdiso))
  IniWrite($inifilename, $ini_section_iso, $iso_token_dvd, CheckBoxStateToString($dvdiso))
  IniWrite($inifilename, $ini_section_usb, $usb_token_copy, CheckBoxStateToString($usbcopy))
  IniWrite($inifilename, $ini_section_usb, $usb_token_path, GUICtrlRead($usbpath))
  IniWrite($inifilename, $ini_section_usb, $usb_token_cleanup, CheckBoxStateToString($usbclean))

;  Miscellaneous
  IniWrite($inifilename, $ini_section_opts, $opts_token_verify, CheckBoxStateToString($verifydownloads))
  IniWrite($inifilename, $ini_section_opts, $opts_token_includesp, CheckBoxStateToString($includesp))
  IniWrite($inifilename, $ini_section_opts, $opts_token_includedotnet, CheckBoxStateToString($dotnet))
  IniWrite($inifilename, $ini_section_opts, $opts_token_seconly, CheckBoxStateToString($seconly))
  IniWrite($inifilename, $ini_section_opts, $opts_token_msse, CheckBoxStateToString($msse))
  IniWrite($inifilename, $ini_section_opts, $opts_token_wddefs, CheckBoxStateToString($wddefs))
  IniWrite($inifilename, $ini_section_misc, $misc_token_proxy, $proxy)
  IniWrite($inifilename, $ini_section_misc, $misc_token_wsus, $wsus)

  Return 0
EndFunc

Func CalcGUISize()
  Dim $reg_val

  If ( (@OSVersion = "WIN_VISTA") OR (@OSVersion = "WIN_2008") OR (@OSVersion = "WIN_7") OR (@OSVersion = "WIN_2008R2") _
    OR (@OSVersion = "WIN_8") OR (@OSVersion = "WIN_2012") OR (@OSVersion = "WIN_81") OR (@OSVersion = "WIN_2012R2") _
    OR (@OSVersion = "WIN_10") OR (@OSVersion = "WIN_2016") ) Then
    DllCall("user32.dll", "int", "SetProcessDPIAware")
  EndIf
  $reg_val = RegRead($reg_key_hkcu_winmetrics, $reg_val_applieddpi)
  If ($reg_val = "") Then
    $reg_val = RegRead($reg_key_hkcu_desktop, $reg_val_logpixels)
  EndIf
  If ($reg_val = "") Then
    $reg_val = $default_logpixels
  EndIf
  $dlgheight = 480 * $reg_val / $default_logpixels
  If ShowGUIInGerman() Then
    $txtwidth = 90 * $reg_val / $default_logpixels
  Else
    $txtwidth = 80 * $reg_val / $default_logpixels
  EndIf
  $txtheight = 20 * $reg_val / $default_logpixels
  $slimheight = 15 * $reg_val / $default_logpixels
  $btnwidth = 80 * $reg_val / $default_logpixels
  $btnheight = 30 * $reg_val / $default_logpixels
  $txtxoffset = 10 * $reg_val / $default_logpixels
  $txtyoffset = 10 * $reg_val / $default_logpixels
  Return 0
EndFunc

;  Main Dialog
AutoItSetOption("GUICloseOnESC", 0)
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayIconHide", 1)
CalcGUISize()
$groupwidth = 8 * $txtwidth + 2 * $txtxoffset
$groupheight_lng = 4 * $txtheight
$groupheight_glb = 2 * $txtheight
$maindlg = GUICreate($title, $groupwidth + 4 * $txtxoffset, $dlgheight)
GUISetFont(8.5, 400, 0, "Sans Serif")
If ($CmdLine[0] > 0) AND (StringRight($CmdLine[$CmdLine[0]], 4) = ".ini") Then
  $inifilename = $CmdLine[$CmdLine[0]]
Else
  $inifilename = StringLeft(@ScriptFullPath, StringInStr(@ScriptFullPath, ".", 0, -1)) & "ini"
EndIf

;  Label
$txtxpos = $txtxoffset
$txtypos = $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateLabel("Lade Microsoft-Updates für...", $txtxpos, $txtypos, 3 * $groupwidth / 4, $txtheight)
Else
  GUICtrlCreateLabel("Download Microsoft updates for...", $txtxpos, $txtypos, 3 * $groupwidth / 4, $txtheight)
EndIf

;  Medium info group
$txtxpos = $txtxoffset + 3 * $groupwidth / 4
$txtypos = 0
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Repository-Info", $txtxpos, $txtypos, $groupwidth / 4 + 2 * $txtxoffset, 2 * $txtheight)
Else
  GUICtrlCreateGroup("Repository info", $txtxpos, $txtypos, $groupwidth / 4 + 2 * $txtxoffset, 2 * $txtheight)
EndIf
$txtxpos = $txtxpos + $txtxoffset
$txtypos = $txtypos + 1.5 * $txtyoffset + 2
If ShowGUIInGerman() Then
  $buildlbl = GUICtrlCreateLabel("Letzter Download: " & LastDownloadRun(), $txtxpos, $txtypos, $groupwidth / 4, $txtheight)
Else
  $buildlbl = GUICtrlCreateLabel("Last download: " & LastDownloadRun(), $txtxpos, $txtypos, $groupwidth / 4, $txtheight)
EndIf

;  Tab control
$txtxpos = $txtxoffset
$txtypos = $txtyoffset + $txtheight
GuiCtrlCreateTab($txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset, 5 * $groupheight_glb + 3.5 * $txtyoffset)

;  Operating Systems' Tab
$tabitemfocused = GuiCtrlCreateTabItem("Windows")

;  Windows 7 / Server 2008 R2 group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Windows 7 / Server 2008 R2 (w61 / w61-x64)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Windows 7 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  $w61_glb = GUICtrlCreateCheckbox("x86 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w61_glb = GUICtrlCreateCheckbox("x86 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w61, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 7 / Server 2008 R2 x64 global
$txtxpos = $txtxpos + $groupwidth / 2 - $txtxoffset
If ShowGUIInGerman() Then
  $w61_x64_glb = GUICtrlCreateCheckbox("x64 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w61_x64_glb = GUICtrlCreateCheckbox("x64 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w61_x64, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Windows Server 2012 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows Server 2012 (w62-x64)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Windows Server 2012 x64 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset + $groupwidth / 2 - $txtxoffset
If ShowGUIInGerman() Then
  $w62_x64_glb = GUICtrlCreateCheckbox("x64 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w62_x64_glb = GUICtrlCreateCheckbox("x64 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w62_x64, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Windows 8.1 / Server 2012 R2 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows 8.1 / Server 2012 R2 (w63 / w63-x64)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Windows 8.1 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  $w63_glb = GUICtrlCreateCheckbox("x86 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w63_glb = GUICtrlCreateCheckbox("x86 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w63, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 8.1 / Server 2012 R2 x64 global
$txtxpos = $txtxpos + $groupwidth / 2 - $txtxoffset
If ShowGUIInGerman() Then
  $w63_x64_glb = GUICtrlCreateCheckbox("x64 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w63_x64_glb = GUICtrlCreateCheckbox("x64 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w63_x64, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Windows 10 / Server 2016 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows 10 / Server 2016 (w100 / w100-x64)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Windows 10 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  $w100_glb = GUICtrlCreateCheckbox("x86 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w100_glb = GUICtrlCreateCheckbox("x86 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w100, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 10 / Server 2016 x64 global
$txtxpos = $txtxpos + $groupwidth / 2 - $txtxoffset
If ShowGUIInGerman() Then
  $w100_x64_glb = GUICtrlCreateCheckbox("x64 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w100_x64_glb = GUICtrlCreateCheckbox("x64 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w100_x64, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office Suites' Tab
GuiCtrlCreateTabItem("Office")

;  Office 2010 group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Office 2010 (o2k10)", $txtxpos, $txtypos, $groupwidth, $groupheight_lng)
;  Office 2010 English
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
$o2k10_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 French
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$o2k10_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Korean
$txtxpos = $txtxpos + $txtwidth
$o2k10_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$o2k10_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k10_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$o2k10_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Chinese simplified
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Chinese traditional
$txtxpos = $txtxpos + $txtwidth
$o2k10_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k10_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k10_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$o2k10_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$o2k10_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Hebrew
$txtxpos = $txtxpos + $txtwidth
$o2k10_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k10_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2010 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k10_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k10, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office 2013 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Office 2013 (o2k13)", $txtxpos, $txtypos, $groupwidth, $groupheight_lng)
;  Office 2013 English
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
$o2k13_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 French
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$o2k13_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Korean
$txtxpos = $txtxpos + $txtwidth
$o2k13_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$o2k13_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k13_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$o2k13_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Chinese simplified
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Chinese traditional
$txtxpos = $txtxpos + $txtwidth
$o2k13_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k13_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k13_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$o2k13_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$o2k13_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Hebrew
$txtxpos = $txtxpos + $txtwidth
$o2k13_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k13_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2013 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k13_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k13, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office 2016 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Office 2016 (o2k16)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Office 2016 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  $o2k16_glb = GUICtrlCreateCheckbox("Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $o2k16_glb = GUICtrlCreateCheckbox("Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_o2k16, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Legacy products' Tab
If ShowGUIInGerman() Then
  GuiCtrlCreateTabItem("Altprodukte")
Else
  GuiCtrlCreateTabItem("Legacy products")
EndIf

;  Windows Vista / Server 2008 group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Windows Vista / Server 2008 (w60 / w60-x64)", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
;  Windows Vista / Server 2008 global
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  $w60_glb = GUICtrlCreateCheckbox("x86 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w60_glb = GUICtrlCreateCheckbox("x86 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w60, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Vista / Server 2008 x64 global
$txtxpos = $txtxpos + $groupwidth / 2 - $txtxoffset
If ShowGUIInGerman() Then
  $w60_x64_glb = GUICtrlCreateCheckbox("x64 Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w60_x64_glb = GUICtrlCreateCheckbox("x64 Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_w60_x64, $lang_token_glb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office 2007 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Office 2007 (o2k7)", $txtxpos, $txtypos, $groupwidth, $groupheight_lng)
;  Office 2007 English
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 3 * $txtxoffset
$o2k7_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 French
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$o2k7_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Korean
$txtxpos = $txtxpos + $txtwidth
$o2k7_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$o2k7_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k7_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$o2k7_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Chinese simplified
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Chinese traditional
$txtxpos = $txtxpos + $txtwidth
$o2k7_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k7_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k7_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$o2k7_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Hebrew
$txtxpos = $txtxpos + $txtwidth
$o2k7_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k7_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k7_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Product Lifecycle group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Produkt-Lebenszyklus-Informationen", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
Else
  GUICtrlCreateGroup("Product lifecycle information", $txtxpos, $txtypos, $groupwidth, $groupheight_glb)
EndIf
;  Product Lifecycle label
$txtypos = $txtypos + 2 * $txtyoffset
$txtxpos = 3 * $txtxoffset
If ShowGUIInGerman() Then
  GUICtrlCreateLabel("Diese Produkte wurden von Microsoft abgekündigt zum 11.04.2017 (Windows Vista / Server 2008) bzw. 10.10.2017 (Office 2007).", $txtxpos, $txtypos, $groupwidth - 2 * $txtxoffset, $txtheight)
Else
  GUICtrlCreateLabel("Microsoft will discontinue these products on 04/11/2017 (Windows Vista / Server 2008) resp. 10/10/2017 (Office 2007).", $txtxpos, $txtypos, $groupwidth - 2 * $txtxoffset, $txtheight)
EndIf

;  End Tab item definition
GuiCtrlCreateTabItem("")
GUICtrlSetState($tabitemfocused, $GUI_SHOW)

;  Options group
$txtxpos = $txtxoffset
$txtypos = 5 * $groupheight_glb + 7 * $txtyoffset

If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Optionen", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_lng)
Else
  GUICtrlCreateGroup("Options", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_lng)
EndIf

;  Verify downloads
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 1.5 * $txtyoffset
If ShowGUIInGerman() Then
  $verifydownloads = GUICtrlCreateCheckbox("Heruntergeladene Updates verifizieren", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $verifydownloads = GUICtrlCreateCheckbox("Verify downloaded updates", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_verify, $enabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Include Service Packs
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $includesp = GUICtrlCreateCheckbox("Service-Packs einschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $includesp = GUICtrlCreateCheckbox("Include Service Packs", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_allowsp, $enabled) = $enabled Then
  If IniRead($inifilename, $ini_section_opts, $opts_token_includesp, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED + $GUI_DISABLE)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Include .NET Frameworks 3.5 SP1 and 4
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $dotnet = GUICtrlCreateCheckbox("C++-Laufzeitbibliotheken und .NET Frameworks einschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $dotnet = GUICtrlCreateCheckbox("Include C++ Runtime Libraries and .NET Frameworks", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_allowdotnet, $enabled) = $enabled Then
  If IniRead($inifilename, $ini_section_opts, $opts_token_includedotnet, $enabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED + $GUI_DISABLE)
EndIf

;  Security Only Updates
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $seconly = GUICtrlCreateCheckbox("'Reine Sicherheitsupdates' anstelle von 'Qualitätsrollups' verwenden", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $seconly = GUICtrlCreateCheckbox("Use 'security only updates' instead of 'quality rollups'", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_seconly, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Include Microsoft Security Essentials
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $msse = GUICtrlCreateCheckbox("Microsoft Security Essentials einschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $msse = GUICtrlCreateCheckbox("Include Microsoft Security Essentials", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_msse, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Include Windows Defender definitions
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $wddefs = GUICtrlCreateCheckbox("Windows Defender-Definitionen einschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $wddefs = GUICtrlCreateCheckbox("Include Windows Defender definitions", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_opts, $opts_token_wddefs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  ISO-Image group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Erstelle ISO-Image(s)...", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_glb)
Else
  GUICtrlCreateGroup("Create ISO image(s)...", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_glb)
EndIf

;  CD ISO image
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 2 * $txtxoffset
If ShowGUIInGerman() Then
  $cdiso = GUICtrlCreateCheckbox("pro Produkt und Sprache", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $cdiso = GUICtrlCreateCheckbox("per selected product and language", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_UNCHECKED + $GUI_DISABLE)
Else
  If IniRead($inifilename, $ini_section_iso, $iso_token_cd, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

;  cross-platform DVD ISO image
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $dvdiso = GUICtrlCreateCheckbox("pro Sprache, x86-produktübergreifend (nur Desktop-Produkte)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $dvdiso = GUICtrlCreateCheckbox("per selected language, 'x86-cross-product' (desktop only)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_UNCHECKED + $GUI_DISABLE)
Else
  If IniRead($inifilename, $ini_section_iso, $iso_token_dvd, $disabled) = $enabled Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

;  USB-Image group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("USB-Medium", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_glb)
Else
  GUICtrlCreateGroup("USB medium", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight_glb)
EndIf

;  USB image
$txtypos = $txtypos + 1.5 * $txtyoffset
$txtxpos = 2 * $txtxoffset
If ShowGUIInGerman() Then
  $usbcopy = GUICtrlCreateCheckbox("Kopiere Updates für gewählte Produkte ins Verzeichnis:", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $usbcopy = GUICtrlCreateCheckbox("Copy updates for selected products into directory:", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_UNCHECKED + $GUI_DISABLE)
Else
  If ( (IniRead($inifilename, $ini_section_usb, $usb_token_copy, $disabled) = $enabled) _
   AND (IniRead($inifilename, $ini_section_usb, $usb_token_path, "") <> "") ) Then
    GUICtrlSetState(-1, $GUI_CHECKED)
  Else
    GUICtrlSetState(-1, $GUI_UNCHECKED)
  EndIf
EndIf

;  USB target
$txtxpos = $txtxpos + $groupwidth / 2
$usbpath = GUICtrlCreateInput(IniRead($inifilename, $ini_section_usb, $usb_token_path, ""), $txtxpos, $txtypos - 2, 2 * $txtwidth - $txtxoffset - $txtheight, $txtheight)
;  USB FSF button - FileSelectFolder
$txtxpos = $txtxpos + 2 * $txtwidth - $txtxoffset - $txtheight
$usbfsf = GUICtrlCreateButton("...", $txtxpos, $txtypos - 2, $txtheight, $txtheight)
;  USB cleanup
$txtxpos = $txtxpos + $txtheight + $txtxoffset
If ShowGUIInGerman() Then
  $usbclean = GUICtrlCreateCheckbox("Zielverzeichnis bereinigen", $txtxpos, $txtypos, 2 * $txtwidth, $txtheight)
Else
  $usbclean = GUICtrlCreateCheckbox("Clean up target directory", $txtxpos, $txtypos, 2 * $txtwidth, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_usb, $usb_token_cleanup, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
If IsCheckBoxChecked($usbcopy) Then
  GUICtrlSetState($usbpath, $GUI_ENABLE)
  GUICtrlSetState($usbfsf, $GUI_ENABLE)
  GUICtrlSetState($usbclean, $GUI_ENABLE)
Else
  GUICtrlSetState($usbpath, $GUI_DISABLE)
  GUICtrlSetState($usbfsf, $GUI_DISABLE)
  GUICtrlSetState($usbclean, $GUI_DISABLE)
EndIf

;  Start button
$txtxpos = $txtxoffset
$txtypos = $txtypos + 1.5 * $txtyoffset + $txtheight
$btn_start = GUICtrlCreateButton("Start", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM)

;  Image only checkbox
$txtxpos = $txtxpos + $btnwidth + $txtxoffset
If ShowGUIInGerman() Then
  $imageonly = GUICtrlCreateCheckbox("Nur ISO / USB präparieren", $txtxpos, $txtypos, 2 * $txtwidth, $slimheight)
Else
  $imageonly = GUICtrlCreateCheckbox("Only prepare ISO / USB", $txtxpos, $txtypos, 2 * $txtwidth, $slimheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf
If NOT (IsCheckBoxChecked($cdiso) OR IsCheckBoxChecked($dvdiso) OR IsCheckBoxChecked($usbcopy)) Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

;  Scripting checkbox
If ShowGUIInGerman() Then
  $scripting = GUICtrlCreateCheckbox("Nur Sammelskript erstellen", $txtxpos, $txtypos + $slimheight, 2 * $txtwidth, $slimheight)
Else
  $scripting = GUICtrlCreateCheckbox("Only create collection script", $txtxpos, $txtypos + $slimheight, 2 * $txtwidth, $slimheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_showshutdown, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_HIDE)
EndIf

;  Shutdown checkbox
If ShowGUIInGerman() Then
  $shutdown = GUICtrlCreateCheckbox("Herunterfahren nach Abschluss", $txtxpos, $txtypos + $slimheight, 2 * $txtwidth, $slimheight)
Else
  $shutdown = GUICtrlCreateCheckbox("Shut down on completion", $txtxpos, $txtypos + $slimheight, 2 * $txtwidth, $slimheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_showshutdown, $disabled) = $disabled Then
  GUICtrlSetState(-1, $GUI_HIDE)
EndIf

;  Proxy button
$txtxpos = 2 * $txtxoffset + $groupwidth / 2 - $btnwidth
$btn_proxy = GUICtrlCreateButton("Proxy...", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
$proxy = IniRead($inifilename, $ini_section_misc, $misc_token_proxy, "")

;  WSUS button
$txtxpos = 2 * $txtxoffset + $groupwidth / 2
$btn_wsus = GUICtrlCreateButton("WSUS...", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
If ( (IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $enabled) _
  OR (IniRead($inifilename, $ini_section_misc, $misc_token_skipdynamic, $disabled) = $enabled) ) Then
  GUICtrlSetState(-1, $GUI_DISABLE)
EndIf
$wsus = IniRead($inifilename, $ini_section_misc, $misc_token_wsus, "")

;  Donate button
$txtxpos = 2.5 * $txtxoffset + 3 * $groupwidth / 4 - $btnwidth / 2
If ShowGUIInGerman() Then
  $btn_donate = GUICtrlCreateButton("Spenden...", $txtxpos, $txtypos, $btnwidth, $btnheight)
Else
  $btn_donate = GUICtrlCreateButton("Donate...", $txtxpos, $txtypos, $btnwidth, $btnheight)
EndIf
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
If IniRead($inifilename, $ini_section_misc, $misc_token_showdonate, $enabled) = $disabled Then
  GUICtrlSetState(-1, $GUI_HIDE)
EndIf

;  Exit button
$txtxpos = 3 * $txtxoffset + $groupwidth - $btnwidth
If ShowGUIInGerman() Then
  $btn_exit = GUICtrlCreateButton("Ende", $txtxpos, $txtypos, $btnwidth, $btnheight)
Else
  $btn_exit = GUICtrlCreateButton("Exit", $txtxpos, $txtypos, $btnwidth, $btnheight)
EndIf
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM)

; GUI message loop
GUISetState()
If IsUNCPath(@ScriptDir) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Das Skript wurde von einem UNC-Pfad gestartet." _
                     & @LF & "Bitte weisen Sie der Netzwerkfreigabe einen Laufwerksbuchstaben zu.")
  Else
    MsgBox(0x2010, "Error", "The script was startet from a UNC path." _
                    & @LF & "Please map a drive letter to the network share.")
  EndIf
  Exit(1)
EndIf
If NOT PathValid(@ScriptDir) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Der Skript-Pfad darf nicht mehr als " & $path_max_length & " Zeichen lang sein und" _
                     & @LF & "darf keines der folgenden Zeichen enthalten: " & $path_invalid_chars)
  Else
    MsgBox(0x2010, "Error", "The script path must not be more than " & $path_max_length & " characters long and" _
                    & @LF & "must not contain any of the following characters: " & $path_invalid_chars)
  EndIf
  Exit(1)
EndIf
If NOT PathValid(@TempDir) Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Der %TEMP%-Pfad darf nicht mehr als " & $path_max_length & " Zeichen lang sein und" _
                     & @LF & "darf keines der folgenden Zeichen enthalten: " & $path_invalid_chars)
  Else
    MsgBox(0x2010, "Error", "The %TEMP% path must not be more than " & $path_max_length & " characters long and" _
                    & @LF & "must not contain any of the following characters: " & $path_invalid_chars)
  EndIf
  Exit(1)
EndIf
If StringRight(EnvGet("TEMP"), 1) = "\" Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Der %TEMP%-Pfad enthält einen abschließenden Backslash ('\').")
  Else
    MsgBox(0x2010, "Error", "The %TEMP% path contains a trailing backslash ('\').")
  EndIf
  Exit(1)
EndIf
If NOT DirectoryStructureExists() Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Die Verzeichnisstruktur ist unvollständig." _
                     & @LF & "Bitte behalten Sie diese beim Entpacken des Zip-Archivs bei.")
  Else
    MsgBox(0x2010, "Error", "The directory structure is incomplete." _
                    & @LF & "Please keep it when you unpack the Zip archive.")
  EndIf
  Exit(1)
EndIf
While 1
  Switch GUIGetMsg()
    Case $GUI_EVENT_CLOSE   ; Window closed
      ExitLoop

    Case $btn_exit          ; Exit button pressed
      ExitLoop

    Case $includesp         ; 'Include Service Packs' check box toggled
      If ( (NOT IsCheckBoxChecked($includesp)) AND (IniRead($inifilename, $ini_section_opts, $opts_token_cleanup, $enabled) = $enabled) ) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch die Option 'Service-Packs ausschließen' werden bereits" _
                               & @LF & "heruntergeladene Service Packs für die selektierten Produkte gelöscht." _
                               & @LF & "Möchten Sie fortsetzen?") = $msgbox_btn_no Then
            GUICtrlSetState($includesp, $GUI_CHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The option 'Exclude Service Packs' will delete" _
                               & @LF & "previously downloaded Service Packs for the selected products." _
                               & @LF & "Do you wish to proceed?") = $msgbox_btn_no Then
            GUICtrlSetState($includesp, $GUI_CHECKED)
          EndIf
        EndIf
      EndIf

    Case $cdiso             ; CD ISO image button pressed
      If (IsCheckBoxChecked($cdiso) OR IsCheckBoxChecked($dvdiso) OR IsCheckBoxChecked($usbcopy)) Then
        GUICtrlSetState($imageonly, $GUI_ENABLE)
      Else
        GUICtrlSetState($imageonly, $GUI_UNCHECKED + $GUI_DISABLE)
        If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
          GUICtrlSetState($verifydownloads, $GUI_ENABLE)
          GUICtrlSetState($seconly, $GUI_ENABLE)
          GUICtrlSetState($shutdown, $GUI_ENABLE)
        EndIf
      EndIf

    Case $dvdiso            ; DVD ISO image button pressed
      If (IsCheckBoxChecked($cdiso) OR IsCheckBoxChecked($dvdiso) OR IsCheckBoxChecked($usbcopy)) Then
        GUICtrlSetState($imageonly, $GUI_ENABLE)
      Else
        GUICtrlSetState($imageonly, $GUI_UNCHECKED + $GUI_DISABLE)
        If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
          GUICtrlSetState($verifydownloads, $GUI_ENABLE)
          GUICtrlSetState($seconly, $GUI_ENABLE)
          GUICtrlSetState($shutdown, $GUI_ENABLE)
        EndIf
      EndIf

    Case $usbcopy           ; USB copy button pressed
      If IsCheckBoxChecked($usbcopy) Then
        GUICtrlSetState($usbpath, $GUI_ENABLE)
        GUICtrlSetState($usbfsf, $GUI_ENABLE)
        GUICtrlSetState($usbclean, $GUI_ENABLE)
      Else
        GUICtrlSetState($usbpath, $GUI_DISABLE)
        GUICtrlSetState($usbfsf, $GUI_DISABLE)
        GUICtrlSetState($usbclean, $GUI_DISABLE)
      EndIf
      If (IsCheckBoxChecked($cdiso) OR IsCheckBoxChecked($dvdiso) OR IsCheckBoxChecked($usbcopy)) Then
        GUICtrlSetState($imageonly, $GUI_ENABLE)
      Else
        GUICtrlSetState($imageonly, $GUI_UNCHECKED + $GUI_DISABLE)
        If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
          GUICtrlSetState($verifydownloads, $GUI_ENABLE)
          GUICtrlSetState($seconly, $GUI_ENABLE)
          GUICtrlSetState($shutdown, $GUI_ENABLE)
        EndIf
      EndIf

    Case $usbfsf            ; FSF button pressed
      If ShowGUIInGerman() Then
        $dummy = FileSelectFolder("Wählen Sie das Zielverzeichnis:", "", 1, GUICtrlRead($usbpath))
      Else
        $dummy = FileSelectFolder("Choose target directory:", "", 1, GUICtrlRead($usbpath))
      EndIf
      If FileExists($dummy) Then
        GUICtrlSetData($usbpath, $dummy)
      EndIf

    Case $usbclean          ; 'Clean up target directory' check box toggled
      If IsCheckBoxChecked($usbclean) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch die Option 'Zielverzeichnis bereinigen'" _
                               & @LF & "werden dort bereits existierende Dateien gelöscht." _
                               & @LF & "Möchten Sie fortsetzen?") = $msgbox_btn_no Then
            GUICtrlSetState($usbclean, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The option 'Clean up target directory'" _
                               & @LF & "will delete existing files there." _
                               & @LF & "Do you wish to proceed?") = $msgbox_btn_no Then
            GUICtrlSetState($usbclean, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $imageonly         ; Image only checkbox toggled
      If IsCheckBoxChecked($imageonly) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch diese Option verhindern Sie das Herunterladen aktueller Updates." _
                               & @LF & "Dies kann ein erhöhtes Sicherheitsrisiko für das Zielsystem bedeuten." _
                               & @LF & "Möchten Sie fortsetzen?") = $msgbox_btn_no Then
            GUICtrlSetState($imageonly, $GUI_UNCHECKED)
          Else
            GUICtrlSetState($verifydownloads, $GUI_DISABLE)
            GUICtrlSetState($seconly, $GUI_DISABLE)
            GUICtrlSetState($shutdown, $GUI_UNCHECKED + $GUI_DISABLE)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "This option prevents downloading of recent updates." _
                               & @LF & "This may increase security risks for the target system." _
                               & @LF & "Do you wish to proceed?") = $msgbox_btn_no Then
            GUICtrlSetState($imageonly, $GUI_UNCHECKED)
          Else
            GUICtrlSetState($verifydownloads, $GUI_DISABLE)
            GUICtrlSetState($seconly, $GUI_DISABLE)
            GUICtrlSetState($shutdown, $GUI_UNCHECKED + $GUI_DISABLE)
          EndIf
        EndIf
      Else
        If IniRead($inifilename, $ini_section_misc, $misc_token_skipdownload, $disabled) = $disabled Then
          GUICtrlSetState($verifydownloads, $GUI_ENABLE)
          GUICtrlSetState($seconly, $GUI_ENABLE)
          GUICtrlSetState($shutdown, $GUI_ENABLE)
        EndIf
      EndIf

    Case $btn_proxy         ; Proxy button pressed
      If ShowGUIInGerman() Then
        $dummy = InputBox("HTTP-Proxy-Einstellung", _
                          "ACHTUNG: Sonderzeichen müssen hier gemäß RFC1738 codiert werden." & @LF _
                        & "Um die Speicherung Ihres Passworts zu vermeiden," & @LF _
                        & "lassen Sie es hier bitte weg (http://Benutzername:@Server[:Port])." & @LF & @LF _
                        & "Bitte geben Sie Ihre HTTP-Proxy-URL ein" & @LF _
                        & "(http://[Benutzername:[Passwort]@]Server[:Port]):", $proxy, "", 400, 180)
      Else
        $dummy = InputBox("HTTP Proxy setting", _
                          "NOTE: Special characters have to be encoded according to RFC1738 here." & @LF _
                        & "To avoid storage of your password, please omit it here" & @LF _
                        & "(http://username:@server[:port])." & @LF & @LF _
                        & "Please enter your HTTP Proxy URL" & @LF _
                        & "(http://[username:[password]@]server[:port]):", $proxy, "", 420, 180)
      EndIf
      If ( (@error = 0) AND ($proxy <> $dummy) ) Then
        $proxy = $dummy
        $proxypwd = ""
      EndIf

    Case $btn_wsus          ; WSUS button pressed
      If ShowGUIInGerman() Then
        $dummy = InputBox("WSUS-Einstellung", "Bitte geben Sie Ihre WSUS-URL ein" & @LF & "(http://Server):", $wsus, "", 220, 130)
      Else
        $dummy = InputBox("WSUS setting", "Please enter your WSUS URL" & @LF & "(http://server):", $wsus, "", 200, 130)
      EndIf
      If @error = 0 Then
        $wsus = $dummy
      EndIf

    Case $btn_donate        ; Donate button pressed
      Run(@ComSpec & " /D /C start " & $donationURL)

    Case $btn_start         ; Start button pressed
      $runany = False
      If NOT IsCheckBoxChecked($imageonly) Then
        If ( (StringInStr($proxy, ":@") > 0) AND ($proxypwd = "") ) Then
          If ShowGUIInGerman() Then
            $dummy = InputBox("HTTP-Proxy-Passwort", _
                              "ACHTUNG: Bitte codieren Sie Sonderzeichen hier nicht." & @LF _
                            & "Dies geschieht automatisch." & @LF & @LF _
                            & "Bitte geben Sie Ihr HTTP-Proxy-Passwort ein:", "", "*", 320, 150)
          Else
            $dummy = InputBox("HTTP Proxy password", _
                              "NOTE: Please do not encode special characters here." & @LF _
                            & "This will be done automatically." & @LF & @LF _
                            & "Please enter your HTTP Proxy password:", "", "*", 300, 150)
          EndIf
          If @error = 0 Then
            $proxypwd = RFC1738EncodedString($dummy)
          Else
            ContinueLoop
          EndIf
        EndIf
        If (IniRead($inifilename, $ini_section_misc, $misc_token_chkver, $enabled) = $enabled) Then
          Switch RunVersionCheck(AuthProxy($proxy, $proxypwd))
            Case -1 ; Yes
              Run(@ComSpec & " /D /C start " & $downloadURL)
              RunSelfUpdate(AuthProxy($proxy, $proxypwd))
              ExitLoop
            Case 1  ; Cancel / Close
              Run(@ComSpec & " /D /C start " & $downloadURL)
              ContinueLoop
          EndSwitch
        EndIf
      EndIf
      IniWrite(ClientIniFileName(), $ini_section_inst, $opts_token_seconly, CheckBoxStateToString($seconly))
      If ( (IniRead($inifilename, $ini_section_misc, $misc_token_wsus_trans, $disabled) = $enabled) AND ($wsus <> "") ) Then
        IniWrite(ClientIniFileName(), $ini_section_misc, $misc_token_clt_wustat, $wsus)
      Else
        IniDelete(ClientIniFileName(), $ini_section_misc, $misc_token_clt_wustat)
      EndIf
      If IniRead($inifilename, $ini_section_misc, $misc_token_minimize, $disabled) = $enabled Then
        WinSetState($maindlg, $maindlg, @SW_MINIMIZE)
      EndIf

;  Global
      If IsCheckBoxChecked($w60_glb) Then
        If RunScripts("w60 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w60_x64_glb) Then
        If RunScripts("w60-x64 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w61_glb) Then
        If RunScripts("w61 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w61_x64_glb) Then
        If RunScripts("w61-x64 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w62_x64_glb) Then
        If RunScripts("w62-x64 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w63_glb) Then
        If RunScripts("w63 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w63_x64_glb) Then
        If RunScripts("w63-x64 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w100_glb) Then
        If RunScripts("w100 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($w100_x64_glb) Then
        If RunScripts("w100-x64 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsLangOfficeChecked() OR IsCheckBoxChecked($o2k16_glb)) Then
        If RunScripts("ofc glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  English
      If IsCheckBoxChecked($o2k7_enu) Then
        If RunScripts("o2k7 enu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_enu) Then
        If RunScripts("o2k10 enu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_enu) Then
        If RunScripts("o2k13 enu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  French
      If IsCheckBoxChecked($o2k7_fra) Then
        If RunScripts("o2k7 fra", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_fra) Then
        If RunScripts("o2k10 fra", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_fra) Then
        If RunScripts("o2k13 fra", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Spanish
      If IsCheckBoxChecked($o2k7_esn) Then
        If RunScripts("o2k7 esn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_esn) Then
        If RunScripts("o2k10 esn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_esn) Then
        If RunScripts("o2k13 esn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Japanese
      If IsCheckBoxChecked($o2k7_jpn) Then
        If RunScripts("o2k7 jpn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_jpn) Then
        If RunScripts("o2k10 jpn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_jpn) Then
        If RunScripts("o2k13 jpn", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Korean
      If IsCheckBoxChecked($o2k7_kor) Then
        If RunScripts("o2k7 kor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_kor) Then
        If RunScripts("o2k10 kor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_kor) Then
        If RunScripts("o2k13 kor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Russian
      If IsCheckBoxChecked($o2k7_rus) Then
        If RunScripts("o2k7 rus", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_rus) Then
        If RunScripts("o2k10 rus", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_rus) Then
        If RunScripts("o2k13 rus", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Portuguese
      If IsCheckBoxChecked($o2k7_ptg) Then
        If RunScripts("o2k7 ptg", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_ptg) Then
        If RunScripts("o2k10 ptg", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_ptg) Then
        If RunScripts("o2k13 ptg", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Brazilian
      If IsCheckBoxChecked($o2k7_ptb) Then
        If RunScripts("o2k7 ptb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_ptb) Then
        If RunScripts("o2k10 ptb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_ptb) Then
        If RunScripts("o2k13 ptb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  German
      If IsCheckBoxChecked($o2k7_deu) Then
        If RunScripts("o2k7 deu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_deu) Then
        If RunScripts("o2k10 deu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_deu) Then
        If RunScripts("o2k13 deu", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Dutch
      If IsCheckBoxChecked($o2k7_nld) Then
        If RunScripts("o2k7 nld", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_nld) Then
        If RunScripts("o2k10 nld", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_nld) Then
        If RunScripts("o2k13 nld", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Italian
      If IsCheckBoxChecked($o2k7_ita) Then
        If RunScripts("o2k7 ita", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_ita) Then
        If RunScripts("o2k10 ita", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_ita) Then
        If RunScripts("o2k13 ita", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Chinese simplified
      If IsCheckBoxChecked($o2k7_chs) Then
        If RunScripts("o2k7 chs", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_chs) Then
        If RunScripts("o2k10 chs", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_chs) Then
        If RunScripts("o2k13 chs", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Chinese traditional
      If IsCheckBoxChecked($o2k7_cht) Then
        If RunScripts("o2k7 cht", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_cht) Then
        If RunScripts("o2k10 cht", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_cht) Then
        If RunScripts("o2k13 cht", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Polish
      If IsCheckBoxChecked($o2k7_plk) Then
        If RunScripts("o2k7 plk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_plk) Then
        If RunScripts("o2k10 plk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_plk) Then
        If RunScripts("o2k13 plk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Hungarian
      If IsCheckBoxChecked($o2k7_hun) Then
        If RunScripts("o2k7 hun", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_hun) Then
        If RunScripts("o2k10 hun", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_hun) Then
        If RunScripts("o2k13 hun", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Czech
      If IsCheckBoxChecked($o2k7_csy) Then
        If RunScripts("o2k7 csy", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_csy) Then
        If RunScripts("o2k10 csy", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_csy) Then
        If RunScripts("o2k13 csy", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Swedish
      If IsCheckBoxChecked($o2k7_sve) Then
        If RunScripts("o2k7 sve", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_sve) Then
        If RunScripts("o2k10 sve", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_sve) Then
        If RunScripts("o2k13 sve", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Turkish
      If IsCheckBoxChecked($o2k7_trk) Then
        If RunScripts("o2k7 trk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_trk) Then
        If RunScripts("o2k10 trk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_trk) Then
        If RunScripts("o2k13 trk", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Greek
      If IsCheckBoxChecked($o2k7_ell) Then
        If RunScripts("o2k7 ell", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_ell) Then
        If RunScripts("o2k10 ell", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_ell) Then
        If RunScripts("o2k13 ell", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Arabic
      If IsCheckBoxChecked($o2k7_ara) Then
        If RunScripts("o2k7 ara", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_ara) Then
        If RunScripts("o2k10 ara", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_ara) Then
        If RunScripts("o2k13 ara", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Hebrew
      If IsCheckBoxChecked($o2k7_heb) Then
        If RunScripts("o2k7 heb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_heb) Then
        If RunScripts("o2k10 heb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_heb) Then
        If RunScripts("o2k13 heb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Danish
      If IsCheckBoxChecked($o2k7_dan) Then
        If RunScripts("o2k7 dan", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_dan) Then
        If RunScripts("o2k10 dan", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_dan) Then
        If RunScripts("o2k13 dan", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Norwegian
      If IsCheckBoxChecked($o2k7_nor) Then
        If RunScripts("o2k7 nor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_nor) Then
        If RunScripts("o2k10 nor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_nor) Then
        If RunScripts("o2k13 nor", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Finnish
      If IsCheckBoxChecked($o2k7_fin) Then
        If RunScripts("o2k7 fin", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k10_fin) Then
        If RunScripts("o2k10 fin", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If IsCheckBoxChecked($o2k13_fin) Then
        If RunScripts("o2k13 fin", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Global (Office 2016)
      If IsCheckBoxChecked($o2k16_glb) Then
        If RunScripts("o2k16 glb", IsCheckBoxChecked($imageonly), DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), False, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), False, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Office language specific
      If (IsCheckBoxChecked($o2k7_enu) OR IsCheckBoxChecked($o2k10_enu) OR IsCheckBoxChecked($o2k13_enu)) Then
        If RunScripts("ofc enu", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_fra) OR IsCheckBoxChecked($o2k10_fra) OR IsCheckBoxChecked($o2k13_fra)) Then
        If RunScripts("ofc fra", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_esn) OR IsCheckBoxChecked($o2k10_esn) OR IsCheckBoxChecked($o2k13_esn)) Then
        If RunScripts("ofc esn", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_jpn) OR IsCheckBoxChecked($o2k10_jpn) OR IsCheckBoxChecked($o2k13_jpn)) Then
        If RunScripts("ofc jpn", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_kor) OR IsCheckBoxChecked($o2k10_kor) OR IsCheckBoxChecked($o2k13_kor)) Then
        If RunScripts("ofc kor", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_rus) OR IsCheckBoxChecked($o2k10_rus) OR IsCheckBoxChecked($o2k13_rus)) Then
        If RunScripts("ofc rus", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_ptg) OR IsCheckBoxChecked($o2k10_ptg) OR IsCheckBoxChecked($o2k13_ptg)) Then
        If RunScripts("ofc ptg", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_ptb) OR IsCheckBoxChecked($o2k10_ptb) OR IsCheckBoxChecked($o2k13_ptb)) Then
        If RunScripts("ofc ptb", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_deu) OR IsCheckBoxChecked($o2k10_deu) OR IsCheckBoxChecked($o2k13_deu)) Then
        If RunScripts("ofc deu", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_nld) OR IsCheckBoxChecked($o2k10_nld) OR IsCheckBoxChecked($o2k13_nld)) Then
        If RunScripts("ofc nld", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_ita) OR IsCheckBoxChecked($o2k10_ita) OR IsCheckBoxChecked($o2k13_ita)) Then
        If RunScripts("ofc ita", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_chs) OR IsCheckBoxChecked($o2k10_chs) OR IsCheckBoxChecked($o2k13_chs)) Then
        If RunScripts("ofc chs", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_cht) OR IsCheckBoxChecked($o2k10_cht) OR IsCheckBoxChecked($o2k13_cht)) Then
        If RunScripts("ofc cht", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_plk) OR IsCheckBoxChecked($o2k10_plk) OR IsCheckBoxChecked($o2k13_plk)) Then
        If RunScripts("ofc plk", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_hun) OR IsCheckBoxChecked($o2k10_hun) OR IsCheckBoxChecked($o2k13_hun)) Then
        If RunScripts("ofc hun", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_csy) OR IsCheckBoxChecked($o2k10_csy) OR IsCheckBoxChecked($o2k13_csy)) Then
        If RunScripts("ofc csy", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_sve) OR IsCheckBoxChecked($o2k10_sve) OR IsCheckBoxChecked($o2k13_sve)) Then
        If RunScripts("ofc sve", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_trk) OR IsCheckBoxChecked($o2k10_trk) OR IsCheckBoxChecked($o2k13_trk)) Then
        If RunScripts("ofc trk", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_ell) OR IsCheckBoxChecked($o2k10_ell) OR IsCheckBoxChecked($o2k13_ell)) Then
        If RunScripts("ofc ell", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_ara) OR IsCheckBoxChecked($o2k10_ara) OR IsCheckBoxChecked($o2k13_ara)) Then
        If RunScripts("ofc ara", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_heb) OR IsCheckBoxChecked($o2k10_heb) OR IsCheckBoxChecked($o2k13_heb)) Then
        If RunScripts("ofc heb", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_dan) OR IsCheckBoxChecked($o2k10_dan) OR IsCheckBoxChecked($o2k13_dan)) Then
        If RunScripts("ofc dan", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_nor) OR IsCheckBoxChecked($o2k10_nor) OR IsCheckBoxChecked($o2k13_nor)) Then
        If RunScripts("ofc nor", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If (IsCheckBoxChecked($o2k7_fin) OR IsCheckBoxChecked($o2k10_fin) OR IsCheckBoxChecked($o2k13_fin)) Then
        If RunScripts("ofc fin", True, DetermineDownloadSwitches($includesp, $dotnet, $seconly, $msse, $wddefs, $verifydownloads, AuthProxy($proxy, $proxypwd), $wsus), IsCheckBoxChecked($cdiso), DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean), IsCheckBoxChecked($usbcopy), GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Create cross-platform DVD ISO images
      If IsCheckBoxChecked($dvdiso) Then
        If (IsCheckBoxChecked($o2k7_enu) OR IsCheckBoxChecked($o2k10_enu) OR IsCheckBoxChecked($o2k13_enu)) Then
          If RunISOCreationScript($lang_token_enu, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_fra) OR IsCheckBoxChecked($o2k10_fra) OR IsCheckBoxChecked($o2k13_fra)) Then
          If RunISOCreationScript($lang_token_fra, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_esn) OR IsCheckBoxChecked($o2k10_esn) OR IsCheckBoxChecked($o2k13_esn)) Then
          If RunISOCreationScript($lang_token_esn, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_jpn) OR IsCheckBoxChecked($o2k10_jpn) OR IsCheckBoxChecked($o2k13_jpn)) Then
          If RunISOCreationScript($lang_token_jpn, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_kor) OR IsCheckBoxChecked($o2k10_kor) OR IsCheckBoxChecked($o2k13_kor)) Then
          If RunISOCreationScript($lang_token_kor, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_rus) OR IsCheckBoxChecked($o2k10_rus) OR IsCheckBoxChecked($o2k13_rus)) Then
          If RunISOCreationScript($lang_token_rus, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_ptg) OR IsCheckBoxChecked($o2k10_ptg) OR IsCheckBoxChecked($o2k13_ptg)) Then
          If RunISOCreationScript($lang_token_ptg, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_ptb) OR IsCheckBoxChecked($o2k10_ptb) OR IsCheckBoxChecked($o2k13_ptb)) Then
          If RunISOCreationScript($lang_token_ptb, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_deu) OR IsCheckBoxChecked($o2k10_deu) OR IsCheckBoxChecked($o2k13_deu)) Then
          If RunISOCreationScript($lang_token_deu, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_nld) OR IsCheckBoxChecked($o2k10_nld) OR IsCheckBoxChecked($o2k13_nld)) Then
          If RunISOCreationScript($lang_token_nld, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_ita) OR IsCheckBoxChecked($o2k10_ita) OR IsCheckBoxChecked($o2k13_ita)) Then
          If RunISOCreationScript($lang_token_ita, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_chs) OR IsCheckBoxChecked($o2k10_chs) OR IsCheckBoxChecked($o2k13_chs)) Then
          If RunISOCreationScript($lang_token_chs, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_cht) OR IsCheckBoxChecked($o2k10_cht) OR IsCheckBoxChecked($o2k13_cht)) Then
          If RunISOCreationScript($lang_token_cht, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_plk) OR IsCheckBoxChecked($o2k10_plk) OR IsCheckBoxChecked($o2k13_plk)) Then
          If RunISOCreationScript($lang_token_plk, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_hun) OR IsCheckBoxChecked($o2k10_hun) OR IsCheckBoxChecked($o2k13_hun)) Then
          If RunISOCreationScript($lang_token_hun, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_csy) OR IsCheckBoxChecked($o2k10_csy) OR IsCheckBoxChecked($o2k13_csy)) Then
          If RunISOCreationScript($lang_token_csy, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_sve) OR IsCheckBoxChecked($o2k10_sve) OR IsCheckBoxChecked($o2k13_sve)) Then
          If RunISOCreationScript($lang_token_sve, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_trk) OR IsCheckBoxChecked($o2k10_trk) OR IsCheckBoxChecked($o2k13_trk)) Then
          If RunISOCreationScript($lang_token_trk, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_ell) OR IsCheckBoxChecked($o2k10_ell) OR IsCheckBoxChecked($o2k13_ell)) Then
          If RunISOCreationScript($lang_token_ell, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_ara) OR IsCheckBoxChecked($o2k10_ara) OR IsCheckBoxChecked($o2k13_ara)) Then
          If RunISOCreationScript($lang_token_ara, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_heb) OR IsCheckBoxChecked($o2k10_heb) OR IsCheckBoxChecked($o2k13_heb)) Then
          If RunISOCreationScript($lang_token_heb, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_dan) OR IsCheckBoxChecked($o2k10_dan) OR IsCheckBoxChecked($o2k13_dan)) Then
          If RunISOCreationScript($lang_token_dan, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_nor) OR IsCheckBoxChecked($o2k10_nor) OR IsCheckBoxChecked($o2k13_nor)) Then
          If RunISOCreationScript($lang_token_nor, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If (IsCheckBoxChecked($o2k7_fin) OR IsCheckBoxChecked($o2k10_fin) OR IsCheckBoxChecked($o2k13_fin)) Then
          If RunISOCreationScript($lang_token_fin, DetermineISOSwitches($includesp, $dotnet, $msse, $wddefs, $usbclean)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
      EndIf

;  Restore window and show success dialog
      WinSetState($maindlg, $maindlg, @SW_RESTORE)
      If ($runany) Then
        If IsCheckBoxChecked($scripting) Then
          If ShowGUIInGerman() Then
            If MsgBox(0x2044, "Info", "Sammelskript " & @ScriptDir & "\cmd\custom\RunAll.cmd erstellt." _
                      & @LF & "Möchten Sie das Skript nun prüfen?") = $msgbox_btn_yes Then
              ShowRunAll()
            EndIf
          Else
            If MsgBox(0x2044, "Info", "Collection script " & @ScriptDir & "\cmd\custom\RunAll.cmd created." _
                      & @LF & "Would you like to check the script now?") = $msgbox_btn_yes Then
              ShowRunAll()
            EndIf
          EndIf
        Else
          If IsCheckBoxChecked($shutdown) Then
            Run(@SystemDir & "\shutdown.exe /s /f /t 5", @SystemDir, @SW_HIDE)
            ExitLoop
          EndIf
          If IsCheckBoxChecked($imageonly) Then
            If ShowGUIInGerman() Then
              MsgBox(0x2040, "Info", "Image-Erstellung / Kopieren erfolgreich.")
            Else
              MsgBox(0x2040, "Info", "Image creation / copying successful.")
            EndIf
          Else
            If ShowGUIInGerman() Then
              If MsgBox(0x2044, "Info", "Herunterladen / Image-Erstellung / Kopieren erfolgreich." _
                        & @LF & "Möchten Sie nun die Protokolldatei auf mögliche Warnungen prüfen?") = $msgbox_btn_yes Then
                ShowLogFile()
              EndIf
            Else
              If MsgBox(0x2044, "Info", "Download / image creation / copying successful." _
                        & @LF & "Would you like to check the log file for possible warnings now?") = $msgbox_btn_yes Then
                ShowLogFile()
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        If ShowGUIInGerman() Then
          MsgBox(0x2040, "Info", "Nichts zu tun!")
        Else
          MsgBox(0x2040, "Info", "Nothing to do!")
        EndIf
      EndIf

  EndSwitch
WEnd
SaveSettings()
Exit
