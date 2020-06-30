/*Declare L298N Dual H-Bridge Motor Controller directly since there is not a library to load.*/
//Define L298N Dual H-Bridge Motor Controller Pins
#define dir1PinL  2    //Motor direction
#define dir2PinL  4    //Motor direction
#define speedPinL 6    // Needs to be a PWM pin to be able to control motor speed

#define dir1PinR  7    //Motor direction
#define dir2PinR  8   //Motor direction
#define speedPinR 5    // Needs to be a PWM pin to be able to control motor speed

#define SERVO_PIN     9  //servo connect to D9

#define Echo_PIN    11 // Ultrasonic Echo pin connect to D11
#define Trig_PIN    12  // Ultrasonic Trig pin connect to D12

#define BUZZ_PIN     3

#define SPEED  200     //both sides of the motor speed
#define BACK_SPEED1  100     //back speed
#define BACK_SPEED2  150     //back speed

int leftscanval, centerscanval, rightscanval, ldiagonalscanval, rdiagonalscanval;
const int distancelimit = 30; //distance limit for obstacles in front           
const int sidedistancelimit = 30; //minimum distance in cm to obstacles at both sides (the car will allow a shorter distance sideways)
int distance;
int numcycles = 0;
const int turntime = 800; //Time the robot spends turning (miliseconds)
const int backtime = 600; //Time the robot spends turning (miliseconds)

int thereis;
