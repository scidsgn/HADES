#include-once

Func _HADES_Construction_Render($oContext)
	Local $hGfx = $oContext.viewport.graphics

	_GDIPlus_GraphicsClear($hGfx, 0)

	Local $iToolX = 8
	For $oTool In $__g_HADES_CONSTR_Tools
		Local $hBrush = $__g_HADES_CONSTR_ToolbarFill
		If $oContext.tool.data.tool = $oTool Then $hBrush = $__g_HADES_CONSTR_ToolbarSelFill

		_GDIPlus_GraphicsFillRect($hGfx, $iToolX, 8, 32, 32, $hBrush)
		_GDIPlus_GraphicsDrawImageRect($hGfx, $oTool.image, $iToolX, 8, 32, 32)

		$iToolX += 32
	Next

	For $oShape In $oContext.tool.data.shapes
		$oShape.render($oContext)
	Next

	For $oPoint In $oContext.tool.data.points
		Local $aWorld = [$oPoint.x, $oPoint.y]
		Local $aLocal = $oContext.coords.worldToLocal($aWorld)

		_GDIPlus_GraphicsFillEllipse($hGfx, $aLocal[0] - 6, $aLocal[1] - 6, 12, 12, $__g_HADES_CONSTR_PointFillOutline)
		_GDIPlus_GraphicsFillEllipse($hGfx, $aLocal[0] - 4, $aLocal[1] - 4, 8, 8, $__g_HADES_CONSTR_PointFill)
	Next

	For $oPoint In $oContext.tool.data.toolPoints
		Local $aWorld = [$oPoint.x, $oPoint.y]
		Local $aLocal = $oContext.coords.worldToLocal($aWorld)

		_GDIPlus_GraphicsFillEllipse($hGfx, $aLocal[0] - 6, $aLocal[1] - 6, 12, 12, $__g_HADES_CONSTR_PointSelFillOutline)
		_GDIPlus_GraphicsFillEllipse($hGfx, $aLocal[0] - 4, $aLocal[1] - 4, 8, 8, $__g_HADES_CONSTR_PointSelFill)
	Next
EndFunc

Func _HADES_Construction_RenderUtil_DrawXHair($hGfx, $iX, $iY, $hPen = 0)
	_GDIPlus_GraphicsDrawLine($hGfx, $iX - 8, $iY, $iX + 8, $iY, $hPen)
	_GDIPlus_GraphicsDrawLine($hGfx, $iX, $iY - 8, $iX, $iY + 8, $hPen)
EndFunc