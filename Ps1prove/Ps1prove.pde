#include <math.h>
#include <stdio.h>
#include <avr/io.h>

#define LED_PIN 13
#define DELAY(wait) digitalWrite(LED_PIN,LOW); delay(wait); digitalWrite(LED_PIN,HIGH);

/* These are AVR PORTB pins, +8 to convert to Arduino pins */
#define PS2clk 5
#define PS2cmd 3
#define PS2att 2
#define PS2dat 4
#define PS2PORT PORTB
#define PS2IN PINB
#define CTRL_CLK 20
#define CTRL_BYTE_DELAY 20

//These are our button constants
#define PSB_SELECT 0x01
#define PSB_L3 0x02
#define PSB_R3 0x04
#define PSB_START 0x08
#define PSB_PAD_UP 0x10
#define PSB_PAD_RIGHT 0x20
#define PSB_PAD_DOWN 0x40
#define PSB_PAD_LEFT 0x80

#define PSB_L2 0x100
#define PSB_R2 0x200
#define PSB_L1 0x400
#define PSB_R1 0x800
#define PSB_GREEN 0x1000
#define PSB_RED 0x2000
#define PSB_BLUE 0x4000
#define PSB_PINK 0x8000

#define SET(x,y) (x|=(1<<y))
#define CLR(x,y) (x&=(~(1<<y)))
#define CHK(x,y) (x & (1<<y))
#define TOG(x,y) (x^=(1<<y))

boolean PSButton();
unsigned char PS2data[9];
void read_gamepad();
void config_gampad();
unsigned char get_gamepad_mode();
unsigned char i;

void setup() {
    randomSeed(analogRead(0));
    Serial.begin(9600);
    pinMode(LED_PIN,OUTPUT);
    digitalWrite(LED_PIN,HIGH);

    pinMode(PS2clk+8,OUTPUT);
    pinMode(PS2att+8,OUTPUT);
    pinMode(PS2cmd+8,OUTPUT);
    pinMode(PS2dat+8,INPUT);
    digitalWrite(PS2dat+8,HIGH);

    config_gampad();
}
void loop () {
    read_gamepad();
    
    
    if(PSButton(PSB_PAD_RIGHT)){
    
     Serial.print("Right");
    }
    
}
boolean PSButton(unsigned int button) {
int byte = 3;
if (button >= 0x100) {
  byte = 4;
  button = button >> 8;
}
  if (~PS2data[byte] & button)
  return true;
  else
  return false;
}
unsigned char _gamepad_shiftinout (char byte) {
   unsigned char tmp = 0;
   for(i=0;i<8;i++) {
	if(CHK(byte,i)) SET(PS2PORT,PS2cmd);
	  else  CLR(PS2PORT,PS2cmd);
	CLR(PS2PORT,PS2clk);
	delayMicroseconds(CTRL_CLK);
	  if(CHK(PS2IN,PS2dat)) SET(tmp,i);
	SET(PS2PORT,PS2clk);
   }
   SET(PS2PORT,PS2cmd);
   delayMicroseconds(CTRL_BYTE_DELAY);
   return tmp;
}
void _gamepad_shiftout (char byte) {
   for(i=0;i<8;i++) {
	if(CHK(byte,i)) SET(PS2PORT,PS2cmd);
	  else  CLR(PS2PORT,PS2cmd);
	CLR(PS2PORT,PS2clk);
	delayMicroseconds(CTRL_CLK);
	SET(PS2PORT,PS2clk);
	//delayMicroseconds(CTRL_CLK);
   }
   SET(PS2PORT,PS2cmd);
   delayMicroseconds(CTRL_BYTE_DELAY);
}
unsigned char _gamepad_shiftin() {
   unsigned char tmp = 0;
   for(i=0;i<8;i++) {
	CLR(PS2PORT,PS2cmd);
	CLR(PS2PORT,PS2clk);
	delayMicroseconds(CTRL_CLK);
	  if(CHK(PS2IN,PS2dat)) SET(tmp,i);
	SET(PS2PORT,PS2clk);
	delayMicroseconds(CTRL_CLK);
   }
   SET(PS2PORT,PS2cmd);
   delayMicroseconds(CTRL_BYTE_DELAY);
   return tmp;
}
void read_gamepad() {
    SET(PS2PORT,PS2cmd);
    SET(PS2PORT,PS2clk);
    CLR(PS2PORT,PS2att); // low enable joystick
    delayMicroseconds(CTRL_BYTE_DELAY);
    char dword[9] = {0x01,0x42,0,0,0,0,0,0,0};
    for (int i = 0; i<9; i++) {
	  PS2data[i] = _gamepad_shiftinout(dword[i]);
    }
    SET(PS2PORT,PS2att); // HI disable joystick
}
unsigned char get_gamepad_mode() {
    SET(PS2PORT,PS2cmd);
    SET(PS2PORT,PS2clk);
    CLR(PS2PORT,PS2att); // low enable joystick
    _gamepad_shiftout(0x01);
    unsigned char x = _gamepad_shiftin();
    SET(PS2PORT,PS2att); // HI disable joystick
    return x;
}
void config_gampad() {
   SET(PS2PORT,PS2cmd);
   SET(PS2PORT,PS2clk);
   CLR(PS2PORT,PS2att); // low enable joystick
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x43);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x00);
    // Lock to Analog Mode on Stick
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x44);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x03);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    // Vibration
    /*
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x4D);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x01);
    */
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x4F);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0xFF);
    _gamepad_shiftout(0xFF);
    _gamepad_shiftout(0x03);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x01);
    _gamepad_shiftout(0x43);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x00);
    _gamepad_shiftout(0x5A);
    _gamepad_shiftout(0x5A);
    _gamepad_shiftout(0x5A);
    _gamepad_shiftout(0x5A);
    _gamepad_shiftout(0x5A);
   SET(PS2PORT,PS2att);
} 
