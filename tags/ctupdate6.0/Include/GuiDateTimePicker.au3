#include-once
#include <Memory.au3>
#include <WinAPI.au3>
#include <DateTimeConstants.au3>
#include <StructureConstants.au3>
#include <SendMessage.au3>
#include <UDFGlobalID.au3>

; #INDEX# =======================================================================================================================
; Title .........: Date Time Picker
; Description ...: A date and time picker (DTP) control provides a simple and intuitive interface through which to exchange date
;                  and time information with a user.  For example, with a DTP control you can ask the user to enter a date and
;                  then retrieve his or her selection with ease.
; Author ........: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_DTP_ghDTLastWnd
Global $Debug_DTP = False
Global Const $__DTPCONSTANT_WS_VISIBLE = 0x10000000
Global Const $__DTPCONSTANT_WS_CHILD = 0x40000000
Global Const $__DTPCONSTANT_ClassName = "SysDateTimePick32"
; ===============================================================================================================================

;===============================================================================
; #CURRENT# =====================================================================================================================
;_GUICtrlDTP_Create
;_GUICtrlDTP_Destroy
;_GUICtrlDTP_GetMCColor
;_GUICtrlDTP_GetMCFont
;_GUICtrlDTP_GetMonthCal
;_GUICtrlDTP_GetRange
;_GUICtrlDTP_GetRangeEx
;_GUICtrlDTP_GetSystemTime
;_GUICtrlDTP_GetSystemTimeEx
;_GUICtrlDTP_SetFormat
;_GUICtrlDTP_SetMCColor
;_GUICtrlDTP_SetMCFont
;_GUICtrlDTP_SetRange
;_GUICtrlDTP_SetRangeEx
;_GUICtrlDTP_SetSystemTime
;_GUICtrlDTP_SetSystemTimeEx
; ===============================================================================================================================
; #INTERNAL_USE_ONLY#============================================================================================================
; For internal use only
; ===============================================================================================================================
;_GUICtrlDTP_DebugPrint
;_GUICtrlDTP_ValidateClassName
;==============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_Create
; Description ...: Create a DTP control
; Syntax.........: _GUICtrlDTP_Create($hWnd, $iX, $iY[, $iWidth = 120[, $iHeight = 21[, $iStyle = 0x00000000[, $iExStyle = 0x00000000]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Wontrol height
;                  $iStyle      - Control styles:
;                  |$DTS_APPCANPARSE            - Allows the owner to parse user input and take action
;                  |$DTS_LONGDATEFORMAT         - Displays the date in long format
;                  |$DTS_RIGHTALIGN             - The calendar will be right-aligned
;                  |$DTS_SHOWNONE               - Displays a check box that can be checked once a date is entered
;                  |$DTS_SHORTDATEFORMAT        - Displays the date in short format
;                  |$DTS_SHORTDATECENTURYFORMAT - The year is a four-digit field
;                  |$DTS_TIMEFORMAT             - Displays the time
;                  |$DTS_UPDOWN                 - Places an up-down control to the right of the control
;                  -
;                  |Forced: $WS_CHILD, $WS_VISIBLE
;                  $iExStyle    - Control external styles
; Return values .: Success      - Handle to the DTP control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlDTP_Destroy
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_Create($hWnd, $iX, $iY, $iWidth = 120, $iHeight = 21, $iStyle = 0x00000000, $iExStyle = 0x00000000)
	$iStyle = BitOR($iStyle, $__DTPCONSTANT_WS_CHILD, $__DTPCONSTANT_WS_VISIBLE)
	Local $nCtrlID

	$nCtrlID = _UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Return _WinAPI_CreateWindowEx($iExStyle, $__DTPCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
EndFunc   ;==>_GUICtrlDTP_Create

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUICtrlDTP_DebugPrint
; Description ...: Used for debugging when creating examples
; Syntax.........: _GUICtrlDTP_DebugPrint($hWnd[, $iLine = @ScriptLineNumber])
; Parameters ....: $sText       - String to printed to console
;                  $iLine       - Line number function was called from
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _GUICtrlDTP_DebugPrint($sText, $iLine = @ScriptLineNumber)
	ConsoleWrite( _
			"!===========================================================" & @LF & _
			"+======================================================" & @LF & _
			"-->Line(" & StringFormat("%04d", $iLine) & "):" & @TAB & $sText & @LF & _
			"+======================================================" & @LF)
EndFunc   ;==>_GUICtrlDTP_DebugPrint

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlDTP_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Date Time Picker create with _GUICtrlDTP_Create
; Related .......: _GUICtrlDTP_Create
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_Destroy(ByRef $hWnd)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)

	Local $iResult, $Destroyed

	If _WinAPI_IsClassName($hWnd, $__DTPCONSTANT_ClassName) Then
		If IsHWnd($hWnd) Then
			If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
				Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
				Local $hParent = _WinAPI_GetParent($hWnd)
				$Destroyed = _WinAPI_DestroyWindow($hWnd)
				$iResult = _UDF_FreeGlobalID($hParent, $nCtrlID)
				If Not $iResult Then
					; can check for errors here if needed, for debug
				EndIf
			Else
				_WinAPI_ShowMsg("Not Allowed to Destroy Other Applications ListView(s)")
				Return SetError(1, 1, False)
			EndIf
		Else
			$Destroyed = GUICtrlDelete($hWnd)
		EndIf
		If $Destroyed Then $hWnd = 0
		Return $Destroyed <> 0
	EndIf
	Return SetError(2, 2, False)
EndFunc   ;==>_GUICtrlDTP_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetMCColor
; Description ...: Retrieves the specified color
; Syntax.........: _GUICtrlDTP_GetMCColor($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Indicates which month calendar color to retrieve:
;                  |0 - Background color displayed between months
;                  |1 - Color used to display text within a month
;                  |2 - Background color displayed in the calendar title
;                  |3 - Color used to display text within the calendar title
;                  |4 - Background color displayed within the month
;                  |5 - Color used to display header day and trailing day text
; Return values .: Success      - The color setting for the specified portion of the control
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_SetMCColor
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetMCColor($hWnd, $iIndex)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Return _SendMessage($hWnd, $DTM_GETMCCOLOR, $iIndex)
EndFunc   ;==>_GUICtrlDTP_GetMCColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetMCFont
; Description ...: Retrieves the month calendar font handle
; Syntax.........: _GUICtrlDTP_GetMCFont($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Font handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_SetMCFont
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetMCFont($hWnd)
	_WinAPI_ValidateClassName($hWnd, $__DTPCONSTANT_ClassName)
	Return _SendMessage($hWnd, $DTM_GETMCFONT)
EndFunc   ;==>_GUICtrlDTP_GetMCFont

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetMonthCal
; Description ...: Retrieves the handle to child month calendar control
; Syntax.........: _GUICtrlDTP_GetMonthCal($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Month calendar handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: DTP controls create a child month calendar control when the user clicks the drop down arrow ($DTN_DROPDOWN
;                  notification). When the month calendar is no longer needed, it is destroyed (a $DTN_CLOSEUP notification is
;                  sent on destruction). So your application must not rely on a static handle to the DTP control's child month
;                  calendar.
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetMonthCal($hWnd)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Return _SendMessage($hWnd, $DTM_GETMONTHCAL)
EndFunc   ;==>_GUICtrlDTP_GetMonthCal

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetRange
; Description ...: Retrieves the current minimum and maximum allowable system times
; Syntax.........: _GUICtrlDTP_GetRange($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns an array with the following format:
;                  |[ 0] - True if Min data is valid, otherwise False
;                  |[ 1] - Min Year
;                  |[ 2] - Min Month
;                  |[ 3] - Min Day
;                  |[ 4] - Min Hour
;                  |[ 5] - Min Minute
;                  |[ 6] - Min Second
;                  |[ 7] - True if Max data is valid, otherwise False
;                  |[ 8] - Max Year
;                  |[ 9] - Max Month
;                  |[10] - Max Day
;                  |[11] - Max Hour
;                  |[12] - Max Minute
;                  |[13] - Max Second
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_SetRange
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetRange($hWnd)
	Local $tRange, $aRange[14]

	$tRange = _GUICtrlDTP_GetRangeEx($hWnd)
	$aRange[0] = DllStructGetData($tRange, "MinValid")
	$aRange[1] = DllStructGetData($tRange, "MinYear")
	$aRange[2] = DllStructGetData($tRange, "MinMonth")
	$aRange[3] = DllStructGetData($tRange, "MinDay")
	$aRange[4] = DllStructGetData($tRange, "MinHour")
	$aRange[5] = DllStructGetData($tRange, "MinMinute")
	$aRange[6] = DllStructGetData($tRange, "MinSecond")
	$aRange[7] = DllStructGetData($tRange, "MaxValid")
	$aRange[8] = DllStructGetData($tRange, "MaxYear")
	$aRange[9] = DllStructGetData($tRange, "MaxMonth")
	$aRange[10] = DllStructGetData($tRange, "MaxDay")
	$aRange[11] = DllStructGetData($tRange, "MaxHour")
	$aRange[12] = DllStructGetData($tRange, "MaxMinute")
	$aRange[13] = DllStructGetData($tRange, "MaxSecond")
	Return $aRange
EndFunc   ;==>_GUICtrlDTP_GetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetRangeEx
; Description ...: Retrieves the current minimum and maximum allowable system times
; Syntax.........: _GUICtrlDTP_GetRangeEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagDTPRANGE structure
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_SetRangeEx, $tagDTPRANGE
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetRangeEx($hWnd)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $iRange, $pRange, $tRange, $pMemory, $tMemMap, $iResult

	$tRange = DllStructCreate($tagDTPRANGE)
	$pRange = DllStructGetPtr($tRange)
	If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
		$iResult = _SendMessage($hWnd, $DTM_GETRANGE, 0, $pRange, 0, "wparam", "ptr")
	Else
		$iRange = DllStructGetSize($tRange)
		$pMemory = _MemInit($hWnd, $iRange, $tMemMap)
		$iResult = _SendMessage($hWnd, $DTM_GETRANGE, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $pRange, $iRange)
		_MemFree($tMemMap)
	EndIf
	DllStructSetData($tRange, "MinValid", BitAND($iResult, $GDTR_MIN) <> 0)
	DllStructSetData($tRange, "MaxValid", BitAND($iResult, $GDTR_MAX) <> 0)
	Return $tRange
EndFunc   ;==>_GUICtrlDTP_GetRangeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetSystemTime
; Description ...: Retrieves the currently selected date and time
; Syntax.........: _GUICtrlDTP_GetSystemTime($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns an array with the following format:
;                  |[0] - Year
;                  |[1] - Month
;                  |[2] - Day
;                  |[3] - Hour
;                  |[4] - Minute
;                  |[5] - Second
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: @Error is set to $GDT_VALID if the time information was successfully returned, $GDT_NONE if the control was
;                  set to the $DTS_SHOWNONE style and the control check box was not selected or $GDT_ERROR if an error occured.
; Related .......: _GUICtrlDTP_SetSystemTime
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetSystemTime($hWnd)
	Local $tDate, $aDate[6]

	$tDate = _GUICtrlDTP_GetSystemTimeEx($hWnd)
	$aDate[0] = DllStructGetData($tDate, "Year")
	$aDate[1] = DllStructGetData($tDate, "Month")
	$aDate[2] = DllStructGetData($tDate, "Day")
	$aDate[3] = DllStructGetData($tDate, "Hour")
	$aDate[4] = DllStructGetData($tDate, "Minute")
	$aDate[5] = DllStructGetData($tDate, "Second")
	Return $aDate
EndFunc   ;==>_GUICtrlDTP_GetSystemTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_GetSystemTimeEx
; Description ...: Retrieves the currently selected date and time
; Syntax.........: _GUICtrlDTP_GetSystemTimeEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagDTPTIME structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: @Error is set to $GDT_VALID if the time information was successfully returned, $GDT_NONE if the control was
;                  set to the $DTS_SHOWNONE style and the control check box was not selected or $GDT_ERROR if an error occured.
; Related .......: _GUICtrlDTP_GetSystemTime, $tagDTPTIME
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_GetSystemTimeEx($hWnd)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $iDate, $pDate, $tDate, $pMemory, $tMemMap, $iResult

	$tDate = DllStructCreate($tagDTPTIME)
	$pDate = DllStructGetPtr($tDate)
	If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
		$iResult = _SendMessage($hWnd, $DTM_GETSYSTEMTIME, 0, $pDate, 0, "wparam", "ptr")
	Else
		$iDate = DllStructGetSize($tDate)
		$pMemory = _MemInit($hWnd, $iDate, $tMemMap)
		$iResult = _SendMessage($hWnd, $DTM_GETSYSTEMTIME, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $pDate, $iDate)
		_MemFree($tMemMap)
	EndIf
	Return SetError($iResult, $iResult, $tDate)
EndFunc   ;==>_GUICtrlDTP_GetSystemTimeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetFormat
; Description ...: Sets the display based on a given format string
; Syntax.........: _GUICtrlDTP_SetFormat($hWnd, $sFormat)
; Parameters ....: $hWnd        - Handle to the control
;                  $sFormat     - String that defines the desired format.  Setting this to blank will reset the control to the
;                  +default format string for the current style. You can use the following format strings:
;                  |"d"    - The one or two digit day
;                  |"dd"   - The two digit day. Single digit day values are preceded by a zero
;                  |"ddd"  - The three character weekday abbreviation
;                  |"dddd" - The full weekday name
;                  |"h"    - The one or two digit hour in 12-hour format
;                  |"hh"   - The two digit hour in 12-hour format
;                  |"H"    - The one or twodigit hour in 24-hour format
;                  |"HH"   - The two digit hour in 24 hour format
;                  |"m"    - The one or two digit minute
;                  |"mm"   - The two digit minute
;                  |"M"    - The one or two digit month number
;                  |"MM"   - The two digit month number
;                  |"MMM"  - The three-character month abbreviation
;                  |"MMMM" - The full month name
;                  |"t"    - The one letter AM/PM abbreviation
;                  |"tt"   - The two letter AM/PM abbreviation
;                  |"yy"   - The last two digits of the year
;                  |"yyyy" - The full year
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: It is acceptable to include extra characters within the format string to produce a more rich display. However,
;                  any nonformat characters must be enclosed within single quotes.  For example, the  format  string  "'Today is:
;                  'hh':'m':'s ddddMMMdd', 'yyy" would produce output like "Today is: 04:22:31 Tuesday Mar 23, 1996". Note: A DTP
;                  control tracks locale changes when it is using the default format string.  If you set a custom format string,
;                  it will not be updated in response to locale changes.
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetFormat($hWnd, $sFormat)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $tMemMap, $iMemory, $pMemory, $iResult

	If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
		$iResult = _SendMessage($hWnd, $DTM_SETFORMAT, 0, $sFormat, 0, "wparam", "str")
	Else
		$iMemory = StringLen($sFormat) + 1
		$pMemory = _MemInit($hWnd, $iMemory, $tMemMap)
		_MemWrite($tMemMap, $sFormat, $pMemory, $iMemory, "str")
		$iResult = _SendMessage($hWnd, $DTM_SETFORMAT, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iResult <> 0
EndFunc   ;==>_GUICtrlDTP_SetFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetMCColor
; Description ...: Sets the color for a given portion of the month calendar
; Syntax.........: _GUICtrlDTP_SetMCColor($hWnd, $iIndex, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Indicates which month calendar color to set:
;                  |0 - Background color displayed between months
;                  |1 - Color used to display text within a month
;                  |2 - Background color displayed in the calendar title
;                  |3 - Color used to display text within the calendar title
;                  |4 - Background color displayed within the month
;                  |5 - Color used to display header day and trailing day text
;                  $iColor      - The color that will be set for the specified area
; Return values .: Success      - The previous color for the given portion
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetMCColor
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetMCColor($hWnd, $iIndex, $iColor)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Return _SendMessage($hWnd, $DTM_SETMCCOLOR, $iIndex, $iColor)
EndFunc   ;==>_GUICtrlDTP_SetMCColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetMCFont
; Description ...: Sets the month calendar font
; Syntax.........: _GUICtrlDTP_SetMCFont($hWnd, $hFont[, $fRedraw = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hFont       - Handle to the font that will be set
;                  $fRedraw     - Specifies whether the control should be redrawn immediately
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetMCFont
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetMCFont($hWnd, $hFont, $fRedraw = True)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	_SendMessage($hWnd, $DTM_SETMCFONT, $hFont, $fRedraw, 0, "hwnd")
EndFunc   ;==>_GUICtrlDTP_SetMCFont

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetRange
; Description ...: Sets the current minimum and maximum allowable system times
; Syntax.........: _GUICtrlDTP_SetRange($hWnd, ByRef $aRange)
; Parameters ....: $hWnd        - Handle to the control
;                  $aRange      - Array formatted as follows:
;                  |[ 0] - True if Min data is to be set, otherwise False
;                  |[ 1] - Min Year
;                  |[ 2] - Min Month
;                  |[ 3] - Min Day
;                  |[ 4] - Min Hour
;                  |[ 5] - Min Minute
;                  |[ 6] - Min Second
;                  |[ 7] - True if Max data is to be set, otherwise False
;                  |[ 8] - Max Year
;                  |[ 9] - Max Month
;                  |[10] - Max Day
;                  |[11] - Max Hour
;                  |[12] - Max Minute
;                  |[13] - Max Second
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetRange
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetRange($hWnd, ByRef $aRange)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $tRange

	$tRange = DllStructCreate($tagDTPRANGE)
	DllStructSetData($tRange, "MinValid", $aRange[0])
	DllStructSetData($tRange, "MinYear", $aRange[1])
	DllStructSetData($tRange, "MinMonth", $aRange[2])
	DllStructSetData($tRange, "MinDay", $aRange[3])
	DllStructSetData($tRange, "MinHour", $aRange[4])
	DllStructSetData($tRange, "MinMinute", $aRange[5])
	DllStructSetData($tRange, "MinSecond", $aRange[6])
	DllStructSetData($tRange, "MaxValid", $aRange[7])
	DllStructSetData($tRange, "MaxYear", $aRange[8])
	DllStructSetData($tRange, "MaxMonth", $aRange[9])
	DllStructSetData($tRange, "MaxDay", $aRange[10])
	DllStructSetData($tRange, "MaxHour", $aRange[11])
	DllStructSetData($tRange, "MaxMinute", $aRange[12])
	DllStructSetData($tRange, "MaxSecond", $aRange[13])
	Return _GUICtrlDTP_SetRangeEx($hWnd, $tRange)
EndFunc   ;==>_GUICtrlDTP_SetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetRangeEx
; Description ...: Sets the current minimum and maximum allowable system times
; Syntax.........: _GUICtrlDTP_SetRangeEx($hWnd, ByRef $tRange)
; Parameters ....: $hWnd        - Handle to the control
;                  $tRange      - $tagDTPRANGE structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetRangeEx, $tagDTPRANGE
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetRangeEx($hWnd, ByRef $tRange)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $iRange, $pRange, $pMemory, $tMemMap, $iFlags, $iResult

	$pRange = DllStructGetPtr($tRange)
	If DllStructGetData($tRange, "MinValid") Then $iFlags = BitOR($iFlags, $GDTR_MIN)
	If DllStructGetData($tRange, "MaxValid") Then $iFlags = BitOR($iFlags, $GDTR_MAX)
	If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
		$iResult = _SendMessage($hWnd, $DTM_SETRANGE, $iFlags, $pRange, 0, "wparam", "ptr")
	Else
		$iRange = DllStructGetSize($tRange)
		$pMemory = _MemInit($hWnd, $iRange, $tMemMap)
		_MemWrite($tMemMap, $pRange)
		$iResult = _SendMessage($hWnd, $DTM_SETRANGE, $iFlags, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iResult <> 0
EndFunc   ;==>_GUICtrlDTP_SetRangeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetSystemTime
; Description ...: Sets the currently selected date and time
; Syntax.........: _GUICtrlDTP_SetSystemTime($hWnd, ByRef $aDate)
; Parameters ....: $hWnd        - Handle to the control
;                  $aDate       - Array formatted as follows:
;                  |[0] - If True, the control will is set to "no date"
;                  |[1] - Year
;                  |[2] - Month
;                  |[3] - Day
;                  |[4] - Hour
;                  |[5] - Minute
;                  |[6] - Second
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetSystemTime
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetSystemTime($hWnd, ByRef $aDate)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $tDate

	$tDate = DllStructCreate($tagDTPTIME)
	DllStructSetData($tDate, "Year", $aDate[1])
	DllStructSetData($tDate, "Month", $aDate[2])
	DllStructSetData($tDate, "Day", $aDate[3])
	DllStructSetData($tDate, "Hour", $aDate[4])
	DllStructSetData($tDate, "Minute", $aDate[5])
	DllStructSetData($tDate, "Second", $aDate[6])
	Return _GUICtrlDTP_SetSystemTimeEx($hWnd, $tDate, $aDate[0])
EndFunc   ;==>_GUICtrlDTP_SetSystemTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlDTP_SetSystemTimeEx
; Description ...: Sets the currently selected date and time
; Syntax.........: _GUICtrlDTP_SetSystemTimeEx($hWnd, ByRef $tDate[, $fFlag = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $tDate       - $tagDTPTIME structure
;                  $fFlag       - No date setting:
;                  | True - Control will be set to "no date"
;                  |False - Control is set to date and time value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlDTP_GetSystemTimeEx, $tagDTPTIME
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _GUICtrlDTP_SetSystemTimeEx($hWnd, ByRef $tDate, $fFlag = False)
	If $Debug_DTP Then _GUICtrlDTP_ValidateClassName($hWnd)
	Local $iFlag, $iDate, $pDate, $pMemory, $tMemMap, $iResult

	$pDate = DllStructGetPtr($tDate)
	If $fFlag Then
		$iFlag = $GDT_NONE
	Else
		$iFlag = $GDT_VALID
	EndIf
	If _WinAPI_InProcess($hWnd, $_DTP_ghDTLastWnd) Then
		$iResult = _SendMessage($hWnd, $DTM_SETSYSTEMTIME, $iFlag, $pDate, 0, "wparam", "ptr")
	Else
		$iDate = DllStructGetSize($tDate)
		$pMemory = _MemInit($hWnd, $iDate, $tMemMap)
		_MemWrite($tMemMap, $pDate)
		$iResult = _SendMessage($hWnd, $DTM_SETSYSTEMTIME, $iFlag, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iResult <> 0
EndFunc   ;==>_GUICtrlDTP_SetSystemTimeEx

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUICtrlDTP_ValidateClassName
; Description ...: Used for debugging when creating examples
; Syntax.........: _GUICtrlDTP_ValidateClassName($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _GUICtrlDTP_ValidateClassName($hWnd)
	_GUICtrlDTP_DebugPrint("This is for debugging only, set the debug variable to false before submitting")
	_WinAPI_ValidateClassName($hWnd, $__DTPCONSTANT_ClassName)
EndFunc   ;==>_GUICtrlDTP_ValidateClassName
