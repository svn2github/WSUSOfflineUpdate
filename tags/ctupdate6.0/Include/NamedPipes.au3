#include-once
#include <WinAPI.au3>
#include <StructureConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: Pipes
; AutoIt Version: 3.2.3++
; Language:       English
; Description ...: A named pipe is a named, one-way or duplex pipe for communication between the pipe server and one or more pipe
;                  clients.  All instances of a named pipe share the same pipe name, but each instance has its  own  buffers  and
;                  handles, and provides a separate conduit for  client  server  communication.  The  use  of  instances  enables
;                  multiple pipe clients to use the same named pipe simultaneously.  Any process can access named pipes,  subject
;                  to security checks, making named pipes an easy form of communication between related or  unrelated  processes.
;                  Any process can act as both a server and a client, making peer-to-peer communication possible.  As used  here,
;                  the term pipe server refers to a process that creates a named pipe, and the  term  pipe  client  refers  to  a
;                  process that connects to an instance of a named pipe. Named pipes can be used to provide communication between
;                  processes on the same computer or between processes on different computers across a  network.  If  the  server
;                  service is running, all named pipes are accessible remotely.
; Author ........: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000
Global Const $FILE_FLAG_OVERLAPPED = 0x40000000
Global Const $FILE_FLAG_WRITE_THROUGH = 0x80000000

Global Const $PIPE_ACCESS_INBOUND = 0x00000001
Global Const $PIPE_ACCESS_OUTBOUND = 0x00000002
Global Const $PIPE_ACCESS_DUPLEX = 0x00000003

Global Const $PIPE_WAIT = 0x00000000
Global Const $PIPE_NOWAIT = 0x00000001

Global Const $PIPE_READMODE_BYTE = 0x00000000
Global Const $PIPE_READMODE_MESSAGE = 0x00000002

Global Const $PIPE_TYPE_BYTE = 0x00000000
Global Const $PIPE_TYPE_MESSAGE = 0x00000004

Global Const $PIPE_CLIENT_END = 0x00000000
Global Const $PIPE_SERVER_END = 0x00000001

Global Const $WRITE_DAC = 0x00040000
Global Const $WRITE_OWNER = 0x00080000
Global Const $ACCESS_SYSTEM_SECURITY = 0x01000000
; ===============================================================================================================================

