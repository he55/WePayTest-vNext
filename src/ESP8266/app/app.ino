#include <WiFiManager.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <LittleFS.h>

#define URLPATH "/url"
#define DEFINT 5000
#define PLED LED_BUILTIN

String payurl;
long interval = DEFINT;

ESP8266WebServer server(80);
String postForms = "<html>\
  <head>\
    <title>ESP8266 Settings</title>\
    <style>\
      body { background-color: #cccccc; font-family: Arial, Helvetica, Sans-Serif; Color: #000088; }\
    </style>\
  </head>\
  <body>\
    <h1>Settings</h1><br>\
    <form method=\"post\" enctype=\"application/x-www-form-urlencoded\" action=\"/saveurl/\">\
      URL: \
      <input type=\"text\" name=\"url\" value=\"{{url}}\"><br>\
      Interval: \
      <input type=\"text\" name=\"interval\" value=\"{{interval}}\"><br>\
      <input type=\"submit\" value=\"Save\">\
    </form>\
  </body>\
</html>";

void handleRoot() {
  String html = postForms;
  html.replace("{{url}}", payurl);
  html.replace("{{interval}}", String(interval));
  server.send(200, "text/html", html);
}

void handleForm() {
  payurl = server.arg("url");
  long val = server.arg("interval").toInt();
  interval = val > 0 ? val : DEFINT;

  File file = LittleFS.open(URLPATH, "w");
  if (file) {
    file.print(payurl);
    file.print("\n");
    file.print(interval);
    file.close();
  }

  server.sendHeader("Location", "/");
  server.send(301);
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

void payLedBlink() {
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
  if (payurl.isEmpty()) {
    return;
  }

  WiFiClient client;
  HTTPClient http;

  Serial.print("[HTTP] begin...\n");
  if (http.begin(client, payurl)) {  // HTTP
    Serial.printf("[HTTP] GET %s ...\n", payurl.c_str());

    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if (httpCode > 0) {
      // HTTP header has been send and Server response header has been handled
      Serial.printf("[HTTP] GET... code: %d\n", httpCode);

      // file found at server
      if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
        String str = http.getString();
        Serial.println(str);
        long val = str.toInt();
        static long lastPayTime;
        if (lastPayTime != 0 && val > lastPayTime) {
          payLedBlink();
        }
        lastPayTime = val;
      }
    } else {
      Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
  } else {
    Serial.println("[HTTP] Unable to connect");
  }
}

void setup() {
  pinMode(PLED, OUTPUT);
  digitalWrite(PLED, LOW);

  // WiFi.mode(WIFI_STA); // explicitly set mode, esp defaults to STA+AP
  // it is a good practice to make sure your code sets wifi mode how you want it.

  // put your setup code here, to run once:
  Serial.begin(9600);
  LittleFS.begin();

  File file;
  if (LittleFS.exists(URLPATH) && (file = LittleFS.open(URLPATH, "r"))) {
    payurl = file.readStringUntil('\n');
    interval = file.readStringUntil('\n').toInt();
    file.close();
  }

  //WiFiManager, Local intialization. Once its business is done, there is no need to keep it around
  WiFiManager wm;

  // reset settings - wipe stored credentials for testing
  // these are stored by the esp library
  // wm.resetSettings();

  // Automatically connect using saved credentials,
  // if connection fails, it starts an access point with the specified name ( "AutoConnectAP"),
  // if empty will auto generate SSID, if password is blank it will be anonymous AP (wm.autoConnect())
  // then goes into a blocking loop awaiting configuration and will return success result

  bool res = wm.autoConnect("ESP8266", "password");  // password protected ap

  if (!res) {
    Serial.println("Failed to connect");
    // ESP.restart();
  } else {
    //if you get here you have connected to the WiFi
    Serial.println("connected...yeey :)");

    server.on("/", HTTP_GET, handleRoot);
    server.on("/saveurl/", HTTP_POST, handleForm);
    server.onNotFound(handleNotFound);
    server.begin();
    Serial.println("HTTP server started");
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  server.handleClient();

  static long nextStopTime = millis() + interval;
  if (millis() > nextStopTime) {
    getPayState();
    nextStopTime = millis() + interval;
  }
}
