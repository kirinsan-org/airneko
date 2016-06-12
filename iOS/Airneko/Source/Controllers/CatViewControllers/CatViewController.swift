//
//  CatViewController.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CoreMotion
import FirebaseDatabase

final class CatViewController: UIViewController {
	
	private let catModel: Cat
	private let catView: CatView
	private let shakeManager: ShakeManager
	
	var catState: Cat.State {
		return catModel.state.value
	}
	
	init(cat: Cat? = nil, catView: CatView? = nil, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: NSBundle? = nil) {
		self.catModel = cat ?? Cat()
		self.catView = catView ?? CatView()
		self.shakeManager = ShakeManager()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.catView.delegate = self
		self.shakeManager.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		shakeManager.stopObserveShakeMotion()
	}
	
	override func loadView() {
		catView.frame = UIScreen.mainScreen().bounds
		view = catView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		catView.startObservingCatStatus()
		
		let button = UIButton()
		let buttonImage = UIImage(named: "Feed")
		button.setImage(buttonImage, forState: .Normal)
		button.addTarget(self, action: #selector(CatViewController.addEsa), forControlEvents: .TouchUpInside)
		catView.itemButton = button
		
		shakeManager.startObserveShakeMotion()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

}

extension CatViewController: ShakeManagerDelegate {
	
	func didStartShake() {
		print("started")
		guard let member = MemberID.currentID else {
			return
		}
		let ref = FIRDatabase.database().referenceWithPath("family/sample/member/\(member)/item")
		ref.setValue("jarashi")
	}
	
	func didFinishShake() {
		print("finished")
		guard let member = MemberID.currentID else {
			return
		}
		let ref = FIRDatabase.database().referenceWithPath("family/sample/member/\(member)/item")
		ref.setValue("none")
	}
	
}

extension CatViewController {
	
	func addEsa() {
		catView.addEsa()
	}
	
}

extension CatViewController: CatViewDelegate {
	
	func getCatState() -> Cat.State {
		return catState
	}
	
}