;==============================================================================================================================
; #CURRENT# =====================================================================================================================
;_NamedPipes_CallNamedPipe
;_NamedPipes_ConnectNamedPipe
;_NamedPipes_CreateNamedPipe
;_NamedPipes_CreatePipe
;_NamedPipes_DisconnectNamedPipe
;_NamedPipes_GetNamedPipeHandleState
;_NamedPipes_GetNamedPipeInfo
;_NamedPipes_PeekNamedPipe
;_NamedPipes_SetNamedPipeHandleState
;_NamedPipes_TransactNamedPipe
;_NamedPipes_WaitNamedPipe
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;
;==============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CallNamedPipe
; Description ...: Performs a read/write operation on a named pipe
; Syntax.........: _NamedPipes_CallNamedPipe($sPipeName, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, ByRef $iRead[, $iTimeOut = 0])
; Parameters ....: $sPipeName   - Pipe name
;                  $pInpBuf     - Pointer to the buffer containing the data written to the pipe
;                  $iInpSize    - Size of the write buffer, in bytes
;                  $pOutBuf     - Pointer to the buffer that receives the data read from the pipe
;                  $iOutSize    - Size of the read buffer, in bytes
;                  $iRead       - On return, contains the number of bytes read from the pipe
;                  $iTimeOut    - Number of milliseconds to wait for the named pipe to  be  available.  In  addition  to  numeric
;                  +values, the following special values can be specified:
;                  |-1 - Wait indefinitely
;                  | 0 - Uses the default time-out specified in the call to the CreateNamedPipe
;                  | 1 - Do not wait. If the pipe is not available, return an error
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Calling CallNamedPipe is equivalent to calling the CreateFile (or WaitNamedPipe,  if  CreateFile  cannot  open
;                  the pipe immediately), TransactNamedPipe, and CloseHandle functions.  CreateFile is called with an access flag
;                  of GENERIC_READ | GENERIC_WRITE, and an inherit handle flag of False.  CallNamedPipe fails if the  pipe  is  a
;                  byte-type pipe.
; Related .......: _NamedPipes_WaitNamedPipe, _NamedPipes_TransactNamedPipe
; Link ..........; @@MsdnLink@@ CallNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_CallNamedPipe($sPipeName, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, ByRef $iRead, $iTimeOut = 0)
	Local $tRead, $aResult

	$tRead = DllStructCreate("int Data")
	$aResult = DllCall("Kernel32.dll", "int", "CallNamedPipe", "str", $sPipeName, "ptr", $pInpBuf, "int", $iInpSize, "ptr", $pOutBuf, _
			"int", $iOutSize, "ptr", DllStructGetPtr($tRead), "int", $iTimeOut)
	$iRead = DllStructGetData($tRead, "Data")
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_CallNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_ConnectNamedPipe
; Description ...: Enables a named pipe server process to wait for a client process to connect
; Syntax.........: _NamedPipes_ConnectNamedPipe($hNamedPipe[, $pOverlapped = 0])
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure.  If hNamedPipe  was  opened  with  $FILE_FLAG_OVERLAPPED,
;                  +pOverlapped must not be 0. If hNamedPipe was created with $FILE_FLAG_OVERLAPPED and pOverlapped is not 0, the
;                  +$tagOVERLAPPED structure should contain a handle to a manual reset event object.  If hNamedPipe was not opened
;                  +with $FILE_FLAG_OVERLAPPED, the function does not return until a client is  connected  or  an  error  occurs.
;                  +Successful synchronous operations result in the function returning a nonzero value if a client connects after
;                  +the function is called.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If a client connects before the function is called, the function returns zero  and  GetLastError  will  return
;                  ERROR_PIPE_CONNECTED. This can happen if a client connects in the interval between the call to CreateNamedPipe
;                  and the call to ConnectNamedPipe. In this situation, there is a good connection between client and server even
;                  though the function returns zero.
; Related .......: _NamedPipes_CreateNamedPipe, $tagOVERLAPPED
; Link ..........; @@MsdnLink@@ ConnectNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_ConnectNamedPipe($hNamedPipe, $pOverlapped = 0)
	Local $aResult

	$aResult = DllCall("Kernel32.dll", "int", "ConnectNamedPipe", "int", $hNamedPipe, "ptr", $pOverlapped)
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_ConnectNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CreateNamedPipe
; Description ...: Creates an instance of a named pipe
; Syntax.........: _NamedPipes_CreateNamedPipe($sName[, $iAccess = 2[, $iFlags = 2[, $iACL = 0[, $iType = 1[, $iRead = 1[, $iWait = 0[, $iMaxInst = 25[, $iOutBufSize = 4096[, $iInpBufSize = 4096[, $iDefTimeout = 5000[, $pSecurity = 0]]]]]]]]]]])
; Parameters ....: $sName       - Pipe name with the following format: \\.\pipe\pipename.  The pipename  part  of  the  name  can
;                  +include any character other than a backslash, including numbers and special characters.  The pipe name string
;                  +can be up to 256 characters long. Pipe names are not case sensitive.
;                  $iAccess     - The pipe access mode. Must be one of the following:
;                  |0 - The flow of data in the pipe goes from client to server only (inbound)
;                  |1 - The flow of data in the pipe goes from server to client only (outbound)
;                  |2 - The pipe is bi-directional (duplex)
;                  $iFlags      - The pipe flags. Can be any combination of the following:
;                  |1 - If you attempt to create multiple instances of a pipe with this flag,  creation  of  the  first  instance
;                  +succeeds, but creation of the next instance fails.
;                  |2 - Overlapped mode is enabled. If this mode  is  enabled  functions  performing  read,  write,  and  connect
;                  +operations that may take a significant time to be completed can return immediately.
;                  |4 - Write-through mode is enabled. This mode affects only write operations on byte type pipes and  only  when
;                  +the client and server are on different computers.
;                  $iACL        - Security ACL flags. Can be any combination of the following:
;                  |1 - The caller will have write access to the named pipe's discretionary ACL
;                  |2 - The caller will have write access to the named pipe's owner
;                  |4 - The caller will have write access to the named pipe's security ACL
;                  $iType       - Pipe type mode. Must be one of the following:
;                  |0 - Data is written to the pipe as a stream of bytes
;                  |1 - Data is written to the pipe as a stream of messages
;                  $Read        - Pipe read mode. Must be one of the following:
;                  |0 - Data is read from the pipe as a stream of bytes
;                  |1 - Data is read from the pipe as a stream of messages
;                  $iWait       - Pipe wait mode. Must be one of the following:
;                  |0 - Blocking mode is enabled.  When the pipe handle is specified in ReadFile, WriteFile, or ConnectNamedPipe,
;                  +the operation is not completed until there is data to read, all data is written, or a client is connected.
;                  |1 - Nonblocking mode is enabled. ReadFile, WriteFile, and ConnectNamedPipe always return immediately.
;                  $iMaxInst    - The maximum number of instances that can be created for this pipe
;                  $iOutBufSize - The number of bytes to reserve for the output buffer
;                  $iInpBufSize - The number of bytes to reserve for the input buffer
;                  $iDefTimeOut - The default time out value, in milliseconds
;                  $pSecurity   - A pointer to a tagSECURITY_ATTRIBUTES structure that specifies a security  descriptor  for  the
;                  +new named pipe and determines whether child processes can inherit the returned handle. If pSecurity is 0, the
;                  +named pipe gets a default security descriptor and the handle cannot be inherited.  The ACLs  in  the  default
;                  +security descriptor for a named pipe grant full control to the LocalSystem account  administrators,  and  the
;                  +creator owner. They also grant read access to members of the Everyone group and the anonymous account.
; Return values .: Success      - Handle to the server end of a named pipe instance
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_ConnectNamedPipe
; Link ..........; @@MsdnLink@@ CreateNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_CreateNamedPipe($sName, $iAccess = 2, $iFlags = 2, $iACL = 0, $iType = 1, $iRead = 1, $iWait = 0, $iMaxInst = 25, _
		$iOutBufSize = 4096, $iInpBufSize = 4096, $iDefTimeout = 5000, $pSecurity = 0)
	Local $iOpenMode, $iPipeMode, $aResult

	Switch $iAccess
		Case 1
			$iOpenMode = $PIPE_ACCESS_OUTBOUND
		Case 2
			$iOpenMode = $PIPE_ACCESS_DUPLEX
		Case Else
			$iOpenMode = $PIPE_ACCESS_INBOUND
	EndSwitch
	If BitAND($iFlags, 1) <> 0 Then $iOpenMode = BitOR($iOpenMode, $FILE_FLAG_FIRST_PIPE_INSTANCE)
	If BitAND($iFlags, 2) <> 0 Then $iOpenMode = BitOR($iOpenMode, $FILE_FLAG_OVERLAPPED)
	If BitAND($iFlags, 4) <> 0 Then $iOpenMode = BitOR($iOpenMode, $FILE_FLAG_WRITE_THROUGH)

	If BitAND($iACL, 1) <> 0 Then $iOpenMode = BitOR($iOpenMode, $WRITE_DAC)
	If BitAND($iACL, 2) <> 0 Then $iOpenMode = BitOR($iOpenMode, $WRITE_OWNER)
	If BitAND($iACL, 4) <> 0 Then $iOpenMode = BitOR($iOpenMode, $ACCESS_SYSTEM_SECURITY)

	Switch $iType
		Case 1
			$iPipeMode = $PIPE_TYPE_MESSAGE
		Case Else
			$iPipeMode = $PIPE_TYPE_BYTE
	EndSwitch

	Switch $iRead
		Case 1
			$iPipeMode = BitOR($iPipeMode, $PIPE_READMODE_MESSAGE)
		Case Else
			$iPipeMode = BitOR($iPipeMode, $PIPE_READMODE_BYTE)
	EndSwitch

	Switch $iWait
		Case 1
			$iPipeMode = BitOR($iPipeMode, $PIPE_NOWAIT)
		Case Else
			$iPipeMode = BitOR($iPipeMode, $PIPE_WAIT)
	EndSwitch

	$aResult = DllCall("Kernel32.dll", "int", "CreateNamedPipe", "str", $sName, "int", $iOpenMode, "int", $iPipeMode, "int", $iMaxInst, _
			"int", $iOutBufSize, "int", $iInpBufSize, "int", $iDefTimeout, "ptr", $pSecurity)
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0])
EndFunc   ;==>_NamedPipes_CreateNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CreatePipe
; Description ...: Creates an anonymous pipe
; Syntax.........: _NamedPipes_CreatePipe(ByRef $hReadPipe, ByRef $hWritePipe[, $tSecurity = 0[, $iSize = 0]])
; Parameters ....: $hReadPipe   - Variable that receives the read handle for the pipe
;                  $hWritePipe  - Variable that receives the write handle for the pipe
;                  $tSecurity   - tagSECURITY_ATTRIBUTES structure that determines if the returned handle  can  be  inherited  by
;                  +child processes. If 0, the handles cannot be inherited.
;                  $iSize       - The size of the buffer for the pipe, in bytes. If 0, the system uses the default buffer size.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_CreateNamedPipe
; Link ..........; @@MsdnLink@@ CreatePipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_CreatePipe(ByRef $hReadPipe, ByRef $hWritePipe, $tSecurity = 0, $iSize = 0)
	Local $pSecurity, $tPipes, $aResult

	If $tSecurity <> 0 Then $pSecurity = DllStructGetPtr($tSecurity)
	$tPipes = DllStructCreate("ptr Read;ptr Write")
	$aResult = DllCall("Kernel32.dll", "int", "CreatePipe", "ptr", DllStructGetPtr($tPipes, "Read"), "ptr", _
			DllStructGetPtr($tPipes, "Write"), "ptr", $pSecurity, "uint", $iSize)
	_WinAPI_Check("_NamedPipes_CreatePipe", $aResult[0] = 0, 0, True)
	$hReadPipe = DllStructGetData($tPipes, "Read")
	$hWritePipe = DllStructGetData($tPipes, "Write")
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_CreatePipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_DisconnectNamedPipe
; Description ...: Disconnects the server end of a named pipe instance from a client process
; Syntax.........: _NamedPipes_DisconnectNamedPipe($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the client end of the named pipe is open, the DisconnectNamedPipe function forces that  end  of  the  named
;                  pipe closed.  The client receives an error the next time it attempts to access the  pipe.  A  client  that  is
;                  forced off a pipe must still use the CloseHandle function to close its end of the pipe.
; Related .......:
; Link ..........; @@MsdnLink@@ DisconnectNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_DisconnectNamedPipe($hNamedPipe)
	Local $aResult

	$aResult = DllCall("Kernel32.dll", "int", "DisconnectNamedPipe", "int", $hNamedPipe)
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_DisconnectNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_GetNamedPipeHandleState
; Description ...: Retrieves information about a specified named pipe
; Syntax.........: _NamedPipes_GetNamedPipeHandleState($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance
; Return values .: Success      - Array with the following format:
;                  |$aState[0] - True if pipe handle is in nonblocking mode, otherwise blocking mode
;                  |$aState[1] - True if pipe handle is in message-read mode, otherwise byte read mode
;                  |$aState[2] - Number of current pipe instances
;                  |$aState[3] - Maximum number of bytes to be collected on the client's computer before transmission
;                  |$aState[4] - Maximum time, in milliseconds, that can pass before a remote named  pipe  transfers  information
;                  +over the network.
;                  |$aState[5] - User name string associated with the client application.  The  server  can  only  retrieve  this
;                  +information if the client opened the pipe with the SECURITY_IMPERSONATION access privilige.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_SetNamedPipeHandleState
; Link ..........; @@MsdnLink@@ GetNamedPipeHandleState
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_GetNamedPipeHandleState($hNamedPipe)
	Local $tBuffer, $tInt, $pState, $pCurInst, $pMaxCount, $pTimeOut, $aState[6]

	$tInt = DllStructCreate("int State;int CurInst;int MaxCount;int TimeOut")
	$pState = DllStructGetPtr($tInt, "State")
	$pCurInst = DllStructGetPtr($tInt, "CurInst")
	$pMaxCount = DllStructGetPtr($tInt, "MaxCount")
	$pTimeOut = DllStructGetPtr($tInt, "TimeOut")
	$tBuffer = DllStructCreate("char Text[4096]")

	DllCall("Kernel32.dll", "int", "GetNamedPipeHandleState", "int", $hNamedPipe, "ptr", $pState, "ptr", $pCurInst, "ptr", _
			$pMaxCount, "ptr", $pTimeOut, "ptr", DllStructGetPtr($tBuffer), "int", 4096)
	$aState[0] = BitAND(DllStructGetData($tInt, "State"), $PIPE_NOWAIT) <> 0
	$aState[1] = BitAND(DllStructGetData($tInt, "State"), $PIPE_READMODE_MESSAGE) <> 0
	$aState[2] = DllStructGetData($tInt, "CurInst")
	$aState[3] = DllStructGetData($tInt, "MaxCount")
	$aState[4] = DllStructGetData($tInt, "TimeOut")
	$aState[5] = DllStructGetData($tBuffer, "Text")
	Return SetError(_WinAPI_GetLastError(), 0, $aState)
EndFunc   ;==>_NamedPipes_GetNamedPipeHandleState

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_GetNamedPipeInfo
; Description ...: Retrieves information about the specified named pipe
; Syntax.........: _NamedPipes_GetNamedPipeInfo($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the named pipe instance. The handle must have GENERIC_READ access to the named pipe
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - True if handle refers to server end, otherwise client end
;                  |$aInfo[1] - True for a message pipe, otherwise byte pipe
;                  |$aInfo[2] - Size of the buffer for outgoing data, in bytes
;                  |$aInfo[3] - Size of the buffer for incoming data, in bytes
;                  |$aInfo[4] - Maximum number of pipe instances that can be created
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ GetNamedPipeInfo
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_GetNamedPipeInfo($hNamedPipe)
	Local $tInt, $pFlags, $pOutSize, $pInpSize, $pMaxInst, $aInfo[5]

	$tInt = DllStructCreate("int Flags;int OutSize;int InpSize;int MaxInst")
	$pFlags = DllStructGetPtr($tInt, "Flags")
	$pOutSize = DllStructGetPtr($tInt, "OutSize")
	$pInpSize = DllStructGetPtr($tInt, "InpSize")
	$pMaxInst = DllStructGetPtr($tInt, "MaxInst")

	DllCall("Kernel32.dll", "int", "GetNamedPipeInfo", "int", $hNamedPipe, "ptr", $pFlags, "ptr", $pOutSize, "ptr", $pInpSize, _
			"ptr", $pMaxInst)
	$aInfo[0] = BitAND(DllStructGetData($tInt, "Flags"), $PIPE_SERVER_END) <> 0
	$aInfo[1] = BitAND(DllStructGetData($tInt, "Flags"), $PIPE_TYPE_MESSAGE) <> 0
	$aInfo[2] = DllStructGetData($tInt, "OutSize")
	$aInfo[3] = DllStructGetData($tInt, "InpSize")
	$aInfo[4] = DllStructGetData($tInt, "MaxInst")
	Return SetError(_WinAPI_GetLastError(), 0, $aInfo)
EndFunc   ;==>_NamedPipes_GetNamedPipeInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_PeekNamedPipe
; Description ...: Copies data from a pipe into a buffer without removing it from the pipe
; Syntax.........: _NamedPipes_PeekNamedPipe($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the pipe
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - Data read from the pipe
;                  |$aInfo[1] - Bytes read from the pipe
;                  |$aInfo[2] - Total bytes available to be read
;                  |$aInfo[3] - Bytes remaining to be read for this message
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ PeekNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_PeekNamedPipe($hNamedPipe)
	Local $pBuffer, $tBuffer, $tInt, $pRead, $pTotal, $pLeft, $aInfo[4]

	$tInt = DllStructCreate("int Read;int Total;int Left")
	$pRead = DllStructGetPtr($tInt, "Read")
	$pTotal = DllStructGetPtr($tInt, "Total")
	$pLeft = DllStructGetPtr($tInt, "Left")
	$tBuffer = DllStructCreate("char Text[4096]")
	$pBuffer = DllStructGetPtr($tBuffer)

	DllCall("Kernel32.dll", "int", "PeekNamedPipe", "int", $hNamedPipe, "ptr", $pBuffer, "int", 4096, "ptr", $pRead, "ptr", $pTotal, "ptr", $pLeft)
	$aInfo[0] = DllStructGetData($tBuffer, "Text")
	$aInfo[1] = DllStructGetData($tInt, "Read")
	$aInfo[2] = DllStructGetData($tInt, "Total")
	$aInfo[3] = DllStructGetData($tInt, "Left")
	Return SetError(_WinAPI_GetLastError(), 0, $aInfo)
EndFunc   ;==>_NamedPipes_PeekNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_SetNamedPipeHandleState
; Description ...: Sets the read mode and the blocking mode of the specified named pipe
; Syntax.........: _NamedPipes_SetNamedPipeHandleState($hNamedPipe, $iRead, $iWait[, $iBytes = 0[, $iTimeOut = 0]])
; Parameters ....: $hNamedPipe  - Handle to the named pipe instance
;                  $iRead       - Pipe read mode. Must be one of the following:
;                  |0 - Data is read from the pipe as a stream of bytes
;                  |1 - Data is read from the pipe as a stream of messages
;                  $iWait       - Pipe wait mode. Must be one of the following:
;                  |0 - Blocking mode is enabled
;                  |1 - Nonblocking mode is enabled
;                  $iBytes      - Maximum number of bytes collected on the client computer before transmission to the server
;                  $iTimeout     - Maximum time, in milliseconds, that can pass before a remote named pipe transfers information
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_GetNamedPipeHandleState
; Link ..........; @@MsdnLink@@ SetNamedPipeHandleState
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_SetNamedPipeHandleState($hNamedPipe, $iRead, $iWait, $iBytes = 0, $iTimeOut = 0)
	Local $iMode, $tInt, $pMode, $pBytes, $pTimeOut, $aResult

	$tInt = DllStructCreate("int Mode;int Bytes;int Timeout")
	$pMode = DllStructGetPtr($tInt, "Mode")
	If $iRead = 1 Then $iMode = BitOR($iMode, $PIPE_READMODE_MESSAGE)
	If $iWait = 1 Then $iMode = BitOR($iMode, $PIPE_NOWAIT)
	DllStructSetData($tInt, "Mode", $iMode)

	If $iBytes <> 0 Then
		$pBytes = DllStructGetPtr($tInt, "Bytes")
		DllStructSetData($tInt, "Bytes", $iBytes)
	EndIf

	If $iTimeOut <> 0 Then
		$pTimeOut = DllStructGetPtr($tInt, "TimeOut")
		DllStructSetData($tInt, "TimeOut", $iTimeOut)
	EndIf

	$aResult = DllCall("Kernel32.dll", "int", "SetNamedPipeHandleState", "int", $hNamedPipe, "ptr", $pMode, "ptr", $pBytes, "ptr", $pTimeOut)
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_SetNamedPipeHandleState

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_TransactNamedPipe
; Description ...: Reads and writes to a named pipe in one network operation
; Syntax.........: _NamedPipes_TransactNamedPipe($hNamedPipe, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize[, $pOverlapped = 0])
; Parameters ....: $hNamedPipe  - The handle to the named pipe
;                  $pInpBuf     - Pointer to the buffer containing the data to be written to the pipe
;                  $iInpSize    - Size of the write buffer, in bytes
;                  $pOutBuf     - Pointer to the buffer that receives the data read from the pipe
;                  $iOutSize    - Size of the read buffer, in bytes
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure.  This structure is required if hNamedPipe was opened with
;                  +$FILE_FLAG_OVERLAPPED. If hNamedPipe was opened with $FILE_FLAG_OVERLAPPED, pOverlapped must  not  be  0.  If
;                  +hNamedPipe was opened with $FILE_FLAG_OVERLAPPED and pOverlapped is not 0, TransactNamedPipe is  executed  as
;                  +an overlapped operation. The $tagOVERLAPPED structure should contain a  manual  reset  event  object.  If  the
;                  +operation cannot be completed immediately, TransactNamedPipe  returns  False  and  GetLastError  will  return
;                  +ERROR_IO_PENDING.
; Return values .: Success      - Number of bytes read from the pipe
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: TransactNamedPipe fails if the server did not create the pipe as a message-type pipe or if the pipe handle  is
;                  not in message-read mode.
; Related .......: $tagOVERLAPPED
; Link ..........; @@MsdnLink@@ TransactNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_TransactNamedPipe($hNamedPipe, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, $pOverlapped = 0)
	Local $pRead, $tRead

	$tRead = DllStructCreate("int Data")
	$pRead = DllStructGetPtr($tRead)
	DllCall("Kernel32.dll", "int", "TransactNamedPipe", "int", $hNamedPipe, "ptr", $pInpBuf, "int", $iInpSize, _
			"ptr", $pOutBuf, "int", $iOutSize, "ptr", $pRead, "ptr", $pOverlapped)
	Return SetError(_WinAPI_GetLastError(), 0, DllStructGetData($tRead, "Data"))
EndFunc   ;==>_NamedPipes_TransactNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_WaitNamedPipe
; Description ...: Waits for an instance of a named pipe to become available
; Syntax.........: _NamedPipes_WaitNamedPipe($sPipeName[, $iTimeOut = 0])
; Parameters ....: $sPipeName   - The name of the named pipe.  The string must include the name of  the  computer  on  which  the
;                  +server process is executing. A period may be used for the servername if the pipe is local.
;                  $iTimeout    - The number of milliseconds that the function will wait for the named pipe to be available.  You
;                  +can also use one of the following values:
;                  |-1 - The function does not return until an instance of the named pipe is available
;                  | 0 - The time-out interval is the default value specified by the server process
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If no instances of the specified named pipe exist the WaitNamedPipe function returns immediately
; Related .......:
; Link ..........; @@MsdnLink@@ WaitNamedPipe
; Example .......;
; ===============================================================================================================================
Func _NamedPipes_WaitNamedPipe($sPipeName, $iTimeOut = 0)
	Local $aResult

	$aResult = DllCall("Kernel32.dll", "int", "WaitNamedPipe", "str", $sPipeName, "int", $iTimeOut)
	Return SetError(_WinAPI_GetLastError(), 0, $aResult[0] <> 0)
EndFunc   ;==>_NamedPipes_WaitNamedPipe
