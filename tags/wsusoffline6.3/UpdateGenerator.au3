; *** WSUS Offline Update 6.3 - Generator ***
; ***  Author: T. Wittrock, RZ Uni Kiel   ***
; ***   USB-Option added by Ch. Riedel    ***
; *** Dialog scaling added by Th. Baisch  ***

#include <GUIConstants.au3>

Dim Const $caption                = "WSUS Offline Update 6.3"
Dim Const $title                  = $caption & " - Generator"
Dim Const $downloadURL            = "http://download.wsusoffline.net/"
Dim Const $donationURL            = "http://www.wsusoffline.net/donate.html"

; Registry constants
Dim Const $reg_key_fontdpi        = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontDPI"
Dim Const $reg_key_windowmetrics  = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
Dim Const $reg_val_applieddpi     = "AppliedDPI"
Dim Const $reg_val_logpixels      = "LogPixels"

; Defaults
Dim Const $default_logpixels      = 96

; INI file constants
Dim Const $ini_section_w2k        = "Windows 2000"
Dim Const $ini_section_wxp        = "Windows XP"
Dim Const $ini_section_w2k3       = "Windows Server 2003"
Dim Const $ini_section_w2k3_x64   = "Windows Server 2003 x64"
Dim Const $ini_section_w60        = "Windows Vista"
Dim Const $ini_section_w60_x64    = "Windows Vista x64"
Dim Const $ini_section_w61        = "Windows 7"
Dim Const $ini_section_w61_x64    = "Windows Server 2008 R2"
Dim Const $ini_section_oxp        = "Office XP"
Dim Const $ini_section_o2k3       = "Office 2003"
Dim Const $ini_section_o2k7       = "Office 2007"
Dim Const $ini_section_o2k7_x64   = "Office 2007 x64"
Dim Const $ini_section_iso        = "ISO Images"
Dim Const $ini_section_usb        = "USB Images"
Dim Const $ini_section_misc       = "Miscellaneous"
Dim Const $enabled                = "Enabled"
Dim Const $disabled               = "Disabled"
Dim Const $lang_token_glb         = "glb"
Dim Const $lang_token_enu         = "enu"
Dim Const $lang_token_fra         = "fra"
Dim Const $lang_token_esn         = "esn"
Dim Const $lang_token_jpn         = "jpn"
Dim Const $lang_token_kor         = "kor"
Dim Const $lang_token_rus         = "rus"
Dim Const $lang_token_ptg         = "ptg"
Dim Const $lang_token_ptb         = "ptb"
Dim Const $lang_token_deu         = "deu"
Dim Const $lang_token_nld         = "nld"
Dim Const $lang_token_ita         = "ita"
Dim Const $lang_token_chs         = "chs"
Dim Const $lang_token_cht         = "cht"
Dim Const $lang_token_plk         = "plk"
Dim Const $lang_token_hun         = "hun"
Dim Const $lang_token_csy         = "csy"
Dim Const $lang_token_sve         = "sve"
Dim Const $lang_token_trk         = "trk"
Dim Const $lang_token_ell         = "ell"
Dim Const $lang_token_ara         = "ara"
Dim Const $lang_token_heb         = "heb"
Dim Const $lang_token_dan         = "dan"
Dim Const $lang_token_nor         = "nor"
Dim Const $lang_token_fin         = "fin"
Dim Const $iso_token_cd           = "single"
Dim Const $iso_token_dvd          = "cross-platform"
Dim Const $usb_token_copy         = "copy"
Dim Const $usb_token_path         = "path"
Dim Const $misc_token_nostatics   = "excludestatics"
Dim Const $misc_token_dotnet      = "includedotnet"
Dim Const $misc_token_cleanup     = "cleanupdownloads"
Dim Const $misc_token_verify      = "verifydownloads"
Dim Const $misc_token_proxy       = "proxy"
Dim Const $misc_token_wsus        = "wsus"
Dim Const $misc_token_chkver      = "checkouversion"
Dim Const $misc_token_minimize    = "minimizeondownload"
Dim Const $misc_token_showdonate  = "showdonate"

Dim $maindlg, $inifilename, $tabitemfocused, $excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $skipdownload
Dim $cdiso, $dvdiso, $usbcopy, $usblbl, $usbpath, $usbfsf, $btn_start, $btn_proxy, $btn_wsus, $btn_donate, $btn_exit, $proxy, $wsus, $dummy
Dim $w2k_enu, $wxp_enu, $w2k3_enu, $w2k3_x64_enu, $oxp_enu, $o2k3_enu, $o2k7_enu  ; English
Dim $w2k_fra, $wxp_fra, $w2k3_fra, $w2k3_x64_fra, $oxp_fra, $o2k3_fra, $o2k7_fra  ; French
Dim $w2k_esn, $wxp_esn, $w2k3_esn, $w2k3_x64_esn, $oxp_esn, $o2k3_esn, $o2k7_esn  ; Spanish
Dim $w2k_jpn, $wxp_jpn, $w2k3_jpn, $w2k3_x64_jpn, $oxp_jpn, $o2k3_jpn, $o2k7_jpn  ; Japanese
Dim $w2k_kor, $wxp_kor, $w2k3_kor, $w2k3_x64_kor, $oxp_kor, $o2k3_kor, $o2k7_kor  ; Korean
Dim $w2k_rus, $wxp_rus, $w2k3_rus, $w2k3_x64_rus, $oxp_rus, $o2k3_rus, $o2k7_rus  ; Russian
Dim $w2k_ptg, $wxp_ptg, $w2k3_ptg, $oxp_ptg, $o2k3_ptg, $o2k7_ptg ; Portuguese
Dim $w2k_ptb, $wxp_ptb, $w2k3_ptb, $w2k3_x64_ptb, $oxp_ptb, $o2k3_ptb, $o2k7_ptb  ; Brazilian
Dim $w2k_deu, $wxp_deu, $w2k3_deu, $w2k3_x64_deu, $oxp_deu, $o2k3_deu, $o2k7_deu  ; German
Dim $w2k_nld, $wxp_nld, $w2k3_nld, $oxp_nld, $o2k3_nld, $o2k7_nld ; Dutch
Dim $w2k_ita, $wxp_ita, $w2k3_ita, $oxp_ita, $o2k3_ita, $o2k7_ita ; Italian
Dim $w2k_chs, $wxp_chs, $w2k3_chs, $oxp_chs, $o2k3_chs, $o2k7_chs ; Chinese
Dim $w2k_cht, $wxp_cht, $w2k3_cht, $oxp_cht, $o2k3_cht, $o2k7_cht ; Taiwanese
Dim $w2k_plk, $wxp_plk, $w2k3_plk, $oxp_plk, $o2k3_plk, $o2k7_plk ; Polish
Dim $w2k_hun, $wxp_hun, $w2k3_hun, $oxp_hun, $o2k3_hun, $o2k7_hun ; Hungarian
Dim $w2k_csy, $wxp_csy, $w2k3_csy, $oxp_csy, $o2k3_csy, $o2k7_csy ; Czech
Dim $w2k_sve, $wxp_sve, $w2k3_sve, $oxp_sve, $o2k3_sve, $o2k7_sve ; Swedish
Dim $w2k_trk, $wxp_trk, $w2k3_trk, $oxp_trk, $o2k3_trk, $o2k7_trk ; Turkish
Dim $w2k_ell, $wxp_ell, $w2k3_ell, $oxp_ell, $o2k3_ell, $o2k7_ell ; Greek
Dim $w2k_ara, $wxp_ara, $w2k3_ara, $oxp_ara, $o2k3_ara, $o2k7_ara ; Arabic
Dim $w2k_heb, $wxp_heb, $w2k3_heb, $oxp_heb, $o2k3_heb, $o2k7_heb ; Hebrew
Dim $w2k_dan, $wxp_dan, $w2k3_dan, $oxp_dan, $o2k3_dan, $o2k7_dan ; Danish
Dim $w2k_nor, $wxp_nor, $w2k3_nor, $oxp_nor, $o2k3_nor, $o2k7_nor ; Norwegian
Dim $w2k_fin, $wxp_fin, $w2k3_fin, $oxp_fin, $o2k3_fin, $o2k7_fin ; Finnish
Dim $w60_glb, $w60_x64_glb                                                  ; Windows Vista / Windows Server 2008 (global)  
Dim $w61_glb, $w61_x64_glb                                                  ; Windows 7 / Windows Server 2008 R2 (global)  

Dim $dlgheight, $groupwidth, $groupheight, $txtwidth, $txtheight, $btnwidth, $btnheight
Dim $txtgrpyoffset, $txtxoffset, $txtyoffset, $txtxpos, $txtypos

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
        Return "Chinesisch"
      Else
        Return "Chinese"
      EndIf
    Case $lang_token_cht
      If $german Then
        Return "Taiwanesisch"
      Else
        Return "Taiwanese"
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

