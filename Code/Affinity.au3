#include-once

#include <WinAPISysWin.au3>

Global $__g_HADES_AfDesignHWND = Null
Global $__g_HADES_AfDesignCanvasHWND = Null

Func _HADES_AfDesignLocate()
	Local $aWndList = WinList("Affinity Designer")
	Local $sAffinityCN = "HwndWrapper[Designer.exe;"

	For $i = 1 To $aWndList[0][0]
		Local $hWnd = $aWndList[$i][1]
		If StringLeft(_WinAPI_GetClassName($hWnd), StringLen($sAffinityCN)) == $sAffinityCN Then
			If $__g_HADES_AfDesignHWND = Null Then
				$__g_HADES_AfDesignHWND = $hWnd
				Return True
			EndIf
		EndIf
	Next

	If IsHWnd($__g_HADES_AfDesignHWND) Then
		$__g_HADES_AfDesignHWND = Null
	EndIf

	Return False
EndFunc

Func _HADES_GetAfDesignCanvasAtXY()
	Local $aPos = MouseGetPos()
	; Slightly offset - a hack to make sure AfDesign's default ctx menu isn't caught
	Local $tPoint = _WinAPI_CreatePoint($aPos[0] - 3, $aPos[1] - 3)
	Local $hWnd = _WinAPI_WindowFromPoint($tPoint)

	If Int($__g_HADES_AfDesignCanvasHWND) = Int($hWnd) Then Return HWnd($hWnd)

	If Int(_WinAPI_GetParent($hWnd)) = Int($__g_HADES_AfDesignHWND) And _WinAPI_GetClassName($hWnd) = "Static" Then
		$__g_HADES_AfDesignCanvasHWND = $hWnd
		Return HWnd($hWnd)
	EndIf

	Return Null
EndFunc

Func _HADES_GetLocalCoords($hCanvasWnd)
	Local $aPos = MouseGetPos()
	Local $tPoint = _WinAPI_CreatePoint($aPos[0], $aPos[1])
	_WinAPI_ScreenToClient($hCanvasWnd, $tPoint)

	Local $aOut = [$tPoint.x, $tPoint.y]

	Return $aOut
EndFunc

Func _HADES_GetScreenCoords($hCanvasWnd, $aCoords)
	Local $tPoint = _WinAPI_CreatePoint($aCoords[0], $aCoords[1])
	_WinAPI_ClientToScreen($hCanvasWnd, $tPoint)

	Local $aOut = [$tPoint.x, $tPoint.y]

	Return $aOut
EndFunc

Func _HADES_IsAfDesignActive()
	If $__g_HADES_AfDesignHWND = Null Then Return False

	Local $hActive = _WinAPI_GetForegroundWindow()
	If $hActive = $__g_HADES_AfDesignHWND Then Return True

	Local $hRoot = _WinAPI_GetAncestor($hActive, $GA_ROOT)
	If $hRoot = $__g_HADES_AfDesignHWND Then Return True

	Return False
EndFunc