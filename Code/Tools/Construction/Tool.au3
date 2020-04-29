#include-once

Func _HADES_Construction_SetupTools()
	_ArrayAdd($__g_HADES_CONSTR_Tools, _HADES_Construction_CreateTool("nothing"))
	_ArrayAdd($__g_HADES_CONSTR_Tools, _HADES_Construction_CreateTool("clear", "_HADES_Construction_Clear_Interact"))
	_ArrayAdd($__g_HADES_CONSTR_Tools, _HADES_Construction_CreateTool("movepoint", "_HADES_Construction_MovePoint_Interact"))
	_ArrayAdd($__g_HADES_CONSTR_Tools, _HADES_Construction_CreateTool("addpoint", "_HADES_Construction_AddPoint_Interact"))
	_ArrayAdd($__g_HADES_CONSTR_Tools, _HADES_Construction_CreateTool("circdiam", "_HADES_Construction_CircDiam_Interact"))
EndFunc

Func _HADES_Construction_CreateTool($sID, $fnInteract = "_HADES_Construction_Generic_Interact")
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "id", $ELSCOPE_PUBLIC, $sID)
	_AutoItObject_AddProperty($oObj, "image", $ELSCOPE_PUBLIC, _HADES_Construction_LoadImage($sID))

	_AutoItObject_AddMethod($oObj, "interact", $fnInteract)

	Return $oObj
EndFunc

Func _HADES_Construction_Generic_Interact($oTool, $oEnviron, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
EndFunc

Func _HADES_Construction_Clear_Interact($oTool, $oEnviron, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iMsg = $WM_LBUTTONUP Then
		$oEnviron.shapes = LinkedList()
		$oEnviron.points = LinkedList()
	EndIf
EndFunc

Func _HADES_Construction_MovePoint_Interact($oTool, $oEnviron, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	Static Local $iLastWorldX = $iWorldX, $iLastWorldY = $iWorldY

	If $iMsg = $WM_LBUTTONDOWN Then
		Local $oPoint = $oEnviron.getNearPoint($iClientX, $iClientY)
		If IsObj($oPoint) Then
			$oEnviron.toolPoints.add($oPoint)
			$oEnviron.context.viewport.setLock(True)
		EndIf
	ElseIf $iMsg = $WM_MOUSEMOVE Then
		If $oEnviron.toolPoints.count() = 1 Then
			Local $oPoint = $oEnviron.toolPoints.at(0)

			$oPoint.x += $iWorldX - $iLastWorldX
			$oPoint.y += $iWorldY - $iLastWorldY
		EndIf
	ElseIf $iMsg = $WM_LBUTTONUP Then
		If $oEnviron.toolPoints.count() = 1 Then
			Local $oPoint = $oEnviron.toolPoints.at(0)

			$oPoint.x += $iWorldX - $iLastWorldX
			$oPoint.y += $iWorldY - $iLastWorldY
		EndIf

		$oEnviron.toolPoints = LinkedList()
		$oEnviron.context.viewport.setLock(False)
	EndIf

	$iLastWorldX = $iWorldX
	$iLastWorldY = $iWorldY
EndFunc

Func _HADES_Construction_AddPoint_Interact($oTool, $oEnviron, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iMsg = $WM_LBUTTONUP Then
		$oEnviron.points.add(_HADES_CreatePoint($iWorldX, $iWorldY))
	EndIf
EndFunc

Func _HADES_Construction_CircDiam_Interact($oTool, $oEnviron, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iMsg = $WM_LBUTTONUP Then
		Local $oPoint = $oEnviron.fetchOrCreatePoint($iClientX, $iClientY)

		If Not $oEnviron.toolPoints.includes($oPoint) Then
			$oEnviron.toolPoints.add($oPoint)

			If $oEnviron.toolPoints.count() = 2 Then
				$oEnviron.shapes.add(_HADES_Construction_CreateCircleFromDiameterPoints($oEnviron.toolPoints))
				$oEnviron.toolPoints = 0
				$oEnviron.toolPoints = LinkedList()
			EndIf
		EndIf
	EndIf
EndFunc