Func DisableGUI()
  GUICtrlSetState($w2k_enu, $GUI_DISABLE)
  GUICtrlSetState($wxp_enu, $GUI_DISABLE)
  GUICtrlSetState($w2k3_enu, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_enu, $GUI_DISABLE)
  GUICtrlSetState($w2k_fra, $GUI_DISABLE)
  GUICtrlSetState($wxp_fra, $GUI_DISABLE)
  GUICtrlSetState($w2k3_fra, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_fra, $GUI_DISABLE)
  GUICtrlSetState($w2k_esn, $GUI_DISABLE)
  GUICtrlSetState($wxp_esn, $GUI_DISABLE)
  GUICtrlSetState($w2k3_esn, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_esn, $GUI_DISABLE)
  GUICtrlSetState($w2k_jpn, $GUI_DISABLE)
  GUICtrlSetState($wxp_jpn, $GUI_DISABLE)
  GUICtrlSetState($w2k3_jpn, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_jpn, $GUI_DISABLE)
  GUICtrlSetState($w2k_kor, $GUI_DISABLE)
  GUICtrlSetState($wxp_kor, $GUI_DISABLE)
  GUICtrlSetState($w2k3_kor, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_kor, $GUI_DISABLE)
  GUICtrlSetState($w2k_rus, $GUI_DISABLE)
  GUICtrlSetState($wxp_rus, $GUI_DISABLE)
  GUICtrlSetState($w2k3_rus, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_rus, $GUI_DISABLE)
  GUICtrlSetState($w2k_ptg, $GUI_DISABLE)
  GUICtrlSetState($wxp_ptg, $GUI_DISABLE)
  GUICtrlSetState($w2k3_ptg, $GUI_DISABLE)
  GUICtrlSetState($w2k_ptb, $GUI_DISABLE)
  GUICtrlSetState($wxp_ptb, $GUI_DISABLE)
  GUICtrlSetState($w2k3_ptb, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_ptb, $GUI_DISABLE)
  GUICtrlSetState($w2k_deu, $GUI_DISABLE)
  GUICtrlSetState($wxp_deu, $GUI_DISABLE)
  GUICtrlSetState($w2k3_deu, $GUI_DISABLE)
  GUICtrlSetState($w2k3_x64_deu, $GUI_DISABLE)
  GUICtrlSetState($w2k_nld, $GUI_DISABLE)
  GUICtrlSetState($wxp_nld, $GUI_DISABLE)
  GUICtrlSetState($w2k3_nld, $GUI_DISABLE)
  GUICtrlSetState($w2k_ita, $GUI_DISABLE)
  GUICtrlSetState($wxp_ita, $GUI_DISABLE)
  GUICtrlSetState($w2k3_ita, $GUI_DISABLE)
  GUICtrlSetState($w2k_chs, $GUI_DISABLE)
  GUICtrlSetState($wxp_chs, $GUI_DISABLE)
  GUICtrlSetState($w2k3_chs, $GUI_DISABLE)
  GUICtrlSetState($w2k_cht, $GUI_DISABLE)
  GUICtrlSetState($wxp_cht, $GUI_DISABLE)
  GUICtrlSetState($w2k3_cht, $GUI_DISABLE)
  GUICtrlSetState($w2k_plk, $GUI_DISABLE)
  GUICtrlSetState($wxp_plk, $GUI_DISABLE)
  GUICtrlSetState($w2k3_plk, $GUI_DISABLE)
  GUICtrlSetState($w2k_hun, $GUI_DISABLE)
  GUICtrlSetState($wxp_hun, $GUI_DISABLE)
  GUICtrlSetState($w2k3_hun, $GUI_DISABLE)
  GUICtrlSetState($w2k_csy, $GUI_DISABLE)
  GUICtrlSetState($wxp_csy, $GUI_DISABLE)
  GUICtrlSetState($w2k3_csy, $GUI_DISABLE)
  GUICtrlSetState($w2k_sve, $GUI_DISABLE)
  GUICtrlSetState($wxp_sve, $GUI_DISABLE)
  GUICtrlSetState($w2k3_sve, $GUI_DISABLE)
  GUICtrlSetState($w2k_trk, $GUI_DISABLE)
  GUICtrlSetState($wxp_trk, $GUI_DISABLE)
  GUICtrlSetState($w2k3_trk, $GUI_DISABLE)
  GUICtrlSetState($w2k_ell, $GUI_DISABLE)
  GUICtrlSetState($wxp_ell, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_ell, $GUI_DISABLE)
  GUICtrlSetState($w2k_ara, $GUI_DISABLE)
  GUICtrlSetState($wxp_ara, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_ara, $GUI_DISABLE)
  GUICtrlSetState($w2k_heb, $GUI_DISABLE)
  GUICtrlSetState($wxp_heb, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_heb, $GUI_DISABLE)
  GUICtrlSetState($w2k_dan, $GUI_DISABLE)
  GUICtrlSetState($wxp_dan, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_dan, $GUI_DISABLE)
  GUICtrlSetState($w2k_nor, $GUI_DISABLE)
  GUICtrlSetState($wxp_nor, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_nor, $GUI_DISABLE)
  GUICtrlSetState($w2k_fin, $GUI_DISABLE)
  GUICtrlSetState($wxp_fin, $GUI_DISABLE)
;  GUICtrlSetState($w2k3_fin, $GUI_DISABLE)
  GUICtrlSetState($w60_glb, $GUI_DISABLE)
  GUICtrlSetState($w60_x64_glb, $GUI_DISABLE)
  GUICtrlSetState($w61_glb, $GUI_DISABLE)
  GUICtrlSetState($w61_x64_glb, $GUI_DISABLE)

  GUICtrlSetState($oxp_enu, $GUI_DISABLE)
  GUICtrlSetState($o2k3_enu, $GUI_DISABLE)
  GUICtrlSetState($o2k7_enu, $GUI_DISABLE)
  GUICtrlSetState($oxp_fra, $GUI_DISABLE)
  GUICtrlSetState($o2k3_fra, $GUI_DISABLE)
  GUICtrlSetState($o2k7_fra, $GUI_DISABLE)
  GUICtrlSetState($oxp_esn, $GUI_DISABLE)
  GUICtrlSetState($o2k3_esn, $GUI_DISABLE)
  GUICtrlSetState($o2k7_esn, $GUI_DISABLE)
  GUICtrlSetState($oxp_jpn, $GUI_DISABLE)
  GUICtrlSetState($o2k3_jpn, $GUI_DISABLE)
  GUICtrlSetState($o2k7_jpn, $GUI_DISABLE)
  GUICtrlSetState($oxp_kor, $GUI_DISABLE)
  GUICtrlSetState($o2k3_kor, $GUI_DISABLE)
  GUICtrlSetState($o2k7_kor, $GUI_DISABLE)
  GUICtrlSetState($oxp_rus, $GUI_DISABLE)
  GUICtrlSetState($o2k3_rus, $GUI_DISABLE)
  GUICtrlSetState($o2k7_rus, $GUI_DISABLE)
  GUICtrlSetState($oxp_ptg, $GUI_DISABLE)
  GUICtrlSetState($o2k3_ptg, $GUI_DISABLE)
  GUICtrlSetState($o2k7_ptg, $GUI_DISABLE)
  GUICtrlSetState($oxp_ptb, $GUI_DISABLE)
  GUICtrlSetState($o2k3_ptb, $GUI_DISABLE)
  GUICtrlSetState($o2k7_ptb, $GUI_DISABLE)
  GUICtrlSetState($oxp_deu, $GUI_DISABLE)
  GUICtrlSetState($o2k3_deu, $GUI_DISABLE)
  GUICtrlSetState($o2k7_deu, $GUI_DISABLE)
  GUICtrlSetState($oxp_nld, $GUI_DISABLE)
  GUICtrlSetState($o2k3_nld, $GUI_DISABLE)
  GUICtrlSetState($o2k7_nld, $GUI_DISABLE)
  GUICtrlSetState($oxp_ita, $GUI_DISABLE)
  GUICtrlSetState($o2k3_ita, $GUI_DISABLE)
  GUICtrlSetState($o2k7_ita, $GUI_DISABLE)
  GUICtrlSetState($oxp_chs, $GUI_DISABLE)
  GUICtrlSetState($o2k3_chs, $GUI_DISABLE)
  GUICtrlSetState($o2k7_chs, $GUI_DISABLE)
  GUICtrlSetState($oxp_cht, $GUI_DISABLE)
  GUICtrlSetState($o2k3_cht, $GUI_DISABLE)
  GUICtrlSetState($o2k7_cht, $GUI_DISABLE)
  GUICtrlSetState($oxp_plk, $GUI_DISABLE)
  GUICtrlSetState($o2k3_plk, $GUI_DISABLE)
  GUICtrlSetState($o2k7_plk, $GUI_DISABLE)
  GUICtrlSetState($oxp_hun, $GUI_DISABLE)
  GUICtrlSetState($o2k3_hun, $GUI_DISABLE)
  GUICtrlSetState($o2k7_hun, $GUI_DISABLE)
  GUICtrlSetState($oxp_csy, $GUI_DISABLE)
  GUICtrlSetState($o2k3_csy, $GUI_DISABLE)
  GUICtrlSetState($o2k7_csy, $GUI_DISABLE)
  GUICtrlSetState($oxp_sve, $GUI_DISABLE)
  GUICtrlSetState($o2k3_sve, $GUI_DISABLE)
  GUICtrlSetState($o2k7_sve, $GUI_DISABLE)
  GUICtrlSetState($oxp_trk, $GUI_DISABLE)
  GUICtrlSetState($o2k3_trk, $GUI_DISABLE)
  GUICtrlSetState($o2k7_trk, $GUI_DISABLE)
  GUICtrlSetState($oxp_ell, $GUI_DISABLE)
  GUICtrlSetState($o2k3_ell, $GUI_DISABLE)
  GUICtrlSetState($o2k7_ell, $GUI_DISABLE)
  GUICtrlSetState($oxp_ara, $GUI_DISABLE)
  GUICtrlSetState($o2k3_ara, $GUI_DISABLE)
  GUICtrlSetState($o2k7_ara, $GUI_DISABLE)
  GUICtrlSetState($oxp_heb, $GUI_DISABLE)
  GUICtrlSetState($o2k3_heb, $GUI_DISABLE)
  GUICtrlSetState($o2k7_heb, $GUI_DISABLE)
  GUICtrlSetState($oxp_dan, $GUI_DISABLE)
  GUICtrlSetState($o2k3_dan, $GUI_DISABLE)
  GUICtrlSetState($o2k7_dan, $GUI_DISABLE)
  GUICtrlSetState($oxp_nor, $GUI_DISABLE)
  GUICtrlSetState($o2k3_nor, $GUI_DISABLE)
  GUICtrlSetState($o2k7_nor, $GUI_DISABLE)
  GUICtrlSetState($oxp_fin, $GUI_DISABLE)
  GUICtrlSetState($o2k3_fin, $GUI_DISABLE)
  GUICtrlSetState($o2k7_fin, $GUI_DISABLE)

  GUICtrlSetState($excludesp, $GUI_DISABLE)
  GUICtrlSetState($dotnet, $GUI_DISABLE)
  GUICtrlSetState($cleanupdownloads, $GUI_DISABLE)
  GUICtrlSetState($verifydownloads, $GUI_DISABLE)

  GUICtrlSetState($cdiso, $GUI_DISABLE)
  GUICtrlSetState($dvdiso, $GUI_DISABLE)
  GUICtrlSetState($usbcopy, $GUI_DISABLE)
  GUICtrlSetState($usblbl, $GUI_DISABLE)
  GUICtrlSetState($usbpath, $GUI_DISABLE)
  GUICtrlSetState($usbfsf, $GUI_DISABLE)

  GUICtrlSetState($btn_start, $GUI_DISABLE)
  GUICtrlSetState($skipdownload, $GUI_DISABLE)
  GUICtrlSetState($btn_proxy, $GUI_DISABLE)
  GUICtrlSetState($btn_wsus, $GUI_DISABLE)
  GUICtrlSetState($btn_donate, $GUI_DISABLE)
  GUICtrlSetState($btn_exit, $GUI_DISABLE)

  Return 0
