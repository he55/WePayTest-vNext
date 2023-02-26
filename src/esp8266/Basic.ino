#include <WiFiManager.h> 
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>

#define PLED LED_BUILTIN

ESP8266WebServer server(80);
const String postForms = "<html>\
  <head>\
    <title>ESP8266 Settings</title>\
    <style>\
      body { background-color: #cccccc; font-family: Arial, Helvetica, Sans-Serif; Color: #000088; }\
    </style>\
  </head>\
  <body>\
    <h1>Set URL</h1><br>\
    <form method=\"post\" enctype=\"application/x-www-form-urlencoded\" action=\"/saveurl/\">\
      <input type=\"text\" name=\"url\" value=\"\"><br>\
      <input type=\"submit\" value=\"Save\">\
    </form>\
  </body>\
</html>";

String pUrl;
long lastPayTime;

void handleRoot() {
  server.send(200, "text/html", postForms);
}

void handleForm() {
  pUrl=server.arg("url");
    String message = "Saved:\n";
    message += "url="+pUrl;
    server.send(200, "text/plain", message);
}

void handleNotFound() {
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i = 0; i < server.args(); i++) { message += " " + server.argName(i) + ": " + server.arg(i) + "\n"; }
  server.send(404, "text/plain", message);
}

void payLedBlink(){
  digitalWrite(PLED, HIGH); 
  delay(120);
  digitalWrite(PLED, LOW); 
  delay(120);

  digitalWrite(PLED, HIGH); 
  delay(120);
  digitalWrite(PLED, LOW); 
  delay(120);

  digitalWrite(PLED, HIGH); 
  delay(120);
  digitalWrite(PLED, LOW); 
}

void getPayState() {
  if (!pUrl.isEmpty()) {
    WiFiClient client;
    HTTPClient http;

    Serial.print("[HTTP] begin...\n");
    if (http.begin(client,pUrl)) {  // HTTP
      Serial.printf("[HTTP] GET %s ...\n",pUrl.c_str());
      // start connection and send HTTP header
      int httpCode = http.GET();

      // httpCode will be negative on error
      if (httpCode > 0) {
        // HTTP header has been send and Server response header has been handled
        Serial.printf("[HTTP] GET... code: %d\n", httpCode);

        // file found at server
        if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
          String str = http.getString();
          long val=str.toInt();
          if(val>lastPayTime&&lastPayTime!=0){
            payLedBlink();
          }
          lastPayTime=val;
          Serial.println(str);
        }
      } else {
        Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
      }

      http.end();
    } else {
      Serial.println("[HTTP] Unable to connect");
    }
  }

  delay(5000);
}

void setup() {
  pinMode(PLED, OUTPUT); 
  digitalWrite(PLED, LOW); 

    // WiFi.mode(WIFI_STA); // explicitly set mode, esp defaults to STA+AP
    // it is a good practice to make sure your code sets wifi mode how you want it.

    // put your setup code here, to run once:
    Serial.begin(9600);
    
    //WiFiManager, Local intialization. Once its business is done, there is no need to keep it around
    WiFiManager wm;

    // reset settings - wipe stored credentials for testing
    // these are stored by the esp library
    // wm.resetSettings();

    // Automatically connect using saved credentials,
    // if connection fails, it starts an access point with the specified name ( "AutoConnectAP"),
    // if empty will auto generate SSID, if password is blank it will be anonymous AP (wm.autoConnect())
    // then goes into a blocking loop awaiting configuration and will return success result

    bool res;
    // res = wm.autoConnect(); // auto generated AP name from chipid
    // res = wm.autoConnect("AutoConnectAP"); // anonymous ap
    res = wm.autoConnect("AutoConnectAP","password"); // password protected ap

    if(!res) {
        Serial.println("Failed to connect");
        // ESP.restart();
    } 
    else {
        //if you get here you have connected to the WiFi    
        Serial.println("connected...yeey :)");
        
  server.on("/",HTTP_GET, handleRoot);

  server.on("/saveurl/",HTTP_POST, handleForm);

  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP server started");
    }

}

void loop() {
    // put your main code here, to run repeatedly:   
  server.handleClient();
  getPayState();
}
