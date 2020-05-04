#include-once

Func _HADES_WCAG_Setup()
	Local $oTG = _HADES_CreateToolGroup("wcag", "WCAG")

	Local $oWCAG = _HADES_CreateTool("wcag", "WCAG 2.1 contrast ratio")
	_AutoItObject_AddMethod($oWCAG, "init", "_HADES_Tool_WCAG_Init")
	_AutoItObject_AddMethod($oWCAG, "uninit", "_HADES_Tool_WCAG_UnInit")
	_AutoItObject_AddMethod($oWCAG, "interact", "_HADES_Tool_WCAG_Interact")
	_AutoItObject_AddMethod($oWCAG, "update", "_HADES_Tool_WCAG_Update")
	_AutoItObject_AddMethod($oWCAG, "render", "_HADES_Tool_WCAG_Render")
	_HADES_AddTool($oTG, $oWCAG)

	_HADES_AddToolGroup($oTG)
EndFunc

Func _HADES_Tool_WCAG_Init($oTool, $oContext)
	Local $hWCAGUI = GUICreate("WCAG contrast", 200, 178, 8, 8, $WS_POPUP, $WS_EX_MDICHILD, HWnd($oContext.viewport.viewportWnd))
	GUISetBkColor(0x111111)
	GUICtrlSetDefBkColor(0x111111)
	GUICtrlSetDefColor(0xFFFFFF)
	GUISetFont(10, 400, 0, "Segoe UI")

	$cidRatio = GUICtrlCreateLabel("21:1", 0, 0, 200, 50, $SS_CENTER)
	GUICtrlSetFont(-1, 28, 700)

	$cidColor1 = GUICtrlCreateLabel("", 0, 50, 100, 30)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateLabel("Ctrl+Click", 0, 80, 100, 20, $SS_CENTER)
	$cidColor2 = GUICtrlCreateLabel("", 100, 50, 100, 30)
	GUICtrlSetBkColor(-1, 0x000000)
	GUICtrlCreateLabel("Ctrl+Shift+Click", 100, 80, 100, 20, $SS_CENTER)

	GUICtrlCreateLabel("Level", 8, 108, 100, 20)
	GUICtrlSetColor(-1, 0x808080)
	GUICtrlCreateLabel("General", 8, 130, 100, 20)
	GUICtrlSetFont(-1, 10, 700)
	GUICtrlCreateLabel("Large text", 8, 150, 100, 20)
	GUICtrlSetFont(-1, 10, 700)

	GUICtrlCreateLabel("AA", 108, 108, 42, 20, $SS_CENTER)
	GUICtrlCreateLabel("AAA", 150, 108, 42, 20, $SS_CENTER)

	$cidAAGeneral = GUICtrlCreateLabel("", 108, 130, 42, 20, $SS_CENTER)
	$cidAAAGeneral = GUICtrlCreateLabel("", 150, 130, 42, 20, $SS_CENTER)
	$cidAALarge = GUICtrlCreateLabel("", 108, 150, 42, 20, $SS_CENTER)
	$cidAAALarge = GUICtrlCreateLabel("", 150, 150, 42, 20, $SS_CENTER)

	_HADES_Tool_WCAG_SetGrade($cidAAGeneral, True)
	_HADES_Tool_WCAG_SetGrade($cidAAAGeneral, True)
	_HADES_Tool_WCAG_SetGrade($cidAALarge, True)
	_HADES_Tool_WCAG_SetGrade($cidAAALarge, True)

	GUISetState()

	Local $oData = _AutoItObject_Create()

	_AutoItObject_AddProperty($oData, "window", $ELSCOPE_PUBLIC, Int($hWCAGUI))

	_AutoItObject_AddProperty($oData, "color1", $ELSCOPE_PUBLIC, 0xFFFFFF)
	_AutoItObject_AddProperty($oData, "color2", $ELSCOPE_PUBLIC, 0x000000)

	_AutoItObject_AddProperty($oData, "ctrlRatio", $ELSCOPE_PUBLIC, $cidRatio)
	_AutoItObject_AddProperty($oData, "ctrlColor1", $ELSCOPE_PUBLIC, $cidColor1)
	_AutoItObject_AddProperty($oData, "ctrlColor2", $ELSCOPE_PUBLIC, $cidColor2)
	_AutoItObject_AddProperty($oData, "ctrlAAGen", $ELSCOPE_PUBLIC, $cidAAGeneral)
	_AutoItObject_AddProperty($oData, "ctrlAAAGen", $ELSCOPE_PUBLIC, $cidAAAGeneral)
	_AutoItObject_AddProperty($oData, "ctrlAALarge", $ELSCOPE_PUBLIC, $cidAALarge)
	_AutoItObject_AddProperty($oData, "ctrlAAALarge", $ELSCOPE_PUBLIC, $cidAAALarge)

	$oContext.data = $oData
