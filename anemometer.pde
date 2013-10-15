/* QRD1114 IR Sensor on an cups anemometer
* Authors: M.A. de Pablo & C. de Pablo S., 2010
Changed to Hall Effect 10/2012
* version: 1.0   20100823
* Wind speed information: http://en.wikipedia.org/wiki/Beaufort_scale
*/
#include "Wire.h"
#include "Adafruit_BMP085.h"
 
// Pin definitions
# define ANEMOMETER 2                 // Receive the data from sensor

// Constants definitions
const float pi = 3.14159265;  // pi number
int period = 2000;           // Measurement period (miliseconds)
int delaytime = 2000;        // Time between samples (miliseconds)
int radio = 70;               // Radio from vertical anemometer axis to a cup center (mm)
char* winds[] = {"Calm", "Light air", "Light breeze", "Gentle breeze", "Moderate breeze", "Fresh breeze", "Strong breeze", "Moderate gale", "Fresh gale", "Strong gale", "Storm", "Violent storm", "Hurricane"};

// Variable definitions
unsigned int Sample = 0;       // Sample number
unsigned int counter = 0;      // B/W counter for sensor 
unsigned int RPM = 0;          // Revolutions per minute
float speedwind = 0;           // Wind speed (m/s)
unsigned short windforce = 0;  // Beaufort Wind Force Scale

Adafruit_BMP085 bmp;

void setup()
{
  bmp.begin();
  // Set the pins
  pinMode(2, INPUT);
  digitalWrite(2, HIGH);

  // sets the serial port to 115200 
  Serial.begin(9600);
  
  // Splash screen
  
  Serial.println("ANEMOMETER");
  Serial.println("**********");
  Serial.println("Based on NRG #40C ANEMOMETER Modified with a Hall Effect Sensor 2 pulse per 1 RPM");
  Serial.print("Sampling period: ");
  Serial.print(period/1000);
  Serial.print(" seconds every ");
  Serial.print(delaytime/1000);
  Serial.println(" seconds.");
  Serial.println("** You could modify those values on code **");
  Serial.println();
}

void loop() 
{
  float wind =  (speedwind) /2 / 0.514; //Change to 2 pulse per REV and conver m/s to kts
  Sample++;
  Serial.print(Sample);
  Serial.print(": Start measurement...");
  windvelocity();
  Serial.println("   finished.");
  Serial.print("Counter: ");
  Serial.print(counter);
  Serial.print(";  RPM: ");
  RPMcalc();
  Serial.print(RPM);
  Serial.print(";  Wind speed: ");
  WindSpeed();
  Serial.print(wind);
  Serial.print(" [kts]  ;  Wind force (Beaufort Scale): ");
  Serial.print(windforce);
  Serial.print(" - ");
  Serial.println(winds[windforce]);
  Serial.println();
    Serial.print("Temperature = ");
    Serial.print(bmp.readTemperature());
    Serial.println(" *C");
    Serial.print("Pressure = ");
    Serial.print(bmp.readPressure());
    Serial.println(" Pa");
    Serial.println();
  delay(10000);  
}

// Measure wind speed
void windvelocity(){
  speedwind = 0;
  counter = 0;  

  attachInterrupt(0, addcount, CHANGE);
  unsigned long millis();                     
  long startTime = millis();
  while(millis() < startTime + period) {
  }
  detachInterrupt(1);
}

void RPMcalc(){
  RPM=((counter/2)*60)/(period/1000);  // Calculate revolutions per minute (RPM)
}

void WindSpeed(){
  speedwind = ((2 * pi * radio * RPM)/60) / 1000;  // Calculate wind speed on m/s
  if (speedwind <= 0.3){                           // Calculate Wind force depending of wind velocity
    windforce = 0;  // Calm
  }
  else if (speedwind <= 1.5){
    windforce = 1;  // Light air
  }
  else if (speedwind <= 3.4){
    windforce = 2;  // Light breeze
  }
  else if (speedwind <= 5.4){
    windforce = 3;  // Gentle breeze
  }
  else if (speedwind <= 7.9){
    windforce = 4;  // Moderate breeze
  }
  else if (speedwind <= 10.7){
    windforce = 5;  // Fresh breeze
  }
  else if (speedwind <= 13.8){
    windforce = 6;  // Strong breeze
  }
  else  if (speedwind <= 17.1){
    windforce = 7;  // High wind, Moderate gale, Near gale
  }
  else if (speedwind <= 20.7){
    windforce = 8;  // Gale, Fresh gale
  }
  else if (speedwind <= 24.4){
    windforce = 9;  // Strong gale
  }
  else if (speedwind <= 28.4){
    windforce = 10;  // Storm, Whole gale
  }
  else if (speedwind <= 32.6){
    windforce = 11;  // Violent storm
  }
  else {
    windforce = 12;  // Hurricane (from this point, apply the Fujita Scale)
  }
}

void addcount(){
  counter++;
}
