//
//  NyaaPlayer.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/12/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import AVFoundation

final class NyaaPlayer {
	static let sharedInstance = NyaaPlayer()

	private let players: [String: AVAudioPlayer]

	init() {
		let names = [
			"nyaa1.wav",
			"nyaa2.wav",
			"nyaa3.wav",
			"nyaa4.wav",
			"nyaa5.wav",
			"nyaa6.wav",
			"nyaa7.wav",
			"nyaa8.wav"
		]

		var players = Dictionary<String, AVAudioPlayer>()
		names.forEach { name in
			guard let url = NSBundle.mainBundle().URLForResource(name, withExtension: nil) else {
				return
			}
			guard let player = try? AVAudioPlayer(contentsOfURL: url) else {
				return
			}
			player.prepareToPlay()
			players[name] = player
		}
		self.players = players
	}

	func play(sound: String) {
		players[sound]?.play()
	}

	func play(notificationPayload payload: [NSObject: AnyObject]) {
		if let sound = (payload["aps"] as? [NSObject: AnyObject])?["sound"] as? String {
			play(sound)
		}
	}
}
