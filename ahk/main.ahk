
#SingleInstance ignore
#Include Gdip.ahk
#include serial.ahk
OnExit, ExitAll



OnMessage(0x219, "ON_DEVICECHANGE")
SetFormat, Integer, HEX

; if(hSerial!=""){
; 	hSerial.close()
; }
; hSerial:=new Serial("COM7")
; hSerial.begin("115200")
; sHandle:=fileOpen(hSerial.__handle,"h")

#include log.ahk
SetTimer, SerialRead, 150
#include GUI.ahk
ON_DEVICECHANGE(0,0,0,0)
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
	; output:=""
	; Loop, Parse, ComList, |,
	; 	output.=A_LoopField "`n"
	; Msgbox, % ComList
	GuiControl, , ComPorts, % ComList
	; Msgbox, % ComList "`n`n" output
}


Esc::ExitApp

ExitAll:
hSerial.close()
logDetail.close()
logHandle.close()
ExitApp, 0