EndFunc

Func _HADES_Tool_WCAG_SetGrade($cidCtrl, $bPass)
	GUICtrlSetColor($cidCtrl, 0)

	If $bPass Then
		GUICtrlSetData($cidCtrl, "Pass")
		GUICtrlSetBkColor($cidCtrl, 0x32FF32)
	Else
		GUICtrlSetData($cidCtrl, "Fail")
		GUICtrlSetBkColor($cidCtrl, 0xFF674F)
	EndIf
EndFunc

Func _HADES_Tool_WCAG_sRGBToLinear($fChannel)
	If $fChannel <= 0.03928 Then Return $fChannel / 12.92
	Return (($fChannel + 0.055) / 1.055) ^ 2.4
EndFunc

Func _HADES_Tool_WCAG_CalcRelativeLum($iColor)
	Local $fRed = BitAND(BitShift($iColor, 16), 0xFF) / 255
	Local $fGreen = BitAND(BitShift($iColor, 8), 0xFF) / 255
	Local $fBlue = BitAND($iColor, 0xFF) / 255

	Local $fLRed = _HADES_Tool_WCAG_sRGBToLinear($fRed)
	Local $fLGreen = _HADES_Tool_WCAG_sRGBToLinear($fGreen)
	Local $fLBlue = _HADES_Tool_WCAG_sRGBToLinear($fBlue)

	Return 0.2126 * $fLRed + 0.7152 * $fLGreen + 0.0722 * $fLBlue
EndFunc

Func _HADES_Tool_WCAG_CalcContrastRatio($iColor1, $iColor2)
	Local $fL1 = _HADES_Tool_WCAG_CalcRelativeLum($iColor1)
	Local $fL2 = _HADES_Tool_WCAG_CalcRelativeLum($iColor2)

	Local $fLMax = _Max($fL1, $fL2)
	Local $fLMin = _Min($fL1, $fL2)

	Return ($fLMax + 0.05) / ($fLMin + 0.05)
EndFunc

Func _HADES_Tool_WCAG_UpdateUI($oData)
	GUISwitch(HWnd($oData.window))

	GUICtrlSetBkColor($oData.ctrlColor1, $oData.color1)
	GUICtrlSetBkColor($oData.ctrlColor2, $oData.color2)

	Local $fContrast = _HADES_Tool_WCAG_CalcContrastRatio($oData.color1, $oData.color2)

	Local $sFormattedContrast = String(Round($fContrast * 1000) / 1000) & ":1"
	GUICtrlSetData($oData.ctrlRatio, $sFormattedContrast)

	_HADES_Tool_WCAG_SetGrade($oData.ctrlAAGen, $fContrast >= 4.5)
	_HADES_Tool_WCAG_SetGrade($oData.ctrlAAAGen, $fContrast >= 7)
	_HADES_Tool_WCAG_SetGrade($oData.ctrlAALarge, $fContrast >= 3)
	_HADES_Tool_WCAG_SetGrade($oData.ctrlAAALarge, $fContrast >= 4.5)
EndFunc

Func _HADES_Tool_WCAG_UnInit($oTool, $oContext)
	GUIDelete(HWnd($oContext.data.window))
EndFunc

Func _HADES_Tool_WCAG_Interact($oTool, $oContext, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
	If $iMsg = $WM_LBUTTONUP Then
		Local $aPos = MouseGetPos()
		Local $iColor = PixelGetColor($aPos[0], $aPos[1])

		If _IsPressed("11") Then
			If _IsPressed("10") Then
				$oContext.data.color2 = $iColor
			Else
				$oContext.data.color1 = $iColor
			EndIf

			_HADES_Tool_WCAG_UpdateUI($oContext.data)
		EndIf
	EndIf
EndFunc

Func _HADES_Tool_WCAG_Update($oTool, $oContext)
EndFunc

Func _HADES_Tool_WCAG_Render($oTool, $oContext)
EndFunc