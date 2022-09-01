#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <DNSServer.h>
#include <WiFiManager.h>
#include <Wire.h>
#include <Ticker.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>
const char* mqtt_server = "ngoinhaiot.com"; //server
int mqtt_port = 1111; // port
const char* mqtt_user = "doanlong28012000asdasd"; // user mqtt
const char* mqtt_pass = "3F405128F5C349A9"; // pass mqtt
String topicsub = "doanlong28012000asdasd/quat"; // topic nhận dữ liệu ESP
String topicpub = "doanlong28012000asdasd/maylanh"; // topic gửi dữ liệu
unsigned long last1 = millis();
unsigned long last = millis();
 String DataMqtt ="";
 int DA2 =0;
 int ND1 = 0 ;
WiFiClient espClient;
PubSubClient client(espClient);
void ConfigWifi();
void ConnectMQTT();
ESP8266WebServer server(80);
#include <DHT.h>
#define chandht 5
#define loaidht DHT11

DHT dht(chandht,loaidht);
const char* ssid = "Team ACE";
const char* pass = "yolodianhem";
#define LED1 14 //D5
#define LED2 12 //D6
#define LED 2 
#define BUTTON1 4 //D2
#define BUTTON2 0 //D3
int TB1=0;
int TB2=0;
float ND,DA;
String DataMQTT = "";
bool connec = false;
Ticker ticker;
void setup() 
{
  Serial.begin(9600);
  pinMode(LED1,OUTPUT);
  pinMode(LED2,OUTPUT);
  pinMode(LED,OUTPUT);
  digitalWrite(LED,HIGH);
  pinMode(BUTTON1,INPUT_PULLUP);
  pinMode(BUTTON2,INPUT_PULLUP);
  delay(1000);
  BeginDHT();
  delay(1000);
 
  
   ConfigWifi();
   delay(1000);
  ConnectMQTT();
  delay(1000);
  connectwifi();
}


void loop() 
{
  DuytriMQTT();
  Nutnhan();
  Send_MQTT();
}
void connectwifi()
{
    if(WiFi.status() == WL_CONNECTED)
    {
      digitalWrite(LED,LOW);
    }
  
}

void ConnectMQTT()
{
  client.setServer(mqtt_server,mqtt_port);
  delay(10);
  client.setCallback(Callback);
  delay(10);
}
void reconnect()
{
  while(!client.connected())
  {
    String clientId = String(random(0xfff),HEX);
    if(client.connect(clientId.c_str(),mqtt_user,mqtt_pass))
    {
      Serial.println("Connected MQTT");
      client.subscribe(topicsub.c_str()); 
    }
    else
    {
      Serial.println("Disconnect MQTT");
      delay(2000);
    }
  }
}
void Callback(char* topic,byte* payload,unsigned int length)
{ String DataM = "";
  Serial.println("Data TOPIC :");
  for( int i = 0; i  < length ;i++)
  {
    DataM += (char)payload[i];
  }
  Serial.print("Data nhận MQTT: ");
  Serial.println(DataM);
  ParseJson(String(DataM));
  last = millis();
  last1 = millis();

  DataM = "";
}
void tick()
{
  int p = digitalRead(LED);
  digitalWrite(LED,!p);
}
void ParseJson(String Data)
{
  //{"TB1":"1"}
  //{"TB1":"0"}
  //{"TB2":"1"}
  //{"TB2":"0"}
  const size_t capacity = JSON_OBJECT_SIZE(2) + 256;
  DynamicJsonDocument JSON(capacity);
  DeserializationError error = deserializeJson(JSON, Data);
  if (error)
  {
    Serial.println("Data JSON Error!!!");
    return;
  }
  else
  {
    Serial.println();
    Serial.println("Data JSON MQTT: ");
    serializeJsonPretty(JSON, Serial);

    if (JSON["TB1"]=="1")
    {
      digitalWrite(LED1,HIGH);
          TB1 = 1;
    }
    else if (JSON["TB1"]=="0")
    {
      digitalWrite(LED1,LOW);
          TB1 = 0;
    }
    else if (JSON["TB2"]=="1")
    {
      digitalWrite(LED2,HIGH);
          TB2 = 1;
    }
    else if (JSON["TB2"]=="0")
    {
      digitalWrite(LED2,LOW);
          TB2 = 0;
    }
    JSON.clear();

  }
}
void Nutnhan()
{
  Nut1();
  Nut2();
}
void Nut1()
{
  if( digitalRead(BUTTON1)== 0 )
  {
    while(1)
    {  DuytriMQTT();
       Send_MQTT();
      delay(100);
      if(digitalRead(BUTTON1)== 1)
      {
        DK_DEN();
      }
      break;
    }
  }
}
void Nut2()
{
  if( digitalRead(BUTTON2)== 0 )
  {
    while(1)
    {  DuytriMQTT();
       Send_MQTT();
      delay(100);
      if(digitalRead(BUTTON2)== 1)
      {
        
        DK_QUAT();
      }
      break;
    }
  }
}
void DuytriMQTT()
{
  if(!client.connected())
  {
    reconnect();
  }
  client.loop();
  
}

void Send_MQTT()
{
  if( millis() - last > 1000)
  {
    if(WiFi.status()== WL_CONNECTED)
    {
      if(client.connected())
      {
        Read_DHT11();
        //CamBien();
        DataJson( String(ND),  String(DA) ,  String(TB1) , String(TB2));
        Serial.println("Data MQTT :");
        Serial.println(DataMqtt);
        client.publish(topicpub.c_str(),DataMqtt.c_str());
        last = millis();
      }
    }
  }
}
void configModeCallback (WiFiManager *myWiFiManager)
{
  Serial.println("Kết Nối Mode WIFI");
  Serial.println(WiFi.softAPIP());
  Serial.println(myWiFiManager->getConfigPortalSSID());
}
void ConfigWifi()
{
  delay(5000);
  WiFiManager wifiManager;
  wifiManager.setAPCallback(configModeCallback);
  wifiManager.autoConnect("ESPWIFICONFIG", "12345678");
}
void Read_DHT11()
{    
  float a = dht.readHumidity();
  float b = dht.readTemperature();
  if (isnan(a) || isnan(b))
  {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
  DA = a;
  ND = b;
  Serial.print("Nhiệt độ:");
  Serial.println(ND);
  Serial.print("Độ Ẩm:");
  Serial.println(DA);
}
void CamBien()
{
  ND1 = ND1 + 1;
  DA2 = DA2 +2;
}
void BeginDHT()
{
  dht.begin();
  delay(100);
}
void DataJson( String ND,  String DA ,  String TB1 , String TB2)
{
      DataMqtt = "{\"ND\":\"" + String(ND) + "\"," +
                 "\"DA\":\"" + String(DA) + "\"," +
                 "\"TB1\":\"" + String(TB1) + "\"," +
                 "\"TB2\":\"" + String(TB2) + "\"}";
}
void DK_DEN()
{
Serial.println("Onclick ĐÈN ");
   if( TB1 == 0 )
        {
          digitalWrite(LED1,HIGH);
           TB1 = 1;
        }
        else
        {
        digitalWrite(LED1,LOW);
          TB1 = 0;
        }
}
void DK_QUAT()
{
     Serial.println("Onclick QUẠT ");
        if( TB2 == 0 )
        {
          digitalWrite(LED2,HIGH);
            TB2 = 1;
        }
        else
        {
        digitalWrite(LED2,LOW);
        TB2 = 0;
        }
}
