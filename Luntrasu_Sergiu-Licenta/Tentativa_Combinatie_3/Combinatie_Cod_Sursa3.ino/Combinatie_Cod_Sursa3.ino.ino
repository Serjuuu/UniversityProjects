#define BLYNK_PRINT Serial
#define BLYNK_TEMPLATE_ID "TMPL4NwQazeOV"
#define BLYNK_TEMPLATE_NAME "Smart Home"
#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>
#include <DHT.h>

char auth[] = "fmFqBCHYLGyNguuVB1XGrIxtEVVXghtv"; // Enter your Blynk auth token 
char ssid[] = "S-302"; // Enter your WIFI name
char pass[] = "@Control"; // Enter your WIFI password

#define LED1 D5
#define LED2 D6
#define Buzzer D7
#define Sensor D0
#define MQ2    A0
#define Buzzer_MQ2 D3

int pinValue = 0;

BlynkTimer timer;
int data = 0;
const int DHTPIN = D1;   
const int DHTTYPE = DHT11;
DHT dht(DHTPIN, DHTTYPE);

float humidity;
float temperature;
float gas;

void setup() {
  Serial.begin(9600);
  pinMode(D2, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(Buzzer, OUTPUT);
  pinMode(Buzzer_MQ2, OUTPUT);
  pinMode(Sensor, INPUT_PULLUP);
  pinMode(MQ2, INPUT); 
  Blynk.begin(auth, ssid, pass, "blynk.cloud", 80);

  dht.begin();
  timer.setInterval(1000L, checkSensor);
}

BLYNK_WRITE(V0) {
  pinValue = param.asInt();
  digitalWrite(D2, pinValue); 
}

BLYNK_WRITE(V1) {
  pinValue = param.asInt();
  digitalWrite(LED2, pinValue); 
}


void checkSensor() {
  int sensorState = digitalRead(Sensor);
  if (digitalRead(LED2) == HIGH) {
  if (sensorState == LOW) {
    digitalWrite(LED1, HIGH);
    digitalWrite(Buzzer, HIGH);
    Blynk.logEvent("fire_detected");
  } else {
    digitalWrite(Buzzer, LOW);
    digitalWrite(LED1, LOW);
  }
  } 

  // Read sensor data
  humidity = dht.readHumidity();
  temperature = dht.readTemperature();
  int gas = analogRead(MQ2);
  if (gas < 1000)
  {
    digitalWrite(Buzzer_MQ2, LOW);
  } else if (gas >= 1000) {
    digitalWrite(Buzzer_MQ2, HIGH);
    Blynk.logEvent("gas_leak");
  }
  Serial.print("Temperature: ");
  Serial.println(temperature);
  Serial.print("Humidity: ");
  Serial.println(humidity);
  Serial.print("Gas Level: ");
  Serial.println(gas);

  // Check if any reading failed
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Send data to the server
  String postData = "temperature=" + String(temperature) + "&humidity=" + String(humidity) + "&gas=" + String(gas);

  if (sendDataToServer(postData)) {
    Serial.println("Data sent successfully");
  } else {
    Serial.println("Data sending failed");
  }
  Blynk.virtualWrite(V4, temperature);  
  Blynk.virtualWrite(V5, humidity); 
  Blynk.virtualWrite(V7, gas);
}

bool sendDataToServer(String data) {


  WiFiClient client;
  if (client.connect("192.168.0.101", 80)) {
    client.print("POST /testcode/connect.php HTTP/1.1\r\n");
    client.print("Host: 192.168.0.101\r\n");
    client.print("Connection: close\r\n");
    client.print("Content-Type: application/x-www-form-urlencoded\r\n");
    client.print("Content-Length: ");
    client.print(data.length());
    client.print("\r\n\r\n");
    client.print(data);

    return true;
  } else {
    return false;
  }
}

void loop() {
  Blynk.run();
  timer.run();
}