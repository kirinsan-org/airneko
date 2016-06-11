//
//  CatView.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit

protocol CatViewDelegate: class {
	func getCatState() -> Cat.State
}

final class CatView: UIView {
	
	weak var delegate: CatViewDelegate?
	
	let imageView = UIImageView()
	
	var isInAnimation = false
	
	private lazy var animationImages: [String: [UIImage]] = {
		let images = Cat.State.allStates.reduce([:]) { (images, nextState) -> [String: [UIImage]] in
			var images = images
			let nextStateImages = nextState.animationImageNames.map({ (name) -> UIImage in
				return UIImage(named: name) ?? UIImage()
			})
			images[nextState.rawValue] = nextStateImages
			return images
		}
		return images
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .whiteColor()
		addSubview(imageView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame.size = CGSize(width: 256, height: 256)
		imageView.center = self.center
		
	}

}

extension CatView {
	
	func startObservingCatStatus() {
		
		GCD.runAsynchronizedQueue(at: .Global(priority: .Default)) {
			self.animateCat(nil, lastFrame: nil)
		}
		
	}
	
	func animateCat(lastState: Cat.State?, lastFrame: Int?) {
		
		let currentTime = NSDate()
		
		guard let state = delegate?.getCatState(), images = animationImages[state.rawValue] else {
			return
		}
		
		let frame: Int
		if let lastState = lastState where state == lastState {
			if let lastFrame = lastFrame where lastFrame + 1 < images.count {
				frame = lastFrame + 1
			} else {
				frame = 0
			}
		} else {
			frame = 0
		}
		
		GCD.runAsynchronizedQueue(at: .Main) {
			self.imageView.image = images[frame]
		}
		
		GCD.runAsynchronizedQueue(at: .Global(priority: .Default), delay: 0.1 - currentTime.timeIntervalSinceNow) {
			self.animateCat(state, lastFrame: frame)
		}
		
	}
	
}

private extension Cat.State {
	var numberOfAnimationImages: Int {
		return 4
	}
	var animationImageNamePrefix: String {
		
		let samplePrefix: String
		switch self {
		case .Delightful, .Sleeping:
			samplePrefix = ""
			
		default:
			samplePrefix = "_sample_"
		}
		
		let prefix: String
		switch self {
		case .Sleeping:
			prefix = "sleepy"
		default:
			prefix = rawValue
		}
		
		return "\(samplePrefix)\(prefix)"
		
	}
	var animationImageNames: [String] {
		return Array(0..<numberOfAnimationImages).map { index in
			let numberString = String(format: "%02d", index)
			return "\(animationImageNamePrefix)\(numberString)"
		}
	}
	var animationInterval: NSTimeInterval {
		return Double(numberOfAnimationImages) * 1/10
	}
}
