#define SOFT_MODEM_DEBUG 1
#include <SoftModem.h> // include the library
#include <ctype.h>

SoftModem modem; // create an instance of Softmodem

void setup()
{
  Serial.begin(9600);
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
  if (time < millis()) {
    Serial.print("ints: ");
    Serial.print(modem.ints);
    Serial.print(":");
    Serial.println(modem._ints);
    Serial.print("errs: ");
    Serial.print(modem.errs, DEC);
    Serial.print(":");
    Serial.println(modem._errs, DEC);
    time = millis() + 10000;
  }
  while (modem.available()) { // Make sure iPhone is receiving data from
    int c = modem.read(); // Read 1byte
    if (isprint(c)) {
      Serial.print("received: ");
      Serial.println((char) c); // send to PC
    }
    else {
      Serial.print("("); // Hex printable characters are displayed in
      Serial.print(c, HEX );
      Serial.println(")");      
    }
  }
  while (Serial.available()) { // Make sure that the PC receives data from
    char c = Serial.read(); // Read 1byte
    Serial.print("r: ");
    Serial.println(c);
    if (c == 'c') {
      modem.begin();
      delay(100);
      modem.write(c);
    }
#ifdef SOFT_MODEM_DEBUG
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
    else
      modem.write(c); // send to iPhone
  }
}
