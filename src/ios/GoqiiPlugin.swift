
import Foundation
import GOQiiSDK
import CoreBluetooth

@objc(GoqiiPlugin) class GoqiiPlugin: CDVPlugin {
    var peripheral: CBPeripheral?
//    var initGoqiiGlucometerSettingsCallbackId: String?
//    var initializeSDKCallbackId: String?
//    var searchCallbackId: String?
//    var dataCallbackId: String?
    var bluetoothManager: CBCentralManager!
    var resultListenerCallBackId: String?

    override func pluginInitialize() {
        print("GoqiiPlugin pluginInitialize")
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        //GlucoBLEManager.shared
    }

//    @objc(initGoqiiGlucometerSettings:)
//    func initGoqiiGlucometerSettings(command: CDVInvokedUrlCommand) {
//    print("initGoqiiGlucometerSettings")
//        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
//        //GlucoBLEManager.shared
//        //initGoqiiGlucometerSettingsCallbackId = command.callbackId
//        if BLE.sharedInstance().isGlucoMeterConnected() {
//            print("✅ GlucoMeter is connected, starting sync... via initGoqiiGlucometerSettings")
//            GlucoBLEManager.shared.glucoBleManagerDelegate = self
//            GlucoBLEManager.shared.connectToSavedGlucometerDevice()
//
//        }
//    }

    @objc(initializeSDK:)
    func initializeSDK(command: CDVInvokedUrlCommand) {
        print("🟢 initializeSDK called... isGlucoMeterConnected = \(BLE.sharedInstance().isGlucoMeterConnected())")

        //initializeSDKCallbackId = command.callbackId
        GlucoBLEManager.shared.glucoBleManagerDelegate = self
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "SDK initialized with Bluetooth ON", "methodType":"initializeSDK"]);
         self.sendDataBackToOutSystem(pluginResult: pluginResult);

        //var pluginResult: CDVPluginResult
//        if bluetoothManager.state == .poweredOn {
//            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "SDK initialized with Bluetooth ON", "methodType":"initializeSDK"]);
//        } else {
//            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Bluetooth is OFF. Please enable Bluetooth.")
//        }
        
       // self.sendDataBackToOutSystem(pluginResult: pluginResult);

       // self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        
//        if BLE.sharedInstance().isGlucoMeterConnected() {
//            print("✅ GlucoMeter is connected, starting sync... via initGoqiiGlucometerSettings")
//            GlucoBLEManager.shared.glucoBleManagerDelegate = self
//            GlucoBLEManager.shared.connectToSavedGlucometerDevice()
//        }
    }

