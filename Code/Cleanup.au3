#include-once

#include <Array.au3>

Global $__g_HADES_ExitQueue[0]

Func _HADES_RegisterExit($fnFunc)
	_ArrayAdd($__g_HADES_ExitQueue, $fnFunc)
EndFunc

Func _HADES_Exit()
	For $fnFunc in $__g_HADES_ExitQueue
		Call($fnFunc)
	Next

	Local $oCtx = _HADES_GetCurrentContext()
	If IsObj($oCtx) Then _HADES_DestroyContext($oCtx)

	_GDIPlus_Shutdown()
	_AutoItObject_Shutdown()
EndFunc