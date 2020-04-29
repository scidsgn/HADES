#include-once

#include "Tools\Test.au3"
#include "Tools\Construction.au3"

Global $__g_HADES_ToolGroups[0]

Func _HADES_StartTool($oTool)
	Local $oCtx = _HADES_CreateContext($oTool)

	_HADES_SetCurrentContext($oCtx)
EndFunc

Func _HADES_GetToolGroups()
	Return $__g_HADES_ToolGroups
EndFunc

Func _HADES_SetupToolGroups()
;~ 	_HADES_Test_Setup()
	_HADES_Construction_Setup()
EndFunc

Func _HADES_CreateToolGroup($sID, $sName)
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "id", $ELSCOPE_PUBLIC, $sID)
	_AutoItObject_AddProperty($oObj, "name", $ELSCOPE_PUBLIC, $sName)
	_AutoItObject_AddProperty($oObj, "subMenu", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddProperty($oObj, "tools", $ELSCOPE_PUBLIC, LinkedList())

	Return $oObj
EndFunc

Func _HADES_AddToolGroup($oTG)
	_ArrayAdd($__g_HADES_ToolGroups, $oTG)
EndFunc

Func _HADES_CreateTool($sID, $sName)
	Local $oObj = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObj, "id", $ELSCOPE_PUBLIC, $sID)
	_AutoItObject_AddProperty($oObj, "name", $ELSCOPE_PUBLIC, $sName)
	_AutoItObject_AddProperty($oObj, "commandID", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddProperty($oObj, "data", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddMethod($oObj, "init", "_HADES_Tool_Generic_Init")
	_AutoItObject_AddMethod($oObj, "interact", "_HADES_Tool_Generic_Interact")
	_AutoItObject_AddMethod($oObj, "update", "_HADES_Tool_Generic_Update")
	_AutoItObject_AddMethod($oObj, "render", "_HADES_Tool_Generic_Render")

	Return $oObj
EndFunc

Func _HADES_AddTool($oTG, $oTool)
	$oTG.tools.add($oTool)
EndFunc

; Placeholders
Func _HADES_Tool_Generic_Init($oTool, $oContext)
EndFunc

Func _HADES_Tool_Generic_Interact($oTool, $oContext, $iMsg, $iClientX, $iClientY, $iWorldX, $iWorldY)
EndFunc

Func _HADES_Tool_Generic_Update($oTool, $oContext)
EndFunc

Func _HADES_Tool_Generic_Render($oTool, $oContext)
EndFunc