//
//  CatView.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

final class CatView: UIView {
	
	let imageView = UIImageView()
	
	var isInAnimation = false

	var modelDisposable: Disposable?
	var model: Cat? {
		willSet {
			stopObservingModel()
		}
		didSet {
			startObservingModel()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .whiteColor()
		addSubview(imageView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		stopObservingModel()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame.size = CGSize(width: 256, height: 256)
		imageView.center = self.center
		
	}

	func startObservingModel() {
		guard let model = model else {
			return
		}

		let disposable = CompositeDisposable()

		disposable += model.state.producer
			.skipRepeats()
			.observeOn(UIScheduler())
			.startWithNext() { [weak self] state in
				guard let imageView = self?.imageView else {
					return
				}
				imageView.animationDuration = state.animationInterval
				imageView.animationImages = state.animationImageNames.flatMap { name in
					print(name)
					return UIImage(named: name)
				}
				imageView.startAnimating()
			}

		modelDisposable = disposable
	}

	func stopObservingModel() {
		modelDisposable?.dispose()
		modelDisposable = nil
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
		return "_sample_\(prefix)"
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
