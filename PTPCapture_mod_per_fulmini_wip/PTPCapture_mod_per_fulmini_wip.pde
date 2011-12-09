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

const int sensorPin = A0;
int sensorValue = 0;
int cal = 0;
int sens = 10;
long previousMillis = 0;       
long interval = 15000;


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
   
   cal = analogRead(sensorPin);
  }
 

 if (analogRead(sensorPin)>sens+cal)Usb.Task();
  
   
}