@objc(searchGlucometer:)
func searchGlucometer(command: CDVInvokedUrlCommand) {
    print("🔍 searchGlucometer called...")

    //searchCallbackId = command.callbackId

    if bluetoothManager.state != .poweredOn {
        print("⚠️ Bluetooth is OFF. Cannot scan.")
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Bluetooth is OFF")
        self.sendDataBackToOutSystem(pluginResult: pluginResult)
        //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        return
    }

    print("🚀 Starting BLE scan")
    GlucoBLEManager.shared.startBLE()

    if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Searching for Glucometers...","methodType":"searchGlucometer"]) {
        
        self.sendDataBackToOutSystem(pluginResult: pluginResult);
        
//        pluginResult.setKeepCallbackAs(true)
//        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
}


    @objc(connectGlucometer:)
    func connectGlucometer(command: CDVInvokedUrlCommand) {
        print("🔗 connectGlucometer called...")

        guard let peripheral = self.peripheral else {
            print("⚠️ No glucometer found to connect.")
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No glucometer found to connect.")
            self.sendDataBackToOutSystem(pluginResult: pluginResult)
            //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }

        print("🔗 Connecting to Glucometer: \(peripheral.name ?? "Unknown")")
        GlucoBLEManager.shared.connect(peripheral: peripheral)

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Connect Glucometer started, mac = \(peripheral.identifier.uuidString)", "methodType":"connectGlucometer"])
        
        self.sendDataBackToOutSystem(pluginResult: pluginResult)
        //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(syncGlucometer:)
    func syncGlucometer(command: CDVInvokedUrlCommand) {
        print("🔄 syncGlucometer called...")

        GlucoBLEManager.shared.glucoBleManagerDelegate = self
        //dataCallbackId = command.callbackId

        if BLE.sharedInstance().isGlucoMeterConnected() {
            print("✅ GlucoMeter is connected, starting sync...")
            GlucoBLEManager.shared.connectToSavedGlucometerDevice()

            // let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Sync Glucometer started"])
            // self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)

        } else {
            print("❌ GlucoMeter not connected. Ensure it is paired.")
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "GlucoMeter not connected. Ensure it is paired to fetch data.")
            self.sendDataBackToOutSystem(pluginResult: pluginResult)
            //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(unlinkGlucometer:)
    func unlinkGlucometer(command: CDVInvokedUrlCommand) {
        print("🔌 unlinkGlucometer called...")

        let result = BLE.sharedInstance().unlinkGlucoMeter()
        var pluginResult:CDVPluginResult!
        if(result){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data":  "Unlink Glucometer successful", "methodType": "unlinkGlucometer"])
        }
        else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Unlink Glucometer failed")
        }
        self.sendDataBackToOutSystem(pluginResult: pluginResult)
        //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(resultListener:)
    func resultListener(command: CDVInvokedUrlCommand) {
        print("🔌 result listener called...")
        resultListenerCallBackId = command.callbackId

    }
}

//MARK:- Helping Methods
extension GoqiiPlugin {
    func sendDataBackToOutSystem(pluginResult:CDVPluginResult?, keepCallback: Bool = false){
        
        if let callbackId = self.resultListenerCallBackId, let pluginResultRef = pluginResult {
            pluginResultRef.setKeepCallbackAs(true)
            self.commandDelegate!.send(pluginResultRef, callbackId: callbackId)
        }
    }
    
}

// MARK: - Bluetooth Delegate
extension GoqiiPlugin: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         switch central.state {
         case .poweredOn:
             print("✅ Bluetooth is ON")
         case .poweredOff:
             print("❌ Bluetooth is OFF")
             let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Bluetooth is OFF. Please enable Bluetooth.")
             self.sendDataBackToOutSystem(pluginResult: pluginResult);
         case .resetting:
             print("🔄 Bluetooth is resetting")
         case .unauthorized:
             print("⚠️ Bluetooth is not authorized")
         case .unsupported:
             print("❌ Device does not support Bluetooth")
         case .unknown:
             print("🤷 Bluetooth state is unknown")
         @unknown default:
             print("⚠️ Unknown Bluetooth state")
         }
    }
}

