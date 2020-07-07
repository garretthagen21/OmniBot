#include "configuration.h"

/*motor control*/
void go_Advance(void) //Forward
{
  digitalWrite(dir1PinL,HIGH);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,HIGH);
  digitalWrite(dir2PinR,LOW);
}
void go_Left()  //Turn left
{
  digitalWrite(dir1PinL,HIGH);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,HIGH);
}
void go_Right()  //Turn right
{
  digitalWrite(dir1PinL,LOW);
  digitalWrite(dir2PinL,HIGH);
  digitalWrite(dir1PinR,HIGH);
  digitalWrite(dir2PinR,LOW);
}
void go_Back()  //Reverse
{
  digitalWrite(dir1PinL,LOW);
  digitalWrite(dir2PinL,HIGH);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,HIGH);
}
void stop_Stop()    //Stop
{
  digitalWrite(dir1PinL,LOW);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,LOW);
}

/*set motor speed */
void set_Motorspeed(int speed_L,int speed_R)
{
  analogWrite(speedPinL,speed_L); 
  analogWrite(speedPinR,speed_R);   
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
void obstacle_avoidance_mode(){
  int up_bound = 10; //cm
  int lo_bound = 2; //cm
  int back_time = 300; //ms
  int turn_time = 300; //ms
  int dis_FL, dis_FR, dis_L, dis_R;
  
  dis_FL = watch_FL();
  dis_FR = watch_FR();
  dis_L = watch_L();
  dis_R = watch_R();
  
  set_Motorspeed(120,120);
  
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
void joystick_mode(){
    int cmd; // TODO: from bluetooth
    int spd; // TODO: from bluetooth
    
    switch(cmd){
    case 0:
      set_Motorspeed(spd, spd);
      break;
    case 1:
      go_Advance();
      break;
    case 2:
      go_Back();
      break;
    case 3:
      go_Left();
      break;
    case 4:
      go_Right();
      break;
   }
}

void gesture_mode(){
  // TODO
}

void setup() {
  /*setup L298N pin mode*/
  pinMode(dir1PinL, OUTPUT); 
  pinMode(dir2PinL, OUTPUT); 
  pinMode(speedPinL, OUTPUT);  
  pinMode(dir1PinR, OUTPUT);
  pinMode(dir2PinR, OUTPUT); 
  pinMode(speedPinR, OUTPUT); 
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

}

void loop() {
  int mode; // TODO: from bluetooth
  
  switch(mode){
    case 0:
      obstacle_avoidance_mode();
      break;
    case 1:
      joystick_mode();
      break;
    case 2:
      gesture_mode();
      break;
   }

}
