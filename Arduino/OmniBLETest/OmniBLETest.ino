
#include <OmniBLE.h>

OmniBLE botBT(3,4);

// Test values to emulate proximity values from ultrasonic sensors
const int NUM_SONIC_SENSORS = 4;
float sensorProximities[NUM_SONIC_SENSORS] = { 1.1, 2.2, 3.1,4.5};

void setup() {
  
  // For debugging
  Serial.begin(9600); 
  botBT.printDebugToSerial = false;
  botBT.begin(9600);

  // Note: We probably only need to do this once and were good
  //botBT.setPeripheralName("OmniBot");
  
}

void loop() {
  
  // Update our botBT with the latest data
  botBT.sync();
  
  // Print the stats
  //Serial.println("");
  //Serial.println("---------------------------------------");
  Serial.println("Current Command: "+botBT.mostRecentCommand());
  //Serial.println("Turning Value: "+String(botBT.turnValue()));
  //Serial.println("Velocity Value: "+String(botBT.velocityValue()));
  //Serial.println("Autopilot Value: "+String(botBT.autopilotValue()));

  // Send sensor vals
  botBT.sendProximityMeasurements(sensorProximities,NUM_SONIC_SENSORS);

  

  delay(100);

}
