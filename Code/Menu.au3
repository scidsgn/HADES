#include-once

#include <GUIMenu.au3>
#include <GUIConstants.au3>

Global $__g_HADES_Menu
Global $__g_HADES_CoordsSubMenu
Global $__g_HADES_AppSubMenu
Global $__g_HADES_MenuOwnerHWND
Global $__g_HADES_MenuStopToolID

Global $__g_HADES_MenuCommandIDs[0]
Global $__g_HADES_MenuBitmaps[0]

Global Enum $HADES_MID_EXITHADES = 1000, _
			$HADES_MID_STOPTOOL

Func _HADES_CreateMenu()
	Local $idItem, $bFirst = True

	$__g_HADES_Menu = _GUICtrlMenu_CreatePopup()
	_HADES_CreateMenuOwnerWindow()

	$__g_HADES_MenuStopToolID = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "Stop current HADES tool", $HADES_MID_STOPTOOL)
	_GUICtrlMenu_SetItemBmp($__g_HADES_Menu, $__g_HADES_MenuStopToolID, _HADES_LoadMenuBitmap("stopcurrent"))

	Local $idCoordsSubmenu = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "Coordinate space")
	_GUICtrlMenu_SetItemBmp($__g_HADES_Menu, $idCoordsSubmenu, _HADES_LoadMenuBitmap("coords"))
	$__g_HADES_CoordsSubMenu = _GUICtrlMenu_CreateMenu()

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_CoordsSubMenu, "Freeze")
	_GUICtrlMenu_SetItemBmp($__g_HADES_CoordsSubMenu, $idItem, _HADES_LoadMenuBitmap("freezexy"))

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_CoordsSubMenu, "Reposition coordinates")
	_GUICtrlMenu_SetItemBmp($__g_HADES_CoordsSubMenu, $idItem, _HADES_LoadMenuBitmap("resetxy"))

	_GUICtrlMenu_SetItemSubMenu($__g_HADES_Menu, $idCoordsSubmenu, $__g_HADES_CoordsSubMenu)

	_GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "")

	For $oTG In _HADES_GetToolGroups()
		If IsString($oTG) Then ContinueLoop

		If $oTG.tools.count() = 1 Then
			$oTool = $oTG.tools.at(0)

			If Not $bFirst Then _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "")

			$iCmdOffset = _ArrayAdd($__g_HADES_MenuCommandIDs, $oTool)
			$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, $oTool.name, 1100 + $iCmdOffset)
			_GUICtrlMenu_SetItemBmp($__g_HADES_Menu, $idItem, _HADES_LoadMenuBitmap($oTool.id))

			$bFirst = False
			ContinueLoop
		EndIf

		Local $idSubmenu = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, $oTG.name)
		$oTG.subMenu = _GUICtrlMenu_CreateMenu()

		For $oTool IN $oTG.tools
			$iCmdOffset = _ArrayAdd($__g_HADES_MenuCommandIDs, $oTool)
			$idItem = _GUICtrlMenu_AddMenuItem($oTG.subMenu, $oTool.name, 1100 + $iCmdOffset)
		Next

		_GUICtrlMenu_SetItemSubMenu($__g_HADES_Menu, $idSubmenu, $oTG.subMenu)

		$bFirst = False
	Next

	_GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "")

	;$HADES_VERSION
	Local $idHadesSubmenu = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "HADES...")
	_GUICtrlMenu_SetItemBmp($__g_HADES_Menu, $idHadesSubmenu, _HADES_LoadMenuBitmap("hades"))
	$__g_HADES_AppSubMenu = _GUICtrlMenu_CreateMenu()

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_AppSubMenu, "HADES v" & $HADES_VERSION)
	_GUICtrlMenu_SetItemDisabled($__g_HADES_AppSubMenu, $idItem)
	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_AppSubMenu, "(h)Affinity Designer Enhancement Suite")
	_GUICtrlMenu_SetItemDisabled($__g_HADES_AppSubMenu, $idItem)
	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_AppSubMenu, "by sci")
	_GUICtrlMenu_SetItemDisabled($__g_HADES_AppSubMenu, $idItem)

	_GUICtrlMenu_AddMenuItem($__g_HADES_AppSubMenu, "")

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_AppSubMenu, "Close HADES", $HADES_MID_EXITHADES)

	_GUICtrlMenu_SetItemSubMenu($__g_HADES_Menu, $idHadesSubmenu, $__g_HADES_AppSubMenu)

	_HADES_RegisterExit(_HADES_DestroyMenu)
EndFunc

Func _HADES_CreateMenuOwnerWindow()
	$__g_HADES_MenuOwnerHWND = GUICreate("HADES Menu Owner", 1, 1, 0, 0, $WS_POPUP, $WS_EX_TRANSPARENT)
	GUIRegisterMsg($WM_COMMAND, _HADES_Menu_WM_COMMAND)
	GUISetState(@SW_HIDE)
EndFunc

Func _HADES_Menu_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	If $hWnd <> $__g_HADES_MenuOwnerHWND Then Return $GUI_RUNDEFMSG

	Local $iCmdID = _WinAPI_LoWord($wParam)

	Switch $iCmdID
		Case $HADES_MID_EXITHADES
			Exit
		Case $HADES_MID_STOPTOOL
			_HADES_SetCurrentContext(Null)
		Case Else
			$iCmdID -= 1100

			If $iCmdID >= 0 And $iCmdID < UBound($__g_HADES_MenuCommandIDs) Then
				_HADES_StartTool($__g_HADES_MenuCommandIDs[$iCmdID])
			EndIf
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc

Func _HADES_ShowMenu()
	Local $hCanvasWnd = _HADES_GetAfDesignCanvasAtXY()
	If Not IsHWnd($hCanvasWnd) Then Return

	If IsObj(_HADES_GetCurrentContext()) Then
		_GUICtrlMenu_SetItemEnabled($__g_HADES_Menu, $__g_HADES_MenuStopToolID)
	Else
		_GUICtrlMenu_SetItemDisabled($__g_HADES_Menu, $__g_HADES_MenuStopToolID)
	EndIf

	WinActivate($__g_HADES_MenuOwnerHWND)
	_GUICtrlMenu_TrackPopupMenu($__g_HADES_Menu, $__g_HADES_MenuOwnerHWND)
EndFunc

Func _HADES_LoadMenuBitmap($sID)
	Local $hImg = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Res\Icons\" & $sID & ".png")
	Local $hBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImg)

	_ArrayAdd($__g_HADES_MenuBitmaps, $hBmp)

	_GDIPlus_ImageDispose($hImg)

	Return $hBmp
EndFunc

Func _HADES_DestroyMenu()
	For $oTG In _HADES_GetToolGroups()
		If IsString($oTG) Then ContinueLoop

		_GUICtrlMenu_DestroyMenu($oTG.subMenu)
	Next

	For $hBmp In $__g_HADES_MenuBitmaps
		_WinAPI_DeleteObject($hBmp)
	Next

	_GUICtrlMenu_DestroyMenu($__g_HADES_CoordsSubMenu)
	_GUICtrlMenu_DestroyMenu($__g_HADES_AppSubMenu)
	_GUICtrlMenu_DestroyMenu($__g_HADES_Menu)
	GUIDelete($__g_HADES_MenuOwnerHWND)
EndFunc