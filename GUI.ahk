

If(!pToken := Gdip_Startup()){
	errorMsg("GDIP init failed!")
	ExitApp
}
; _DEBUG_:=1
LED_h:=27
Gui, -Caption +Border +LastFound +Owner +ToolWindow +hwndhGui +AlwaysOnTop
Gui, Color, 333631, 333631
Gui, font, s24 cffffff, ;微软雅黑
Gui, Add, Text, w350 center gdrag,Fineck SN Code`n Programmer
Gui, font, s12 cffffff, Consolas
Gui, Add, Text, ,Port:
Gui, Add, DDL,x+5 yp-5 w70 h%LED_h% r7 vComPorts gPortSelect,
gui, add, Pic,x+10 w27 h%LED_h% Border 0xE hwndstatuLED
; Gui, Add, Button, x+10 h%LED_h%, Connect
Gui, Add, Text, xm y+10,Log:
Gui, Add, Edit, disabled y+0 w350 r18 voutput Hwndedit,
Gui, Add, Text, xm y+10,SN Code:
Gui, Add, Edit, y+0 w350 r1 vvar ginput, 

Gui, font, s8 cffffff, ;微软雅黑
Gui, Add, Text, right w350 y+0 gdrag, jiyucheng007@gmail.com
Gui, Show, AutoSize, 01010001110101010
WinSet, Transparent, 230, ahk_id %hGui%

LED_pBitmap := Gdip_CreateBitmap(LED_h, LED_h)
		, LED_G := Gdip_GraphicsFromImage(LED_pBitmap)
		, Gdip_SetSmoothingMode(LED_G, 4)
		, Gdip_SetInterpolationMode(LED_G, 7)

LED_OFF:=0xff666567
LED_RED:=0xffE64547
LED_GREEN:=0xff46E547
setLED(LED_OFF)

revBuf:=Object()

; #if _DEBUG_
; gui, Show
; F5::ExitApp, 0
; #include GUI_app.ahk
; #if

setLED(color)
{
	global LED_h,LED_G,statuLED,LED_pBitmap
	pBrush:=Gdip_BrushCreateSolid(color)
	Gdip_FillRectangle(LED_G, pBrush, 1, 1, LED_h-3,LED_h-3)
	Gdip_DeleteBrush(pBrush)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(LED_pBitmap)
	SetImage(statuLED, hBitmap)
	DeleteObject(hBitmap)
}

