#include-once

Func _HADES_CreateViewport($oCtx)
	Local $hCanvasWnd = _HADES_GetAfDesignCanvas()

	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "context", $ELSCOPE_PUBLIC, $oCtx)

	_AutoItObject_AddProperty($oObj, "canvasWnd", $ELSCOPE_PUBLIC, Int($hCanvasWnd))

	_AutoItObject_AddProperty($oObj, "bitmap", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObj, "graphics", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddProperty($oObj, "viewportWnd", $ELSCOPE_PUBLIC, _HADES_CreateViewportGUI($oObj))

	Return $oObj
EndFunc

Func _HADES_CreateViewportGUI($oVp)
	Local $aPos = WinGetPos(HWnd($oVp.canvasWnd))
	Local $hWnd = GUICreate("HADES Viewport", $aPos[2], $aPos[3], $aPos[0], $aPos[1], $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TRANSPARENT, HWnd($oVp.canvasWnd))

	GUISetState()

	$oVp.bitmap = Int(_GDIPlus_BitmapCreateFromScan0($aPos[2], $aPos[3]))
	$oVp.graphics = Int(_GDIPlus_ImageGetGraphicsContext($oVp.bitmap))
	_GDIPlus_GraphicsSetSmoothingMode($oVp.graphics, 2)

	Return Int($hWnd)
EndFunc

Func _HADES_DestroyViewport($oVp)
	GUIDelete(HWnd($oVp.viewportWnd))

	_GDIPlus_GraphicsDispose($oVp.graphics)
	_GDIPlus_BitmapDispose($oVp.bitmap)
EndFunc

; 2 things in the universe are constant:
; - the 40-day unlimited trial of winrar
; - everyone copying the alphablend example code
Func _HADES_UpdateViewportGUI($oVp)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend

	Local $hWnd = HWnd($oVp.viewportWnd)
	Local $aPos = WinGetPos($hWnd)

	$oVp.context.tool.render($oVp.context)

	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($oVp.bitmap)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", $aPos[2])
	DllStructSetData($tSize, "Y", $aPos[3])
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", 255)
	DllStructSetData($tBlend, "Format", 1)
	_WinAPI_UpdateLayeredWindow($hWnd, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc