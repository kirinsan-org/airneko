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
	
	enum AnimationType {
		enum WalkingDirection {
			case Left, Right
		}
		
		case Walking(direction: WalkingDirection)
		case Sleeping
		case Angry
		case Playful
		case Yawn
		case Delightful
		case Eating
		case Unko
		
		static let allTypes: [AnimationType] = [
			.Walking(direction: .Left),
			.Sleeping,
			.Angry,
			.Playful,
			.Yawn,
			.Delightful,
			.Eating,
			.Unko
		]
	}
	
	weak var delegate: CatViewDelegate?
	
	private let background = UIImageView()
	
	let catView = UIImageView()
	let itemView = UIImageView()
	
	var animationType: AnimationType?
	
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
		let images = AnimationType.allTypes.reduce([:]) { (images, nextState) -> [String: [UIImage]] in
			var images = images
			let nextStateImages = nextState.animationImageNames.map({ (name) -> UIImage in
				return UIImage(named: name) ?? UIImage()
			})
			images[nextState.animationImageNamePrefix] = nextStateImages
			return images
		}
		return images
	}()
	
	private let esaImage = UIImage(named: "Item_Esa")
	private let unkoImage = UIImage(named: "Item_Kuso")
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		do {
			let view = background
			view.image = UIImage(named: "Background")
		}
		
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
		
		guard let state = delegate?.getCatState(), type = AnimationType(catState: state), images = animationImages[type.animationImageNamePrefix] else {
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
		
		let targetSize = itemView.frame.size
		let targetPosition = itemView.center
		
		let dummyView = UIImageView(image: itemView.image)
		dummyView.center = targetPosition
		addSubview(dummyView)
		itemView.frame.origin.y = -itemView.frame.height
		itemView.image = esaImage
		
		UIView.animateKeyframesWithDuration(0.4, delay: 0, options: .CalculationModeCubic, animations: {
			
			let length = self.itemView.frame.width
			
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.6, animations: {
				self.itemView.center = targetPosition
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.4, animations: {
				let transform = CGAffineTransform(a: 3, b: 0, c: 0, d: 3, tx: 0, ty: 0)
				dummyView.transform = transform
				dummyView.alpha = 0
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.2, animations: {
				self.itemView.frame.origin.x -= length * 0.1
				self.itemView.frame.size.width += length * 0.2
				self.itemView.frame.origin.y += length * 0.3
				self.itemView.frame.size.height -= length * 0.3
			})
			
			UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: { 
				self.itemView.frame.size = targetSize
				self.itemView.center = targetPosition
			})
			
		}) { (_) in
			dummyView.removeFromSuperview()
		}
		
	}
	
	func receiveUnko() {
		itemView.image = unkoImage
	}
	
}

extension CatView.AnimationType {
	
	init?(catState: Cat.State) {
		switch catState {
		case .Idle:
			self = .Walking(direction: .Left)
			
		case .Sleeping:
			self = .Sleeping
			
		case .Angry:
			self = .Angry
			
		case .Playful:
			self = .Playful
			
		case .Yawn:
			self = .Yawn
			
		case .Delightful:
			self = .Delightful
			
		case .Eating:
			self = .Eating
			
		case .Unko:
			self = .Unko
			
		case .Escapade:
			return nil
		}
	}
	
	var numberOfAnimationImages: Int {
		return 4
	}
	
	var animationImageNamePrefix: String {
		
		switch self {
		case .Walking:
			return "idle"
			
		case .Sleeping:
			return "sleepy"
			
		case .Angry:
			return "angry"
			
		case .Playful:
			return "playful"
			
		case .Yawn:
			return "Yawn"
			
		case .Delightful:
			return "delightful"
			
		case .Eating:
			return "eating"
			
		case .Unko:
			return "unko"
		}
		
	}
	
	var animationImageNames: [String] {
		return Array(0 ..< numberOfAnimationImages).map { index in
			let numberString = String(format: "%02d", index)
			return "\(animationImageNamePrefix)\(numberString)"
		}
	}
	
	var animationInterval: NSTimeInterval {
		return Double(numberOfAnimationImages) * 1/10
	}
}
