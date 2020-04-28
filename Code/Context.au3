#include-once

#include "CoordinateSystem.au3"

Global $__g_HADES_CurrentContext = Null

Func _HADES_GetCurrentContext()
	Return $__g_HADES_CurrentContext
EndFunc

Func _HADES_SetCurrentContext($oContext)
	$__g_HADES_CurrentContext = $oContext
EndFunc

Func _HADES_CreateContext()
	Local $oCtx = _AutoItObject_Create()

	_AutoItObject_AddProperty($oCtx, "coords", $ELSCOPE_PUBLIC, _HADES_CreateCoordinateSystem())

	Return $oCtx
EndFunc