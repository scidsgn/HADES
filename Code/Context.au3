#include-once

#include "CoordinateSystem.au3"

Global $__g_HADES_CurrentContext = Null

Func _HADES_GetCurrentContext()
	Return $__g_HADES_CurrentContext
EndFunc

Func _HADES_SetCurrentContext($oContext)
	If IsObj($__g_HADES_CurrentContext) Then _HADES_DestroyContext($__g_HADES_CurrentContext)
	$__g_HADES_CurrentContext = $oContext
EndFunc

Func _HADES_CreateContext($oTool)
	Local $oCtx = _AutoItObject_Create()

	_AutoItObject_AddProperty($oCtx, "coords", $ELSCOPE_PUBLIC, _HADES_GetCoordinateSystem())
	_AutoItObject_AddProperty($oCtx, "viewport", $ELSCOPE_PUBLIC, _HADES_CreateViewport($oCtx))

	_AutoItObject_AddProperty($oCtx, "data", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oCtx, "tool", $ELSCOPE_PUBLIC, $oTool)

	$oTool.init($oCtx)
	$oCtx.viewport.updateUI()

	Return $oCtx
EndFunc

Func _HADES_DestroyContext($oContext)
	_HADES_DestroyViewport($oContext.viewport)
EndFunc