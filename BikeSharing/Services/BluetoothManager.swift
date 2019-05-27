//
//  BluetoothManager.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 18/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import CoreBluetooth
import RxSwift

enum LockState {
    case sendUnlock
    case unlocked
    case locked
}

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    public static let shared = BluetoothManager()
    
    var centralManager: CBCentralManager!
    
    let id = "0xFFE0"
    let charasteristicID = "0xFFE1"
    
    var discoveredPeripheral: CBPeripheral?
    weak var writeCharacteristic: CBCharacteristic?
    var data: Data?
    
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    let statusFromLock = Variable<String>("")
    
    var isReady: Bool {
        get {
            return centralManager.state == .poweredOn &&
                discoveredPeripheral != nil &&
                writeCharacteristic != nil
        }
    }
    
    var lockState: LockState = .locked
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func cleanUp() {
        // Don't do anything if we're not connected
//        if (self.discoveredPeripheral?.isConnected != true) {
//            return
//        }
        
        data = nil
        
        guard let discoveredPeripheral = self.discoveredPeripheral else {
            return
        }
        
        // See if we are subscribed to a characteristic on the peripheral
        if let services = discoveredPeripheral.services {
            for service in services {
                if (service.characteristics != nil) {
                    for characteristic in service.characteristics ?? [] {
                        if characteristic.uuid == CBUUID(string: id) {
                            if (characteristic.isNotifying) {
                                // It is notifying, so unsubscribe
                                self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                                
                                // And we're done.
                                return
                            }
                        }
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        self.centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    func sendMessageToDevice(_ message: String) {
        guard isReady else { return }
        
        lockState = .sendUnlock
        if let data = message.data(using: String.Encoding.utf8) {
            discoveredPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
            print("Send: ", message)
        }
    }
    
    func scan() {
        self.centralManager.scanForPeripherals(withServices: [CBUUID(string: id)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        
        print("Scanning started");
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            NotificationBanner.showErrorBanner("Включите Bluetooth")
        }
        
        central.scanForPeripherals(withServices: [CBUUID(string: id)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Reject any where the value is above reasonable range
        if (RSSI.intValue > -15) {
            return;
        }
        
        // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//        if (RSSI.intValue < -35) {
//            return;
//        }
        
        print("Discovered %@ at %@", peripheral.name, RSSI);
        
        data = nil
        
        // Ok, it's in range - have we already seen it?
        if (self.discoveredPeripheral != peripheral) {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            self.discoveredPeripheral = peripheral;
            
            // And connect
            print("Connecting to peripheral %@", peripheral);
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NotificationBanner.showErrorBanner("Fail to connect")
        cleanUp()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        // Stop scanning
        self.centralManager.stopScan()
        
        // Clear the data that we may already have
        self.data = nil
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([CBUUID(string: id)])
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %@", error.localizedDescription);
            cleanUp()
            return;
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([CBUUID(string: charasteristicID)], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            self.cleanUp()
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == CBUUID(string: charasteristicID) {
                peripheral.setNotifyValue(true, for: characteristic)
                
                writeCharacteristic = characteristic
                
                // find out writeType
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print("error update charsterics", error.localizedDescription)
            return
        }
        
        guard let string = String(data: characteristic.value!, encoding: .utf8) else { return }
        
        switch string {
        case "CLOSED":
            if lockState == .sendUnlock {
                break
            } else if lockState == .unlocked {
                lockState = .locked
                NotificationBanner.showSuccessBanner("Замок закрыт!")
                
                statusFromLock.value = string
                
                peripheral.setNotifyValue(false, for: characteristic)
                centralManager.cancelPeripheralConnection(peripheral)
            }
        case "OPENED":
            if lockState == .sendUnlock {
                lockState = .unlocked
                NotificationBanner.showSuccessBanner("Замок открыт!")
            } else if lockState == .locked {
                NotificationBanner.showErrorBanner("Мошенничество!")
            }
        default:
            break
        }
        
        self.data?.append(characteristic.value!)
        
        print("Recieved: ", string)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: %@", error.localizedDescription);
        }
        
        // Exit if it's not the transfer characteristic
        if (characteristic.uuid != CBUUID(string: charasteristicID)) {
            return;
        }
        
        // Notification has started
        if (characteristic.isNotifying) {
            print("Notification began on %@", characteristic)
        }
            
            // Notification has stopped
        else {
            // so disconnect from the peripheral
            print("Notification stopped on %@.  Disconnecting", characteristic)
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Peripheral Disconnected");
        self.discoveredPeripheral = nil;
        
        // We're disconnected, so start scanning again
        self.scan()
    }
}
