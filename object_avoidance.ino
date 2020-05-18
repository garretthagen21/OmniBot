  #include <Servo.h>
#include "configuration.h"

Servo head;
/*motor control*/
void go_Advance(void)  //Forward
{
  digitalWrite(dir1PinL,HIGH);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,HIGH);
  digitalWrite(dir2PinR,LOW);
}
void go_Left()  //Turn left
{
  digitalWrite(dir1PinL, HIGH);
  digitalWrite(dir2PinL,LOW);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,HIGH);
}
void go_Right()  //Turn right
{
  digitalWrite(dir1PinL, LOW);
  digitalWrite(dir2PinL,HIGH);
  digitalWrite(dir1PinR,HIGH);
  digitalWrite(dir2PinR,LOW);
}
void go_Back()  //Reverse
{
  digitalWrite(dir1PinL, LOW);
  digitalWrite(dir2PinL,HIGH);
  digitalWrite(dir1PinR,LOW);
  digitalWrite(dir2PinR,HIGH);
}
void stop_Stop()    //Stop
{
  digitalWrite(dir1PinL, LOW);
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

int ang=30;
int inc=1;

void buzz_ON(int value)   //open buzzer
{
  tone(BUZZ_PIN, value);
}
void buzz_OFF()  //close buzzer
{
 noTone(BUZZ_PIN);
 digitalWrite(BUZZ_PIN,HIGH);
}

/*detection of ultrasonic distance*/
int watch(){
  long echo_distance;
  digitalWrite(Trig_PIN,LOW);
  delayMicroseconds(5);                                                                              
  digitalWrite(Trig_PIN,HIGH);
  delayMicroseconds(15);
  digitalWrite(Trig_PIN,LOW);
  echo_distance=pulseIn(Echo_PIN,HIGH);
  echo_distance=echo_distance*0.01657; //how far away is the object in cm
  //Serial.println((int)echo_distance);
  return round(echo_distance);
}
//Meassures distances to the right, left, front, left diagonal, right diagonal and asign them in cm to the variables rightscanval, 
//leftscanval, centerscanval, ldiagonalscanval and rdiagonalscanval (there are 5 points for distance testing)


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
  pinMode(Trig_PIN, OUTPUT); 
  pinMode(Echo_PIN,INPUT); 
  /*init buzzer*/
  pinMode(BUZZ_PIN, OUTPUT);
  digitalWrite(BUZZ_PIN, HIGH);  
  buzz_OFF(); 

  digitalWrite(Trig_PIN,LOW);
  /*init servo*/
  head.attach(SERVO_PIN); 
  head.write(90);
  delay(4000);
 
  /*set motorspeed*/
  set_Motorspeed(120,120);
  
  /*baud rate*/
  Serial.begin(9600);

}

void loop() {
   int distance;
   int value;
   
   head.write(ang);
   ang+=inc;
   if(ang >= 120 || ang <= 1){
      inc=-inc;
   }
   distance = watch();
   //Serial.println(ang);
   //Serial.println(distance);
   if (distance <= 10 && distance > 0 ){
      value = map(distance, 0, 10, 1023, 0);
      Serial.println(value);
      buzz_ON(value);
      if (ang < 90){
        go_Back();
        delay(500);
        go_Left();
        delay(500);
        //ang = 90;
        stop_Stop();
      }
      else {
        go_Back();
        delay(500);
        go_Right();
        delay(500);
        //ang = 90;
        stop_Stop();
      }
   }
   else {
      Serial.println("OFF");
      buzz_OFF();
      go_Advance();
   }
}
