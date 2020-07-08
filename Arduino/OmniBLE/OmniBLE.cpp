#include "OmniBLE.h"


OmniBLE::OmniBLE(int rx,int tx){
  rxPin = rx;
  txPin = tx;
  bluetoothLE = new SoftwareSerial(rxPin,txPin);
  
}
OmniBLE::~OmniBLE(){
    free(bluetoothLE);
}

void OmniBLE::begin(long baudRate){
    bluetoothLE->begin(baudRate);
    if(printDebugToSerial)
        Serial.println("[OmniBLE::begin()] Started OmniBLE at baud "+String(baudRate));
}

void OmniBLE::sync(){
    String inputCommand = "";
    while(bluetoothLE->available() > 0){
        char streamChar = bluetoothLE->read();
        inputCommand += streamChar;

        if (streamChar == '\n'){
            break;
        }
    }
    // Assign the current command
    if(!inputCommand.equals("")){
        currentCommand = inputCommand;
        parseCommand(currentCommand,incomingCommandPrefix);
        
        if(printDebugToSerial)
            Serial.println("[OmniBLE::sync()] Recieved Commmand: "+currentCommand);
    }
}

float OmniBLE::turnValue(){
    float extractedVal = 0.0f;
    if (!extractedData[0].equals(""))
        extractedVal = extractedData[0].toFloat();
    
    return extractedVal;
}

float OmniBLE::velocityValue(){
    float extractedVal = 0.0f;
    if (!extractedData[1].equals(""))
        extractedVal = extractedData[1].toFloat();
    return extractedVal;
}

boolean OmniBLE::autopilotValue()
{
    float extractedVal = false;
    if (!extractedData[2].equals(""))
       extractedVal = (boolean)extractedData[2].toInt();
    return extractedVal;
}

char OmniBLE::cardinalDirection(){
    char direction = 'N';
    float turnVal = turnValue();
    float velocityVal = velocityValue();
    
    // Left/right will take priority over north/south
    if(turnVal < -turnThreshhold)
        direction = 'W';
    else if(turnVal > turnThreshhold)
        direction = 'E';
    else if (velocityVal < 0.0)
        direction = 'S';
    else
        direction = 'N';
    
    return direction;
}

float OmniBLE::speedValue(){
    return abs(velocityValue());
}




void OmniBLE::sendMessage(String message,boolean newLine)
{
    if(newLine)
        bluetoothLE->println(message);
    else
        bluetoothLE->print(message);
    
    if(printDebugToSerial)
            Serial.println("[OmniBLE::sendMessage()] Sent Message: "+message);
    
    
}

String OmniBLE::mostRecentCommand(){
    return currentCommand;
}


void OmniBLE::sendProximityMeasurements(float measurements[],int arrLength)
{
    String measureString = outgoingProxPrefix+":";
    
    for(int i = 0; i < arrLength; i++){
        measureString+=String(round(measurements[i] * 10) / 10);
        if (i < arrLength - 1)
            measureString+=",";
    }
    
    sendMessage(measureString);
    
}

void OmniBLE::setPeripheralName(String name,unsigned long timeout)
{
    
    unsigned long startTime = millis();
    String bluetoothName = "";

    // Try for 5 seconds before giving up ~ approx 10 tries
    while(millis() - startTime < timeout){
       bluetoothLE->print("AT+NAME?");
       // Read for 250 ms or until the change takes place
       unsigned long readTime = millis();
       while(millis() - readTime < 250)
       {
           bluetoothName = bluetoothLE->readString();
           if(bluetoothName.equals(name)){
               if(printDebugToSerial)
                    Serial.println("[OmniBLE::setPeripheralName()] Successfully Set BT Name: "+name);
               
               return;
               
           }
       }

       // Else set the name and try again
       bluetoothLE->print("AT+NAME"+name);
        delay(100);
     }
    
    if(printDebugToSerial)
        Serial.println("[OmniBLE::setPeripheralName()] Failed to Set BT Name: "+name+". Current Name: "+bluetoothName);
}

void OmniBLE::parseCommand(String commandString,String expectedType){
  int dividerIndex = commandString.indexOf(':');
  String commandType = (String)commandString.substring(0,dividerIndex);
  
    // If it is not the data type we are currently looking for leave the loop
   if(!commandType.equals(expectedType))
        return;
     
  String dataString = commandString.substring(dividerIndex+1);
  int itemCount = 0;

  while (!dataString.equals("")){
    int endIndex = dataString.indexOf(",");
    
    if (endIndex != -1){
       String newItem = dataString.substring(0,endIndex);
       dataString.remove(0,endIndex+1); //Get the item with the comma attached
       extractedData[itemCount] = newItem;
       itemCount++;
     }
    else{
       extractedData[itemCount] = dataString; //Last item in data string
       dataString.remove(0,dataString.length()); //Empty the string
       itemCount++;
    }
    
 }
}
