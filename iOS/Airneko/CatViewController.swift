//
//  CatViewController.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit

final class CatViewController: UIViewController {
	var catView: CatView!

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = UIColor.whiteColor()

		catView = CatView()
		catView.bounds = CGRect(x: 0, y: 0, width: 256, height: 256)
		catView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
		catView.model = Cat()

		view.addSubview(catView)
	}
}
