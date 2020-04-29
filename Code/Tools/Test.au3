#include-once

Func _HADES_Test_Setup()
	Local $oTG = _HADES_CreateToolGroup("test", "Test")

	Local $oBBox = _HADES_CreateTool("bbox", "Bounding box test")
	_AutoItObject_AddMethod($oBBox, "init", "_HADES_Tool_BBox_Init")
	_AutoItObject_AddMethod($oBBox, "interact", "_HADES_Tool_BBox_Interact")
	_AutoItObject_AddMethod($oBBox, "update", "_HADES_Tool_BBox_Update")
	_AutoItObject_AddMethod($oBBox, "render", "_HADES_Tool_BBox_Render")
	_HADES_AddTool($oTG, $oBBox)

	_HADES_AddToolGroup($oTG)
EndFunc

Func _HADES_Tool_BBox_Init($oTool, $oContext)
EndFunc

Func _HADES_Tool_BBox_Interact($oTool, $oContext, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iMsg = $WM_LBUTTONUP Then
		$oContext.coords.forceContainRect(100, 100, 200, 200)
	EndIf
EndFunc

Func _HADES_Tool_BBox_Update($oTool, $oContext)
EndFunc

Func _HADES_Tool_BBox_Render($oTool, $oContext)
	$hGfx = $oContext.viewport.graphics

	_GDIPlus_GraphicsClear($hGfx, 0)

	Local $aCoords = [100, 100]
	Local $fScale = $oContext.coords.scaleFactor

	$aCoords = $oContext.coords.worldToLocal($aCoords)

	_GDIPlus_GraphicsFillEllipse($hGfx, $aCoords[0], $aCoords[1], 200 * $fScale, 200 * $fScale)
EndFunc