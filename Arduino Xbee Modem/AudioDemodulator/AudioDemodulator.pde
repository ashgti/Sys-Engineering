#define SOFT_MODEM_DEBUG
#include <SoftModem.h> // include the library
#include <ctype.h>

SoftModem modem; // create an instance of Softmodem

void setup()
{
  Serial.begin(57600);
  modem.begin(); // Setup () call to begin at
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(1, OUTPUT);
  digitalWrite(1, HIGH);
  digitalWrite(5, HIGH);
  digitalWrite(4, LOW);
}

unsigned long time = 0;

void loop()
{
/*  if (time < millis()) {
    Serial.print("ints: ");
    Serial.print(modem.ints);
    Serial.print(":");
    Serial.println(modem._ints);
    Serial.print("errs: ");
    Serial.print(modem.errs, DEC);
    Serial.print(":");
    Serial.println(modem._errs, DEC);
    time = millis() + 10000;
  } */
  while (modem.available()) { // Make sure iPhone is receiving data from
    int c = modem.read(); // Read 1byte
    Serial.print((char)c);
/*    if (isprint(c)) {
        Serial.print("received: ");
//      Serial.print((char) c); // send to PC
    }
    else {
      Serial.print("received: ");
      Serial.print("("); // Hex printable characters are displayed in
      Serial.print(c, HEX );
      Serial.println(")");      
    } */
  }
  while (Serial.available()) { // Make sure that the PC receives data from
    char c = Serial.read(); // Read 1byte
/*    Serial.print("r: ");
    Serial.println(c);
    if (c == 'c') {
      modem.begin();
      delay(100);
      modem.write(c);
    }
#if SOFT_MODEM_DEBUG
    else if (c == 'a') {
      Serial.print("ints: ");
      Serial.print(modem.ints);
      Serial.print(":");
      Serial.println(modem._ints);
      Serial.print("errs: ");
      Serial.print(modem.errs, DEC);
      Serial.print(":");
      Serial.println(modem._errs, DEC);
    }
    else if (c == 'v') {
      modem.demodulateTest();
    }
#endif
    else {
      Serial.print("Writing: ");
      Serial.println(c, HEX); */
      modem.write((char)c); // send to iPhone
    //}
  }
}
