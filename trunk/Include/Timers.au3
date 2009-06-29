#include-once

; #INDEX# =======================================================================================================================
; Title .........: Timers
; AutoIt Version: 3.2.3++
; Language:       English
; Description ...: An application uses a timer to schedule an event for a window after a specified time has elapsed.
;                  Each time the specified interval (or time-out value) for a timer elapses, the system notifies the window
;                  associated with the timer. Because a timer's accuracy depends on the system clock rate and how often the
;                  application retrieves messages from the message queue, the time-out value is only approximate.
; Author ........: Gary Frost
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_Timers_aTimerIDs[1][3]
; ===============================================================================================================================

; ===============================================================================================================================
; #CURRENT# =====================================================================================================================
;_Timer_Diff
;_Timer_GetIdleTime
;_Timer_GetTimerID
;_Timer_Init
;_Timer_KillAllTimers
;_Timer_KillTimer
;_Timer_SetTimer
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;_Timer_QueryPerformanceCounter
;_Timer_QueryPerformanceFrequency
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_Diff
; Description ...: Returns the difference in time from a previous call to _Timer_Init
; Syntax.........: _Timer_Diff($iTimeStamp)
; Parameters ....: $iTimeStamp - Timestamp returned from a previous call to _Timer_Init().
; Return values .: Success - Returns the time difference (in milliseconds) from a previous call to _Timer_Init().
; Author ........: Gary Frost, original by Toady
; Modified.......:
; Remarks .......:
; Related .......: _Timer_Diff
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_Diff($iTimeStamp)
	Return 1000 * (_Timer_QueryPerformanceCounter() - $iTimeStamp) / _Timer_QueryPerformanceFrequency()
EndFunc   ;==>_Timer_Diff

; #FUNCTION#;===============================================================================
; Name...........: _Timer_GetIdleTime
; Description ...: Returns the number of ticks since last user activity (i.e. KYBD/Mouse)
; Syntax.........: _Timer_GetIdleTime()
; Parameters ....: None
; Return values .: Success - integer ticks since last (approx. milliseconds) since last activity
;                  Failure - Sets @extended = 1 if rollover occurs (see remarks)
; Author ........: PsaltyDS at http://www.autoitscript.com/forum
; Modified.......:
; Remarks .......: The current ticks since last system restart will roll over to 0 every 50 days or so,
;                  which makes it possible for last user activity to be before the rollover, but run time
;                  of this function to be after the rollover.  If this happens, @extended = 1 and the
;                  returned value is ticks since rollover occured.
; Related .......:
; Link ..........;
; Example .......; Yes
;;==========================================================================================
Func _Timer_GetIdleTime()
	; Get ticks at last activity
	Local $tStruct = DllStructCreate("uint;dword");
	DllStructSetData($tStruct, 1, DllStructGetSize($tStruct));
	DllCall("user32.dll", "int", "GetLastInputInfo", "ptr", DllStructGetPtr($tStruct))

	; Get current ticks since last restart
	Local $avTicks = DllCall("Kernel32.dll", "int", "GetTickCount")

	; Return time since last activity, in ticks (approx milliseconds)
	Local $iDiff = $avTicks[0] - DllStructGetData($tStruct, 2)
	If $iDiff >= 0 Then
		; Normal return
		Return $iDiff
	Else
		; Rollover of ticks counter has occured
		Return SetError(0, 1, $avTicks[0])
	EndIf
EndFunc   ;==>_Timer_GetIdleTime

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_GetTimerID
; Description ...: Returns the Timer ID from $iwParam
; Syntax.........: _Timer_GetTimerID($iwParam)
; Parameters ....: $iwParam - Specifies the timer identifier event.
; Return values .: Success - The Timer ID
;                  Failure - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _Timer_SetTimer
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_GetTimerID($iwParam)
	Local $_iTimerID = Dec(Hex($iwParam, 8)), $iMax = UBound($_Timers_aTimerIDs) - 1
	For $x = 1 To $iMax
		If $_iTimerID = $_Timers_aTimerIDs[$x][1] Then Return $_Timers_aTimerIDs[$x][0]
	Next
	Return 0
EndFunc   ;==>_Timer_GetTimerID

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_Init
; Description ...: Returns a timestamp (in milliseconds).
; Syntax.........: _Timer_Init()
; Parameters ....:
; Return values .: Success - Returns a timestamp number (in milliseconds).
; Author ........: Gary Frost, original by Toady
; Modified.......:
; Remarks .......:
; Related .......: _Timer_Diff
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_Init()
	Return _Timer_QueryPerformanceCounter()
