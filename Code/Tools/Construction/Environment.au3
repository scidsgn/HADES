#include-once

Func _HADES_Construction_CreateEnviron()
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "context", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddProperty($oObj, "shapes", $ELSCOPE_PUBLIC, LinkedList())
	_AutoItObject_AddProperty($oObj, "points", $ELSCOPE_PUBLIC, LinkedList())

	_AutoItObject_AddProperty($oObj, "tool", $ELSCOPE_PUBLIC, Null)
	_AutoItObject_AddProperty($oObj, "toolData", $ELSCOPE_PUBLIC, Null)
	_AutoItObject_AddProperty($oObj, "toolPoints", $ELSCOPE_PUBLIC, LinkedList())

	_AutoItObject_AddMethod($oObj, "fetchOrCreatePoint", "_HADES_Construction_Environ_FetchOrCreatePoint")
	_AutoItObject_AddMethod($oObj, "getNearPoint", "_HADES_Construction_Environ_GetNearPoint")

	Return $oObj
EndFunc

Func _HADES_Construction_Environ_FetchOrCreatePoint($oEnviron, $iClientX, $iClientY)
	Local $oCoords = $oEnviron.context.coords
	Local $oExistingPoint = $oEnviron.getNearPoint($iClientX, $iClientY)
	If IsObj($oExistingPoint) Then Return $oExistingPoint

	Local $aXY = [$iClientX, $iClientY]
	$aXY = $oCoords.localToWorld($aXY)

	Local $oPoint = _HADES_CreatePoint($aXY[0], $aXY[1])
	$oEnviron.points.add($oPoint)

	Return $oPoint
EndFunc

Func _HADES_Construction_Environ_GetNearPoint($oEnviron, $iClientX, $iClientY)
	Local $oCoords = $oEnviron.context.coords
	For $oPoint In $oEnviron.points
		Local $aXY = [$oPoint.x, $oPoint.y]
		$aXY = $oCoords.worldToLocal($aXY)

		Local $iDist = Sqrt(($iClientX - $aXY[0])^2 + ($iClientY - $aXY[1])^2)
		If $iDist < 8 Then Return $oPoint
	Next

	Return Null
EndFunc