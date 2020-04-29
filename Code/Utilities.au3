#include-once

Func _HADES_CreatePoint($iX, $iY)
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "x", $ELSCOPE_PUBLIC, $iX)
	_AutoItObject_AddProperty($oObj, "y", $ELSCOPE_PUBLIC, $iY)

	Return $oObj
EndFunc
