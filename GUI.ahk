
_DEBUG_:=1

Gui, -Caption +Border +LastFound +Owner +ToolWindow +hwndhGui +AlwaysOnTop
Gui, Color, 333631, 333631
Gui, font, s24 cffffff, ;微软雅黑
Gui, Add, Text, w350 center gdrag,Fineck SN Code`n Programmer
Gui, font, s12 cffffff, Consolas
gui, add, Pic,w27 h27 Border 0xE hwndstatuLED
Gui, Add, DDL,x+10 w70 h27 vcomPort, COM1|COM2|COM3
Gui, Add, Button, x+10 h27, Connect
Gui, Add, Text, xm,Log:
Gui, Add, Edit, disabled y+0 w350 r18 voutput Hwndedit,
Gui, Add, Text, xm,SN Code:
Gui, Add, Edit, y+0 w350 r1 vvar ginput, 

Gui, font, s8 cffffff, ;微软雅黑
Gui, Add, Text, right w350 y+0 gdrag, jiyucheng007@gmail.com
Gui, Show, AutoSize, 01010001110101010
WinSet, Transparent, 230, ahk_id %hGui%

revBuf:=Object()

; #if _DEBUG_
; gui, Show
; F5::ExitApp, 0
; #include GUI_app.ahk
; #if
