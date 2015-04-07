
#include serial.ahk

OnExit, ExitAll

OnMessage(0x219, "ON_DEVICECHANGE")
SetFormat, Integer, HEX

; if(hSerial!=""){
; 	hSerial.close()
; }
; hSerial:=new Serial("COM5")
; hSerial.begin("115200")
; sHandle:=fileOpen(hSerial.__handle,"h")

SetTimer, SerialRead, 50
#include GUI.ahk
Return

#include GUI_app.ahk
#include com_scan.ahk

ON_DEVICECHANGE(wp,lp,msg,hwnd)
{
	global ComList
	com_scan()
	ComList:=getComList()
	output:=""
	Loop, Parse, ComList, |,
		output.=A_LoopField "`n"
	Msgbox, % ComList "`n`n" output
}


F5::ExitApp

ExitAll:
hSerial.close()
ExitApp, 0

