//
//  CatViewController.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

final class CatViewController: UIViewController {
	
	private let catModel: Cat
	private let catView: CatView
	var modelDisposable: Disposable?
	
	init(cat: Cat? = nil, catView: CatView? = nil, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: NSBundle? = nil) {
		self.catModel = cat ?? Cat()
		self.catView = catView ?? CatView()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		stopObservingModel()
	}
	
	override func loadView() {
		catView.frame = UIScreen.mainScreen().bounds
		view = catView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		startObservingModel()
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		catView.doAnimation()
	}
	
}

extension CatViewController {
	
	func startObservingModel() {
		
		let disposable = CompositeDisposable()
		
		disposable += catModel.state.producer
			.skipRepeats()
			.observeOn(UIScheduler())
			.startWithNext() { [weak self] state in
				self?.catView.catStatusIsChanged(to: state)
		}
		
		modelDisposable = disposable
	}
	
	func stopObservingModel() {
		modelDisposable?.dispose()
		modelDisposable = nil
	}
	
}