EndFunc   ;==>_Timer_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_KillAllTimers
; Description ...: Destroys all the timers
; Syntax.........: _Timer_KillAllTimers($hWnd)
; Parameters ....: $hWnd        - Handle to the window associated with the timers.
;                  |This value must be the same as the hWnd value passed to the _Timer_SetTimer function that created the timer
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......: Squirrely1
; Remarks .......: The _Timer_KillAllTimers function does not remove WM_TIMER messages already posted to the message queue
; Related .......: _Timer_KillTimer, _Timer_SetTimer
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_KillAllTimers($hWnd)
	Local $iResult, $hCallBack = 0, $iNumTimers = $_Timers_aTimerIDs[0][0]
	If $iNumTimers Then
		For $x = $iNumTimers To 1 Step -1
			If IsHWnd($hWnd) Then
				$iResult = DllCall("user32.dll", "int", "KillTimer", "hwnd", $hWnd, "int", $_Timers_aTimerIDs[$x][1])
				If @error Then Return SetError(-1, -1, False)
			Else
				$iResult = DllCall("user32.dll", "int", "KillTimer", "hwnd", $hWnd, "int", $_Timers_aTimerIDs[$x][0])
				If @error Then Return SetError(-1, -1, False)
			EndIf
			$hCallBack = $_Timers_aTimerIDs[$x][2]
			If $hCallBack <> 0 Then DllCallbackFree($hCallBack)
			$_Timers_aTimerIDs[0][0] -= 1
		Next
		ReDim $_Timers_aTimerIDs[1][3]
	Else
		Return False
	EndIf
	Return $iResult[0] <> 0
EndFunc   ;==>_Timer_KillAllTimers

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_KillTimer
; Description ...: Destroys the specified timer
; Syntax.........: _Timer_KillTimer($hWnd, $iTimerID)
; Parameters ....: $hWnd        - Handle to the window associated with the specified timer.
;                  |This value must be the same as the hWnd value passed to the _Timer_SetTimer function that created the timer
;                  $iTimerID      - Specifies the timer to be destroyed
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......: Squirrely1
; Remarks .......: The _Timer_KillTimer function does not remove WM_TIMER messages already posted to the message queue
; Related .......: _Timer_KillAllTimers, _Timer_SetTimer
; Link ..........; @@MsdnLink@@ KillTimer
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_KillTimer($hWnd, $iTimerID)
	Local $iResult[1] = [0], $hCallBack = 0, $iUBound = UBound($_Timers_aTimerIDs) - 1
	For $x = 1 To $iUBound
		If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
			If IsHWnd($hWnd) Then
				$iResult = DllCall("user32.dll", "int", "KillTimer", "hwnd", $hWnd, "int", $_Timers_aTimerIDs[$x][1])
			Else
				$iResult = DllCall("user32.dll", "int", "KillTimer", "hwnd", $hWnd, "int", $_Timers_aTimerIDs[$x][0])
			EndIf
			If @error Then Return SetError(-1, -1, False)
			If $iResult[0] = 0 Then Return SetError(-1, -1, False)
			$hCallBack = $_Timers_aTimerIDs[$x][2]
			If $hCallBack <> 0 Then DllCallbackFree($hCallBack)
			For $i = $x To $iUBound - 1
				$_Timers_aTimerIDs[$i][0] = $_Timers_aTimerIDs[$i + 1][0]
				$_Timers_aTimerIDs[$i][1] = $_Timers_aTimerIDs[$i + 1][1]
				$_Timers_aTimerIDs[$i][2] = $_Timers_aTimerIDs[$i + 1][2]
			Next
			ReDim $_Timers_aTimerIDs[UBound($_Timers_aTimerIDs - 1)][3]
			$_Timers_aTimerIDs[0][0] -= 1
			ExitLoop
		EndIf
	Next
	Return $iResult[0] <> 0
EndFunc   ;==>_Timer_KillTimer

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Timer_QueryPerformanceCounter
; Description ...: Retrieves the current value of the high-resolution performance counter
; Syntax.........: _Timer_QueryPerformanceCounter()
; Parameters ....:
; Return values .: Success - Current performance-counter value, in counts
;                  Failure - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _Timer_QueryPerformanceFrequency
; Link ..........; @@MsdnLink@@ QueryPerformanceCounter
; Example .......;
; ===============================================================================================================================
Func _Timer_QueryPerformanceCounter()
	Local $tperf = DllStructCreate("int64")
	DllCall("kernel32.dll", "int", "QueryPerformanceCounter", "ptr", DllStructGetPtr($tperf))
	If @error Then Return SetError(-1, -1, -1)
	Return DllStructGetData($tperf, 1)
