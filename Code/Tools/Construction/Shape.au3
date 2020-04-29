#include-once

Func _HADES_Construction_CreateShape($oPoints, $fnRenderFunc = "_HADES_Construction_Shape_Render")
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "points", $ELSCOPE_PUBLIC, $oPoints)

	_AutoItObject_AddMethod($oObj, "render", $fnRenderFunc)

	Return $oObj
EndFunc

Func _HADES_Construction_Shape_Render($oShape, $oContext)
EndFunc

Func _HADES_Construction_CreateCircleFromDiameterPoints($oPoints)
	Return _HADES_Construction_CreateShape($oPoints, "_HADES_Construction_CircDiam_Render")
EndFunc

Func _HADES_Construction_CircDiam_Render($oShape, $oContext)
	Local $oPt1 = $oShape.points.at(0)
	Local $oPt2 = $oShape.points.at(1)

	Local $fDiameter = Sqrt(($oPt1.x - $oPt2.x)^2 + ($oPt1.y - $oPt2.y)^2)
	Local $iCenterX = ($oPt1.x + $oPt2.x) / 2
	Local $iCenterY = ($oPt1.y + $oPt2.y) / 2

	Local $aCorner = [$iCenterX - $fDiameter / 2, $iCenterY - $fDiameter / 2]
	$aCorner = $oContext.coords.worldToLocal($aCorner)
	$fDiameter *= $oContext.coords.scaleFactor

	Local $hGfx = $oContext.viewport.graphics

	_GDIPlus_GraphicsDrawRect($hGfx, $aCorner[0], $aCorner[1], $fDiameter, $fDiameter, $__g_HADES_CONSTR_LineGuidePen)
	_HADES_Construction_RenderUtil_DrawXHair($hGfx, $aCorner[0] + $fDiameter / 2, $aCorner[1] + $fDiameter / 2)

	_GDIPlus_GraphicsDrawEllipse($hGfx, $aCorner[0], $aCorner[1], $fDiameter, $fDiameter, $__g_HADES_CONSTR_LinePen)
EndFunc