EndFunc

Func EnableGUI()
  GUICtrlSetState($w2k_enu, $GUI_ENABLE)
  GUICtrlSetState($wxp_enu, $GUI_ENABLE)
  GUICtrlSetState($w2k3_enu, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_enu, $GUI_ENABLE)
  GUICtrlSetState($w2k_fra, $GUI_ENABLE)
  GUICtrlSetState($wxp_fra, $GUI_ENABLE)
  GUICtrlSetState($w2k3_fra, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_fra, $GUI_ENABLE)
  GUICtrlSetState($w2k_esn, $GUI_ENABLE)
  GUICtrlSetState($wxp_esn, $GUI_ENABLE)
  GUICtrlSetState($w2k3_esn, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_esn, $GUI_ENABLE)
  GUICtrlSetState($w2k_jpn, $GUI_ENABLE)
  GUICtrlSetState($wxp_jpn, $GUI_ENABLE)
  GUICtrlSetState($w2k3_jpn, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_jpn, $GUI_ENABLE)
  GUICtrlSetState($w2k_kor, $GUI_ENABLE)
  GUICtrlSetState($wxp_kor, $GUI_ENABLE)
  GUICtrlSetState($w2k3_kor, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_kor, $GUI_ENABLE)
  GUICtrlSetState($w2k_rus, $GUI_ENABLE)
  GUICtrlSetState($wxp_rus, $GUI_ENABLE)
  GUICtrlSetState($w2k3_rus, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_rus, $GUI_ENABLE)
  GUICtrlSetState($w2k_ptg, $GUI_ENABLE)
  GUICtrlSetState($wxp_ptg, $GUI_ENABLE)
  GUICtrlSetState($w2k3_ptg, $GUI_ENABLE)
  GUICtrlSetState($w2k_ptb, $GUI_ENABLE)
  GUICtrlSetState($wxp_ptb, $GUI_ENABLE)
  GUICtrlSetState($w2k3_ptb, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_ptb, $GUI_ENABLE)
  GUICtrlSetState($w2k_deu, $GUI_ENABLE)
  GUICtrlSetState($wxp_deu, $GUI_ENABLE)
  GUICtrlSetState($w2k3_deu, $GUI_ENABLE)
  GUICtrlSetState($w2k3_x64_deu, $GUI_ENABLE)
  GUICtrlSetState($w2k_nld, $GUI_ENABLE)
  GUICtrlSetState($wxp_nld, $GUI_ENABLE)
  GUICtrlSetState($w2k3_nld, $GUI_ENABLE)
  GUICtrlSetState($w2k_ita, $GUI_ENABLE)
  GUICtrlSetState($wxp_ita, $GUI_ENABLE)
  GUICtrlSetState($w2k3_ita, $GUI_ENABLE)
  GUICtrlSetState($w2k_chs, $GUI_ENABLE)
  GUICtrlSetState($wxp_chs, $GUI_ENABLE)
  GUICtrlSetState($w2k3_chs, $GUI_ENABLE)
  GUICtrlSetState($w2k_cht, $GUI_ENABLE)
  GUICtrlSetState($wxp_cht, $GUI_ENABLE)
  GUICtrlSetState($w2k3_cht, $GUI_ENABLE)
  GUICtrlSetState($w2k_plk, $GUI_ENABLE)
  GUICtrlSetState($wxp_plk, $GUI_ENABLE)
  GUICtrlSetState($w2k3_plk, $GUI_ENABLE)
  GUICtrlSetState($w2k_hun, $GUI_ENABLE)
  GUICtrlSetState($wxp_hun, $GUI_ENABLE)
  GUICtrlSetState($w2k3_hun, $GUI_ENABLE)
  GUICtrlSetState($w2k_csy, $GUI_ENABLE)
  GUICtrlSetState($wxp_csy, $GUI_ENABLE)
  GUICtrlSetState($w2k3_csy, $GUI_ENABLE)
  GUICtrlSetState($w2k_sve, $GUI_ENABLE)
  GUICtrlSetState($wxp_sve, $GUI_ENABLE)
  GUICtrlSetState($w2k3_sve, $GUI_ENABLE)
  GUICtrlSetState($w2k_trk, $GUI_ENABLE)
  GUICtrlSetState($wxp_trk, $GUI_ENABLE)
  GUICtrlSetState($w2k3_trk, $GUI_ENABLE)
  GUICtrlSetState($w2k_ell, $GUI_ENABLE)
  GUICtrlSetState($wxp_ell, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_ell, $GUI_ENABLE)
  GUICtrlSetState($w2k_ara, $GUI_ENABLE)
  GUICtrlSetState($wxp_ara, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_ara, $GUI_ENABLE)
  GUICtrlSetState($w2k_heb, $GUI_ENABLE)
  GUICtrlSetState($wxp_heb, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_heb, $GUI_ENABLE)
  GUICtrlSetState($w2k_dan, $GUI_ENABLE)
  GUICtrlSetState($wxp_dan, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_dan, $GUI_ENABLE)
  GUICtrlSetState($w2k_nor, $GUI_ENABLE)
  GUICtrlSetState($wxp_nor, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_nor, $GUI_ENABLE)
  GUICtrlSetState($w2k_fin, $GUI_ENABLE)
  GUICtrlSetState($wxp_fin, $GUI_ENABLE)
