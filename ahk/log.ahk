
SetWorkingDir, %A_ScriptDir%

logHandle:=fileOpen("snlog.csv","a")
if(!IsObject(logHandle)){
	errorMsg("无法生成log文件，请使用管理员权限执行。")
	ExitApp, -1
}

; FileRead, snLib, SNCodeLib.csv
; if(!snLib){
; 	errorMsg("没有找到SN码仓库，请确认SN码仓库已就位。")
; 	ExitApp, -2
; }

logDetail:=fileOpen("log.log","a")

isSNInLib(code)
{
	global snLib
	return instr(snLib,code)
}

writeLog(logs,isNewLog=0)
{
	global logDetail
	if(isNewLog){
		date:=A_MM "/" A_DD
		time:=A_Hour ":" A_Min ":" A_Sec "." A_MSec
		logDetail.WriteLine(date " " time ":")
	}
	logDetail.WriteLine(logs "`r`n")
}

SNCodeSuccess(code)
{
	global logHandle
	date:=A_MM "/" A_DD
	time:=A_Hour ":" A_Min ":" A_Sec "." A_MSec
	logHandle.WriteLine(date " " time "," code)
}

getMacNumFromLib(ByRef SNCode)
{
	length:=NumGet(SNCode,1,"UChar")
	NumPut(Asc("@"),SNCode,length-5,"UChar")
	NumPut(0x1A,SNCode,length-4,"UChar")
	NumPut(0x1B,SNCode,length-3,"UChar")
	NumPut(0x1C,SNCode,length-2,"UChar")
	NumPut(0x1D,SNCode,length-1,"UChar")
	NumPut(0x1E,SNCode,length+0,"UChar")
	NumPut(0x1F,SNCode,length+1,"UChar")
}
