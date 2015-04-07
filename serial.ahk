

class Serial
{
	static Serial_Port:="COM8"
	static Serial_Baud:="9600"
	static Serial_Parity:="N"
	static Serial_Data:="8"
	static Serial_Stop:="1"
	static Serial_Settings:=Serial_Port ":baud=" Serial_Baud " parity=" Serial_Parity " data=" Serial_Data " stop=" Serial_Stop " dtr=Off"
	static __handle:=""

	__New(Port)
	{
		this.Serial_Port:=Port
		Return this
	}

	begin(Baud)
	{
		this.Serial_Baud:=Baud
		this.Serial_Settings:=this.Serial_Port ":baud=" this.Serial_Baud " parity=" this.Serial_Parity " data=" this.Serial_Data " stop=" this.Serial_Stop " dtr=Off"
		this.__handle:=this.RS232_Initialize(this.Serial_Settings)
		Return this.__handle
	}

	read()
	{
		
	}

	write(ptr,Data_Length)
	{
		VarSetCapacity(Bytes_Sent, 2, 0)
		DllCall("WriteFile"
		,"UInt" , this.__handle		;File Handle
		,"UInt" , ptr				;Pointer to string to send
		,"UInt" , Data_Length		;Data Length
		,"UInt*", Bytes_Sent		;Returns pointer to num bytes sent
		,"Int"  , "NULL")
		return Bytes_Sent
	}

	close()
	{
		this.RS232_Close()
	}

	RS232_Initialize(RS232_Settings)
	{
		;###### Extract/Format the RS232 COM Port Number ######
		;7/23/08 Thanks krisky68 for finding/solving the bug in which RS232 COM Ports greater than 9 didn't work.
		StringSplit, RS232_Temp, RS232_Settings, `:
		RS232_Temp1_Len := StrLen(RS232_Temp1)	;For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
		If (RS232_Temp1_Len > 4)                 	;So the valid names are
		RS232_COM = \\.\%RS232_Temp1%           	; ... COM8	COM9 	\\.\COM10	\\.\COM11	\\.\COM12 and so on...
		Else                                        	;
		RS232_COM = %RS232_Temp1%
		;8/10/09 A BIG Thanks to trenton_xavier for figuring out how to make COM Ports greater than 9 work for USB-Serial Dongles.
		StringTrimLeft, RS232_Settings, RS232_Settings, RS232_Temp1_Len+1 ;Remove the COM number (+1 for the semicolon) for BuildCommDCB.
		;###### Build RS232 COM DCB ######
		;Creates the structure that contains the RS232 COM Port number, baud rate,...
		VarSetCapacity(DCB, 28)
		BCD_Result := DllCall("BuildCommDCB"
		 	,"str" , RS232_Settings ;lpDef
		 	,"UInt", &DCB)      	;lpDCB
		If (BCD_Result <> 1)
		{
			MsgBox, There is a problem with Serial Port communication. `nFailed Dll BuildCommDCB, BCD_Result=%BCD_Result% `nThe Script Will Now Exit.
			this.RS232_Close()
			ExitApp
		}
		;###### Create RS232 COM File ######
		;Creates the RS232 COM Port File Handle
		this.__handle := DllCall("CreateFile"
		 	,"Str" , RS232_COM   	;File Name
		 	,"UInt", 0xC0000000 	;Desired Access
		 	,"UInt", 3          	;Safe Mode
		 	,"UInt", 0          	;Security Attributes
		 	,"UInt", 3          	;Creation Disposition
		 	,"UInt", 0          	;Flags And Attributes
		 	,"UInt", 0          	;Template File
		 	,"Cdecl Int")
		If (this.__handle < 1)
		{
			MsgBox, There is a problem with Serial Port communication. ;`nFailed Dll CreateFile, this.__handle=%this.__handle% `nThe Script Will Now Exit.
			this.RS232_Close()
			ExitApp
		}
		;###### Set COM State ######
		;Sets the RS232 COM Port number, baud rate,...
		SCS_Result := DllCall("SetCommState"
		 	,"UInt", this.__handle ;File Handle
		 	,"UInt", &DCB)        	;Pointer to DCB structure
		If (SCS_Result <> 1)
		{
			MsgBox, There is a problem with Serial Port communication. ;`nFailed Dll SetCommState, SCS_Result=%SCS_Result% `nThe Script Will Now Exit.
			this.RS232_Close()
			ExitApp
		}
		;###### Create the SetCommTimeouts Structure ######
		ReadIntervalTimeout      	= 0xffffffff
		ReadTotalTimeoutMultiplier = 0x00000000
		ReadTotalTimeoutConstant 	= 0x00000000
		WriteTotalTimeoutMultiplier= 0x00000000
		WriteTotalTimeoutConstant	= 0x00000000
		VarSetCapacity(Data, 20, 0) ; 5 * sizeof(DWORD)
		NumPut(ReadIntervalTimeout,       	Data,	0, "UInt")
		NumPut(ReadTotalTimeoutMultiplier,	Data,	4, "UInt")
		NumPut(ReadTotalTimeoutConstant,  	Data,	8, "UInt")
		NumPut(WriteTotalTimeoutMultiplier, Data, 12, "UInt")
		NumPut(WriteTotalTimeoutConstant, 	Data, 16, "UInt")
		;###### Set the RS232 COM Timeouts ######
		SCT_result := DllCall("SetCommTimeouts"
		 ,"UInt", this.__handle ;File Handle
		 ,"UInt", &Data)       	;Pointer to the data structure
		If (SCT_result <> 1)
		{
			MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result% `nThe Script Will Now Exit.
			this.RS232_Close()
			ExitApp
		}
		Return % this.__handle
	}

	RS232_Close()
	{
		;###### Close the COM File ######
		CH_result := DllCall("CloseHandle", "UInt", this.__handle)
		If (CH_result <> 1)
		MsgBox, Failed Dll CloseHandle CH_result=%CH_result%
		Return
	}

	RS232_Write(Message)
	{
		SetFormat, Integer, DEC
		;Parse the Message. Byte0 is the number of bytes in the array.
		StringSplit, Byte, Message, `,
		Data_Length := Byte0
		;Set the Data buffer size, prefill with 0xFF.
		VarSetCapacity(Data, Byte0, 0xFF)
		;Write the Message into the Data buffer
		i=1
		Loop %Byte0%
		{
			NumPut(Byte%i%, Data, (i-1) , "UChar")
			i++
		}
		;###### Write the data to the RS232 COM Port ######
		WF_Result := DllCall("WriteFile"
		 	,"UInt" , this.__handle ;File Handle
		 	,"UInt" , &Data        	;Pointer to string to send
		 	,"UInt" , Data_Length  	;Data Length
		 	,"UInt*", Bytes_Sent   	;Returns pointer to num bytes sent
		 	,"Int"	, "NULL")
		If (WF_Result <> 1 or Bytes_Sent <> Data_Length)
		MsgBox, Failed Dll WriteFile to RS232 COM, result=%WF_Result% `nData Length=%Data_Length% `nBytes_Sent=%Bytes_Sent%
	}

}

