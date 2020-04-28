#include-once

#include <GUIMenu.au3>

Global $__g_HADES_Menu
Global $__g_HADES_MenuOwnerHWND

Func _HADES_CreateMenu()
	Local $idItem

	$__g_HADES_Menu = _GUICtrlMenu_CreatePopup()
	_HADES_CreateMenuOwnerWindow()

	$idItem = _GUICtrlMenu_AddMenuItem($__g_HADES_Menu, "HADES")
	_GUICtrlMenu_SetItemDisabled($__g_HADES_Menu, $idItem)

	_HADES_RegisterExit(_HADES_DestroyMenu)
EndFunc

Func _HADES_CreateMenuOwnerWindow()
	$__g_HADES_MenuOwnerHWND = GUICreate("HADES Menu Owner", 40, 40, 0, 0, $WS_POPUP, $WS_EX_TRANSPARENT)
	GUISetBkColor(0xFF0000)
	WinSetOnTop($__g_HADES_MenuOwnerHWND, "", True)
	GUISetState()
EndFunc

Func _HADES_ShowMenu()
	Local $hCanvasWnd = _HADES_GetAfDesignCanvasAtXY()
	If Not IsHWnd($hCanvasWnd) Then Return

	WinActivate($__g_HADES_MenuOwnerHWND)
	_GUICtrlMenu_TrackPopupMenu($__g_HADES_Menu, $__g_HADES_MenuOwnerHWND)
EndFunc

Func _HADES_DestroyMenu()
	_GUICtrlMenu_DestroyMenu($__g_HADES_Menu)
	GUIDelete($__g_HADES_MenuOwnerHWND)
EndFunc