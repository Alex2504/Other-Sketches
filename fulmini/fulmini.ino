const int button1Pin = 2;
const int button2Pin = 3;
const int sensorPin = A0;
int button1State = 0;
int button2State = 0;   
int IRledPin =  12; 
int sensorValue = 0;
int cal = 0;
int sens = 10;
int lastState = 0;

long previousMillis = 0;       
long interval = 250;           

void setup()   {                
  
  pinMode(button1Pin, INPUT);
  pinMode(button2Pin, INPUT);
  pinMode(IRledPin, OUTPUT);      
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
  Serial.println(" ");
  Serial.println((sensorValue)-(cal+sens));
  Serial.println(sens);
  Serial.println(" ");
  }
  
  if(sensorValue > cal+sens) 
  SendNikonCode();
 
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
 
// This procedure sends a 38KHz pulse to the IRledPin 
// for a certain # of microseconds. We'll use this whenever we need to send codes
void pulseIR(long microsecs) {
  // we'll count down from the number of microseconds we are told to wait
 
  cli();  // this turns off any background interrupts
 
  while (microsecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
   digitalWrite(IRledPin, HIGH);  // this takes about 3 microseconds to happen
   delayMicroseconds(10);         // hang out for 10 microseconds
   digitalWrite(IRledPin, LOW);   // this also takes about 3 microseconds
   delayMicroseconds(10);         // hang out for 10 microseconds
 
   // so 26 microseconds altogether
   microsecs -= 26;
  }
 
  sei();  // this turns them back on
}
 
void SendNikonCode() {
  // This is the code for my particular Nikon, for others use the tutorial
  // to 'grab' the proper code from the remote
 
  pulseIR(2080);
  delay(27);
  pulseIR(440);
  delayMicroseconds(1500);
  pulseIR(460);
  delayMicroseconds(3440);
  pulseIR(480);
 
 
  delay(65); // wait 65 milliseconds before sending it again
 
  pulseIR(2000);
  delay(27);
  pulseIR(440);
  delayMicroseconds(1500);
  pulseIR(460);
  delayMicroseconds(3440);
  pulseIR(480);
}
