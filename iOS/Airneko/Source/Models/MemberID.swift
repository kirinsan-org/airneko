//
//  MemberID.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/12/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit

private let MemberIDUserDefaultsKey = "member_id"

final class MemberID {
	static var currentID: String? {
		get {
			let userDefaults = NSUserDefaults.standardUserDefaults()
			return userDefaults.stringForKey(MemberIDUserDefaultsKey)
		}
		set(value) {
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setValue(value, forKey: MemberIDUserDefaultsKey)
			userDefaults.synchronize()
		}
	}
}

extension MemberID {
	static func currentIDSetupDialogViewController() -> UIAlertController {
		let alert = UIAlertController(title: "Member 名を選んでね 🐱", message: nil, preferredStyle: .Alert)

		let memberIDs = [
			"child1",
			"child2",
			"child3",
			"child4",
			"child5"
		]

		memberIDs.forEach { memberID in
			alert.addAction(UIAlertAction(title: memberID, style: .Default, handler: { action in
				self.currentID = memberID
			}))
		}

		alert.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil))

		return alert
	}
}
