#include-once

Func _HADES_CreateCoordinateSystem()
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "originX", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObj, "originY", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObj, "scaleFactor", $ELSCOPE_PUBLIC, 1)

	_AutoItObject_AddMethod($oObj, "localToWorld", "__HCS_LocalToWorld")
	_AutoItObject_AddMethod($oObj, "worldToLocal", "__HCS_WorldToLocal")

	_AutoItObject_AddMethod($oObj, "translate", "__HCS_Translate")
	_AutoItObject_AddMethod($oObj, "scale", "__HCS_Scale")

	Return $oObj
EndFunc

Func __HCS_LocalToWorld($oSelf, $aCoords)
	Local $iX = ($aCoords[0] - $oSelf.originX) / $oSelf.scaleFactor + $oSelf.originX
	Local $iY = ($aCoords[1] - $oSelf.originY) / $oSelf.scaleFactor + $oSelf.originY

	Local $aOut = [$iX, $iY]

	Return $aOut
EndFunc

Func __HCS_WorldToLocal($oSelf, $aCoords)
	Local $iX = ($aCoords[0] - $oSelf.originX) * $oSelf.scaleFactor + $oSelf.originX
	Local $iY = ($aCoords[1] - $oSelf.originY) * $oSelf.scaleFactor + $oSelf.originY

	Local $aOut = [$iX, $iY]

	Return $aOut
EndFunc

Func __HCS_Translate($oSelf, $dX, $dY)
	$oSelf.originX += $dX / $oSelf.scaleFactor
	$oSelf.originY += $dY / $oSelf.scaleFactor
EndFunc

Func __HCS_Scale($oSelf, $iX, $iY, $fScale)
	$oSelf.originX = ($oSelf.originX - $iX) * $fScale + $iX
	$oSelf.originY = ($oSelf.originY - $iY) * $fScale + $iY
	$oSelf.scaleFactor *= $fScale
EndFunc