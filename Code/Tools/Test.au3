#include-once

Func _HADES_Test_Setup()
	Local $oTG = _HADES_CreateToolGroup("test", "Test")

	Local $oTool1 = _HADES_CreateTool("ttool1", "Draw Some Points, K?")
	_HADES_AddTool($oTG, $oTool1)

	_HADES_AddToolGroup($oTG)
EndFunc