/**
 * OmniBLE.h - Library for handling Bluetooth Operations with Omnibot
 */

#ifndef OmniBLE_h
#define OmniBLE_h
 
#include "Arduino.h"
#include <SoftwareSerial.h>
#include <String.h>


class OmniBLE{
    
 
  public:
    OmniBLE(int rx,int tx);
    OmniBLE();
    ~OmniBLE();
    void begin(long baudRate = 115200);
    void sync();
    float velocityValue();
    float speedValue();
    float turnValue();
    boolean autopilotValue();
    char cardinalDirection();
    void sendMessage(String message,boolean newLine = false);
    void sendProximityMeasurements(float measurements[],int arrLength);
    void setPeripheralName(String name,unsigned long timeout = 5000);
    String mostRecentCommand();
    
    // Some defaults
    boolean printDebugToSerial = false;
    float turnThreshhold = 0.25f;
    String incomingCommandPrefix = "C";
    String outgoingProxPrefix = "P";
    unsigned int maxInputStringLength = 100;
    
   
  private:
    int rxPin;
    int txPin;
    String currentCommand;
    String extractedData[3];
    SoftwareSerial *bluetoothLE;
     boolean useSerialChannel = false;

    void parseCommand(String message,String expectedType);
    String getSerialInput();
    String getSoftwareInput();


  
};



#endif
