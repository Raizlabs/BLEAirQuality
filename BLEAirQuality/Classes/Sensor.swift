//
//  Sensor.swift
//  BLEAirQuality
//
//  Created by Chris Ballinger on 5/17/18.
//

import Foundation
import RZBluetooth

public struct Reading: Codable {
    public enum SensorType: Int, Codable {
        case pm2_5
        case pm10
    }
    public var peripheral: Peripheral
    public var type: SensorType
    /// particle concentration in µg/m3
    public var value: Float
    public var timestamp: Date
}

public struct Peripheral: Codable, Hashable {
    /// Core Bluetooth identifier
    public var identifier: UUID
}

public enum ReadError: Error {
    case unknown
    /// characteristic had no value
    case noValue
    /// characteristic had invalid value
    case invalidValue
    case rzBluetoothError(NSError)
}

public typealias ReadingBlock = (Reading?, ReadError?)->Void
public typealias ScanBlock = ((Peripheral)->Void)

public class SensorManager {

    private let serviceUUID = CBUUID(string: "22AF619F-4A1B-4BCB-B481-5B13BFE86E94")
    private let centralManager = RZBCentralManager()
    private var devices: [UUID:RZBPeripheral] = [:]

    public init() {}

    /// callback is on main queue
    public var scanBlock: ScanBlock? = nil

    public func startScan() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil) { [weak self] (info, error) in
            guard let info = info else {
                if let error = error {
                    debugPrint("Scan error: \(error)")
                } else {
                    debugPrint("Unknown scan error")
                }
                return
            }
            let device = info.peripheral
            debugPrint("Found device: \(device.debugString)")
            self?.devices[device.identifier] = device
            self?.scanBlock?(Peripheral(identifier: device.identifier))
        }
    }

    public func stopScan() {
        centralManager.stopScan()
    }

    public func reset() {
        stopScan()
        devices.removeAll()
    }

    public func fetchReading(from peripheral: Peripheral, type: Reading.SensorType, completion: @escaping ReadingBlock) {
        guard let device = devices[peripheral.identifier] else {
            debugPrint("Device not found for \(peripheral)")
            return
        }
        device.readCharacteristicUUID(type.uuid, serviceUUID: serviceUUID) { (characteristic, error) in
            guard let characteristic = characteristic else {
                if let error = error {
                    debugPrint("Read error \(error)")
                    completion(nil, ReadError.rzBluetoothError(error as NSError))
                } else {
                    completion(nil, ReadError.unknown)
                }
                return
            }
            guard let value = characteristic.value else {
                completion(nil, ReadError.noValue)
                return
            }
            guard let float = value.floatValue else {
                completion(nil, ReadError.invalidValue)
                return
            }
            debugPrint("Read value \(peripheral) \(type): \(float)")
            let reading = Reading(peripheral: peripheral, type: type, value: float, timestamp: Date())
            completion(reading, nil)
        }
    }
}

private extension Data {
    var floatValue: Float? {
        guard count == 4 else {
            return nil
        }
        let float = Float(bitPattern: UInt32(bigEndian: self.withUnsafeBytes { $0.pointee }))
        return float
    }
}

private extension Reading.SensorType {
    var uuid: CBUUID {
        switch self {
        case .pm2_5:
            return CBUUID(string: "2A6E")
        case .pm10:
            return CBUUID(string: "2A6F")
        }
    }
}

private extension RZBPeripheral {
    var debugString: String {
        var string = "RZBPeripheral: "
        if let name = name {
            string += "name: \(name)"
        }
        return string
    }
}
