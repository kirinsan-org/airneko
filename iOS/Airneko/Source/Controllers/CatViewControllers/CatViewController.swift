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
	
	var catState: Cat.State {
		return catModel.state.value
	}
	
	init(cat: Cat? = nil, catView: CatView? = nil, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: NSBundle? = nil) {
		self.catModel = cat ?? Cat()
		self.catView = catView ?? CatView()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.catView.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		catView.frame = UIScreen.mainScreen().bounds
		view = catView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		catView.startObservingCatStatus()
	}

//	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//		catView.doAnimation()
//	}
	
}

extension CatViewController: CatViewDelegate {
	
	func getCatState() -> Cat.State {
		return catState
	}
	
}