;  GUICtrlSetState($w2k3_fin, $GUI_ENABLE)
  GUICtrlSetState($w60_glb, $GUI_ENABLE)
  GUICtrlSetState($w60_x64_glb, $GUI_ENABLE)
  GUICtrlSetState($w61_glb, $GUI_ENABLE)
  GUICtrlSetState($w61_x64_glb, $GUI_ENABLE)

  GUICtrlSetState($oxp_enu, $GUI_ENABLE)
  GUICtrlSetState($o2k3_enu, $GUI_ENABLE)
  GUICtrlSetState($o2k7_enu, $GUI_ENABLE)
  GUICtrlSetState($oxp_fra, $GUI_ENABLE)
  GUICtrlSetState($o2k3_fra, $GUI_ENABLE)
  GUICtrlSetState($o2k7_fra, $GUI_ENABLE)
  GUICtrlSetState($oxp_esn, $GUI_ENABLE)
  GUICtrlSetState($o2k3_esn, $GUI_ENABLE)
  GUICtrlSetState($o2k7_esn, $GUI_ENABLE)
  GUICtrlSetState($oxp_jpn, $GUI_ENABLE)
  GUICtrlSetState($o2k3_jpn, $GUI_ENABLE)
  GUICtrlSetState($o2k7_jpn, $GUI_ENABLE)
  GUICtrlSetState($oxp_kor, $GUI_ENABLE)
  GUICtrlSetState($o2k3_kor, $GUI_ENABLE)
  GUICtrlSetState($o2k7_kor, $GUI_ENABLE)
  GUICtrlSetState($oxp_rus, $GUI_ENABLE)
  GUICtrlSetState($o2k3_rus, $GUI_ENABLE)
  GUICtrlSetState($o2k7_rus, $GUI_ENABLE)
  GUICtrlSetState($oxp_ptg, $GUI_ENABLE)
  GUICtrlSetState($o2k3_ptg, $GUI_ENABLE)
  GUICtrlSetState($o2k7_ptg, $GUI_ENABLE)
  GUICtrlSetState($oxp_ptb, $GUI_ENABLE)
  GUICtrlSetState($o2k3_ptb, $GUI_ENABLE)
  GUICtrlSetState($o2k7_ptb, $GUI_ENABLE)
  GUICtrlSetState($oxp_deu, $GUI_ENABLE)
  GUICtrlSetState($o2k3_deu, $GUI_ENABLE)
  GUICtrlSetState($o2k7_deu, $GUI_ENABLE)
  GUICtrlSetState($oxp_nld, $GUI_ENABLE)
  GUICtrlSetState($o2k3_nld, $GUI_ENABLE)
  GUICtrlSetState($o2k7_nld, $GUI_ENABLE)
  GUICtrlSetState($oxp_ita, $GUI_ENABLE)
  GUICtrlSetState($o2k3_ita, $GUI_ENABLE)
  GUICtrlSetState($o2k7_ita, $GUI_ENABLE)
  GUICtrlSetState($oxp_chs, $GUI_ENABLE)
  GUICtrlSetState($o2k3_chs, $GUI_ENABLE)
  GUICtrlSetState($o2k7_chs, $GUI_ENABLE)
  GUICtrlSetState($oxp_cht, $GUI_ENABLE)
  GUICtrlSetState($o2k3_cht, $GUI_ENABLE)
  GUICtrlSetState($o2k7_cht, $GUI_ENABLE)
  GUICtrlSetState($oxp_plk, $GUI_ENABLE)
  GUICtrlSetState($o2k3_plk, $GUI_ENABLE)
  GUICtrlSetState($o2k7_plk, $GUI_ENABLE)
  GUICtrlSetState($oxp_hun, $GUI_ENABLE)
  GUICtrlSetState($o2k3_hun, $GUI_ENABLE)
  GUICtrlSetState($o2k7_hun, $GUI_ENABLE)
  GUICtrlSetState($oxp_csy, $GUI_ENABLE)
  GUICtrlSetState($o2k3_csy, $GUI_ENABLE)
  GUICtrlSetState($o2k7_csy, $GUI_ENABLE)
  GUICtrlSetState($oxp_sve, $GUI_ENABLE)
  GUICtrlSetState($o2k3_sve, $GUI_ENABLE)
  GUICtrlSetState($o2k7_sve, $GUI_ENABLE)
  GUICtrlSetState($oxp_trk, $GUI_ENABLE)
  GUICtrlSetState($o2k3_trk, $GUI_ENABLE)
  GUICtrlSetState($o2k7_trk, $GUI_ENABLE)
  GUICtrlSetState($oxp_ell, $GUI_ENABLE)
  GUICtrlSetState($o2k3_ell, $GUI_ENABLE)
  GUICtrlSetState($o2k7_ell, $GUI_ENABLE)
  GUICtrlSetState($oxp_ara, $GUI_ENABLE)
  GUICtrlSetState($o2k3_ara, $GUI_ENABLE)
  GUICtrlSetState($o2k7_ara, $GUI_ENABLE)
  GUICtrlSetState($oxp_heb, $GUI_ENABLE)
  GUICtrlSetState($o2k3_heb, $GUI_ENABLE)
  GUICtrlSetState($o2k7_heb, $GUI_ENABLE)
  GUICtrlSetState($oxp_dan, $GUI_ENABLE)
  GUICtrlSetState($o2k3_dan, $GUI_ENABLE)
  GUICtrlSetState($o2k7_dan, $GUI_ENABLE)
  GUICtrlSetState($oxp_nor, $GUI_ENABLE)
  GUICtrlSetState($o2k3_nor, $GUI_ENABLE)
  GUICtrlSetState($o2k7_nor, $GUI_ENABLE)
  GUICtrlSetState($oxp_fin, $GUI_ENABLE)
  GUICtrlSetState($o2k3_fin, $GUI_ENABLE)
  GUICtrlSetState($o2k7_fin, $GUI_ENABLE)

  GUICtrlSetState($excludesp, $GUI_ENABLE)
  GUICtrlSetState($dotnet, $GUI_ENABLE)
  If BitAND(GUICtrlRead($skipdownload), $GUI_CHECKED) <> $GUI_CHECKED Then
    GUICtrlSetState($cleanupdownloads, $GUI_ENABLE)
    GUICtrlSetState($verifydownloads, $GUI_ENABLE)
  EndIf
  GUICtrlSetState($cdiso, $GUI_ENABLE)
  GUICtrlSetState($dvdiso, $GUI_ENABLE)
  GUICtrlSetState($usbcopy, $GUI_ENABLE)
  If BitAND(GUICtrlRead($usbcopy), $GUI_CHECKED) = $GUI_CHECKED Then
    GUICtrlSetState($usblbl, $GUI_ENABLE)
    GUICtrlSetState($usbpath, $GUI_ENABLE)
    GUICtrlSetState($usbfsf, $GUI_ENABLE)
  EndIf
  GUICtrlSetState($btn_start, $GUI_ENABLE)
  GUICtrlSetState($skipdownload, $GUI_ENABLE)
  GUICtrlSetState($btn_proxy, $GUI_ENABLE)
  GUICtrlSetState($btn_wsus, $GUI_ENABLE)
  GUICtrlSetState($btn_donate, $GUI_ENABLE)
  GUICtrlSetState($btn_exit, $GUI_ENABLE)

  Return 0
EndFunc

Func CheckBoxState2String($chkbox)
Dim $result = ""

  If BitAND(GUICtrlRead($chkbox), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $enabled
  Else
    $result = $disabled
  EndIf
  Return $result
EndFunc

Func DetermineDownloadSwitches($chkboxexcludesp, $chkboxdotnet, $chkboxcleanupdownloads, $chkboxverifydownloads, $chkboxcdiso, $chkboxdvdiso, $strproxy, $strwsus)
Dim $result = ""

  If BitAND(GUICtrlRead($chkboxexcludesp), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $result & " /excludesp"
  EndIf
  If BitAND(GUICtrlRead($chkboxdotnet), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $result & " /includedotnet"
  EndIf
  If BitAND(GUICtrlRead($chkboxcleanupdownloads), $GUI_CHECKED) <> $GUI_CHECKED Then
    $result = $result & " /nocleanup"
  EndIf
  If BitAND(GUICtrlRead($chkboxverifydownloads), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $result & " /verify"
  EndIf
  $result = $result & " /exitonerror"
  If ( (BitAND(GUICtrlRead($chkboxcdiso), $GUI_CHECKED) <> $GUI_CHECKED) _
   AND (BitAND(GUICtrlRead($chkboxdvdiso), $GUI_CHECKED) <> $GUI_CHECKED) ) Then
    $result = $result & " /skipmkisofs"
  EndIf
  If $strproxy <> "" Then
    $result = $result & " /proxy " & $strproxy
  EndIf
  If $strwsus <> "" Then
    $result = $result & " /wsus " & $strwsus
  EndIf
  Return $result
EndFunc

Func DetermineISOSwitches($chkboxexcludesp, $chkboxdotnet)
Dim $result = ""

  If BitAND(GUICtrlRead($chkboxexcludesp), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $result & " /excludesp"
  EndIf
  If BitAND(GUICtrlRead($chkboxdotnet), $GUI_CHECKED) = $GUI_CHECKED Then
    $result = $result & " /includedotnet"
  EndIf
  Return $result
EndFunc

Func RunDonationSite()
  Run(@ComSpec & " /D /C start " & $donationURL)
EndFunc

Func RunVersionCheck($strproxy)
Dim $result

  DisableGUI()
  If $strproxy <> "" Then
    $result = RunWait(@ComSpec & " /D /C CheckOUVersion.cmd /proxy " & $strproxy, @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  Else
    $result = RunWait(@ComSpec & " /D /C CheckOUVersion.cmd", @ScriptDir & "\cmd", @SW_SHOWMINNOACTIVE)
  EndIf
  If $result = 0 Then
    $result = @error
  EndIf
  If $result <> 0 Then
    If ShowGUIInGerman() Then
      $result = MsgBox(0x2023, "Versionsprüfung", "Sie setzen " & $caption & " ein. Eine neue Version ist verfügbar." _
                                          & @LF & "Möchten Sie nun die Download-Seite (" & $downloadURL & ") besuchen?")
    Else
      $result = MsgBox(0x2023, "Version check", "You use " & $caption & ". A new version is available." _
                                        & @LF & "Do you want to visit the download site (" & $downloadURL & ") now?")
    EndIf
    Switch $result
      Case 6  ; Yes
        $result = -1
      Case 7  ; No
        $result = 0
      Case Else
        $result = 1
    EndSwitch
  EndIf
  EnableGUI()
  Return $result
EndFunc

Func RunDownloadScript($stroptions, $strswitches)
Dim $result
  
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
  If $result <> 0 Then
    WinSetState($maindlg, $maindlg, @SW_RESTORE)
    If ShowGUIInGerman() Then
      MsgBox(0x2010, "Fehler", "Fehler beim Herunterladen / Verifizieren der Updates für " & $stroptions & ".")
    Else
      MsgBox(0x2010, "Error", "Error downloading / verifying updates for " & $stroptions & ".")
    EndIf
  EndIf
  WinSetTitle($maindlg, $maindlg, $title)
  EnableGUI()
  Return $result
EndFunc

Func RunISOCreationScript($stroptions, $strswitches)
Dim $result

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
  If $result <> 0 Then
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
  If $result <> 0 Then
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

Func RunScripts($stroptions, $strdownloadswitches, $chkboxcdiso, $strisoswitches, $chkboxusb, $strusbpath)
Dim $result

  If BitAND(GUICtrlRead($skipdownload), $GUI_CHECKED) = $GUI_CHECKED Then 
    $result = 0
  Else
    $result = RunDownloadScript($stroptions, $strdownloadswitches)
  EndIf
  If ( ($result = 0) AND (BitAND(GUICtrlRead($chkboxcdiso), $GUI_CHECKED) = $GUI_CHECKED) ) Then
    $result = RunISOCreationScript($stroptions, $strisoswitches)
  EndIf
  If ( ($result = 0) AND (BitAND(GUICtrlRead($chkboxusb), $GUI_CHECKED) = $GUI_CHECKED) ) Then
    $result = RunUSBCreationScript($stroptions, $strisoswitches, $strusbpath)
  EndIf
  Return $result
EndFunc

Func SaveSettings()

;  Windows 2000 group
  IniWrite($inifilename, $ini_section_w2k, $lang_token_enu, CheckBoxState2String($w2k_enu))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_fra, CheckBoxState2String($w2k_fra))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_esn, CheckBoxState2String($w2k_esn))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_jpn, CheckBoxState2String($w2k_jpn))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_kor, CheckBoxState2String($w2k_kor))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_rus, CheckBoxState2String($w2k_rus))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_ptg, CheckBoxState2String($w2k_ptg))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_ptb, CheckBoxState2String($w2k_ptb))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_deu, CheckBoxState2String($w2k_deu))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_nld, CheckBoxState2String($w2k_nld))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_ita, CheckBoxState2String($w2k_ita))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_chs, CheckBoxState2String($w2k_chs))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_cht, CheckBoxState2String($w2k_cht))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_plk, CheckBoxState2String($w2k_plk))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_hun, CheckBoxState2String($w2k_hun))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_csy, CheckBoxState2String($w2k_csy))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_sve, CheckBoxState2String($w2k_sve))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_trk, CheckBoxState2String($w2k_trk))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_ell, CheckBoxState2String($w2k_ell))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_ara, CheckBoxState2String($w2k_ara))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_heb, CheckBoxState2String($w2k_heb))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_dan, CheckBoxState2String($w2k_dan))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_nor, CheckBoxState2String($w2k_nor))
  IniWrite($inifilename, $ini_section_w2k, $lang_token_fin, CheckBoxState2String($w2k_fin))