EndFunc   ;==>_Timer_QueryPerformanceCounter

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Timer_QueryPerformanceFrequency
; Description ...: Retrieves the current value of the high-resolution performance counter
; Syntax.........: _Timer_QueryPerformanceFrequency()
; Parameters ....:
; Return values .: Success - Current performance-counter frequency, in counts per second
;                  Failure - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If the installed hardware does not support a high-resolution performance counter, the return can be zero.
; Related .......: _Timer_QueryPerformanceCounter
; Link ..........; @@MsdnLink@@ QueryPerformanceCounter
; Example .......;
; ===============================================================================================================================
Func _Timer_QueryPerformanceFrequency()
	Local $tperf = DllStructCreate("int64")
	DllCall("kernel32.dll", "int", "QueryPerformanceFrequency", "ptr", DllStructGetPtr($tperf))
	If @error Then Return SetError(-1, -1, 0)
	Return DllStructGetData($tperf, 1)
EndFunc   ;==>_Timer_QueryPerformanceFrequency

; #FUNCTION# ====================================================================================================================
; Name...........: _Timer_SetTimer
; Description ...: Creates a timer with the specified time-out value
; Syntax.........: _Timer_SetTimer($hWnd[, $iElapse = 250[, $sTimerFunc = ""[, $iTimerID = -1]]])
; Parameters ....: $hWnd        - Handle to the window to be associated with the timer.
;                  |This window must be owned by the calling thread
;                  $iElapse     - Specifies the time-out value, in milliseconds
;                  $sTimerFunc  - Function name to be notified when the time-out value elapses
;                  $iTimerID    - Specifies a timer identifier.
;                  |If $iTimerID = -1 then a new timer is created
;                  |If $iTimerID matches an existing timer then the timer is replaced
;                  |If $iTimerID = -1 and $sTimerFunc = "" then timer will use WM_TIMER events
; Return values .: Success - Integer identifying the new timer
;                  Failure - 0
; Author ........: Gary Frost
; Modified.......: Squirrely1
; Remarks .......:
; Related .......: _Timer_KillTimer, _Timer_KillAllTimers, _Timer_GetTimerID
; Link ..........; @@MsdnLink@@ SetTimer
; Example .......; Yes
; ===============================================================================================================================
Func _Timer_SetTimer($hWnd, $iElapse = 250, $sTimerFunc = "", $iTimerID = -1)
	Local $iResult[1], $pTimerFunc = 0, $hCallBack = 0, $iIndex = $_Timers_aTimerIDs[0][0] + 1
	If $iTimerID = -1 Then ; create a new timer
		ReDim $_Timers_aTimerIDs[$iIndex + 1][3]
		$_Timers_aTimerIDs[0][0] = $iIndex
		$iTimerID = $iIndex + 1000
		For $x = 1 To $iIndex
			If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
				$iTimerID = $iTimerID + 1
				$x = 0
			EndIf
		Next
		If $sTimerFunc <> "" Then ; using callbacks, if $sTimerFunc = "" then using WM_TIMER events
			$hCallBack = DllCallbackRegister($sTimerFunc, "none", "hwnd;int;int;dword")
			If $hCallBack = 0 Then Return SetError(-1, -1, 0)
			$pTimerFunc = DllCallbackGetPtr($hCallBack)
			If $pTimerFunc = 0 Then Return SetError(-1, -1, 0)
		EndIf
		$iResult = DllCall("user32.dll", "int", "SetTimer", "hwnd", $hWnd, "int", $iTimerID, "int", $iElapse, "ptr", $pTimerFunc)
		If @error Then Return SetError(-1, -1, 0)
		If $iResult[0] = 0 Then Return SetError(-1, -1, 0)
		$_Timers_aTimerIDs[$iIndex][0] = $iResult[0] ; integer identifier
		$_Timers_aTimerIDs[$iIndex][1] = $iTimerID ; timer id
		$_Timers_aTimerIDs[$iIndex][2] = $hCallBack ; callback identifier, need this for the Kill Timer
	Else ; reuse timer
		For $x = 1 To $iIndex - 1
			If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
				If IsHWnd($hWnd) Then $iTimerID = $_Timers_aTimerIDs[$x][1]
				$hCallBack = $_Timers_aTimerIDs[$x][2]
				If $hCallBack <> 0 Then ; call back was used to create the timer
					$pTimerFunc = DllCallbackGetPtr($hCallBack)
					If $pTimerFunc = 0 Then Return SetError(-1, -1, 0)
				EndIf
				$iResult = DllCall("user32.dll", "int", "SetTimer", "hwnd", $hWnd, "int", $iTimerID, "int", $iElapse, "ptr", $pTimerFunc)
				If @error Then Return SetError(-1, -1, 0)
				If $iResult[0] = 0 Then Return SetError(-1, -1, 0)
				ExitLoop
			EndIf
		Next
	EndIf
	Return $iResult[0]
EndFunc   ;==>_Timer_SetTimer
