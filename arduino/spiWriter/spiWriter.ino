
#define gpio(x,n) digitalWrite(x,n)
#define io_read(x) digitalRead(x)

#define VCC		(8)
#define CS		(9)
#define SCLK	(10)
#define MISO	(11)
#define MOSI	(12)
#define GND		(13)

#define FLASH_READ_UID (0x4B)
#define FLASH_WRITE_ENABLE (0x06)
#define FLASH_READ_STATU_REG1 (0x05)
#define FLASH_READ_DATA (0x03)
#define FLASH_PAGE_PROGRAM (0x02)
#define FLASH_SECTOR_ERASE (0x20)

#define sendStr(str) \
		Serial.write('#');\
		Serial.write(sizeof(str)+1);\
		Serial.write(0xFF);\
		Serial.print(str);\
		Serial.write(0xAA);

// shiftOut(dataPin, clock, MSBFIRST, data);
// byte incoming = shiftIn(dataPin, clockPin, bitOrder)

unsigned char flash_uid[8]={0xFF};
unsigned char mac_addr[6]={0x00,0x12,0x34,0xab,0xcd,0xef};

void setup(void)
{
	Serial.begin(115200);

	digitalWrite(VCC,0);
	digitalWrite(GND,0);
	digitalWrite(CS,1);
	digitalWrite(SCLK,0);
	digitalWrite(MOSI,0);

	pinMode(VCC,OUTPUT);
	pinMode(GND,OUTPUT);
	pinMode(CS,OUTPUT);
	pinMode(SCLK,OUTPUT);
	pinMode(MISO,INPUT);
	pinMode(MOSI,OUTPUT);
	digitalWrite(VCC,1);

	sendStr("booting");
}


unsigned int delays=0;
void loop(void)
{
	while(Serial.available()){
		unsigned char incomingByte = Serial.read();
		uartParse(incomingByte);
	}
	delay(1);delays+=1;
	if(delays>1000){
		delays=0;
		Serial.write('#');
		Serial.write(2);
		Serial.write(0xF0);
		Serial.write(0x01);		// 心跳包
		Serial.write(0xAA);
	}
}

struct
{
	unsigned char buffer[128];		// receive buffer
	unsigned char length;			// length of receive buffer
}uartBuffer={{0},0};
inline void bufPush(unsigned char x)
{
	uartBuffer.buffer[ uartBuffer.length ] = x;
	uartBuffer.length++;
}
inline int isCheckSumOK(void)
{
	unsigned char sum=0;
	unsigned char index=2;

	while(index<=uartBuffer.buffer[1]+1){
		sum+=uartBuffer.buffer[index++];
	}
	if(sum==uartBuffer.buffer[index]){
		return 1;
	}else{
		return 0;
	}
}
void uartParse(unsigned char chr)
{
	if(uartBuffer.length>=40){
		uartBuffer.length=0;
	}

	if(uartBuffer.length==0){
		if(chr=='#'){
			bufPush(chr);
		}
		return;
	}
	bufPush(chr);

	if(uartBuffer.length>=uartBuffer.buffer[1]+3){
		if(isCheckSumOK()){
			parser();
			// flashProgram();
		}else{
			sendStr("CheckSum Error");
		}
		uartBuffer.length=0;
	}
}

char ble_name[]="BPC-";
void mac(void)
{
	unsigned long writeAddr=0x21100;
	unsigned long readPtr=0;
	debug_erase(0x21100);
	flash_write(0x21100,(unsigned char*)mac_addr,6);
	flash_wait_idle();
	flash_write(0x21110,(unsigned char*)ble_name,sizeof(ble_name)-1);
	flash_wait_idle();
	flash_write_byte(0x21110+sizeof(ble_name)-1,(mac_addr[0]>>4)+'A');
	flash_wait_idle();
	flash_write_byte(0x21110+sizeof(ble_name),(mac_addr[0]&0x0F)+'A');
	flash_wait_idle();
	flash_write_byte(0x21110+sizeof(ble_name)+1,0);
	flash_wait_idle();
	flash_write_byte(0x2111F,sizeof(ble_name)+1);
	flash_wait_idle();
	Serial.println("MAC Program finished");
}

void debug_erase(unsigned long addr){
	Serial.print("Start Erasing 0x");
	Serial.println(addr,HEX);
	flash_wait_idle();
	flash_erase(addr);
	flash_wait_idle();
	Serial.println("Erased");
}

int flash_isBusy(void)
{
	return !flash_isIdle();
}
void flash_wait_idle(void)
{
	while(!flash_isIdle()) delay(1);
}

