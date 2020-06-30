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
    ~OmniBLE();
    void begin(long baudRate = 115200);
    void sync();
    float velocityValue();
    float turnValue();
    boolean autopilotValue();
    void sendMessage(String message,boolean newLine = false);
    void sendProximityMeasurements(float measurements[],int arrLength);
    void setPeripheralName(String name,unsigned long timeout = 5000);
    String mostRecentCommand();
    
    boolean printDebugToSerial = false;
    
   
  private:
    int rxPin;
    int txPin;
    String currentCommand;
    String extractedData[3];
    SoftwareSerial *bluetoothLE;

    void parseCommand(String message,String expectedType);

  
};



#endif
