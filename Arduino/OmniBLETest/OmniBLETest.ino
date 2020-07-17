
#include <OmniBLE.h>

// OmniBLE botBT(3,4); // Use this for SoftwareSerial implementation
OmniBLE botBT;        // Use this for Serial implementation

// Test values to emulate proximity values from ultrasonic sensors
const int NUM_SONIC_SENSORS = 4;
float sensorProximities[NUM_SONIC_SENSORS] = { 1.1, 2.2, 3.1,4.5 };

void setup() {
  
  // For debugging: Note do not start Serial here if using it in OmniBLE
  // Serial.begin(9600); 

  botBT.printDebugToSerial = true; // Note: This value does not matter if Serial implementation in OmniBLE is used
  botBT.begin(9600);

  // Note: This sets the broadcasting name of the HM-10 bluetooth module. We only need to do this once
  // botBT.setPeripheralName("OmniBot");
  
}

void loop() {
  
  // Update our botBT with the latest data
  botBT.sync();
  
  // Print the stats: WARNING: Doing this while OmniBLE is also using serial will cause invalid commands to be sent to the iOS App
  //Serial.println("");
  //Serial.println("---------------------------------------");
  //Serial.println("Recieved Command: "+botBT.mostRecentCommand());
  // Serial.println("Turning: "+String(botBT.turnValue())+", Velocity: "+String(botBT.velocityValue())+" Autopilot: "+String(botBT.autopilotValue()));
 
  // Note: These are the new commands where cardinalDirection() returns either N,S,E,W and speedValue() is a value from 0.0 - 1.0
  // Serial.println("Cardinal Direction: "+String(botBT.cardinalDirection()));
  // Serial.println("Speed Value: "+String(botBT.speedValue()));

  // Send sensor vals to device. Note we should only send a message when these change to avoid clobbering bluetooth channel
  // botBT.sendProximityMeasurements(sensorProximities,NUM_SONIC_SENSORS);

  
  // Should probably use a delay so bluetooth doesnt get overloaded
  delay(100);

}
