//
//  EntranceController.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/12.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

class EntranceController: UIViewController {
	
	private let entranceView: EntranceView
	
	lazy var createFamilyButton: UIButton = {
		let buttonImage = UIImage(named: "CreateFamilyButton")
		let buttonRect = CGRect(origin: .zero, size: buttonImage?.size ?? .zero)
		let button = UIButton(frame: buttonRect)
		button.setImage(buttonImage, forState: .Normal)
		return button
	}()
	
	lazy var existingFamilyButton: UIButton = {
		let buttonImage = UIImage(named: "ExistingFamilyButton")
		let buttonRect = CGRect(origin: .zero, size: buttonImage?.size ?? .zero)
		let button = UIButton(frame: buttonRect)
		button.setImage(buttonImage, forState: .Normal)
		button.addTarget(self, action: #selector(EntranceController.enterExistingFamily), forControlEvents: .TouchUpInside)
		return button
	}()
	
	init(entranceView: EntranceView? = nil) {
		self.entranceView = entranceView ?? EntranceView()
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		entranceView.frame = UIScreen.mainScreen().bounds
		view = entranceView
	}
	
	override func viewDidLoad() {
		entranceView.leftButton = createFamilyButton
		entranceView.rightButton = existingFamilyButton
		entranceView.initializeButtonDisplays()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		entranceView.startCloudsRunningAnimation(withDuration: 2)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
}

extension EntranceController {
	
	func enterExistingFamily() {
		
		let controller = CatViewController()
		self.presentViewController(controller, animated: true, completion: nil)
		
	}
	
}
