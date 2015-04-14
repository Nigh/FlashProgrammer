
drag:
PostMessage, 0xA1, 2
Return

PortSelect:
gui, Submit, NoHide
; errorMsg(ComPorts)
if(hSerial!=""){
	hSerial.close()
}
hSerial:=new Serial(ComPorts)
if(hSerial.begin("115200")<1){
	setLED(LED_RED)
	hSerial.close()
	hSerial:=""
	sHandle:=""
	GuiControl, , var,
	GuiControl, Disable, var,
}
Else
{
	setLED(LED_GREEN)
	sHandle:=fileOpen(hSerial.__handle,"h")
	GuiControl, Enable, var,
	GuiControl, Focus, var
}
Return

SerialRead:
if(!sHandle)
Return
VarSetCapacity(_,128,0xff)
RawLength:=sHandle.RawRead(_,32)
loop, % RawLength
{
	revBuf.Insert(NumGet(_, A_Index-1, "UChar"))
	if(revBuf[1]=0x23){
		if(revBuf.MaxIndex()>1){
			if(revBuf[2]+2<32 and revBuf.MaxIndex()>=revBuf[2]+2){
				_print:="接收:"
				loop, % revBuf.MaxIndex()-4
					_print.=chr(revBuf[A_Index+3])
				_print.="`r`n"
				SetTimer, timeOut, Off
				print(_print)
				if(InStr(_print, lastSend)){
					Gui, Color, 238d37, 333631
					print("校对通过!!!`r`n`r`n")
				}Else{
					Gui, Color, aa3631, 333631
					print("校对异常!!!`r`n`r`n")
				}
				GuiControl, Enable, var,
				GuiControl, Focus, var
				; Control,EditPaste,% _print,, ahk_id %edit%
				revBuf:=Object()
			}
		}
	}
	Else
		revBuf:=Object()
}
; if(RawLength){
; 	; Control,EditPaste,% "接收:`r`n",, ahk_id %edit%
; 	Control,EditPaste,% revBuf " ",, ahk_id %edit%
; 	revBuf:=""
; }
Return

bufDiff(buf)
{
	static buf1:=""
	static buf2:=""
	static flag:=0
	if(!buf)
		return 0
	flag:=!flag
	if(flag)
	{
		buf1:=buf
	}
	Else
	{
		buf2:=buf
	}
	if(buf1=buf2){
		tmp:=buf2
		buf1:=""
		buf2:=""
		Return tmp
	}
	Else{
		Return 0
	}
}

input:
gui, Submit, NoHide
if(StrLen(var)>=14){
	GuiControl, Text, var,
	temp:=bufDiff(var)
	if(temp)
	{
		VarSetCapacity(SNCode, 18, 0x00)
		NumPut(0x23, SNCode,0,"UChar")
		NumPut(16, SNCode,1,"UChar")
		NumPut(0x09, SNCode,2,"UChar")
		loop, 14
			NumPut(asc(SubStr(var, A_Index, 1)), SNCode,A_Index+2,"UChar")
		checkSum:=0
		loop, 15
			checkSum+=NumGet(SNCode,A_Index+1,"UChar")
		checkSum&=0xFF
		NumPut(checkSum, SNCode,17,"UChar")
		SerialOut:=""
		loop, 14
			SerialOut.=Chr(NumGet(SNCode,A_Index+2,"UChar"))
		print("确认发送:" SerialOut "`r`n")
		lastSend:=SerialOut
		hSerial.Write(&SNCode,18)
		GuiControl, , var,
		GuiControl, Disable, var,
		SetTimer, timeOut, -3000
		Gui, Color, 333631, 333631
	}
	Else
	{
		print("缓存校验:" var "`r`n")
	}
}
Return

timeOut:
print("接收超时!!!`r`n`r`n")
Gui, Color, aa3631, 333631
GuiControl, Enable, var,
GuiControl, Focus, var
Return

print(txt)
{
	global edit
	Control,EditPaste,% txt,, ahk_id %edit%
}
