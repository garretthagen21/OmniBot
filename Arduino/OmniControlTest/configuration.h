/*Declare L298N Dual H-Bridge Motor Controller directly since there is not a library to load.*/
//Define L298N Dual H-Bridge Motor Controller Pins
#define dir1PinL  10    //Motor direction
#define dir2PinL  9    //Motor direction
#define speedPinL 2    // Needs to be a PWM pin to be able to control motor speed

#define dir1PinR  3    //Motor direction
#define dir2PinR  11   //Motor direction
#define speedPinR 4    // Needs to be a PWM pin to be able to control motor speed

#define Echo_PIN_FL    A4 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_FL    8  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_FR    A3 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_FR    7  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_L    A4 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_L    12  // Ultrasonic Trig pin connect to D12

#define Echo_PIN_R    A5 // Ultrasonic Echo pin connect to D11
#define Trig_PIN_R    13  // Ultrasonic Trig pin connect to D12


#define SPEED  200     //both sides of the motor speed
#define BACK_SPEED1  100     //back speed
#define BACK_SPEED2  150     //back speed
         
const int sidedistancelimit = 30; //minimum distance in cm to obstacles at both sides (the car will allow a shorter distance sideways)
const int NUM_SONIC_SENSORS = 4;
const int numcycles = 0;
const int turn_time = 400; //Time the robot spends turning (miliseconds)
const int back_time = 300; //Time the robot spends turning (miliseconds)
const int up_bound = 10; //cm
const int lo_bound = 2; //cm

const int test_len = 5000;
const int stop_len = 1000;

int distance, thereis, dis_FL, dis_FR, dis_L, dis_R, spd;
