
SetWorkingDir, %A_ScriptDir%

logHandle:=fileOpen("snlog.csv","a")
if(!IsObject(logHandle)){
	errorMsg("无法生成log文件，请使用管理员权限执行。")
	ExitApp, -1
}

FileRead, snLib, SNCodeLib.csv
if(!snLib){
	errorMsg("没有找到SN码仓库，请确认SN码仓库已就位。")
	ExitApp, -2
}

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
		time:=A_Hour ":" A_Min ":" A_Sec
		logDetail.WriteLine(date " " time ":")
	}
	logDetail.WriteLine(logs "`r`n")
}

SNCodeSuccess(code)
{
	global logHandle
	date:=A_MM "/" A_DD
	time:=A_Hour ":" A_Min ":" A_Sec
	logHandle.WriteLine(date " " time "," code)
}
