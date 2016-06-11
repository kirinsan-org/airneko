//
//  CatViewController.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit

final class CatViewController: UIViewController {
	@IBOutlet weak var catView: CatView!

	override func viewDidLoad() {
		super.viewDidLoad()
		catView.model = Cat()
	}
}
