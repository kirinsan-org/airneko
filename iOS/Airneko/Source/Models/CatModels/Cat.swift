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
import Result

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
		case Here // ここ
		case Elsewhere // ここではないどこか
	}

	let name = MutableProperty<String>("")
	let state = MutableProperty<State>(.Idle)
	let hungry = MutableProperty<Float>(0)
	let unko = MutableProperty<Float>(0)
	let place: AnyProperty<Place>

	let firebaseReference: FIRDatabaseReference

	static var defaultFirebaseReference: FIRDatabaseReference {
		return FIRDatabase.database().referenceWithPath("family/sample/neko/sampleneko")
	}

	init(firebaseReference ref: FIRDatabaseReference = defaultFirebaseReference) {
		firebaseReference = ref

		let (placeSignal, placeObserver) = Signal<Place, NoError>.pipe()
		place = AnyProperty(initialValue: .Elsewhere, signal: placeSignal)

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
			if let value = dictionary["place"] as? String where value == MemberID.currentID {
				placeObserver.sendNext(.Here)
			} else {
				placeObserver.sendNext(.Elsewhere)
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
