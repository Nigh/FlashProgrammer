
#SingleInstance ignore
#Include Gdip.ahk
#include serial.ahk
OnExit, ExitAll

OnMessage(0x219, "ON_DEVICECHANGE")
SetFormat, Integer, HEX

#include log.ahk
SetTimer, SerialRead, 150
#include GUI.ahk
ON_DEVICECHANGE(0,0,0,0)
Gosub, init
Return

#include GUI_app.ahk
#include com_scan.ahk

ON_DEVICECHANGE(wp,lp,msg,hwnd)
{
	global ComList,hSerial,LED_OFF,var
	com_scan()
	ComList:=getComList()
	
	if(hSerial.Serial_Port and !InStr(ComList,hSerial.Serial_Port)){
		setLED(LED_OFF)
		hSerial.close()
		hSerial:=""
		GuiControl, , var,
		GuiControl, Disable, var,
	}
	GuiControl, , ComPorts, % ComList
}


_exit:
ExitApp

ExitAll:
hSerial.close()
logDetail.close()
logHandle.close()
ExitApp, 0

_reload:
hSerial.close()
logDetail.close()
logHandle.close()
Reload
