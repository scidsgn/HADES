#include-once

#include <Math.au3>

Func _HADES_CreateCoordinateSystem($oCtx)
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "context", $ELSCOPE_PUBLIC, $oCtx)

	_AutoItObject_AddProperty($oObj, "locked", $ELSCOPE_PUBLIC, False)

	_AutoItObject_AddProperty($oObj, "originX", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObj, "originY", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObj, "scaleFactor", $ELSCOPE_PUBLIC, 1)

	_AutoItObject_AddMethod($oObj, "localToWorld", "__HCS_LocalToWorld")
	_AutoItObject_AddMethod($oObj, "worldToLocal", "__HCS_WorldToLocal")

	_AutoItObject_AddMethod($oObj, "translate", "__HCS_Translate")
	_AutoItObject_AddMethod($oObj, "scale", "__HCS_Scale")

	_AutoItObject_AddMethod($oObj, "forceContainRect", "__HCS_ForceContainRect")

	Return $oObj
EndFunc

Func __HCS_ForceContainRect($oCoords, $iX, $iY, $iWidth, $iHeight)
	Local $aVpPos = WinGetPos(HWnd($oCoords.context.viewport.canvasWnd))

	Local $aMousePos = MouseGetPos()

	Local $aXY = [$iX, $iY]
	Local $fScale = $oCoords.scaleFactor
	$aXY = $oCoords.worldToLocal($aXY)

	$iWidth *= $fScale
	$iHeight *= $fScale

	If $iWidth > $aVpPos[2] Or $iHeight > $aVpPos[3] Then
		Local $fWRatio = $iWidth / $aVpPos[2]
		Local $fHRatio = $iHeight / $aVpPos[3]

		Local $fRatio = _Max($fWRatio, $fHRatio)
		Local $fTicks = Ceiling(Log($fRatio) / Log(1.25))

		$aMousePos[0] -= $aVpPos[0]
		$aMousePos[1] -= $aVpPos[1]
		$aMousePos = $oCoords.localToWorld($aMousePos)

		$oCoords.locked = True
		MouseDown("middle")
		MouseWheel("down", $fTicks)
		MouseUp("middle")
		$oCoords.locked = False

		$oCoords.scale($aMousePos[0], $aMousePos[1], 0.8^$fTicks)

		$iWidth *= 0.8^$fTicks
		$iHeight *= 0.8^$fTicks
	EndIf

	Local $dX = 0, $dY = 0
	Local $bRequiresReadjustment = False

	If $aXY[0] < 0 Then
		$dX = -$aXY[0] + 4
	ElseIf $aXY[0] + $iWidth >= $aVpPos[2] Then
		$dX =  $aVpPos[2] - ($aXY[0] + $iWidth) - 4
	EndIf

	If $aXY[1] < 0 Then
		$dY = -$aXY[0] + 4
	ElseIf $aXY[1] + $iHeight >= $aVpPos[3] Then
		$dY =  $aVpPos[3] - ($aXY[1] + $iHeight) - 4
	EndIf

	If $dX = 0 And $dY = 0 Then Return
	If Abs($dX) > $aVpPos[2] Or Abs($dY) > $aVpPos[3] Then
		Local $fRatio = 1

		If _Max(Abs($dX), Abs($dY)) = $dX Then
			$fRatio = $aVpPos[2] / Abs($dX)
		Else
			$fRatio = $aVpPos[3] / Abs($dY)
		EndIf

		$dX /= $fRatio
		$dY /= $fRatio

		$bRequiresReadjustment = True
	EndIf

	Local $iDragStartX = ($dX < 0) ? -$dX : 0
	Local $iDragStartY = ($dY < 0) ? -$dY : 0

	$oCoords.locked = True
	MouseClickDrag("middle", $aVpPos[0] + $iDragStartX, $aVpPos[1] + $iDragStartY, $aVpPos[0] + $iDragStartX + $dX, $aVpPos[1] + $iDragStartY + $dY, 1)
	$oCoords.locked = False

	$oCoords.translate($dX, $dY)

	MouseMove($aMousePos[0], $aMousePos[1], 0)

	If $bRequiresReadjustment Then $oCoords.forceContainRect($iX, $iY, $iWidth, $iHeight)
EndFunc

Func __HCS_LocalToWorld($oSelf, $aCoords)
	Local $iX = ($aCoords[0] - $oSelf.originX) / $oSelf.scaleFactor
	Local $iY = ($aCoords[1] - $oSelf.originY) / $oSelf.scaleFactor

	Local $aOut = [$iX, $iY]

	Return $aOut
EndFunc

Func __HCS_WorldToLocal($oSelf, $aCoords, $bForceInteger = False)
	Local $iX = $aCoords[0] * $oSelf.scaleFactor + $oSelf.originX
	Local $iY = $aCoords[1] * $oSelf.scaleFactor + $oSelf.originY

	If $bForceInteger Then
		$iX = Int($iX)
		$iY = Int($iY)
	EndIf

	Local $aOut = [$iX, $iY]

	Return $aOut
EndFunc

Func __HCS_Translate($oSelf, $dX, $dY)
	If $oSelf.locked Then Return

	$oSelf.originX += $dX
	$oSelf.originY += $dY
EndFunc

Func __HCS_Scale($oSelf, $iX, $iY, $fScale)
	If $oSelf.locked Then Return

	Local $fNewScale = $fScale * $oSelf.scaleFactor

	Local $originX = $oSelf.originX + $oSelf.scaleFactor * $iX - $fNewScale * $iX
	Local $originY = $oSelf.originY + $oSelf.scaleFactor * $iY - $fNewScale * $iY

	$oSelf.originX = $originX
	$oSelf.originY = $originY
	$oSelf.scaleFactor = $fNewScale
EndFunc