
drag:
PostMessage, 0xA1, 2
Return

SerialRead:
VarSetCapacity(_,128,0xff)
RawLength:=sHandle.RawRead(_,32)
loop, % RawLength
{
	revBuf.Insert(NumGet(_, A_Index-1, "UChar"))
	if(revBuf[1]=0x23){
		if(revBuf.MaxIndex()>1){
			if(revBuf[2]+2<32 and revBuf.MaxIndex()>=revBuf[2]+2){
					_print:="接收：`r`n"
				loop, % revBuf.MaxIndex()-4
					_print.=chr(revBuf[A_Index+3])
				_print.="`r`n`r`n"
				Control,EditPaste,% _print,, ahk_id %edit%
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

input:
gui, Submit, NoHide
if(StrLen(var)>=14){
	GuiControl, Text, var,
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
	Control,EditPaste,% "发送:`r`n",, ahk_id %edit%
	Control,EditPaste,% SerialOut "`r`n",, ahk_id %edit%
	hSerial.Write(&SNCode,18)
}
Return
