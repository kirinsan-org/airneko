//
//  Extensions.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/12.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

extension UIColor {
	
	convenience init(hexRGBAValue: Int) {
		
		let redValue = (hexRGBAValue >> 24) & 0xFF
		let greenValue = (hexRGBAValue >> 16) & 0xFF
		let blueValue = (hexRGBAValue >> 8) & 0xFF
		let alphaValue = (hexRGBAValue >> 0) & 0xFF
		
		let red = CGFloat(redValue) / CGFloat(UInt8.max)
		let green = CGFloat(greenValue) / CGFloat(UInt8.max)
		let blue = CGFloat(blueValue) / CGFloat(UInt8.max)
		let alpha = CGFloat(alphaValue) / CGFloat(UInt8.max)
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
		
	}
	
}
