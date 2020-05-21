#include-once

#include <WinAPIEx.au3>
#include <WindowsConstants.au3>

#include <Misc.au3>

Global Const $tagMSLLHOOKSTRUCT = "long x;long y;dword mouseData;dword flags;dword time;ulong_ptr dwExtraInfo"

Global $__g_HADES_MouseHook, $__g_HADES_MouseHookProc
Global $__g_HADES_KeybHook, $__g_HADES_KeybHookProc

Global $__g_HADES_iLastPosX = Null, $__g_HADES_iLastPosY = Null

Func _HADES_RegisterHook()
	$__g_HADES_MouseHookProc = DLLCallbackRegister(_HADES_ProcessMouseHook, "long", "int;wparam;lparam")
	$__g_HADES_KeybHookProc = DLLCallbackRegister(_HADES_ProcessKeyboardHook, "long", "int;wparam;lparam")
	$hMod = _WinAPI_GetModuleHandle(0)

	$__g_HADES_MouseHook = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, DllCallbackGetPtr($__g_HADES_MouseHookProc), $hMod)
	$__g_HADES_KeybHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($__g_HADES_KeybHookProc), $hMod)

	AdlibRegister(_HADES_ProcessAdlib, 250)

	_HADES_RegisterExit(_HADES_DeregisterHook)
EndFunc

Func _HADES_UpdateMousePos()
	Local $aPos = MouseGetPos()

	$__g_HADES_iLastPosX = $aPos[0]
	$__g_HADES_iLastPosY = $aPos[1]
EndFunc

Func _HADES_GetMouseMove()
	Local $aPos = MouseGetPos()
	Local $aOut = [$aPos[0] - $__g_HADES_iLastPosX, $aPos[1] - $__g_HADES_iLastPosY]

	Return $aOut
EndFunc

Func _HADES_ProcessAdlib()
	Local $oContext = _HADES_GetCurrentContext()

	If IsObj($oContext) Then
		$oContext.tool.update($oContext)
	EndIf
EndFunc

Func _HADES_ProcessKeyboardHook($nCode, $wParam, $lParam)
	Local $tKeybData = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)

	If $wParam = $WM_KEYUP And $tKeybData.flags = $LLKHF_UP Then
		Local $iVKCode = $tKeybData.vkCode
		If $iVKCode = 81 And _IsPressed("11") Then ; Ctrl+Q
			_HADES_ShowMenu()
		EndIf
	EndIf

	Return _WinAPI_CallNextHookEx($__g_HADES_MouseHook, $nCode, $wParam, $lParam)
EndFunc

Func _HADES_ProcessMouseHook($nCode, $wParam, $lParam)
	Local $iMsg = $wParam
	Local $tMouseData = DllStructCreate($tagMSLLHOOKSTRUCT, $lParam)

;~ 	If Not _HADES_IsAfDesignActive() Then
;~ 		Return _WinAPI_CallNextHookEx($__g_HADES_MouseHook, $nCode, $wParam, $lParam)
;~ 	EndIf
	Local $hCanvasWnd = _HADES_GetAfDesignCanvasAtXY()
	Local $oContext = _HADES_GetCurrentContext()
	Local $oCoords = _HADES_GetCoordinateSystem()

	If IsObj($oContext) And $oContext.viewport.locked Then
		$hCanvasWnd = HWnd($oContext.viewport.viewportWnd)
	EndIf

	Local $bLetToolHandle = True

	Switch $iMsg
		Case $WM_MOUSEWHEEL
			; 1 - up
			; -1 - down
			Local $iDirection = _WinAPI_HiWord($tMouseData.mouseData) / 120

			If $hCanvasWnd And IsObj($oCoords) And Not $oCoords.locked Then
				Local $aCoords = _HADES_GetLocalCoords($hCanvasWnd)
				Local $aAfCoords = $oCoords.localToWorld($aCoords)

				If _IsPressed("11") Or _IsPressed("04") Then
					$oCoords.scale($aAfCoords[0], $aAfCoords[1], 1.25^$iDirection)
				ElseIf _IsPressed("10") Then
					$oCoords.translate(30 * $iDirection, 0)
				Else
					$oCoords.translate(0, 30 * $iDirection)
				EndIf

				If IsObj($oContext) Then
					$oContext.tool.update($oContext)
					$oContext.viewport.updateUI()
					$bLetToolHandle = False
				EndIf
			EndIf
		Case $WM_MOUSEMOVE
			If $hCanvasWnd And IsObj($oCoords) And Not $oCoords.locked Then
				If _IsPressed("04") Then
					Local $aMove = _HADES_GetMouseMove()
					$oCoords.translate($aMove[0], $aMove[1])

					If IsObj($oContext) Then
						$oContext.tool.update($oContext)
						$oContext.viewport.updateUI()
						$bLetToolHandle = False
					EndIf
				EndIf
			EndIf
	EndSwitch

	If $hCanvasWnd And IsObj($oContext) And $bLetToolHandle Then
		Local $aCoords = _HADES_GetLocalCoords($hCanvasWnd)
		Local $aWorldCoords = $oContext.coords.localToWorld($aCoords)

		$oContext.tool.interact($oContext, $iMsg, $aCoords[0], $aCoords[1], $aWorldCoords[0], $aWorldCoords[1])
		$oContext.viewport.updateUI()
	EndIf

	_HADES_UpdateMousePos()
	Return _WinAPI_CallNextHookEx($__g_HADES_MouseHook, $nCode, $wParam, $lParam)
EndFunc

Func _HADES_DeregisterHook()
	AdlibUnRegister(_HADES_ProcessAdlib)

	_WinAPI_UnhookWindowsHookEx($__g_HADES_MouseHook)
	DllCallbackFree($__g_HADES_MouseHookProc)

	_WinAPI_UnhookWindowsHookEx($__g_HADES_KeybHook)
	DllCallbackFree($__g_HADES_KeybHookProc)
EndFunc