//
//  BluetoothManager.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

private let SensorName = "Airneko"

final class BluetoothManager: NSObject {
	var central: CBCentralManager!
	var peripheral: CBPeripheral?

	var ambiente: Double = 0

	override init() {
		super.init()
		central = CBCentralManager(delegate: self, queue: nil)
	}

	func startScan() {
		central.scanForPeripheralsWithServices(nil, options: nil)
	}

	func stopScan() {
		central.stopScan()
	}
}

extension BluetoothManager: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(central: CBCentralManager) {
		switch central.state {
		case .Unknown:
			print("status: Unknown")
		case .Resetting:
			print("status: Resetting")
		case .Unsupported:
			print("status: Unsupported")
		case .Unauthorized:
			print("status: Unaurhorized")
		case .PoweredOff:
			print("status: PowerOff")
		case .PoweredOn:
			print("status: PowerOn")
			startScan()
		}
	}

	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		print(peripheral)
		if peripheral.name == SensorName {
			print("\(SensorName) peripheral found")
			self.peripheral = peripheral
			central.connectPeripheral(peripheral, options: nil)
		}
	}

	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		print("\(SensorName) peripheral connected!")
		peripheral.delegate = self
		peripheral.discoverServices([CBUUID(string: "47FE55D8-447F-43EF-9AD9-FE6325E17C47")])
	}

	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("\(SensorName) peripheral connection failed")
	}
}

extension BluetoothManager: CBPeripheralDelegate {
	enum Characteristic: String {
		case Custom1 = "686A9A3B-4C2C-4231-B871-9CFE92CC6B1E" // for reading
		case Custom2 = "078FF5D6-3C93-47F5-A30C-05563B8D831E" // not used
		case Custom3 = "B962BDD1-5A77-4797-93A1-EDE8D0FF74BD" // for writing

		var uuid: CBUUID {
			return CBUUID(string: self.rawValue)
		}
	}

	enum EventCode: UInt8 {
		case DataPacket1 = 0xF2
		case DataPacket2 = 0xF3
		case DataPacket3 = 0xE0
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if let error = error {
			print("error: \(error)")
			return
		}

		dispatch_async(dispatch_get_main_queue()) { 
			let alert = UIAlertController(title: "Devie Found!", message: nil, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
			(UIApplication.sharedApplication().delegate as? AppDelegate)?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
		}

		if let service = peripheral.services?.first {
			peripheral.discoverCharacteristics([
				Characteristic.Custom1.uuid,
				Characteristic.Custom3.uuid
			], forService: service)
		}
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		if let error = error {
			print("error: \(error)")
			return
		}

		service.characteristics?.forEach { characteristic in
			switch characteristic.UUID {
			case Characteristic.Custom1.uuid:
				peripheral.setNotifyValue(true, forCharacteristic: characteristic)
				peripheral.readValueForCharacteristic(characteristic)
			case Characteristic.Custom3.uuid:
				let packets = [
//					NSData(bytes: [0x2F, 0x03, 0x03] as [UInt8], length: 3), // 設定の初期化
//					NSData(bytes: [0x01, 0x03, 0x7c] as [UInt8], length: 3), // 環境系センサ選択
//					NSData(bytes: [0x04, 0x03, 0x00] as [UInt8], length: 3), // Slow モード
//					NSData(bytes: [0x05, 0x04, 0x01, 0x00] as [UInt8], length: 4), // 1秒間隔
//					NSData(bytes: [0x2F, 0x03, 0x01] as [UInt8], length: 3), // 設定内容の保存
					NSData(bytes: [0x20, 0x03, 0x01] as [UInt8], length: 3), // 計測動作を開始
				]
				packets.forEach { packet in
					peripheral.writeValue(packet, forCharacteristic: characteristic, type: .WithResponse)
				}
				print("Requested value updates!")
			default:
				break
			}
		}
	}

	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if let error = error {
			print("error: \(error)")
			return
		}

		if let data = characteristic.value {
			let bytes = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))

			if characteristic.UUID == Characteristic.Custom1.uuid,
				let firstByte = bytes.first,
				let eventCode = EventCode(rawValue: firstByte) {
				switch eventCode {
				case .DataPacket1:
					break
				case .DataPacket2:
					let rawUV = UnsafePointer<UInt16>([bytes[8], bytes[9]]).memory
					let rawAmbiente = UnsafePointer<UInt16>([bytes[10], bytes[11]]).memory
 					let uv = Double(rawUV) / (100 * 0.388)
					let ambiente: Double
					if uv < 0.814 {
						ambiente = Double(rawAmbiente) / (0.05 * 0.928 * (0.3102 * (Double(rawUV) / (100 * 0.388)) + 0.8525))
					} else {
						ambiente = Double(rawAmbiente) / (0.05 * 0.928 * (0.03683 * (Double(rawUV) / (100 * 0.388)) + 1.075))
					}
					self.ambiente = ambiente
					print("ambient: \(ambiente)Lx")
				case .DataPacket3:
					break
				}
			}
		}
	}

	func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if let error = error {
			print("error: \(error)")
		} else {
			print("Stared observing value changes…")
		}
	}
}
