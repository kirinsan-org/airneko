//
//  Cat.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import ReactiveCocoa

final class Cat {
	
	enum State: String {
		case Idle = "idle" // 初期状態
		case Sleeping = "sleeping" // 寝ている
		case Angry = "angry" // 怒っている
		case Playful = "playful" // じゃれている
		case Yawn = "yawn" // あくびしている
		case Delightful = "delightful" // よろこんでいる
		case Eating = "eating" // eating
		case Unko = "unko" // unko
		case Escapade = "escapade"
		
	}

	enum Place: Equatable {
		case Member(String) // 誰かのところ
		case Some // 誰かのところではないどこか
	}

	let name = MutableProperty<String>("")
	let state = MutableProperty<State>(.Idle)
	let place = MutableProperty<Place>(.Some)
	let hungry = MutableProperty<Float>(0)
	let unko = MutableProperty<Float>(0)

	let firebaseReference: FIRDatabaseReference

	static var defaultFirebaseReference: FIRDatabaseReference {
		return FIRDatabase.database().referenceWithPath("family/sample/neko/sampleneko")
	}

	init(firebaseReference ref: FIRDatabaseReference = defaultFirebaseReference) {
		firebaseReference = ref

		ref.observeEventType(FIRDataEventType.Value, withBlock: { [weak self] snapshot in
			guard let dictionary = snapshot.value as? [String : AnyObject] else {
				fatalError("invalid response")
			}
			if let value = dictionary["state"] as? String, let state = State(rawValue: value) {
				self?.state.value = state
			}
			if let value = dictionary["name"] as? String {
				self?.name.value = value
			}
			if let value = dictionary["place"] as? String {
				self?.place.value = .Member(value)
			} else {
				self?.place.value = .Some
			}
			if let value = dictionary["hungry"] as? Float {
				self?.hungry.value = value
			}
			if let value = dictionary["unko"] as? Float {
				self?.unko.value = value
			}
		})
	}
}

func ==(lhs: Cat.Place, rhs: Cat.Place) -> Bool {
	switch (lhs, rhs) {
	case (.Member(let user1), .Member(let user2)):
		return user1 == user2
	case (.Some, .Some):
		return true
	default:
		return false
	}
}
