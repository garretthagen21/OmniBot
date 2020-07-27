#include "configuration.h"
  
/*motor control*/
void go_Advance(void) //Forward
{
  enable_Motors();
  analogWrite(dir1PinL,spd);
  digitalWrite(dir2PinL,LOW);
  analogWrite(dir1PinR,spd);
  digitalWrite(dir2PinR,LOW);
}
void go_Right()  //Turn right
{
  enable_Motors();
  analogWrite(dir1PinL,spd);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  analogWrite(dir2PinR,spd);
}
void go_Left()  //Turn left
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
  Serial.println((int)echo_distance);
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
  Serial.println((int)echo_distance);
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
  Serial.println((int)echo_distance);
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
  Serial.println((int)echo_distance);
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


/*Obstacle Avoidance Mode*/
void obstacle_avoidance_mode_2(int dis_FL, int dis_FR, int dis_L, int dis_R){  
  if ( (dis_FL <= up_bound) || (dis_FR <= up_bound) ){
    go_Back();
    delay(back_time);
    stop_Stop();
    if (dis_L < dis_R){
      go_Right();
      while( (dis_FL <= up_bound + extra_space) || (dis_FR <= up_bound + extra_space)){
        delay(turn_time);
      }
      stop_Stop();
    }
    else if (dis_R < dis_L){
      go_Left();
      while( (dis_FL <= up_bound + extra_space) || (dis_FR <= up_bound + extra_space)){
        delay(turn_time);
      }
      stop_Stop();      
    }
  }
  else {
    go_Advance();
  }
}

/*Obstacle Avoidance Mode*/
void testObstacleAvoidanceMode(){
  dis_FL = watch_FL();
  dis_FR = watch_FR();
  dis_L = watch_L();
  dis_R = watch_R();
  
  obstacle_avoidance_mode(dis_FL, dis_FR, dis_L, dis_R);
}


/*Obstacle Avoidance Mode*/
void testObstacleAvoidanceMode2(){
  dis_FL = watch_FL();
  dis_FR = watch_FR();
  dis_L = watch_L();
  dis_R = watch_R();
  
  obstacle_avoidance_mode_2(dis_FL, dis_FR, dis_L, dis_R);
}

void testStop(){
  Serial.println("Test Stop");
  stop_Stop();
  delay(stop_len);
}

void testForwardSlow(){
  Serial.println("Test Forward slow");
  spd = 50;
  go_Advance();
  delay(test_len);
}

void testForwardMedium(){
  Serial.println("Test Forward medium");
  spd = 150;
  go_Advance();
  delay(test_len);
}

void testForwardFast(){
  Serial.println("Test Forward fast");
  spd = 250;
  go_Advance();
  delay(test_len);
}

void testBackwards(){
  Serial.println("Test Backward");
  go_Back();
  delay(test_len);
}

void testLeft(){
  Serial.println("Test Left");
  go_Left();
  delay(test_len);
}

void testRight(){
  Serial.println("Test Right");
  go_Right();
  delay(test_len);
}

void testFLUS(){
  Serial.println("Test Read Front Left Ultrasonic sensor");
  for(int i = 0; i < test_len; i++){
    dis_FL = watch_FL();
    delay(1);
  }
}

void testFRUS(){
  Serial.println("Test Read Front Right Ultrasonic sensor");
  for(int i = 0; i < test_len; i++){
    dis_FR = watch_FR();
    delay(1);
  }
}

void testLUS(){
  Serial.println("Test Read Left Ultrasonic sensor");
  for(int i = 0; i < test_len; i++){
    dis_L = watch_L();
    delay(1);
  }
}

void testRUS(){
  Serial.println("Test Read Right Ultrasonic sensor");
  for(int i = 0; i < test_len; i++){
    dis_R = watch_R();
    delay(1);
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
}

void loop() {
//
//  testForwardSlow();
//  testForwardMedium();
//  testForwardFast();
//  testStop();
//  
  spd = 70;
//  testBackwards();
//  testStop();
  
//  testLeft();
//  testStop();
  
//  testRight();
//  testStop();
  
//  testFLUS();
//  testFRUS();
//  testLUS();
//  testRUS();

//  testObstacleAvoidanceMode();
  testObstacleAvoidanceMode2();

}
