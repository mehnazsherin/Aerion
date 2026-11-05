/*
 * AERION ESP32 BLE Air Monitoring Firmware
 *
 * Board: ESP32 Dev Module (or ESP32-WROOM / ESP32-S3)
 * Arduino Core for ESP32 v2.0+ or v3.0+
 *
 * Telemetry Protocol:
 * - Service UUID: 4d61716d-0001-4b10-8000-00805f9b34fb
 * - Temp Char UUID: 4d61716d-0002-4b10-8000-00805f9b34fb (READ, NOTIFY)
 * - Humidity Char UUID: 4d61716d-0003-4b10-8000-00805f9b34fb (READ, NOTIFY)
 * - Interval Char UUID: 4d61716d-0004-4b10-8000-00805f9b34fb (READ, WRITE)
 *
 * Default Device Name: AQM-Meha
 * Encoding: UTF-8 Strings (e.g., "24.5", "55.0", "5")
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID           "4d61716d-0001-4b10-8000-00805f9b34fb"
#define TEMP_CHAR_UUID         "4d61716d-0002-4b10-8000-00805f9b34fb"
#define HUMIDITY_CHAR_UUID     "4d61716d-0003-4b10-8000-00805f9b34fb"
#define INTERVAL_CHAR_UUID     "4d61716d-0004-4b10-8000-00805f9b34fb"

#define DEVICE_NAME            "AQM-Meha"

BLEServer* pServer = NULL;
BLECharacteristic* pTempChar = NULL;
BLECharacteristic* pHumidityChar = NULL;
BLECharacteristic* pIntervalChar = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;

// Default sampling interval in seconds
int samplingIntervalSeconds = 5;
unsigned long lastReadTime = 0;

// Simulated reading helpers (Replace with DHT22 / BME280 / SHT31 sensor I2C calls)
float currentTemperature = 24.2;
float currentHumidity = 54.0;

class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println(">> AERION Mobile App Connected!");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println(">> AERION Mobile App Disconnected!");
    }
};

class IntervalCharCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string rxValue = pCharacteristic->getValue();
      if (rxValue.length() > 0) {
        String valStr = "";
        for (int i = 0; i < rxValue.length(); i++) {
          valStr += rxValue[i];
        }
        int newInterval = valStr.toInt();
        if (newInterval >= 1 && newInterval <= 300) {
          samplingIntervalSeconds = newInterval;
          Serial.printf(">> Updated Sampling Interval to %d seconds\n", samplingIntervalSeconds);
          
          // Echo back confirmed value
          pCharacteristic->setValue(String(samplingIntervalSeconds).c_str());
        }
      }
    }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Starting AERION ESP32 BLE Server...");

  // Initialize BLE Device
  BLEDevice::init(DEVICE_NAME);

  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Create GATT Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Temperature Characteristic (Read + Notify)
  pTempChar = pService->createCharacteristic(
                      TEMP_CHAR_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pTempChar->addDescriptor(new BLE2902());
  pTempChar->setValue(String(currentTemperature, 1).c_str());

  // Humidity Characteristic (Read + Notify)
  pHumidityChar = pService->createCharacteristic(
                      HUMIDITY_CHAR_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pHumidityChar->addDescriptor(new BLE2902());
  pHumidityChar->setValue(String(currentHumidity, 1).c_str());

  // Sampling Interval Characteristic (Read + Write)
  pIntervalChar = pService->createCharacteristic(
                      INTERVAL_CHAR_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_WRITE
                    );
  pIntervalChar->setCallbacks(new IntervalCharCallbacks());
  pIntervalChar->setValue(String(samplingIntervalSeconds).c_str());

  // Start the Service
  pService->start();

  // Start Advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Help with iPhone BLE connection latency
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println(">> AERION ESP32 is advertising as " DEVICE_NAME);
}

void loop() {
  unsigned long now = millis();

  // Transmit telemetry periodically according to configured samplingIntervalSeconds
  if (deviceConnected && (now - lastReadTime >= (unsigned long)samplingIntervalSeconds * 1000)) {
    lastReadTime = now;

    // TODO: Read actual hardware sensor (e.g. dht.readTemperature(), bme.readHumidity())
    currentTemperature += ((random(0, 20) - 10) / 50.0);
    currentHumidity += ((random(0, 30) - 15) / 30.0);

    // Format UTF-8 decimal strings
    String tempStr = String(currentTemperature, 1);
    String humStr = String(currentHumidity, 1);

    // Update GATT characteristics and notify Flutter client
    pTempChar->setValue(tempStr.c_str());
    pTempChar->notify();

    pHumidityChar->setValue(humStr.c_str());
    pHumidityChar->notify();

    Serial.printf("[TELEMETRY] Sent -> Temp: %s C | Humidity: %s %%\n", tempStr.c_str(), humStr.c_str());
  }

  // Handle Disconnection / Re-advertising
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    pServer->startAdvertising();
    Serial.println(">> Restarted BLE advertising...");
    oldDeviceConnected = deviceConnected;
  }
  
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  delay(20);
}

