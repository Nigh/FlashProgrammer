

If(!pToken := Gdip_Startup()){
	errorMsg("GDIP init failed!")
	ExitApp
}
; _DEBUG_:=1

user_width:=550 ; 客户区宽度

DataLength:=20
LED_h:=27
Gui, -Caption +Border +LastFound +Owner +ToolWindow +hwndhGui +AlwaysOnTop
Gui, Color, 333631, 333631
Gui, font, s34 cffffff, Impact
Gui, Add, Text, section w%user_width% center gdrag,W07 Flash Programmer
Gui, font, s12 cffffff, Consolas
Gui, Add, Text, ,Port:
Gui, Add, DDL,x+5 w130 h%LED_h% r7 vComPorts gPortSelect,
gui, add, Pic,x+10 w27 h%LED_h% Border 0xE hwndstatuLED
Gui, Add, Text,x+100,Length:
Gui, Add, DDL,x+5 w130 h%LED_h% r7 choose%DataLength% vDataLength gLengthSelect, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30
; Gui, Add, Button, x+10 h%LED_h%, Connect
Gui, Add, Text, xm y+10,Log:
Gui, Add, Edit, ReadOnly c27cfff y+0 w%user_width% r18 voutput Hwndedit,
Gui, Add, Text, xm y+10,SN Code:
Gui, Add, Edit, y+0 w%user_width% r1 vvar ginput Disabled, 

Gui, font, s16, Consolas
Gui, Add, Button, y+5 g_reload, Reload
Gui, Add, Button, x+10 g_exit, EXIT
Gui, font, s10 cffffff, ;微软雅黑
Gui, Add, Text, xs right w%user_width% yp+10 gdrag BackgroundTrans, jiyucheng007@gmail.com
Gui, Add, Text, xs right w%user_width% y+0 gdrag BackgroundTrans, version 1.4.0 W07
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

