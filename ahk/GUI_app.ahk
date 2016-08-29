
init:
init_mac:="24-4E-7B-2X-XX-XX"
init0:=0
init1:=0
Return


drag:
PostMessage, 0xA1, 2
Return

bpsSelect:
gui, Submit, NoHide
writeLog("更改波特率设置为:" bps,1)
Return

PortSelect:
gui, Submit, NoHide
; errorMsg(ComPorts)
if(hSerial!=""){
	hSerial.close()
}
hSerial:=new Serial(ComPorts)
if(hSerial.begin("" bps)<1){
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
	writeLog("波特率设置为:" bps)
	setLED(LED_GREEN)
	sHandle:=fileOpen(hSerial.__handle,"h")
	GuiControl, Enable, var,
	GuiControl, Focus, var
}
Return


prog:=""	; 进度

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
				if(revBuf[3]=0xF0){
					; _print:=".`r`n"
					_print:=""
				}
				if(revBuf[3]=0xFF){
					loop, % revBuf[2]-1
					{
						_print.=Chr(revBuf[3+A_Index])
					}
				}
				if(revBuf[3]=0x01){		; read
					addr:=format_Hex(revBuf[4]) format_Hex(revBuf[5]) format_Hex(revBuf[6])
					hex:=""
					name:=""
					if(addr="021100"){
						loop, % revBuf[2]-14
							hex.=format_Hex(revBuf[6+A_Index]) ","
						_print.="addr:0x" addr ":" hex "`r`n"					
						if(__flag=0){
							__flag:=1
							writeLog("Read MAC1:" hex,1)
						}
						if(__flag=3){
							__flag:=4
							writeLog("Read MAC2:" hex)
							Gui, Color, % color.success, % color.normal
							init0:=Mod(init0+1,0xFF)
							if(init0=0){
								init1:=Mod(init1+1,0xFF)
							}
						}
					}
					if(addr="021110"){
						loop, % revBuf[2]-14
							name.=Chr(revBuf[6+A_Index])
						_length:=revBuf[revBuf.MaxIndex()-1]
						_print.="addr:0x" addr ":" name " (" _length ")`r`n"
					}
				}
				if(revBuf[3]=0x02){		; write
					_print.="写入完成！`r`n"
					if(__flag=2){
						__flag:=3
						writeLog("Write Success")
					}

				}
				if(revBuf[3]=0x03){		; erase
					_print.="擦除完成！`r`n"
					if(__flag=1){
						__flag:=2
						writeLog("Erase Success")
					}

				}
				; revCode:=""
				; loop, % revBuf[2]
				; 	revCode.=chr(revBuf[A_Index+2])
				; _print.=substr(revCode,1,revBuf[2]-7)
				; _print.= "@" getMacStrFrom(revBuf) "`r`n"
				SetTimer, timeOut, Off
				print(_print)
				; if(lastSend and InStr(revCode, lastSend)){
				; 	Gui, Color, % color.success, % color.normal
				; 	print("校对通过!!!`r`n`r`n")
				; 	writeLog("校对通过 --- OK`r`n",1)
				; 	temp:=""
				; 	temp.=substr(revCode,1,revBuf[2]-7)
				; 	vCheckList.=temp "`r`n"
				; 	hCheckList.write(temp "`r`n")
				; 	temp.="@"
				; 	temp.=getMacStrFrom(revBuf)
				; 	SNCodeSuccess(temp)
				; }Else{
				; 	Gui, Color, % color.wrong, % color.normal
				; 	writeLog("校对异常:`r`n#" revCode "`r`n#" lastSend "`r`n",1)
				; 	print("校对异常!!!`r`n`r`n")
				; }
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

getMacStrFrom(ByRef buf)
{
	temp:=""
	temp.=format_Hex(buf[buf[2]-3]) "-"
	temp.=format_Hex(buf[buf[2]-2]) "-"
	temp.=format_Hex(buf[buf[2]-1]) "-"
	temp.=format_Hex(buf[buf[2]+0]) "-"
	temp.=format_Hex(buf[buf[2]+1]) "-"
	temp.=format_Hex(buf[buf[2]+2])
	return temp
}