;  Windows XP group
  IniWrite($inifilename, $ini_section_wxp, $lang_token_enu, CheckBoxState2String($wxp_enu))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_fra, CheckBoxState2String($wxp_fra))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_esn, CheckBoxState2String($wxp_esn))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_jpn, CheckBoxState2String($wxp_jpn))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_kor, CheckBoxState2String($wxp_kor))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_rus, CheckBoxState2String($wxp_rus))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_ptg, CheckBoxState2String($wxp_ptg))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_ptb, CheckBoxState2String($wxp_ptb))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_deu, CheckBoxState2String($wxp_deu))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_nld, CheckBoxState2String($wxp_nld))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_ita, CheckBoxState2String($wxp_ita))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_chs, CheckBoxState2String($wxp_chs))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_cht, CheckBoxState2String($wxp_cht))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_plk, CheckBoxState2String($wxp_plk))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_hun, CheckBoxState2String($wxp_hun))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_csy, CheckBoxState2String($wxp_csy))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_sve, CheckBoxState2String($wxp_sve))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_trk, CheckBoxState2String($wxp_trk))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_ell, CheckBoxState2String($wxp_ell))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_ara, CheckBoxState2String($wxp_ara))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_heb, CheckBoxState2String($wxp_heb))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_dan, CheckBoxState2String($wxp_dan))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_nor, CheckBoxState2String($wxp_nor))
  IniWrite($inifilename, $ini_section_wxp, $lang_token_fin, CheckBoxState2String($wxp_fin))

;  Windows Server 2003 group
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_enu, CheckBoxState2String($w2k3_enu))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_fra, CheckBoxState2String($w2k3_fra))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_esn, CheckBoxState2String($w2k3_esn))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_jpn, CheckBoxState2String($w2k3_jpn))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_kor, CheckBoxState2String($w2k3_kor))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_rus, CheckBoxState2String($w2k3_rus))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_ptg, CheckBoxState2String($w2k3_ptg))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_ptb, CheckBoxState2String($w2k3_ptb))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_deu, CheckBoxState2String($w2k3_deu))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_nld, CheckBoxState2String($w2k3_nld))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_ita, CheckBoxState2String($w2k3_ita))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_chs, CheckBoxState2String($w2k3_chs))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_cht, CheckBoxState2String($w2k3_cht))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_plk, CheckBoxState2String($w2k3_plk))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_hun, CheckBoxState2String($w2k3_hun))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_csy, CheckBoxState2String($w2k3_csy))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_sve, CheckBoxState2String($w2k3_sve))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_trk, CheckBoxState2String($w2k3_trk))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_ell, CheckBoxState2String($w2k3_ell))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_ara, CheckBoxState2String($w2k3_ara))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_heb, CheckBoxState2String($w2k3_heb))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_dan, CheckBoxState2String($w2k3_dan))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_nor, CheckBoxState2String($w2k3_nor))
  IniWrite($inifilename, $ini_section_w2k3, $lang_token_fin, CheckBoxState2String($w2k3_fin))

;  Windows Server 2003 x64 group
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_enu, CheckBoxState2String($w2k3_x64_enu))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_fra, CheckBoxState2String($w2k3_x64_fra))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_esn, CheckBoxState2String($w2k3_x64_esn))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_jpn, CheckBoxState2String($w2k3_x64_jpn))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_kor, CheckBoxState2String($w2k3_x64_kor))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_rus, CheckBoxState2String($w2k3_x64_rus))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_ptb, CheckBoxState2String($w2k3_x64_ptb))
  IniWrite($inifilename, $ini_section_w2k3_x64, $lang_token_deu, CheckBoxState2String($w2k3_x64_deu))

;  Windows Vista / Server 2008 group
  IniWrite($inifilename, $ini_section_w60, $lang_token_glb, CheckBoxState2String($w60_glb))
  IniWrite($inifilename, $ini_section_w60_x64, $lang_token_glb, CheckBoxState2String($w60_x64_glb))

;  Windows 7 / Server 2008 R2 group
  IniWrite($inifilename, $ini_section_w61, $lang_token_glb, CheckBoxState2String($w61_glb))
  IniWrite($inifilename, $ini_section_w61_x64, $lang_token_glb, CheckBoxState2String($w61_x64_glb))

;  Office XP group
  IniWrite($inifilename, $ini_section_oxp, $lang_token_enu, CheckBoxState2String($oxp_enu))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_fra, CheckBoxState2String($oxp_fra))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_esn, CheckBoxState2String($oxp_esn))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_jpn, CheckBoxState2String($oxp_jpn))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_kor, CheckBoxState2String($oxp_kor))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_rus, CheckBoxState2String($oxp_rus))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_ptg, CheckBoxState2String($oxp_ptg))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_ptb, CheckBoxState2String($oxp_ptb))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_deu, CheckBoxState2String($oxp_deu))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_nld, CheckBoxState2String($oxp_nld))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_ita, CheckBoxState2String($oxp_ita))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_chs, CheckBoxState2String($oxp_chs))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_cht, CheckBoxState2String($oxp_cht))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_plk, CheckBoxState2String($oxp_plk))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_hun, CheckBoxState2String($oxp_hun))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_csy, CheckBoxState2String($oxp_csy))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_sve, CheckBoxState2String($oxp_sve))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_trk, CheckBoxState2String($oxp_trk))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_ell, CheckBoxState2String($oxp_ell))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_ara, CheckBoxState2String($oxp_ara))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_heb, CheckBoxState2String($oxp_heb))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_dan, CheckBoxState2String($oxp_dan))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_nor, CheckBoxState2String($oxp_nor))
  IniWrite($inifilename, $ini_section_oxp, $lang_token_fin, CheckBoxState2String($oxp_fin))

;  Office 2003 group
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_enu, CheckBoxState2String($o2k3_enu))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_fra, CheckBoxState2String($o2k3_fra))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_esn, CheckBoxState2String($o2k3_esn))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_jpn, CheckBoxState2String($o2k3_jpn))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_kor, CheckBoxState2String($o2k3_kor))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_rus, CheckBoxState2String($o2k3_rus))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_ptg, CheckBoxState2String($o2k3_ptg))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_ptb, CheckBoxState2String($o2k3_ptb))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_deu, CheckBoxState2String($o2k3_deu))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_nld, CheckBoxState2String($o2k3_nld))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_ita, CheckBoxState2String($o2k3_ita))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_chs, CheckBoxState2String($o2k3_chs))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_cht, CheckBoxState2String($o2k3_cht))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_plk, CheckBoxState2String($o2k3_plk))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_hun, CheckBoxState2String($o2k3_hun))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_csy, CheckBoxState2String($o2k3_csy))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_sve, CheckBoxState2String($o2k3_sve))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_trk, CheckBoxState2String($o2k3_trk))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_ell, CheckBoxState2String($o2k3_ell))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_ara, CheckBoxState2String($o2k3_ara))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_heb, CheckBoxState2String($o2k3_heb))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_dan, CheckBoxState2String($o2k3_dan))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_nor, CheckBoxState2String($o2k3_nor))
  IniWrite($inifilename, $ini_section_o2k3, $lang_token_fin, CheckBoxState2String($o2k3_fin))

;  Office 2007 group
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_enu, CheckBoxState2String($o2k7_enu))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_fra, CheckBoxState2String($o2k7_fra))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_esn, CheckBoxState2String($o2k7_esn))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_jpn, CheckBoxState2String($o2k7_jpn))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_kor, CheckBoxState2String($o2k7_kor))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_rus, CheckBoxState2String($o2k7_rus))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ptg, CheckBoxState2String($o2k7_ptg))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ptb, CheckBoxState2String($o2k7_ptb))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_deu, CheckBoxState2String($o2k7_deu))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_nld, CheckBoxState2String($o2k7_nld))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ita, CheckBoxState2String($o2k7_ita))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_chs, CheckBoxState2String($o2k7_chs))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_cht, CheckBoxState2String($o2k7_cht))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_plk, CheckBoxState2String($o2k7_plk))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_hun, CheckBoxState2String($o2k7_hun))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_csy, CheckBoxState2String($o2k7_csy))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_sve, CheckBoxState2String($o2k7_sve))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_trk, CheckBoxState2String($o2k7_trk))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ell, CheckBoxState2String($o2k7_ell))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_ara, CheckBoxState2String($o2k7_ara))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_heb, CheckBoxState2String($o2k7_heb))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_dan, CheckBoxState2String($o2k7_dan))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_nor, CheckBoxState2String($o2k7_nor))
  IniWrite($inifilename, $ini_section_o2k7, $lang_token_fin, CheckBoxState2String($o2k7_fin))

;  Image creation
  IniWrite($inifilename, $ini_section_iso, $iso_token_cd, CheckBoxState2String($cdiso))
  IniWrite($inifilename, $ini_section_iso, $iso_token_dvd, CheckBoxState2String($dvdiso))
  IniWrite($inifilename, $ini_section_usb, $usb_token_copy, CheckBoxState2String($usbcopy))
  IniWrite($inifilename, $ini_section_usb, $usb_token_path, GUICtrlRead($usbpath))

