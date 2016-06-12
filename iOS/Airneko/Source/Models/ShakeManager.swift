//
//  ShakeManager.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/12.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import Foundation
import CoreMotion

protocol ShakeManagerDelegate: class {
	func didStartShake()
	func didFinishShake()
}

class ShakeManager {
	
	weak var delegate: ShakeManagerDelegate?
	
	var x: Double?
	var y: Double?
	var z: Double?
	var isShaking = false
	
	private let motionManager = CMMotionManager()
	
	func startObserveShakeMotion() {
		
		motionManager.accelerometerUpdateInterval = 0.5
		motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) { [unowned self] (data, error) in
			guard error == nil else {
				print(error)
				return
			}
			
			if let data = data?.acceleration {
				self.handleAccelerationData(data)
			}
		}
		
	}
	
	func stopObserveShakeMotion() {
		
		motionManager.stopAccelerometerUpdates()
		x = nil
		y = nil
		z = nil
		isShaking = false
		
	}
	
}

extension ShakeManager {
	
	func handleAccelerationData(data: CMAcceleration) {
		
		defer {
			self.x = data.x
			self.y = data.y
			self.z = data.z
		}
		
		guard let x = x, y = y, z = z else {
			return
		}
		
		if (x !=~ data.x) || (y !=~ data.y) || (z !=~ data.z) {
			if !isShaking {
				isShaking = true
				GCD.runAsynchronizedQueue(at: .Global(priority: .Default), with: { [unowned self] in
					self.delegate?.didStartShake()
				})
			}
			
		} else {
			if isShaking {
				isShaking = false
				GCD.runAsynchronizedQueue(at: .Global(priority: .Default), with: { [unowned self] in
					self.delegate?.didFinishShake()
				})
			}
		}
		
	}
	
}

infix operator =~ {}
infix operator !=~ {}

private func =~ (lhs: Double, rhs: Double) -> Bool {
	if abs(lhs - rhs) < 0.5 {
		return true
	} else {
		return false
	}
}

private func !=~ (lhs: Double, rhs: Double) -> Bool {
	return !(lhs =~ rhs)
}
