import Foundation
import GOQiiSDK
import CoreBluetooth

@objc(OmronDevicePlugin) class OmronDevicePlugin: CDVPlugin {
    var peripheral: CBPeripheral?
//    var initializeCallbackId: String?
//    var searchCallbackId: String?
//    var connectAndSyncCallbackId: String?
    var resultListenerCallBackId: String?
    //var unlinkCallbackId: String?
    //var dataCallbackId: String?
    var bluetoothManager: CBCentralManager!

    override func pluginInitialize() {
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }

    @objc(initialize:)
    func initialize(command: CDVInvokedUrlCommand) {
        print("🟢 initialize called...")

        //initializeCallbackId = command.callbackId
        OmronBluetoothManager.sharedInstance.initaliseBle()
        OmronBluetoothManager.sharedInstance.delegate = self
    }

    @objc(startScanning:)
    func startScanning(command: CDVInvokedUrlCommand) {
        print("🔍 startScanning called...")
        //searchCallbackId = command.callbackId
        if bluetoothManager.state == .poweredOn {
            OmronBluetoothManager.sharedInstance.startScanning()
        } else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Bluetooth is not enabled.")
            self.sendDataBackToOutSystem(pluginResult: pluginResult)
            //self.commandDelegate!.send(pluginResult, callbackId: searchCallbackId)
        }
    }

    @objc(connectAndSync:)
    func connectAndSync(command: CDVInvokedUrlCommand) {
        print("🔗 connectAndSync called...")
        //connectAndSyncCallbackId = command.callbackId
        OmronBluetoothManager.sharedInstance.connectAndSync()
    }

    @objc(unlink:)
    func unlink(command: CDVInvokedUrlCommand) {
        print("🔌 unlink called...")
        //unlinkCallbackId = command.callbackId
        OmronBluetoothManager.sharedInstance.disconnect()
    }
    
    
    @objc(resultListener:)
    func resultListener(command: CDVInvokedUrlCommand) {
        print("🔌 result listener called...")
        resultListenerCallBackId = command.callbackId

    }
    
    
    
}


//MARK:- Helping Methods
extension OmronDevicePlugin {
    func sendDataBackToOutSystem(pluginResult:CDVPluginResult?, keepCallback: Bool = false){
        
        if let callbackId = self.resultListenerCallBackId, let pluginResultRef = pluginResult {
            pluginResultRef.setKeepCallbackAs(true)
            self.commandDelegate!.send(pluginResultRef, callbackId: callbackId)
        }
    }
    
}



// MARK: - Bluetooth Delegate
extension OmronDevicePlugin: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is ON")
        case .poweredOff:
            print("❌ Bluetooth is OFF")
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

// MARK: - Omron BLE Delegate
extension OmronDevicePlugin: OmronBluetoothManagerDelegate {
    func didInitialize(isSuccessfully: Bool) {
        print("didInitialize isSuccessfully: \(isSuccessfully)")
        
        let deviceInfo = ["isSuccessfully": "\(isSuccessfully)", "methodType" : "initialize_method_bupa"]
        let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo)
        //self.commandDelegate!.send(pluginResult, callbackId: callbackId)
        self.sendDataBackToOutSystem(pluginResult: pluginResult)
        
        
        
//        if let callbackId = initializeCallbackId {
//            let deviceInfo = ["isSuccessfully": "\(isSuccessfully)"]
//            let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
        
        
    }

    func didFindDevice(isSuccessfully: Bool) {
        print("didFindDevice isSuccessfully: \(isSuccessfully)")
        let deviceInfo = ["isSuccessfully": "\(isSuccessfully)", "methodType" : "startScanning_method_bupa"]
        let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo)
        self.sendDataBackToOutSystem(pluginResult: pluginResult)
        
        
//        if let callbackId = searchCallbackId {
//            let deviceInfo = ["isSuccessfully": "\(isSuccessfully)"]
//            let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//        }
    }

    func didConnectDevice(isSuccessfully: Bool, macId: String) {
        print("didConnectDevice isSuccessfully: \(isSuccessfully) macId: \(macId)")
        let deviceInfo = ["isSuccessfully": "\(isSuccessfully)", "macId": macId, "methodType":"connectAndSync_method_bupa"]
        if let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo){
            self.sendDataBackToOutSystem(pluginResult: pluginResult, keepCallback:true);
        }
        
//        if let callbackId = connectAndSyncCallbackId {
//            let deviceInfo = ["isSuccessfully": "\(isSuccessfully)", "macId": macId]
//            if let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo){
//            pluginResult.setKeepCallbackAs(true)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//            }
//        }
    }

    func didReceiveBloodPressureData(_ data: [String: Any]) {
        print("didReceiveBloodPressureData: \(data)")
        var data = data;
        data["methodType"] = "connectAndSync_method_bupa";
        let deviceInfo = ["data": data]
        if let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo){
            self.sendDataBackToOutSystem(pluginResult: pluginResult, keepCallback:true);
        }
        
//        if let callbackId = connectAndSyncCallbackId {
//            let deviceInfo = ["data": data]
//            if let pluginResult = CDVPluginResult(status: .ok, messageAs: deviceInfo){
//            pluginResult.setKeepCallbackAs(true)
//            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
//            }
//        }else{
//
//        }
    }

    func didDisconnectDevice(isSuccessfully: Bool) {
        print("didDisconnectDevice isSuccessfully: \(isSuccessfully)")
    }
}
