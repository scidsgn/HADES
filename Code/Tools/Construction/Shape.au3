#include-once

Func _HADES_Construction_CreateShape($oPoints, $fnRenderFunc = "_HADES_Construction_Shape_Render")
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "points", $ELSCOPE_PUBLIC, $oPoints)

	_AutoItObject_AddMethod($oObj, "render", $fnRenderFunc)

	Return $oObj
EndFunc

Func _HADES_Construction_Shape_Render($oShape, $oContext)
EndFunc