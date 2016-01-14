

// pin configration
#define gpio(x,n) digitalWrite(x,n)
#define io_read(x) digitalRead(x)
unsigned char SPI0RXD_RXD=0;

// const unsigned int PIN_CS=4;
// const unsigned int PIN_CLK=5;
// const unsigned int PIN_MOSI=6;
// const unsigned int PIN_MISO=7;
// const unsigned int PIN_GND=13;

#define PIN_CS 47
#define PIN_CLK 49
#define PIN_MOSI 51
#define PIN_MISO 53
#define PIN_GND 13

void setup(void)
{
	Serial.begin(115200);
	pinMode(PIN_CS,OUTPUT);
	pinMode(PIN_CLK,OUTPUT);
	pinMode(PIN_MOSI,OUTPUT);
	pinMode(PIN_MISO,INPUT);
	pinMode(PIN_GND,OUTPUT);
	gpio(PIN_CS,1);
	gpio(PIN_CLK,0);
	gpio(PIN_MOSI,0);
	gpio(PIN_GND,0);
	Serial.println("Yes, my lord.\n");
}


void loop(void)
{
	while(Serial.available()){
		unsigned char incomingByte = Serial.read();
		if(incomingByte=='e'){
			flash_erase();
		}
	}
}
#define SN_NUM_ADDR	(0x40000)
#define MAC_ADDR (0x40100)
#define FACTORY_ADDR (0x40200)
void flash_erase(void){
	unsigned char _;	// for timeout
	unsigned char localBuf[17]={0xFF};

	Serial.println("Before:");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(SN_NUM_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(MAC_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(FACTORY_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	Serial.println("");

	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_Erase(SN_NUM_ADDR);
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_Erase(MAC_ADDR);
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_Erase(FACTORY_ADDR);
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(FACTORY_ADDR,localBuf,16);

	Serial.println("After:");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(SN_NUM_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(MAC_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
	flash_read(FACTORY_ADDR,localBuf,16);
	_=0;while(_<16) Serial.print(localBuf[_++],HEX);Serial.println("");
	Serial.println("");
}

#define FLASH_WRITE_ENABLE (0x06)
#define FLASH_READ_STATU_REG1 (0x05)
#define FLASH_READ_DATA (0x03)
#define FLASH_PAGE_PROGRAM (0x02)
#define FLASH_SECTOR_ERASE (0x20)
int flash_isIdle(void)
{
	unsigned char flashReg;
	gpio(PIN_CS,0);
	flashReg = _spi0ReadReg(FLASH_READ_STATU_REG1);
	gpio(PIN_CS,1);
	if((flashReg&0x01)==0x01){
		return 0;
	}else{
		return 1;
	}
}

int flash_isBusy(void)
{
	return !flash_isIdle();
}

void flash_Erase(unsigned long addr)
{
	gpio(PIN_CS,0);
	_spi0Write(FLASH_WRITE_ENABLE);
	gpio(PIN_CS,1);
	gpio(PIN_CS,0);
	_spi0Write(FLASH_SECTOR_ERASE);
	_spi0Write( (unsigned char)((addr>>16)&0xFF) );
	_spi0Write( (unsigned char)((addr>>8)&0xFF) );
	_spi0Write( (unsigned char)((addr)&0xFF) );
	gpio(PIN_CS,1);
}

void flash_Write(unsigned long addr,unsigned char *data,unsigned int length)
{
	gpio(PIN_CS,0);
	_spi0Write(FLASH_WRITE_ENABLE);
	gpio(PIN_CS,1);
	gpio(PIN_CS,0);
	_spi0Write(FLASH_PAGE_PROGRAM);
	_spi0Write( (unsigned char)((addr>>16)&0xFF) );
	_spi0Write( (unsigned char)((addr>>8)&0xFF) );
	_spi0Write( (unsigned char)((addr)&0xFF) );
	while(length-- > 0){
		_spi0Write( *data++ );
	}
	gpio(PIN_CS,1);
}

void flash_read(unsigned long addr,unsigned char *data,unsigned int length)
{
	gpio(PIN_CS,0);
	_spi0Write(FLASH_READ_DATA);
	_spi0Write( (unsigned char)((addr>>16)&0xFF) );
	_spi0Write( (unsigned char)((addr>>8)&0xFF) );
	_spi0Write( (unsigned char)((addr)&0xFF) );
	while(length-- > 0){
		*data++=_spi0Read();
	}
	gpio(PIN_CS,1);
}

// #define gpio(x,n) digitalWrite(x,n)
// #define io_read(x) digitalRead(x)
__inline__ void _spi0Write(unsigned char var)
{
	gpio(PIN_CLK,0);
	SPI0RXD_RXD = 0;
	for (int i = 0; i < 8; ++i)
	{
		if((var&0x80)>0) gpio(PIN_MOSI,1);
		else gpio(PIN_MOSI,0);
		var <<= 1;
		gpio(PIN_CLK,1);
		SPI0RXD_RXD<<=1;
		if( io_read(PIN_MISO)>0 ) SPI0RXD_RXD|=0x01;
		delayMicroseconds(1);
		gpio(PIN_CLK,0);
	}
	gpio(PIN_CLK,0);
}

__inline__ unsigned char _spi0Read(void)
{
	_spi0Write(0x00);
	return SPI0RXD_RXD;
}

__inline__ void _spi0WriteReg(unsigned char addr,unsigned char val)
{
	_spi0Write(addr);
	_spi0Write(val);
}

__inline__ unsigned char _spi0ReadReg(unsigned char addr)
{
	_spi0Write(addr);
	return _spi0Read();
}


// SN addr:0x40000
// BLE mac addr:0x40100
// void flashProgram(void)
// {
// 	unsigned char buf[64];
// 	unsigned char _;	// for timeout
// 	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
// 	flash_Erase(0x40000);
// 	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
// 	flash_Write(0x40000,uartBuffer.buffer+2,uartBuffer.buffer[1]-7);
// 	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
// 	flash_Write(0x40100,uartBuffer.buffer+2+uartBuffer.buffer[1]-6,6);
// 	_=0;while(flash_isBusy()>0) {delay(50);if(_++>40)return;}
// 	flash_read(0x40000,buf,uartBuffer.buffer[1]-7);
// 	buf[uartBuffer.buffer[1]-7]=',';
// 	flash_read(0x40100,buf+uartBuffer.buffer[1]-6,6);
// 	Serial.write('#');
// 	Serial.write(uartBuffer.buffer[1]);
// 	Serial.write(buf,uartBuffer.buffer[1]);
// 	Serial.write(0xAA);
// }

