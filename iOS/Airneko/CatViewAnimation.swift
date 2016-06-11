//
//  CatViewAnimation.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/11.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

extension CatView {
	
	var animations: [() -> Void] {
		return [
			self.jump,
			self.moveAround,
		]
	}
	
	func doAnimation() {
		let index = Int(arc4random_uniform(UInt32(animations.count)))
		animations[index]()
	}
	
	func jump() {
		
		guard !isInAnimation else {
			return
		}
		
		isInAnimation = true
				
		UIView.animateKeyframesWithDuration(0.4, delay: 0, options: .CalculationModeCubic, animations: {
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.25) {
				self.imageView.frame.origin.y -= 70
			}
			UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.3, animations: {
				self.layoutSubviews()
			})
			UIView.addKeyframeWithRelativeStartTime(0.55, relativeDuration: 0.5, animations: {
				self.imageView.frame.origin.y += 50
				self.imageView.frame.origin.x -= 20
				self.imageView.frame.size.height -= 50
				self.imageView.frame.size.width += 40
			})
			UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: {
				self.layoutSubviews()
			})
		}, completion: { (_) in self.isInAnimation = false } )
		
	}
	
	func moveAround() {
		
		guard !isInAnimation else {
			return
		}
		
		isInAnimation = true
		
		let currentPosition = imageView.frame
		let leftMoveLength = currentPosition.origin.x
		let rightMoveLength = self.frame.width - imageView.frame.width - leftMoveLength
		
		UIView.animateKeyframesWithDuration(4, delay: 0, options: .CalculationModeCubic, animations: {
			
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.2, animations: {
				let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: -leftMoveLength, ty: 0)
				self.imageView.transform = transform
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.1, animations: {
				let transform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: -leftMoveLength, ty: 0)
				self.imageView.transform = transform
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.4, animations: {
				let transform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: rightMoveLength, ty: 0)
				self.imageView.transform = transform
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.7, relativeDuration: 0.1, animations: {
				let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: rightMoveLength, ty: 0)
				self.imageView.transform = transform
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: {
				let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
				self.imageView.transform = transform
			})
			
		}) { (_) in
			self.isInAnimation = false
		}
		
	}
	
}
