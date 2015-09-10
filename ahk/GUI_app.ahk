
drag:
PostMessage, 0xA1, 2
Return

LengthSelect:
gui, Submit, NoHide
writeLog("数据长度设置为:" DataLength,1)
Return

PortSelect:
gui, Submit, NoHide
; errorMsg(ComPorts)
if(hSerial!=""){
	hSerial.close()
}
hSerial:=new Serial(ComPorts)
if(hSerial.begin("115200")<1){
	writeLog("Hid设备打开失败",1)
	setLED(LED_RED)
	hSerial.close()
	hSerial:=""
	sHandle:=""
	GuiControl, , var,
	GuiControl, Disable, var,
}
Else
{
	writeLog("Hid设备打开成功",1)
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
			if(revBuf[2]+3<32 and revBuf.MaxIndex()>=revBuf[2]+3){
				_print:="接收:"
				revCode:=""
				loop, % revBuf.MaxIndex()-3
					revCode.=chr(revBuf[A_Index+2])
				_print.=revCode "`r`n"
				SetTimer, timeOut, Off
				print(_print)
				if(lastSend and InStr(revCode, lastSend)){
					Gui, Color, 238d37, 333631
					print("校对通过!!!`r`n`r`n")
					writeLog("校对通过 --- OK`r`n",1)
					SNCodeSuccess(lastSend)
				}Else{
					Gui, Color, aa3631, 333631
					writeLog("校对异常:#" revCode "#`r`n",1)
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

format_Hex(num)
{
	SetFormat, Integer, HEX
	num:=num+0 ""
	num:=SubStr("00" SubStr(num, 3),-1)
	return num
}

; uart数据帧格式:0x23 | dataLength | data... | checksum
; dataLength指data...长度
; checksum为data...的和
input:
gui, Submit, NoHide
if(StrLen(var)>=DataLength){
	GuiControl, Text, var,
	writeLog("扫码: <" var ">",1)
	; if(!isSNInLib(var)){
	; 	writeLog("此码不在仓库中")
	; 	print("<" var "> 此码不在库中`r`n")
	; 	Exit
	; }
	temp:=bufDiff(var)
	if(temp)
	{
		writeLog("两次扫码一致，执行写入[" var "]")

		VarSetCapacity(SNCode, DataLength+4+7, 0x00)
		NumPut(0x23, SNCode,0,"UChar")
		NumPut(DataLength+7, SNCode,1,"UChar")

		; 写入SN码
		loop, % DataLength
			NumPut(asc(SubStr(var, A_Index, 1)), SNCode,A_Index+1,"UChar")

		; 写入mac地址
		getMacNumFromLib(SNCode)

		checkSum:=0
		loop, % DataLength+7
			checkSum+=NumGet(SNCode,A_Index+1,"UChar")
		checkSum&=0xFF
		NumPut(checkSum, SNCode,DataLength+2+7,"UChar")
		SerialOut:=""
		loop, % DataLength+7
			SerialOut.=Chr(NumGet(SNCode,A_Index+1,"UChar"))
		
		Shows:=SubStr(SerialOut, 1, DataLength)
		Shows.=",`r`n"
		Shows.=format_Hex(NumGet(SNCode,10,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,11,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,12,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,13,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,14,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,15,"UChar"))

		print("确认发送:" Shows "`r`n")
		lastSend:=SerialOut
		hSerial.Write(&SNCode,DataLength+3)
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
writeLog("校对超时",1)
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
