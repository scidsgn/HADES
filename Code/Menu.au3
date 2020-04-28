#include-once

#include <GUIMenu.au3>
#include <GUIConstants.au3>

Global $__g_HADES_Menu
Global $__g_HADES_MenuOwnerHWND

Global $__g_HADES_MenuCommandIDs[0]

Func _HADES_CreateMenu()
	Local $idItem

	$__g_HADES_Menu = _GUICtrlMenu_CreatePopup()
	_HADES_CreateMenuOwnerWindow()

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "HADES")
	_GUICtrlMenu_SetItemDisabled($__g_HADES_Menu, $idItem)

	For $oTG In _HADES_GetToolGroups()
		If IsString($oTG) Then ContinueLoop

		Local $idSubmenu = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, $oTG.name)
		$oTG.subMenu = _GUICtrlMenu_CreateMenu()

		For $oTool IN $oTG.tools
			$iCmdOffset = _ArrayAdd($__g_HADES_MenuCommandIDs, $oTool)
			$idItem = _GUICtrlMenu_AddMenuItem($oTG.subMenu, $oTool.name, 1000 + $iCmdOffset)
		Next

		_GUICtrlMenu_SetItemSubMenu($__g_HADES_Menu, $idSubmenu, $oTG.subMenu)
	Next

	_HADES_RegisterExit(_HADES_DestroyMenu)
EndFunc

Func _HADES_CreateMenuOwnerWindow()
	$__g_HADES_MenuOwnerHWND = GUICreate("HADES Menu Owner", 1, 1, 0, 0, $WS_POPUP, $WS_EX_TRANSPARENT)
	WinSetOnTop($__g_HADES_MenuOwnerHWND, "", True)
	GUIRegisterMsg($WM_COMMAND, _HADES_Menu_WM_COMMAND)
	GUISetState(@SW_HIDE)
EndFunc

Func _HADES_Menu_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	If $hWnd <> $__g_HADES_MenuOwnerHWND Then Return $GUI_RUNDEFMSG

	Local $iCmdID = _WinAPI_LoWord($wParam) - 1000

	If $iCmdID >= 0 And $iCmdID < UBound($__g_HADES_MenuCommandIDs) Then
		_HADES_StartTool($__g_HADES_MenuCommandIDs[$iCmdID])
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc

Func _HADES_ShowMenu()
	Local $hCanvasWnd = _HADES_GetAfDesignCanvasAtXY()
	If Not IsHWnd($hCanvasWnd) Then Return

	WinActivate($__g_HADES_MenuOwnerHWND)
	_GUICtrlMenu_TrackPopupMenu($__g_HADES_Menu, $__g_HADES_MenuOwnerHWND)
EndFunc

Func _HADES_DestroyMenu()
	For $oTG In _HADES_GetToolGroups()
		If IsString($oTG) Then ContinueLoop

		_GUICtrlMenu_DestroyMenu($oTG.subMenu)
	Next

	_GUICtrlMenu_DestroyMenu($__g_HADES_Menu)
	GUIDelete($__g_HADES_MenuOwnerHWND)
EndFunc