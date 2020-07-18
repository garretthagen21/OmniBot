#include "configuration.h"
#include <OmniBLE.h>

/*setup Bluetooth module*/
OmniBLE botBT(5,6); // Pins: rx, rt
  
/*motor control*/
void go_Advance(void) //Forward
{
  enable_Motors();
  analogWrite(dir1PinL,spd);
  digitalWrite(dir2PinL,LOW);
  analogWrite(dir1PinR,spd);
  digitalWrite(dir2PinR,LOW);
}
void go_Left()  //Turn left
{
  enable_Motors();
  analogWrite(dir1PinL,spd);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  analogWrite(dir2PinR,spd);
}
void go_Right()  //Turn right
{
  enable_Motors();
  digitalWrite(dir1PinL,LOW);
  analogWrite(dir2PinL,spd);
  analogWrite(dir1PinR,spd);
  digitalWrite(dir2PinR,LOW);
}
void go_Back()  //Reverse
{
  enable_Motors();
  digitalWrite(dir1PinL,LOW);
  analogWrite(dir2PinL,spd);
  digitalWrite(dir1PinR,LOW);
  analogWrite(dir2PinR,spd);
}
void stop_Stop()    //Stop
{
  disable_Motors();
  digitalWrite(dir1PinL,LOW);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,LOW);
}

/*enable motor speed */
void enable_Motors()
{
  digitalWrite(enableL,HIGH); 
  digitalWrite(enableR,HIGH);   
}

/*disable motor speed */
void disable_Motors()
{
  digitalWrite(enableL,LOW); 
  digitalWrite(enableR,LOW);   
}

/*detection of FL ultrasonic distance*/
int watch_FL(){
  long echo_distance;
  digitalWrite(Trig_PIN_FL,LOW);
  delayMicroseconds(5);                                                                              
  digitalWrite(Trig_PIN_FL,HIGH);
  delayMicroseconds(15);
  digitalWrite(Trig_PIN_FL,LOW);
  echo_distance=pulseIn(Echo_PIN_FL,HIGH);
  echo_distance=echo_distance*0.01657; //how far away is the object in cm
  //Serial.println((int)echo_distance);
  return round(echo_distance);
}

/*detection of FR ultrasonic distance*/
int watch_FR(){
  long echo_distance;
  digitalWrite(Trig_PIN_FR,LOW);
  delayMicroseconds(5);                                                                              
  digitalWrite(Trig_PIN_FR,HIGH);
  delayMicroseconds(15);
  digitalWrite(Trig_PIN_FR,LOW);
  echo_distance=pulseIn(Echo_PIN_FR,HIGH);
  echo_distance=echo_distance*0.01657; //how far away is the object in cm
  //Serial.println((int)echo_distance);
  return round(echo_distance);
}

/*detection of L ultrasonic distance*/
int watch_L(){
  long echo_distance;
  digitalWrite(Trig_PIN_L,LOW);
  delayMicroseconds(5);                                                                              
  digitalWrite(Trig_PIN_L,HIGH);
  delayMicroseconds(15);
  digitalWrite(Trig_PIN_L,LOW);
  echo_distance=pulseIn(Echo_PIN_L,HIGH);
  echo_distance=echo_distance*0.01657; //how far away is the object in cm
  //Serial.println((int)echo_distance);
  return round(echo_distance);
}

/*detection of FL ultrasonic distance*/
int watch_R(){
  long echo_distance;
  digitalWrite(Trig_PIN_R,LOW);
  delayMicroseconds(5);                                                                              
  digitalWrite(Trig_PIN_R,HIGH);
  delayMicroseconds(15);
  digitalWrite(Trig_PIN_R,LOW);
  echo_distance=pulseIn(Echo_PIN_R,HIGH);
  echo_distance=echo_distance*0.01657; //how far away is the object in cm
  //Serial.println((int)echo_distance);
  return round(echo_distance);
}

/*Obstacle Avoidance Mode*/
void obstacle_avoidance_mode(int dis_FL, int dis_FR, int dis_L, int dis_R){  
  if ( (dis_FL <= up_bound && dis_FL >= lo_bound) || (dis_FR <= up_bound && dis_FR >= lo_bound) ){
    go_Back();
    delay(back_time);
    stop_Stop();
    if (dis_L < dis_R && dis_L >= lo_bound){
      go_Right();
      delay(turn_time);
      stop_Stop();
    }
    else if (dis_R < dis_L && dis_R >= lo_bound){
      go_Left();
      delay(turn_time);
      stop_Stop();      
    }
  }
  else {
    go_Advance();
  }
}

/* Joystick Mode */
void joystick_gesture_mode(){
    char cmd;
    
    cmd = botBT.cardinalDirection();
    switch(cmd){
      case 'N':
        go_Advance();
        break;
      case 'S':
        go_Back();
        break;
      case 'W':
        go_Left();
        break;
      case 'E':
        go_Right();
        break;
   }
}

void setup() {  
  /*setup L298N pin mode*/
  pinMode(dir1PinL, OUTPUT); 
  pinMode(dir2PinL, OUTPUT); 
  pinMode(enableL, OUTPUT);  
  pinMode(dir1PinR, OUTPUT);
  pinMode(dir2PinR, OUTPUT); 
  pinMode(enableR, OUTPUT); 
  stop_Stop(); // stop move
  
  /*init HC-SR04*/
  pinMode(Trig_PIN_FL, OUTPUT); 
  pinMode(Echo_PIN_FL, INPUT); 
  digitalWrite(Trig_PIN_FL, LOW);

  pinMode(Trig_PIN_FR, OUTPUT); 
  pinMode(Echo_PIN_FR, INPUT); 
  digitalWrite(Trig_PIN_FR, LOW);

  pinMode(Trig_PIN_L, OUTPUT); 
  pinMode(Echo_PIN_L, INPUT); 
  digitalWrite(Trig_PIN_L, LOW);

  pinMode(Trig_PIN_R, OUTPUT); 
  pinMode(Echo_PIN_R, INPUT); 
  digitalWrite(Trig_PIN_R, LOW);
  
  /*baud rate*/
  Serial.begin(9600);

  /*bluetooth wrapper*/
  botBT.printDebugToSerial = true;
  botBT.begin(9600);

  // Note: This sets the broadcasting name of the HM-10 bluetooth module. We only need to do this once
  botBT.setPeripheralName("OmniBot");
}

void loop() {
  dis_FL = watch_FL();
  dis_FR = watch_FR();
  dis_L = watch_L();
  dis_R = watch_R();
  
  // Update our botBT with the latest data
  botBT.sync();
  
  spd = round(botBT.speedValue()*255);
  if (spd < 50 && spd > 0){
    spd = 50;
  }
    
  if(botBT.autopilotValue()){
      obstacle_avoidance_mode(dis_FL, dis_FR, dis_L, dis_R);
  }
  else {
      joystick_gesture_mode();
  }
  
  // Send sensor vals to device. 
  // Note we should only send a message when these change to avoid clobbering bluetooth channel
  float sensorProximities[NUM_SONIC_SENSORS] = {float(dis_FL), float(dis_FR), float(dis_L), float(dis_R)};
  botBT.sendProximityMeasurements(sensorProximities,NUM_SONIC_SENSORS);
}