;  Miscellaneous
  IniWrite($inifilename, $ini_section_misc, $misc_token_nostatics, CheckBoxState2String($excludesp))
  IniWrite($inifilename, $ini_section_misc, $misc_token_dotnet, CheckBoxState2String($dotnet))
  IniWrite($inifilename, $ini_section_misc, $misc_token_cleanup, CheckBoxState2String($cleanupdownloads))
  IniWrite($inifilename, $ini_section_misc, $misc_token_verify, CheckBoxState2String($verifydownloads))
  IniWrite($inifilename, $ini_section_misc, $misc_token_proxy, $proxy)
  IniWrite($inifilename, $ini_section_misc, $misc_token_wsus, $wsus)
  
  Return 0
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
  $dlgheight = 535 * $reg_val / $default_logpixels
  If ShowGUIInGerman() Then
    $txtwidth = 90 * $reg_val / $default_logpixels
  Else
    $txtwidth = 80 * $reg_val / $default_logpixels
  EndIf
  $txtheight = 20 * $reg_val / $default_logpixels
  $btnwidth = 80 * $reg_val / $default_logpixels
  $btnheight = 25 * $reg_val / $default_logpixels  
  $txtgrpyoffset = 15 * $reg_val / $default_logpixels
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
$groupheight = 4 * $txtheight 
$maindlg = GUICreate($title, $groupwidth + 4 * $txtxoffset, $dlgheight)
GUISetFont(8.5, 400, 0, "Sans Serif")
$inifilename = StringLeft(@ScriptFullPath, StringInStr(@ScriptFullPath, ".", 0, -1)) & "ini"

;  Label 1
$txtxpos = $txtxoffset
$txtypos = $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateLabel("Lade Microsoft-Updates für...", $txtxpos, $txtypos, $groupwidth, $txtheight)
Else
  GUICtrlCreateLabel("Download Microsoft updates for...", $txtxpos, $txtypos, $groupwidth, $txtheight)
EndIf

;  Tab control
$txtypos = $txtypos + $txtheight
GuiCtrlCreateTab($txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset, 5 * $groupheight - 6 * $txtheight + 3.5 * $txtyoffset)

;  Operating Systems' Tab
If ShowGUIInGerman() Then
  $tabitemfocused = GuiCtrlCreateTabItem("Betriebssysteme")
Else
  $tabitemfocused = GuiCtrlCreateTabItem("Operating Systems")
EndIf

;  Windows XP group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Windows XP", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Windows XP English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$wxp_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP French
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$wxp_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Korean
$txtxpos = $txtxpos + $txtwidth
$wxp_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Russian
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$wxp_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$wxp_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Italian
$txtxpos = $txtxpos + $txtwidth + 10
$wxp_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Taiwanese
$txtxpos = $txtxpos + $txtwidth
$wxp_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Polish
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$wxp_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Czech
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$wxp_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Greek
$txtxpos = $txtxpos + $txtwidth + 10
$wxp_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$wxp_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Hebrew
$txtxpos = $txtxpos + $txtwidth
$wxp_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Danish
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$wxp_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows XP Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$wxp_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_wxp, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Windows Server 2003 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows Server 2003", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Windows Server 2003 English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$w2k3_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 French
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$w2k3_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Korean
$txtxpos = $txtxpos + $txtwidth
$w2k3_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$w2k3_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$w2k3_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$w2k3_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Taiwanese
$txtxpos = $txtxpos + $txtwidth
$w2k3_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$w2k3_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$w2k3_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$w2k3_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
;  Windows Server 2003 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
;  Windows Server 2003 Hebrew
$txtxpos = $txtxpos + $txtwidth
$w2k3_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
;  Windows Server 2003 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
;  Windows Server 2003 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$w2k3_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
;  Windows Server 2003 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)

;  Windows Server 2003 x64 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Windows XP / Server 2003 x64-Editionen", $txtxpos, $txtypos, $groupwidth, $groupheight - 2 * $txtheight)
Else
  GUICtrlCreateGroup("Windows XP / Server 2003 x64 editions", $txtxpos, $txtypos, $groupwidth, $groupheight - 2 * $txtheight)
