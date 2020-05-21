#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\App icon.ico
#AutoIt3Wrapper_Outfile_x64=HADES.exe
#AutoIt3Wrapper_Res_Description=(h)Affinity Designer Enrichment Suite
#AutoIt3Wrapper_Res_Fileversion=0.1.0.0
#AutoIt3Wrapper_Res_ProductName=HADES
#AutoIt3Wrapper_Res_ProductVersion=0.1.0.0
#AutoIt3Wrapper_Res_CompanyName=sci
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

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

AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayMenuMode", 3)

Global Const $HADES_VERSION = "Alpha 0.1"

_HADES_Startup()

Func _HADES_Startup()
	OnAutoItExitRegister(_HADES_Exit)

	_AutoItObject_Startup(True, @ScriptDir & "\Lib\AutoItObject_x64.dll")
	_GDIPlus_Startup()

	_HADES_CreateCoordinateSystem()
	_HADES_RegisterHook()

	_HADES_SetupToolGroups()
	_HADES_CreateMenu()

	While 1
		If TrayGetMsg() = $__g_HADES_TrayCloseItem Then Exit
		_HADES_AfDesignLocate()
		Sleep(10)
	WEnd
EndFunc
