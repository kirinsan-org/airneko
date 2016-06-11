//
//  CatViewController.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit

final class CatViewController: UIViewController {
	
	private let catView: CatView
	
	init(catView: CatView? = nil, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: NSBundle? = nil) {
		self.catView = catView ?? CatView()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
		catView.model = Cat()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		catView.doAnimation()
	}
	
}
