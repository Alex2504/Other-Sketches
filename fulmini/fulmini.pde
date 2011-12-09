
#include <LiquidCrystal.h>

const int button1Pin = 6;
const int button2Pin = 7;
int button1State = 0;
int button2State = 0;  


const int sensorPin = A0;
int sensorValue = 0;
int cal = 0;
int sens = 10;
int lastState = 0;

long previousMillis = 0;       
long interval = 15000;    //intervallo update calibrazione       

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup()   {                
  lcd.begin(16, 2);
  lcd.setCursor(0, 0);
  lcd.print("Allo scatto:");
  lcd.setCursor(0, 1);
  lcd.print("Sensibilita':");
  
  pinMode(button1Pin, INPUT);
  pinMode(button2Pin, INPUT);
        
  pinMode(sensorPin, INPUT);
  Serial.begin(9600);
  cal = analogRead(sensorPin);
  }
 
void loop()                     
{
  sensorValue = analogRead(sensorPin);
  
  unsigned long currentMillis = millis();
 
  if(currentMillis - previousMillis > interval) {
    
    previousMillis = currentMillis;   
   
   cal = analogRead(sensorPin);
  }
  
  if(sensorValue > cal+sens) 
  cameraSnap(CameraIrPin);    //non funziona, no lib
  
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
 

