
SetWorkingDir, %A_ScriptDir%

logHandle:=fileOpen("snlog.csv","a")
if(!IsObject(logHandle)){
	errorMsg("无法生成log文件，请使用管理员权限执行。")
	ExitApp, -1
}

FileRead, snLib, sn_lib.txt
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
		time:=A_Hour ":" A_Min ":" A_Sec "." A_MSec
		logDetail.WriteLine("---> " date " " time ":")
	}
	logDetail.WriteLine(logs "`r`n")
}

SNCodeSuccess(code)
{
	global logHandle
	date:=A_MM "/" A_DD
	time:=A_Hour ":" A_Min ":" A_Sec "." A_MSec
	logHandle.WriteLine(date " " time " [ " code " ]")
}

getMacNumFromLib(ByRef SNCode)
{
	global snLib
	length:=NumGet(SNCode,1,"UChar")

	sn_Str:=""
	loop, % length
	{
		sn_Str.=chr(NumGet(SNCode,1+A_Index,"UChar"))
	}

	pos:=instr(snLib,sn_Str)
	RegExMatch(snLib, "@([0-9A-F][0-9A-F])-([0-9A-F][0-9A-F])-([0-9A-F][0-9A-F])-([0-9A-F][0-9A-F])-([0-9A-F][0-9A-F])-([0-9A-F][0-9A-F])",mac,pos)
	m1:="0x" mac1
	m2:="0x" mac2
	m3:="0x" mac3
	m4:="0x" mac4
	m5:="0x" mac5
	m6:="0x" mac6
	m1+=0,m2+=0,m3+=0,m4+=0,m5+=0,m6+=0

	NumPut(Asc(","),SNCode,length-5,"UChar")
	NumPut(m1,SNCode,length-4,"UChar")
	NumPut(m2,SNCode,length-3,"UChar")
	NumPut(m3,SNCode,length-2,"UChar")
	NumPut(m4,SNCode,length-1,"UChar")
	NumPut(m5,SNCode,length+0,"UChar")
	NumPut(m6,SNCode,length+1,"UChar")
}