// MARK: - Glucometer BLE Delegate
extension GoqiiPlugin: GlucoBLEManagerProtocol {
func BLEactivated(state: Bool) {
    print("💡 BLE Activated: \(state)")

    if state { GlucoBLEManager.shared.startScanning() }
    
    

   // if let callbackId = initializeSDKCallbackId {
//    let deviceInfo = ["BLEState": "\(state)", "methodType":"BLEactivated"];
//        if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: deviceInfo) {
//           // pluginResult.setKeepCallbackAs(true)
//            self.sendDataBackToOutSystem(pluginResult: pluginResult);
//            //self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
   // }
}


func BLEfoundPeripheral(device: CBPeripheral, rssi: Int, mac: String) {
    print("📡 Found Device: \(device.name ?? "Unknown") | RSSI: \(rssi) | MAC: \(mac)")

    let connectedMACID = GlucoBLEManager.shared.getGlucoUUID()
    print("🔗 Previously Connected MAC: \(connectedMACID ?? "None")")

    // Check if a device is already assigned
    if self.peripheral == nil {
        print("ℹ️ No previously assigned peripheral.")
    } else {
        print("✔️ A peripheral was already assigned.")
    }

    // Check if a device is already connected
    if BLE.sharedInstance().isGlucoMeterConnected() {
        print("✅ A GlucoMeter is already connected.")
    } else {
        print("❌ No GlucoMeter is currently connected.")
    }

    // Assign the peripheral if it is not set, and the connected MAC matches
    if self.peripheral == nil,
       BLE.sharedInstance().isGlucoMeterConnected(),
       connectedMACID == mac {
        self.peripheral = device
        print("🔄 Assigned new peripheral as it matches previous connection.")
        
        if let tempPer = self.peripheral{
        GlucoBLEManager.shared.connect(peripheral: tempPer)
        
        }
        if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Device Searched and Connected Successfully","methodType":"connectGlucometer"]) {
            
            self.sendDataBackToOutSystem(pluginResult: pluginResult);
            
    //        pluginResult.setKeepCallbackAs(true)
    //        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
    } else {
        self.peripheral = device
        if device.state == .disconnected,BLE.sharedInstance().isGlucoMeterConnected(), connectedMACID == mac {
            print("🔄 Assigned new peripheral as it matches previous connection. 222")
            if let tempPer = self.peripheral{
            GlucoBLEManager.shared.connect(peripheral: tempPer)
                if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Device Searched and Connected Successfully","methodType":"connectGlucometer"]) {
                    
                    self.sendDataBackToOutSystem(pluginResult: pluginResult);
                    
            //        pluginResult.setKeepCallbackAs(true)
            //        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
        else if connectedMACID == "" {
            GlucoBLEManager.shared.connect(peripheral: device) ;
            if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "Device Searched and Connected Successfully","methodType":"connectGlucometer"]) {
                
                self.sendDataBackToOutSystem(pluginResult: pluginResult);
                
        //        pluginResult.setKeepCallbackAs(true)
        //        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        }
        
        print("🔄 Assigned the found peripheral.")
        
        
    }

    // Send response if searchCallbackId is available
    //if let callbackId = searchCallbackId {
        print("💡 Responding to search callback...")
        //searchCallbackId = nil
//        let deviceInfo: [String: String] = [
//            "name": device.name ?? "Unknown",
//            "macId": mac,
//            "rssi": "\(rssi)"
//        ]
//        if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: deviceInfo) {
//            //pluginResult.setKeepCallbackAs(true)
//            self.sendDataBackToOutSystem(pluginResult: pluginResult)
//            //self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
    //}
}

    func BLEready(RACPcharacteristic: CBCharacteristic) {
        print("✅ BLEready Glucometer is ready for data sync. Ensure device is paired.")
    }

func glucoMeterData(_ data: [Any]) {
    print("📊 Received Glucometer Data: \(data)")
    
    var f = " \(data)";
   f =  f.replacingOccurrences(of: "[", with: "{")
    f = f.replacingOccurrences(of: "]", with: "}")
    
    var newStr = ""

    for (x, char) in f.enumerated() {
       if x ==  f.distance(from: f.startIndex, to: f.firstIndex(of: "{")!) {
          newStr.append("[")
       } else if x == f.distance(from: f.startIndex, to: f.lastIndex(of: "}")!){
           newStr.append("]")
       }
        else {
          newStr.append(char)
       }
    }
    
//    if let i = f.firstIndex(of: "{") {
//      let index: Int = f.distance(from: f.firstIndex(of: "{")!, to: i)
//      print(index) // Prints 4
//    }
    
    
    
    //
    if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": newStr, "methodType" : "glucometerData"]) {
        self.sendDataBackToOutSystem(pluginResult: pluginResult);
    }

//    if let callbackId = dataCallbackId {
//        print("💡 Sending data callback with dataCallbackId")
//        if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "\(data)"]) {
//            pluginResult.setKeepCallbackAs(true)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
//    }else if let callbackId = initGoqiiGlucometerSettingsCallbackId{
//        print("💡 Sending data callback with initGoqiiGlucometerSettingsCallbackId")
//        if let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ["data": "\(data)"]) {
//            pluginResult.setKeepCallbackAs(true)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
//    }
}

    func BLESyncCompleted() {
        print("✅ Glucometer Data Sync Completed.")
    }
}


