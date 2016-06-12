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
	
	private let background = UIImageView()
	
	let catView = UIImageView()
	let itemView = UIImageView()
	
	weak var itemButton: UIButton? {
		didSet {
			if let superview = oldValue?.superview where superview == self {
				oldValue?.removeFromSuperview()
			}
			if let view = self.itemButton {
				addSubview(view)
			}
		}
	}
	
	var isInAnimation = false
	
	private let animationImages: [String: [UIImage]] = {
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
	
	private let esaImage = UIImage(named: "Item_Esa") ?? UIImage()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		background.image = UIImage(named: "Background")		
		addSubview(background)
		addSubview(catView)
		addSubview(itemView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		
		do {
			let view = background
			view.frame = self.bounds
			view.contentMode = .ScaleAspectFill
			view.center = self.center
		}
		
		do {
			let view = catView
			view.frame.size = CGSize(width: frame.width * 0.8, height: frame.width * 0.8)
			view.center = self.center
		}
		
		do {
			let view = itemView
			view.frame.size = CGSize(width: frame.width * 0.4, height: frame.width * 0.4)
			view.center.x = frame.width * 0.5
			view.center.y = frame.height * 0.8
		}
		
		if let view = itemButton {
			view.frame.size = CGSize(width: frame.width * 0.2, height: frame.width * 0.2)
			view.center.x = frame.width * 0.5
			view.center.y = frame.height * 0.2
		}
		
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
			self.catView.image = images[frame]
		}
		
		GCD.runAsynchronizedQueue(at: .Global(priority: .Default), delay: 0.1 - currentTime.timeIntervalSinceNow) {
			self.animateCat(state, lastFrame: frame)
		}
		
	}
	
}

extension CatView {
	
	func addEsa() {
		itemView.image = esaImage
	}
	
}

private extension Cat.State {
	var numberOfAnimationImages: Int {
		return 4
	}
	var animationImageNamePrefix: String {
		
		let prefix: String
		switch self {
		case .Sleeping:
			prefix = "sleepy"
		default:
			prefix = rawValue
		}
		
		return prefix
		
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
