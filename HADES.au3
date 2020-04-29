#cs

	HADES
	(h)Affinity Designer Enhancement Suite

#ce

#include "Lib\AutoItObject.au3"
#include "Lib\oLinkedList.au3"

#include <GDIPlus.au3>

#include "Code\Cleanup.au3"
#include "Code\Hook.au3"
#include "Code\Affinity.au3"
#include "Code\Context.au3"
#include "Code\ViewportOverlay.au3"
#include "Code\Tools.au3"
#include "Code\Menu.au3"
#include "Code\Utilities.au3"

Global Const $HADES_VERSION = "0.1"

_HADES_Startup()

Func _HADES_Startup()
	OnAutoItExitRegister(_HADES_Exit)

	_AutoItObject_Startup(True, @ScriptDir & "\Lib\AutoItObject_x64.dll")
	_GDIPlus_Startup()

	_HADES_RegisterHook()

	_HADES_SetupToolGroups()
	_HADES_CreateMenu()

	HotKeySet("^q", _HADES_ShowMenu)

	While 1
		_HADES_AfDesignLocate()
		Sleep(10)
	WEnd
EndFunc
