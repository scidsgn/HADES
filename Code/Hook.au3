#include-once

#include <WinAPIEx.au3>
#include <WindowsConstants.au3>

#include <Misc.au3>

Global Const $tagMSLLHOOKSTRUCT = "long x;long y;dword mouseData;dword flags;dword time;ulong_ptr dwExtraInfo"

Global $__g_HADES_Hook, $__g_HADES_HookProc

Global $__g_HADES_iLastPosX = Null, $__g_HADES_iLastPosY = Null

Func _HADES_RegisterHook()
	$__g_HADES_HookProc = DLLCallbackRegister(_HADES_ProcessMouseHook, "long", "int;wparam;lparam")
	$hMod = _WinAPI_GetModuleHandle(0)

	$__g_HADES_Hook = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, DllCallbackGetPtr($__g_HADES_HookProc), $hMod)

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

Func _HADES_ProcessMouseHook($nCode, $wParam, $lParam)
	Local $iMsg = $wParam
	Local $tMouseData = DllStructCreate($tagMSLLHOOKSTRUCT, $lParam)

;~ 	If Not _HADES_IsAfDesignActive() Then
;~ 		Return _WinAPI_CallNextHookEx($__g_HADES_Hook, $nCode, $wParam, $lParam)
;~ 	EndIf
	Local $hCanvasWnd = _HADES_GetAfDesignCanvasAtXY()
	Local $oContext = _HADES_GetCurrentContext()

	Local $bLetToolHandle = True

	Switch $iMsg
		Case $WM_MOUSEWHEEL
			; 1 - up
			; -1 - down
			Local $iDirection = _WinAPI_HiWord($tMouseData.mouseData) / 120

			If $hCanvasWnd And IsObj($oContext) Then
				Local $oCoords = $oContext.coords
				Local $aCoords = _HADES_GetLocalCoords($hCanvasWnd)
				Local $aAfCoords = $oCoords.localToWorld($aCoords)

				If _IsPressed("11") Then
					$oCoords.scale($aAfCoords[0], $aAfCoords[1], 1.25^$iDirection)
				ElseIf _IsPressed("10") Then
					$oCoords.translate(30 * $iDirection, 0)
				Else
					$oCoords.translate(0, 30 * $iDirection)
				EndIf

				$oContext.tool.update($oContext)
				_HADES_UpdateViewportGUI($oContext.viewport)
				$bLetToolHandle = False
			EndIf
		Case $WM_MOUSEMOVE
			If $hCanvasWnd And IsObj($oContext) Then
				Local $oCoords = $oContext.coords

				If _IsPressed("04") Then
					Local $aMove = _HADES_GetMouseMove()
					$oCoords.translate($aMove[0], $aMove[1])

					$oContext.tool.update($oContext)
					_HADES_UpdateViewportGUI($oContext.viewport)
					$bLetToolHandle = False
				Else
					; ..
				EndIf
			EndIf
	EndSwitch

	If $hCanvasWnd And IsObj($oContext) And $bLetToolHandle Then
		Local $oCoords = $oContext.coords
		Local $aCoords = _HADES_GetLocalCoords($hCanvasWnd)
		Local $aWorldCoords = $oContext.coords.localToWorld($aCoords)

		$oContext.tool.interact($oContext, $iMsg, $aCoords[0], $aCoords[1], $aWorldCoords[0], $aWorldCoords[1])
		_HADES_UpdateViewportGUI($oContext.viewport)
	EndIf

	_HADES_UpdateMousePos()
	Return _WinAPI_CallNextHookEx($__g_HADES_Hook, $nCode, $wParam, $lParam)
EndFunc

Func _HADES_DeregisterHook()
	_WinAPI_UnhookWindowsHookEx($__g_HADES_Hook)
	DllCallbackFree($__g_HADES_HookProc)
EndFunc