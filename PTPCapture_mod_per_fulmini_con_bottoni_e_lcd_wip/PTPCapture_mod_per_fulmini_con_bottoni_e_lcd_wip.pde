#include <inttypes.h>
#include <avr/pgmspace.h>
#include <avrpins.h>
#include <max3421e.h>
#include <usbhost.h>
#include <usb_ch9.h>
#include <Usb.h>
#include <usbhub.h>
#include <address.h>
#include <printhex.h>
#include <message.h>
#include <hexdump.h>
#include <parsetools.h>
#include <ptp.h>

#include <LiquidCrystal.h>

const int sensorPin = A0;
int sensorValue = 0;
int cal = 0;
int sens = 10;
int lastState = 0;
long previousMillis = 0;       
long interval = 15000;

const int button1Pin = 0;
const int button2Pin = 1;
int button1State = 0;
int button2State = 0;  

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);

class CamStateHandlers : public PTPStateHandlers
{
      enum CamStates { stInitial, stDisconnected, stConnected };
      CamStates stateConnected;
    
public:
      CamStateHandlers() : stateConnected(stInitial) {};
      
      virtual void OnDeviceDisconnectedState(PTP *ptp);
      virtual void OnDeviceInitializedState(PTP *ptp);
} CamStates;

USB      Usb;
USBHub   Hub1(&Usb);
PTP      Ptp(&Usb, &CamStates);


void CamStateHandlers::OnDeviceDisconnectedState(PTP *ptp)
{
   
}

void CamStateHandlers::OnDeviceInitializedState(PTP *ptp)
{
         ptp->CaptureImage();   
      
}  
         
           
        
          
void setup() 
{
  
    lcd.begin(16, 2);
    lcd.setCursor(0, 0);
    lcd.print("Allo scatto:");
    lcd.setCursor(0, 1);
    lcd.print("Sensibilita':");
  
    pinMode(button1Pin, INPUT);
    pinMode(button2Pin, INPUT);
    Serial.begin( 115200 );
    Serial.println("Start");

    if (Usb.Init() == -1)
        Serial.println("OSC did not start.");
        
    pinMode(sensorPin, INPUT);
    
    cal = analogRead(sensorPin);
  
    
}

void loop() 
{
    
  unsigned long currentMillis = millis();
 
  if(currentMillis - previousMillis > interval) {
    
    previousMillis = currentMillis;   
   
   cal = analogRead(sensorPin);        //calibra ogni 15000 millis
  }
 

 if (analogRead(sensorPin)>sens+cal)Usb.Task();
  
  lcd.setCursor(13, 0);
  lcd.print((sensorValue)-(cal+sens),DEC);
  lcd.setCursor(14, 1);
  lcd.print(sens,DEC);
 button1State = digitalRead(button1Pin);
 button2State = digitalRead(button2Pin);
 
 if (button1State == HIGH && lastState != HIGH) {     
      
   sens = sens+1;
   lastState = HIGH;
  } 
 
  if (button2State == HIGH && lastState != HIGH) {     
      
   sens = sens-1;
   lastState = HIGH;
  } 
  if (button1State == LOW && button2State == LOW) {
  
    
  lastState = LOW;

  }
   
}

