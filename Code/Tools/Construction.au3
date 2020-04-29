#include-once

#include "Construction\Environment.au3"
#include "Construction\Tool.au3"
#include "Construction\Render.au3"
#include "Construction\Shape.au3"

Global $__g_HADES_CONSTR_Tools[0]
Global $__g_HADES_CONSTR_Images[0]

Global $__g_HADES_CONSTR_ToolbarFill
Global $__g_HADES_CONSTR_ToolbarSelFill
Global $__g_HADES_CONSTR_PointFill
Global $__g_HADES_CONSTR_PointFillOutline
Global $__g_HADES_CONSTR_PointSelFill
Global $__g_HADES_CONSTR_PointSelFillOutline
Global $__g_HADES_CONSTR_LinePen
Global $__g_HADES_CONSTR_LineGuidePen

Func _HADES_Construction_Setup()
	_HADES_Construction_SetupGfx()
	_HADES_Construction_SetupTools()

	Local $oTG = _HADES_CreateToolGroup("construction", "Construction")

	Local $oCGuides = _HADES_CreateTool("cguides", "Construction guides")
	$oCGuides.data = _HADES_Construction_CreateEnviron()
	$oCGuides.data.tool = $__g_HADES_CONSTR_Tools[0]

	_AutoItObject_AddMethod($oCGuides, "init", "_HADES_Tool_CGuides_Init")
	_AutoItObject_AddMethod($oCGuides, "interact", "_HADES_Tool_CGuides_Interact")
	_AutoItObject_AddMethod($oCGuides, "update", "_HADES_Tool_CGuides_Update")
	_AutoItObject_AddMethod($oCGuides, "render", "_HADES_Tool_CGuides_Render")

	_HADES_AddTool($oTG, $oCGuides)

	_HADES_AddToolGroup($oTG)
EndFunc

Func _HADES_Construction_SetupGfx()
	$__g_HADES_CONSTR_ToolbarFill = _GDIPlus_BrushCreateSolid(0xFF383838)
	$__g_HADES_CONSTR_ToolbarSelFill = _GDIPlus_BrushCreateSolid(0xFF465A6D)
	$__g_HADES_CONSTR_PointFill = _GDIPlus_BrushCreateSolid(0xFF3551FF)
	$__g_HADES_CONSTR_PointFillOutline = _GDIPlus_BrushCreateSolid(0xFF4D00B0)
	$__g_HADES_CONSTR_PointSelFill = _GDIPlus_BrushCreateSolid(0xFF35CCFF)
	$__g_HADES_CONSTR_PointSelFillOutline = _GDIPlus_BrushCreateSolid(0xFF9E002B)

	$__g_HADES_CONSTR_LinePen = _GDIPlus_PenCreate(0xFF808080, 2)
	$__g_HADES_CONSTR_LineGuidePen = _GDIPlus_PenCreate(0x80808080, 1)
	_GDIPlus_PenSetDashStyle($__g_HADES_CONSTR_LineGuidePen, $GDIP_DASHSTYLEDASH)
EndFunc

Func _HADES_Construction_LoadImage($sID)
	Local $iId = _ArrayAdd( _
		$__g_HADES_CONSTR_Images, _
		_GDIPlus_ImageLoadFromFile(@ScriptDir & "\Res\Construction\" & $sID & ".png") _
	)

	Return $__g_HADES_CONSTR_Images[$iId]
EndFunc

Func _HADES_Construction_Exit()
	For $hImg In $__g_HADES_CONSTR_Images
		_GDIPlus_ImageDispose($hImg)
	Next

	_GDIPlus_BrushDispose($__g_HADES_CONSTR_ToolbarFill)
	_GDIPlus_BrushDispose($__g_HADES_CONSTR_ToolbarSelFill)
	_GDIPlus_BrushDispose($__g_HADES_CONSTR_PointFill)
	_GDIPlus_BrushDispose($__g_HADES_CONSTR_PointFillOutline)
	_GDIPlus_BrushDispose($__g_HADES_CONSTR_PointSelFill)
	_GDIPlus_BrushDispose($__g_HADES_CONSTR_PointSelFillOutline)

	_GDIPlus_PenDispose($__g_HADES_CONSTR_LinePen)
	_GDIPlus_PenDispose($__g_HADES_CONSTR_LineGuidePen)
EndFunc

Func _HADES_Tool_CGuides_Init($oTool, $oContext)
	$oTool.data.context = $oContext
EndFunc

Func _HADES_Tool_CGuides_Interact($oTool, $oContext, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iClientX >= 8 And $iClientY >= 8 And $iClientY < 40 And $iClientX < UBound($__g_HADES_CONSTR_Tools) * 32 + 8 And $iMsg = $WM_LBUTTONUP Then
		Local $iTool = Floor(($iClientX - 8) / 32)
		$oContext.tool.data.tool = $__g_HADES_CONSTR_Tools[$iTool]
		$oContext.tool.data.toolData = Null
		$oContext.tool.data.toolPoints = 0
		$oContext.tool.data.toolPoints = LinkedList()
	Else
		$oContext.tool.data.tool.interact($oContext.tool.data, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	EndIf
EndFunc

Func _HADES_Tool_CGuides_Update($oTool, $oContext)
EndFunc

Func _HADES_Tool_CGuides_Render($oTool, $oContext)
	_HADES_Construction_Render($oContext)
EndFunc