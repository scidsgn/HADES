#include-once

#include "CoordinateSystem.au3"

Global $__g_HADES_CurrentContext = Null

Func _HADES_GetCurrentContext()
	Return $__g_HADES_CurrentContext
EndFunc

Func _HADES_SetCurrentContext($oContext)
	If $__g_HADES_CurrentContext Then _HADES_DestroyContext($__g_HADES_CurrentContext)
	$__g_HADES_CurrentContext = $oContext
EndFunc

Func _HADES_CreateContext($oTool)
	Local $oCtx = _AutoItObject_Create()

	_AutoItObject_AddProperty($oCtx, "data", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oCtx, "tool", $ELSCOPE_PUBLIC, $oTool)


	_AutoItObject_AddProperty($oCtx, "coords", $ELSCOPE_PUBLIC, _HADES_CreateCoordinateSystem())
	_AutoItObject_AddProperty($oCtx, "viewport", $ELSCOPE_PUBLIC, _HADES_CreateViewport($oCtx))

	$oTool.init($oCtx)
	_HADES_UpdateViewportGUI($oCtx.viewport)

	Return $oCtx
EndFunc

Func _HADES_DestroyContext($oContext)
	_HADES_DestroyViewport($oContext.viewport)
EndFunc