int flash_isIdle(void)
{
	unsigned char flashReg;
	gpio(CS,0);
	flashReg = _spiReadReg(FLASH_READ_STATU_REG1);
	gpio(CS,1);
	if((flashReg&0x01)==0x01){
		return 0;
	}else{
		return 1;
	}
}

void flash_ReadUID(unsigned char *uid)
{
	gpio(CS,0);
	_spiWrite(FLASH_READ_UID);
	_spiWrite(0); _spiWrite(0); _spiWrite(0); _spiWrite(0);
	*uid++=_spiRead(); *uid++=_spiRead();
	*uid++=_spiRead(); *uid++=_spiRead();
	*uid++=_spiRead(); *uid++=_spiRead();
	*uid++=_spiRead(); *uid++=_spiRead();
	gpio(CS,1);
}

void flash_erase(unsigned long addr)
{
	gpio(CS,0);
	_spiWrite(FLASH_WRITE_ENABLE);
	gpio(CS,1);
	gpio(CS,0);
	_spiWrite(FLASH_SECTOR_ERASE);
	_spiWrite( (unsigned char)((addr>>16)&0xFF) );
	_spiWrite( (unsigned char)((addr>>8)&0xFF) );
	_spiWrite( (unsigned char)((addr)&0xFF) );
	gpio(CS,1);
}

void flash_write(unsigned long addr,unsigned char *data,unsigned int length)
{
	gpio(CS,0);
	_spiWrite(FLASH_WRITE_ENABLE);
	gpio(CS,1);
	gpio(CS,0);
	_spiWrite(FLASH_PAGE_PROGRAM);
	_spiWrite( (unsigned char)((addr>>16)&0xFF) );
	_spiWrite( (unsigned char)((addr>>8)&0xFF) );
	_spiWrite( (unsigned char)((addr)&0xFF) );
	while(length-- > 0){
		_spiWrite( *data++ );
	}
	gpio(CS,1);
}

void flash_write_byte(unsigned long addr,unsigned char byte)
{
	gpio(CS,0);
	_spiWrite(FLASH_WRITE_ENABLE);
	gpio(CS,1);
	gpio(CS,0);
	_spiWrite(FLASH_PAGE_PROGRAM);
	_spiWrite( (unsigned char)((addr>>16)&0xFF) );
	_spiWrite( (unsigned char)((addr>>8)&0xFF) );
	_spiWrite( (unsigned char)((addr)&0xFF) );
	_spiWrite( byte );
	gpio(CS,1);
}



void flash_read(unsigned long addr,unsigned char *data,unsigned int length)
{
	gpio(CS,0);
	_spiWrite(FLASH_READ_DATA);
	_spiWrite( (unsigned char)((addr>>16)&0xFF) );
	_spiWrite( (unsigned char)((addr>>8)&0xFF) );
	_spiWrite( (unsigned char)((addr)&0xFF) );
	while(length-- > 0){
		*data++=_spiRead();
	}
	gpio(CS,1);
}


inline void _spiWrite(unsigned char var)
{
	shiftOut(MOSI, SCLK, MSBFIRST, var);
}

inline unsigned char _spiRead(void)
{
	return shiftIn(MISO, SCLK, MSBFIRST);
}

inline void _spiWriteReg(unsigned char addr,unsigned char val)
{
	_spiWrite(addr);
	_spiWrite(val);
}
inline unsigned char _spiReadReg(unsigned char addr)
{
	shiftOut(MOSI, SCLK, MSBFIRST, addr);
	return shiftIn(MISO, SCLK, MSBFIRST);
}

void parser(void)
{
	unsigned char _;
	unsigned long addr;
	unsigned char buf[16];
	addr = (uartBuffer.buffer[3]<<16) | (uartBuffer.buffer[4]<<8) | uartBuffer.buffer[5];
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	switch(uartBuffer.buffer[2]){
		case 0x01:	// read
		flash_read(addr,buf,16);
		Serial.write('#');
		Serial.write(1+3+16);
		Serial.write(uartBuffer.buffer+2,4);
		Serial.write(buf,16);
		Serial.write(0xAA);
		break;
		case 0x02:	// write
		flash_write(addr,uartBuffer.buffer+1+1+3,uartBuffer.buffer[1]-1-3);
		_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
		Serial.write('#');
		Serial.write(2);
		Serial.write(uartBuffer.buffer[2]);
		Serial.write(0x01);
		Serial.write(0xAA);
		break;
		case 0x03:	// erase
		flash_erase(addr);
		_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
		Serial.write('#');
		Serial.write(2);
		Serial.write(uartBuffer.buffer[2]);
		Serial.write(0x01);
		Serial.write(0xAA);
		break;
	}
}
