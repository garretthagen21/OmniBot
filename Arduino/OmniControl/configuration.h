/*Declare L298N Dual H-Bridge Motor Controller directly since there is not a library to load.*/
//Define L298N Dual H-Bridge Motor Controller Pins
#define dir1PinL  2    //Motor direction
#define dir2PinL  4    //Motor direction
#define speedPinL 6    // Needs to be a PWM pin to be able to control motor speed

#define dir1PinR  7    //Motor direction
#define dir2PinR  8   //Motor direction
#define speedPinR 5    // Needs to be a PWM pin to be able to control motor speed

#define Echo_PIN_FL    11 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_FL    12  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_FR    11 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_FR    12  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_L    11 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_L    12  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_R    11 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_R    12  // Ultrasonic Trig pin connect to D12


#define SPEED  200     //both sides of the motor speed
#define BACK_SPEED1  100     //back speed
#define BACK_SPEED2  150     //back speed

const int distancelimit = 30; //distance limit for obstacles in front           
const int sidedistancelimit = 30; //minimum distance in cm to obstacles at both sides (the car will allow a shorter distance sideways)
const int NUM_SONIC_SENSORS = 4;
int distance;
int numcycles = 0;
const int turn_time = 400; //Time the robot spends turning (miliseconds)
const int back_time = 300; //Time the robot spends turning (miliseconds)
const int up_bound = 10; //cm
const int lo_bound = 2; //cm

int thereis;