EndIf
;  Windows Server 2003 x64 English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$w2k3_x64_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 French
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_x64_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$w2k3_x64_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$w2k3_x64_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 Korean
$txtxpos = $txtxpos + $txtwidth
$w2k3_x64_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_x64_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 Brazilian
$txtxpos = $txtxpos + $txtwidth - 10
$w2k3_x64_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows Server 2003 x64 German
$txtxpos = $txtxpos + $txtwidth + 5
$w2k3_x64_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k3_x64, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Windows Vista / Server 2008 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows Vista / Server 2008", $txtxpos, $txtypos, $groupwidth, $groupheight - 2 * $txtheight)
;  Windows Vista / Server 2008 global
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
If ShowGUIInGerman() Then
  $w60_glb = GUICtrlCreateCheckbox("Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w60_glb = GUICtrlCreateCheckbox("Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
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

;  Windows 7 / Server 2008 R2 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Windows 7 / Server 2008 R2", $txtxpos, $txtypos, $groupwidth, $groupheight - 2 * $txtheight)
;  Windows 7 global
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
If ShowGUIInGerman() Then
  $w61_glb = GUICtrlCreateCheckbox("Global (mehrsprachige Updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
Else
  $w61_glb = GUICtrlCreateCheckbox("Global (multilingual updates)", $txtxpos, $txtypos, $groupwidth / 2 - $txtxoffset, $txtheight)
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

;  Office Suites' Tab
If ShowGUIInGerman() Then
  GuiCtrlCreateTabItem("Office-Pakete")
Else
  GuiCtrlCreateTabItem("Office Suites")
EndIf

;  Office XP group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Office XP", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Office XP English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$oxp_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP French
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$oxp_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Korean
$txtxpos = $txtxpos + $txtwidth
$oxp_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Russian
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$oxp_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$oxp_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Italian
$txtxpos = $txtxpos + $txtwidth + 10
$oxp_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Taiwanese
$txtxpos = $txtxpos + $txtwidth
$oxp_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Polish
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$oxp_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Czech
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$oxp_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Greek
$txtxpos = $txtxpos + $txtwidth + 10
$oxp_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$oxp_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Hebrew
$txtxpos = $txtxpos + $txtwidth
$oxp_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Danish
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$oxp_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office XP Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$oxp_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_oxp, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office 2003 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Office 2003", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Office 2003 English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$o2k3_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 French
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$o2k3_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Korean
$txtxpos = $txtxpos + $txtwidth
$o2k3_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$o2k3_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k3_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$o2k3_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Taiwanese
$txtxpos = $txtxpos + $txtwidth
$o2k3_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k3_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$o2k3_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$o2k3_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$o2k3_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Hebrew
$txtxpos = $txtxpos + $txtwidth
$o2k3_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$o2k3_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2003 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$o2k3_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k3, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Office 2007 group
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
GUICtrlCreateGroup("Office 2007", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Office 2007 English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
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
;  Office 2007 Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$o2k7_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_o2k7, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Office 2007 Taiwanese
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

;  Discontinued Products' Tab
If ShowGUIInGerman() Then
  GuiCtrlCreateTabItem("Abgekündigte Produkte")
Else
  GuiCtrlCreateTabItem("Discontinued Products")
EndIf

;  Windows 2000 group
$txtxpos = 2 * $txtxoffset
$txtypos = 3.5 * $txtyoffset + $txtheight
GUICtrlCreateGroup("Windows 2000", $txtxpos, $txtypos, $groupwidth, $groupheight)
;  Windows 2000 English
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
$w2k_enu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_enu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_enu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 French
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_fra = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fra, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_fra, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Spanish
$txtxpos = $txtxpos + $txtwidth + 10
$w2k_esn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_esn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_esn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Japanese
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_jpn = GUICtrlCreateCheckbox(LanguageCaption($lang_token_jpn, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_jpn, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Korean
$txtxpos = $txtxpos + $txtwidth
$w2k_kor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_kor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_kor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Russian
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_rus = GUICtrlCreateCheckbox(LanguageCaption($lang_token_rus, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_rus, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Portuguese
$txtxpos = $txtxpos + $txtwidth - 10
$w2k_ptg = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptg, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_ptg, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Brazilian
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_ptb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ptb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_ptb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 German
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$w2k_deu = GUICtrlCreateCheckbox(LanguageCaption($lang_token_deu, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_deu, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Dutch
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_nld = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nld, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_nld, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Italian
$txtxpos = $txtxpos + $txtwidth + 10
$w2k_ita = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ita, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_ita, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Chinese
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_chs = GUICtrlCreateCheckbox(LanguageCaption($lang_token_chs, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_chs, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Taiwanese
$txtxpos = $txtxpos + $txtwidth
$w2k_cht = GUICtrlCreateCheckbox(LanguageCaption($lang_token_cht, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_cht, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Polish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_plk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_plk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_plk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Hungarian
$txtxpos = $txtxpos + $txtwidth - 10
$w2k_hun = GUICtrlCreateCheckbox(LanguageCaption($lang_token_hun, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_hun, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Czech
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_csy = GUICtrlCreateCheckbox(LanguageCaption($lang_token_csy, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_csy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Swedish
$txtxpos = 3 * $txtxoffset
$txtypos = $txtypos + $txtheight
$w2k_sve = GUICtrlCreateCheckbox(LanguageCaption($lang_token_sve, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_sve, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Turkish
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_trk = GUICtrlCreateCheckbox(LanguageCaption($lang_token_trk, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_trk, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Greek
$txtxpos = $txtxpos + $txtwidth + 10
$w2k_ell = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ell, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_ell, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Arabic
$txtxpos = $txtxpos + $txtwidth - 5
$w2k_ara = GUICtrlCreateCheckbox(LanguageCaption($lang_token_ara, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_ara, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Hebrew
$txtxpos = $txtxpos + $txtwidth
$w2k_heb = GUICtrlCreateCheckbox(LanguageCaption($lang_token_heb, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_heb, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Danish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_dan = GUICtrlCreateCheckbox(LanguageCaption($lang_token_dan, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth - 10, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_dan, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Norwegian
$txtxpos = $txtxpos + $txtwidth - 10
$w2k_nor = GUICtrlCreateCheckbox(LanguageCaption($lang_token_nor, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth + 5, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_nor, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf
;  Windows 2000 Finnish
$txtxpos = $txtxpos + $txtwidth + 5
$w2k_fin = GUICtrlCreateCheckbox(LanguageCaption($lang_token_fin, ShowGUIInGerman()), $txtxpos, $txtypos, $txtwidth, $txtheight)
If IniRead($inifilename, $ini_section_w2k, $lang_token_fin, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  End Tab item definition
GuiCtrlCreateTabItem("")
GUICtrlSetState($tabitemfocused, $GUI_SHOW)

;  Options group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 4 * $txtyoffset
$txtypos = 5 * $groupheight - 6 * $txtheight + 7 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Optionen", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - $txtheight)
Else
  GUICtrlCreateGroup("Options", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - $txtheight)
EndIf

;  Exclude Service Packs
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
If ShowGUIInGerman() Then
  $excludesp = GUICtrlCreateCheckbox("Service-Packs ausschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $excludesp = GUICtrlCreateCheckbox("Exclude Service Packs", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_nostatics, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Cleanup download directories
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $cleanupdownloads = GUICtrlCreateCheckbox("Download-Verzeichnisse bereinigen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $cleanupdownloads = GUICtrlCreateCheckbox("Clean up download directories", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_cleanup, $enabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Include .NET Framework 3.5 SP1
$txtxpos = 2 * $txtxoffset
$txtypos = $txtypos + $txtheight
If ShowGUIInGerman() Then
  $dotnet = GUICtrlCreateCheckbox(".NET Framework 3.5 SP1 einschließen", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $dotnet = GUICtrlCreateCheckbox("Include .NET Framework 3.5 SP1", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_dotnet, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  Verify downloads
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $verifydownloads = GUICtrlCreateCheckbox("Heruntergeladene Updates verifizieren", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $verifydownloads = GUICtrlCreateCheckbox("Verify downloaded updates", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_misc, $misc_token_verify, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  ISO-Image group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("Erstelle ISO-Image(s)...", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - 2 * $txtheight)
Else
  GUICtrlCreateGroup("Create ISO image(s)...", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - 2 * $txtheight)
EndIf

;  CD ISO image
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
If ShowGUIInGerman() Then
  $cdiso = GUICtrlCreateCheckbox("pro Produkt und Sprache (CD / DVD)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $cdiso = GUICtrlCreateCheckbox("per selected product and language (CD / DVD)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_iso, $iso_token_cd, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  cross-platform DVD ISO image
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $dvdiso = GUICtrlCreateCheckbox("pro Sprache, x86-/x64-produktübergreifend (DVDs)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $dvdiso = GUICtrlCreateCheckbox("per selected language, 'x86-/x64-cross-product' (DVDs)", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_iso, $iso_token_dvd, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  USB-Image group
$txtxpos = $txtxoffset
$txtypos = $txtypos + 2.5 * $txtyoffset
If ShowGUIInGerman() Then
  GUICtrlCreateGroup("USB-Stick", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - 2 * $txtheight)
Else
  GUICtrlCreateGroup("USB stick", $txtxpos, $txtypos, $groupwidth + 2 * $txtxoffset,  $groupheight - 2 * $txtheight)
EndIf

;  USB image
$txtypos = $txtypos + $txtgrpyoffset
$txtxpos = $txtxpos + $txtxoffset
If ShowGUIInGerman() Then
  $usbcopy = GUICtrlCreateCheckbox("Kopiere Updates für gewählte Produkte ins...", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
Else
  $usbcopy = GUICtrlCreateCheckbox("Copy updates for selected products into...", $txtxpos, $txtypos, $groupwidth / 2, $txtheight)
EndIf
If IniRead($inifilename, $ini_section_usb, $usb_token_copy, $disabled) = $enabled Then
  GUICtrlSetState(-1, $GUI_CHECKED)
Else
  GUICtrlSetState(-1, $GUI_UNCHECKED)
EndIf

;  USB target
$txtxpos = $txtxpos + $groupwidth / 2
If ShowGUIInGerman() Then
  $usblbl = GUICtrlCreateLabel("Verzeichnis:", $txtxpos, $txtypos, $txtwidth - 20, $txtheight)
Else
  $usblbl = GUICtrlCreateLabel("Directory:", $txtxpos, $txtypos, $txtwidth - 20, $txtheight)
EndIf
$txtxpos = $txtxpos + $txtwidth - 20
$usbpath = GUICtrlCreateInput(IniRead($inifilename, $ini_section_usb, $usb_token_path, ""), $txtxpos, $txtypos - 2, $groupwidth / 2 - ($txtwidth - 20) - $txtheight, $txtheight)
;  USB FSF button - FileSelectFolder
$txtxpos = $txtxpos + $groupwidth / 2 - ($txtwidth - 20) - $txtheight
$usbfsf = GUICtrlCreateButton("...", $txtxpos, $txtypos - 2, $txtheight, $txtheight)
If BitAND(GUICtrlRead($usbcopy), $GUI_CHECKED) = $GUI_CHECKED Then
  GUICtrlSetState($usblbl, $GUI_ENABLE)
  GUICtrlSetState($usbpath, $GUI_ENABLE)
  GUICtrlSetState($usbfsf, $GUI_ENABLE)
Else
  GUICtrlSetState($usblbl, $GUI_DISABLE)
  GUICtrlSetState($usbpath, $GUI_DISABLE)
  GUICtrlSetState($usbfsf, $GUI_DISABLE)
EndIf

;  Start button
$txtxpos = $txtxoffset
$txtypos = $txtypos + $txtgrpyoffset + $txtheight
$btn_start = GUICtrlCreateButton("Start", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM)

;  Skip download checkbox
$txtxpos = $txtxpos + $btnwidth + $txtxoffset
If ShowGUIInGerman() Then
  $skipdownload = GUICtrlCreateCheckbox("Ohne Download", $txtxpos, $txtypos + 2, 2 * $txtwidth, $txtheight)
Else
  $skipdownload = GUICtrlCreateCheckbox("Skip download", $txtxpos, $txtypos + 2, 2 * $txtwidth, $txtheight)
EndIf

;  Proxy button
$txtxpos = 2* $txtxoffset + $groupwidth / 2 - $btnwidth
$btn_proxy = GUICtrlCreateButton("Proxy...", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
$proxy = IniRead($inifilename, $ini_section_misc, $misc_token_proxy, "")

;  WSUS button
$txtxpos = 2 * $txtxoffset + $groupwidth / 2
$btn_wsus = GUICtrlCreateButton("WSUS...", $txtxpos, $txtypos, $btnwidth, $btnheight)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
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
If StringRight(EnvGet("TEMP"), 1) = "\" Then
  If ShowGUIInGerman() Then
    MsgBox(0x2010, "Fehler", "Die Umgebungsvariable TEMP" & @LF _
         & "enthält einen abschließenden Backslash ('\').")
    Exit(1)
  Else
    MsgBox(0x2010, "Error", "The environment variable TEMP" & @LF _
         & "contains a trailing backslash ('\').")
    Exit(1)
  EndIf
EndIf
While 1
  Switch GUIGetMsg()
    Case $GUI_EVENT_CLOSE   ; Window closed
      ExitLoop

    Case $btn_exit          ; Exit button pressed
      ExitLoop

    Case $excludesp         ; 'Exclude Service Packs' check box toggled
      If ( (BitAND(GUICtrlRead($excludesp), $GUI_CHECKED) = $GUI_CHECKED) _
       AND (BitAND(GUICtrlRead($cleanupdownloads), $GUI_CHECKED) = $GUI_CHECKED) ) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch die Kombination der Optionen 'Service-Packs ausschließen' und" _
                               & @LF & "'Download-Verzeichnisse bereinigen' werden bereits heruntergeladene" _
                               & @LF & "Service Packs für die selektierten Produkte gelöscht." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($excludesp, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The combination of 'Exclude Service Packs' and" _
                               & @LF & "'Clean up download directories' options will delete" _
                               & @LF & "previously downloaded Service Packs for the selected products." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($excludesp, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $cleanupdownloads  ; 'Cleanup download directories' check box toggled
      If ( (BitAND(GUICtrlRead($excludesp), $GUI_CHECKED) = $GUI_CHECKED) _
       AND (BitAND(GUICtrlRead($cleanupdownloads), $GUI_CHECKED) = $GUI_CHECKED) ) Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch die Kombination der Optionen 'Service-Packs ausschließen' und" _
                               & @LF & "'Download-Verzeichnisse bereinigen' werden bereits heruntergeladene" _
                               & @LF & "Service Packs für die selektierten Produkte gelöscht." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($cleanupdownloads, $GUI_UNCHECKED)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "The combination of 'Exclude Service Packs' and" _
                               & @LF & "'Clean up download directories' options will delete" _
                               & @LF & "previously downloaded Service Packs for the selected products." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($cleanupdownloads, $GUI_UNCHECKED)
          EndIf
        EndIf
      EndIf

    Case $usbcopy           ; USB copy button pressed
      If BitAND(GUICtrlRead($usbcopy), $GUI_CHECKED) = $GUI_CHECKED Then
        GUICtrlSetState($usblbl, $GUI_ENABLE)
        GUICtrlSetState($usbpath, $GUI_ENABLE)
        GUICtrlSetState($usbfsf, $GUI_ENABLE)
      Else
        GUICtrlSetState($usblbl, $GUI_DISABLE)
        GUICtrlSetState($usbpath, $GUI_DISABLE)
        GUICtrlSetState($usbfsf, $GUI_DISABLE)
      EndIf

    Case $usbfsf            ; FSF button pressed
      If ShowGUIInGerman() Then
        $dummy = FileSelectFolder("Wählen Sie ein Zielverzeichnis:", "", 1, GUICtrlRead($usbpath)) 
      Else
        $dummy = FileSelectFolder("Choose destination directory:", "", 1, GUICtrlRead($usbpath))
      EndIf
      If FileExists($dummy) Then
        GUICtrlSetData($usbpath, $dummy)
      EndIf

    Case $skipdownload      ; Skip download checkbox toggled
      If BitAND(GUICtrlRead($skipdownload), $GUI_CHECKED) = $GUI_CHECKED Then
        If ShowGUIInGerman() Then
          If MsgBox(0x2134, "Warnung", "Durch diese Option verhindern Sie das Herunterladen aktueller Updates." _
                               & @LF & "Dies kann ein erhöhtes Sicherheitsrisiko für das Zielsystem bedeuten." _
                               & @LF & "Möchten Sie fortsetzen?") = 7 Then
            GUICtrlSetState($skipdownload, $GUI_UNCHECKED)
          Else
            GUICtrlSetState($cleanupdownloads, $GUI_DISABLE)
            GUICtrlSetState($verifydownloads, $GUI_DISABLE)
          EndIf
        Else
          If MsgBox(0x2134, "Warning", "This option prevents downloading of recent updates." _
                               & @LF & "This may increase security risks for the target system." _
                               & @LF & "Do you wish to proceed?") = 7 Then
            GUICtrlSetState($skipdownload, $GUI_UNCHECKED)
          Else
            GUICtrlSetState($cleanupdownloads, $GUI_DISABLE)
            GUICtrlSetState($verifydownloads, $GUI_DISABLE)
          EndIf
        EndIf
      Else
        GUICtrlSetState($cleanupdownloads, $GUI_ENABLE)
        GUICtrlSetState($verifydownloads, $GUI_ENABLE)
      EndIf

    Case $btn_proxy         ; Proxy button pressed
      If ShowGUIInGerman() Then
        $dummy = InputBox("HTTP-Proxy-Einstellung", "Bitte geben Sie die HTTP-Proxy-URL ein (Syntax:" & @LF & "http://[Benutzername:Passwort@]<Server>:<Port>):", $proxy, "", 300, 130)
      Else
        $dummy = InputBox("HTTP proxy setting", "Please enter HTTP proxy URL (syntax:" & @LF & "http://[username:password@]<server>:<port>):", $proxy, "", 280, 130)
      EndIf
      If @error = 0 Then
        $proxy = $dummy
      EndIf

    Case $btn_wsus          ; WSUS button pressed
      If ShowGUIInGerman() Then
        $dummy = InputBox("WSUS-Einstellung", "Bitte geben Sie die WSUS-URL ein" & @LF & "(Syntax: http://<Server>):", $wsus, "", 220, 130)
      Else
        $dummy = InputBox("WSUS setting", "Please enter WSUS URL" & @LF & "(syntax: http://<server>):", $wsus, "", 200, 130)
      EndIf
      If @error = 0 Then
        $wsus = $dummy
      EndIf
      
    Case $btn_donate        ; Donate button pressed
      RunDonationSite()

    Case $btn_start         ; Start button pressed
      If IniRead($inifilename, $ini_section_misc, $misc_token_chkver, $enabled) = $enabled Then
        Switch RunVersionCheck($proxy)
          Case -1 ; Yes
            Run(@ComSpec & " /D /C start " & $downloadURL)
            ExitLoop
          Case 1  ; Cancel / Close
            ContinueLoop
          Case Else
        EndSwitch
      EndIf
      If IniRead($inifilename, $ini_section_misc, $misc_token_minimize, $disabled) = $enabled Then
        WinSetState($maindlg, $maindlg, @SW_MINIMIZE)
      EndIf

;  Global
      If BitAND(GUICtrlRead($w60_glb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w60 glb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w60_x64_glb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w60-x64 glb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w61_glb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w61 glb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w61_x64_glb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w61-x64 glb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  English
      If BitAND(GUICtrlRead($w2k_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_enu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 enu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  French
      If BitAND(GUICtrlRead($w2k_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_fra), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 fra", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Spanish
      If BitAND(GUICtrlRead($w2k_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_esn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 esn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Japanese
      If BitAND(GUICtrlRead($w2k_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_jpn), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 jpn", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Korean
      If BitAND(GUICtrlRead($w2k_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_kor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 kor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Russian
      If BitAND(GUICtrlRead($w2k_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_rus), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 rus", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Portuguese
      If BitAND(GUICtrlRead($w2k_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_ptg), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 ptg", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Brazilian
      If BitAND(GUICtrlRead($w2k_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_ptb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 ptb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  German
      If BitAND(GUICtrlRead($w2k_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_x64_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3-x64 deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_deu), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 deu", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Dutch
      If BitAND(GUICtrlRead($w2k_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_nld), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 nld", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Italian
      If BitAND(GUICtrlRead($w2k_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_ita), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 ita", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Chinese
      If BitAND(GUICtrlRead($w2k_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_chs), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 chs", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Taiwanese
      If BitAND(GUICtrlRead($w2k_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_cht), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 cht", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Polish
      If BitAND(GUICtrlRead($w2k_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_plk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 plk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Hungarian
      If BitAND(GUICtrlRead($w2k_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_hun), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 hun", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Czech
      If BitAND(GUICtrlRead($w2k_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_csy), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 csy", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Swedish
      If BitAND(GUICtrlRead($w2k_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_sve), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 sve", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Turkish
      If BitAND(GUICtrlRead($w2k_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($w2k3_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k3 trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_trk), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 trk", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Greek
      If BitAND(GUICtrlRead($w2k_ell), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k ell", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_ell), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp ell", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_ell), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp ell", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_ell), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 ell", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_ell), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 ell", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Arabic
      If BitAND(GUICtrlRead($w2k_ara), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k ara", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_ara), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp ara", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_ara), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp ara", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_ara), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 ara", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_ara), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 ara", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Hebrew
      If BitAND(GUICtrlRead($w2k_heb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k heb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_heb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp heb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_heb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp heb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_heb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 heb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_heb), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 heb", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Danish
      If BitAND(GUICtrlRead($w2k_dan), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k dan", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_dan), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp dan", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_dan), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp dan", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_dan), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 dan", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_dan), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 dan", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Norwegian
      If BitAND(GUICtrlRead($w2k_nor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k nor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_nor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp nor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_nor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp nor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_nor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 nor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_nor), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 nor", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Finnish
      If BitAND(GUICtrlRead($w2k_fin), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("w2k fin", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($wxp_fin), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("wxp fin", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($oxp_fin), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("oxp fin", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k3_fin), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k3 fin", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf
      If BitAND(GUICtrlRead($o2k7_fin), $GUI_CHECKED) = $GUI_CHECKED Then
        If RunScripts("o2k7 fin", DetermineDownloadSwitches($excludesp, $dotnet, $cleanupdownloads, $verifydownloads, $cdiso, $dvdiso, $proxy, $wsus), $cdiso, DetermineISOSwitches($excludesp, $dotnet), $usbcopy, GUICtrlRead($usbpath)) <> 0 Then
          ContinueLoop
        EndIf
      EndIf

;  Create cross-platform DVD ISO images
      If BitAND(GUICtrlRead($dvdiso), $GUI_CHECKED) = $GUI_CHECKED Then
        If ( (BitAND(GUICtrlRead($w2k_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_enu), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_enu, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_fra), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_fra, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_esn), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_esn, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_jpn), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_jpn, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_kor), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_kor, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_rus), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_rus, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_ptg), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_ptg), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_ptg), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_ptg), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_ptg), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_ptg), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_ptg, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_ptb), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_ptb, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_deu), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_deu, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_nld), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_nld), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_nld), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_nld), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_nld), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_nld), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_nld, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_ita), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_ita), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_ita), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_ita), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_ita), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_ita), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_ita, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_chs), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_chs), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_chs), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_chs), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_chs), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_chs), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_chs, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_cht), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_cht), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_cht), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_cht), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_cht), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_cht), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_cht, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_plk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_plk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_plk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_plk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_plk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_plk), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_plk, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_hun), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_hun), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_hun), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_hun), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_hun), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_hun), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_hun, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_csy), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_csy), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_csy), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_csy), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_csy), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_csy), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_csy, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_sve), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_sve), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_sve), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_sve), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_sve), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_sve), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_sve, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_trk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_trk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_trk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_trk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_trk), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_trk), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_trk, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_ell), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_ell), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_ell), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_ell), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_ell), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_ell, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_ara), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_ara), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_ara), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_ara), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_ara), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_ara, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_heb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_heb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_heb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_heb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_heb), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_heb, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_dan), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_dan), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_dan), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_dan), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_dan), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_dan, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_nor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_nor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_nor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_nor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_nor), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_nor, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k_fin), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($wxp_fin), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($oxp_fin), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k3_fin), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($o2k7_fin), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript($lang_token_fin, DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
        If ( (BitAND(GUICtrlRead($w2k3_x64_enu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_fra), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_esn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_jpn), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_kor), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_rus), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_ptb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w2k3_x64_deu), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w60_x64_glb), $GUI_CHECKED) = $GUI_CHECKED) _
          OR (BitAND(GUICtrlRead($w61_x64_glb), $GUI_CHECKED) = $GUI_CHECKED) ) Then
          If RunISOCreationScript("all-x64", DetermineISOSwitches($excludesp, $dotnet)) <> 0 Then
            ContinueLoop
          EndIf
        EndIf
      EndIf

;  Restore window and show success dialog
      WinSetState($maindlg, $maindlg, @SW_RESTORE)
      If ShowGUIInGerman() Then
        MsgBox(0x2040, "Info", "Herunterladen / Image-Erstellung erfolgreich.")
      Else
        MsgBox(0x2040, "Info", "Download / image creation successful.")
      EndIf

  EndSwitch
WEnd
SaveSettings()
Exit
