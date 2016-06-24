//
//  DeadFishScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-06-24.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope


class DeadFishScene {
	
	let fish = Layer()
	var target = Point()
	var heartbeat: Heartbeat!
	
	init() {
		Layer.root.backgroundColor = Palette.lightBackground
		
		fish.size = Size(width: 100, height: 100)
		fish.cornerRadius = 4
		fish.backgroundColor = Palette.selectedYellow
		
		fish.moveToCenterOfParentLayer()
		
		
		
		Layer.root.touchBeganHandler = { seq in
			self.target = seq.currentGlobalLocation
		}
		
		Layer.root.touchMovedHandler = { seq in
			self.target = seq.currentGlobalLocation
		}
		
		heartbeat = Heartbeat { beat in
			self.onEachFrame()
		}
	}
	
	
	func onEachFrame() {
//		trackTarget()
		chaseTarget()
	}
	
	
	func trackTarget() {
		fish.position = target
	}
	
	
	func chaseTarget() {
		let line = Line(start: fish.position, end: target)
		let scaledLine = line.scaled(by: 0.15)
		fish.position = scaledLine.end
	}
}


struct Line {
	let start: Point
	let end: Point
}

extension Line {
	func scaled(by by: Double) -> Line {
		
		let delta = end - start
		let scaled = delta * by
		
		return Line(start: start, end: start + scaled)
	}
}