bufDiff(buf)
{
	static buf1:=""
	static buf2:=""
	static flag:=0
	if(!buf)
		return 0
	flag:=!flag
	if(flag) {
		buf1:=buf
	} Else {
		buf2:=buf
	}
	if(buf1=buf2){
		tmp:=buf2
		buf1:=""
		buf2:=""
		Return tmp
	} Else{
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
	if(!isSNInLib(var)){
		writeLog("此码不在仓库中")
		print("<" var "> 此码不在库中`r`n")
		Exit
	}
	if( InStr(vCheckList, var)>0 ){
		writeLog("此码已经使用")
		print("<" var "> 此码已经使用`r`n")
		Exit
	}
	temp:=bufDiff(var)
	if(temp)
	{
		writeLog("两次扫码一致，执行写入[" var "]")
		; vCheckList.=var "`r`n"
		; hCheckList.write(var "`r`n")
		
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
		Shows.=","
		Shows.=format_Hex(NumGet(SNCode,DataLength+3,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,DataLength+4,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,DataLength+5,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,DataLength+6,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,DataLength+7,"UChar")) "-"
		Shows.=format_Hex(NumGet(SNCode,DataLength+8,"UChar"))

		print("确认发送:" Shows "`r`n")
		lastSend:=SerialOut
		hSerial.Write(&SNCode,DataLength+3+7)
		GuiControl, , var,
		GuiControl, Disable, var,
		SetTimer, timeOut, -3000
		Gui, Color, % color.normal, % color.normal
	}
	Else
	{
		print("缓存校验:" var "`r`n")
	}
}
Return

timeOut:
writeLog("超时",1)
print("接收超时!!!`r`n`r`n")
Gui, Color, % color.wrong, % color.normal
GuiControl, Enable, var,
GuiControl, Focus, var
Return


_read:
Gosub, _readmac
Gosub, _readname
Return

; 0x21100 mac
; 0x21110 name
_readmac:
_array:=[0x23,4,0x01,0x02,0x11,0x00,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())
Return

_readname:
_array:=[0x23,4,0x01,0x02,0x11,0x10,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())
Return

_erase:
_array:=[0x23,4,0x03,0x02,0x11,0x00,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())
Return

_write:
_array:=[0x23,10,0x02,0x02,0x11,0x00,init0,init1,0x20,0x7B,0x4E,0x24,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())

_array:=[0x23,11,0x02,0x02,0x11,0x10,Asc("B"),Asc("P"),Asc("C"),Asc("-")
,Asc(substr(format_Hex(init0),-1))
,Asc(substr(format_Hex(init0),0))
,0x00,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())

_array:=[0x23,5,0x02,0x02,0x11,0x1F,6,0xFF]
VarSetCapacity(array, _array.MaxIndex(), 0x00)
loop, % _array.MaxIndex()
{
	NumPut(_array[A_Index],array,A_Index-1,"UChar")
}
checkSum:=0
loop, % _array.MaxIndex()-3
{
	checkSum+=_array[A_Index+2]
}
checkSum&=0xFF
NumPut(checkSum,array,_array.MaxIndex()-1,"UChar")
hSerial.Write(&array,_array.MaxIndex())
Return


_program:
Gui, Color, % color.normal, % color.normal
__flag:=0	; 进程flag
SetTimer, timeOut, -3000
Gosub, _read
while(__flag=0){
	Sleep, 50
	if(A_Index>19)
		Return
}
Gosub, _erase
while(__flag=1){
	Sleep, 50
	if(A_Index>19)
		Return
}
Gosub, _write
while(__flag=2){
	Sleep, 50
	if(A_Index>19)
		Return
}
Gosub, _read
while(__flag=3){
	Sleep, 50
	if(A_Index>19)
		Return
}
SetTimer, timeOut, Off
Return

print(txt)
{
	global edit
	Control,EditPaste,% txt,, ahk_id %edit%
}
