//
//  ViewController.swift
//  Airneko
//
//  Created by 史翔新 on 2016/06/12.
//  Copyright © 2016年 eje Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let controller = CatViewController()
		self.presentViewController(controller, animated: false, completion: nil)
	}
	
}
