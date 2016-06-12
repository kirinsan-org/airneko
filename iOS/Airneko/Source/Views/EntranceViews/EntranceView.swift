//
//  EntranceView.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/12.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

class EntranceView: UIView {
	
	weak var titleLogo: UIView?
	weak var leftButton: UIView?
	weak var rightButton: UIView?
	
	private let buttonMargin: CGFloat = 2
	
	override func willMoveToSuperview(newSuperview: UIView?) {
		self.backgroundColor = UIColor(hexRGBAValue: 0x00CCFFFF)
	}
	
	func initializeButtonDisplays() {
		
		if let button = leftButton {
			button.frame.origin.x = (frame.width / 2) - button.frame.width - buttonMargin
			button.frame.origin.y = frame.height
			button.clipsToBounds = true
			button.layer.cornerRadius = 10
			button.layer.borderColor = UIColor.whiteColor().CGColor
			button.layer.borderWidth = 3
			addSubview(button)
		}
		
		if let button = rightButton {
			button.frame.origin.x = (frame.width / 2) + buttonMargin
			button.frame.origin.y = frame.height
			button.clipsToBounds = true
			button.layer.cornerRadius = 10
			button.layer.borderColor = UIColor.whiteColor().CGColor
			button.layer.borderWidth = 3
			addSubview(button)
		}
		
	}
	
	func startCloudsRunningAnimation(withDuration duration: NSTimeInterval, comelete completionHandler: (() -> Void)? = nil ) {
		
		let cloudViews: [UIView] = {
			if let cloudImage = UIImage(named: "SplashClouds") {
				let cloudViews = 0.stride(through: Int(self.frame.width), by: Int(cloudImage.size.width)).map({ (i) -> UIImageView in
					let view = UIImageView(image: cloudImage)
					view.frame.origin.x = CGFloat(i)
					self.addSubview(view)
					return view
				})
				return cloudViews
				
			} else {
				return []
			}

		}()
		
		let bottomView: UIView? = {
			if let image = UIImage(named: "SplashBottom") {
				let view = UIImageView(image: image)
				view.frame.size.width = self.frame.width
				view.frame.origin.y = self.frame.height - view.frame.height
				view.contentMode = .Top
				self.addSubview(view)
				return view
				
			} else {
				return nil
			}
		}()
		
		let title: UIView? = {
			if let image = UIImage(named: "Title") {
				let view = UIImageView(image: image)
				view.contentMode = .ScaleAspectFit
				view.center = self.center
				self.titleLogo = view
				self.addSubview(view)
				return view
				
			} else {
				return nil
			}
		}()
		
		UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeLinear, animations: {
			
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: { 
				cloudViews.forEach({ (view) in
					view.frame.origin.x -= CGFloat(duration) * 30
				})
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.95, relativeDuration: 0.05, animations: { 
				cloudViews.forEach({ (view) in
					view.frame.origin.y -= view.frame.height
				})
				bottomView?.frame.origin.y += bottomView?.frame.height ?? 0
			})
		}) { (_) in
			cloudViews.forEach({ (view) in
				view.removeFromSuperview()
			})
			bottomView?.removeFromSuperview()
			UIView.animateWithDuration(0.2, animations: { 
				let transform = CGAffineTransform(a: 0.7, b: 0, c: 0, d: 0.7, tx: 0, ty: -self.frame.height * 0.3)
				title?.transform = transform
				
				self.leftButton?.frame.origin.y = self.frame.height * 0.4
				self.rightButton?.frame.origin.y = self.frame.height * 0.4
				
			}, completion: { (_) in
				completionHandler?()
			})
		}
		
	}
	
}
