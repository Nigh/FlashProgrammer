

com_scan()
{
	global
	COMPort := Object()
	Loop, HKLM, HARDWARE\DEVICEMAP\SERIALCOMM\
	{
	    RegRead, OutputVar
	    COMPort.Insert(OutputVar)
	}
}

getComList()
{
	global COMPort
	ComList:=""
	loop, % COMPort.MaxIndex()
	{
		ComList.="|" COMPort[A_Index]
	}
	Return ComList
}
