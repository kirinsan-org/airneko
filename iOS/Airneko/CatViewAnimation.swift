//
//  CatViewAnimation.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/11.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

extension CatView {
	
	func jump() {
		
		UIView.animateKeyframesWithDuration(0.4, delay: 0, options: [], animations: {
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.25) {
				self.imageView.frame.origin.y -= 70
			}
			UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.25, animations: {
				self.layoutSubviews()
			})
			UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.25, animations: {
				self.imageView.frame.origin.y += 40
				self.imageView.frame.origin.x -= 10
				self.imageView.frame.size.height -= 40
				self.imageView.frame.size.width += 20
			})
			UIView.addKeyframeWithRelativeStartTime(0.75, relativeDuration: 0.25, animations: { 
				self.layoutSubviews()
			})
		}, completion: nil)
		
	}
	
}
