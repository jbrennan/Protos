//
//  DeadFishScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-06-24.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope


class DeadFishScene {
	static let FishInitialPosition = Point(x: 50, y: 50)
	let fish = Layer()
	var target = Point()
	var heartbeat: Heartbeat!
	
	init() {
		Layer.root.backgroundColor = Palette.lightBackground
		
		fish.size = Size(width: 100, height: 100)
		fish.cornerRadius = 4
		fish.backgroundColor = Palette.selectedYellow
		
		fish.position = DeadFishScene.FishInitialPosition
		
		
		
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
//		chaseTarget()
		springTowardTarget()
	}
	
	
	func trackTarget() {
		fish.position = target
	}
	
	
	func chaseTarget() {
		let line = Line(start: fish.position, end: target)
		let scaledLine = line.scaled(by: 0.15)
		fish.position = scaledLine.end
	}
	
	var velocity = Line(start: DeadFishScene.FishInitialPosition, end: Point(x: 50, y: 150))
	func springTowardTarget() {
		fish.position = velocity.end
		
		
		velocity = velocity.movedToStartingPoint(fish.position)
		velocity = velocity.scaled(by: 0.78)
		
		let scalingLine = Line(start: fish.position, end: target)
		let scaledLine = scalingLine.scaled(by: 0.3)
		let movedLine = scaledLine.movedToStartingPoint(velocity.end)
		
		velocity = Line(start: velocity.start, end: movedLine.end)
		
		let hue = fish.position.y / Layer.root.height
		let saturation = fish.position.x / Layer.root.width
		fish.backgroundColor = Color(hue: hue, saturation: saturation, brightness: 1)
		
		updateLineView()
	}
	
	
	var lineView: ShapeLayer!
	func updateLineView() {
		lineView?.parent = nil
		
		lineView = ShapeLayer(lineFromFirstPoint: velocity.start, toSecondPoint: velocity.end)
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
	
	func translated(by translation: Point) -> Line {
		return Line(start: start + translation, end: end + translation)
	}
	
	func movedToStartingPoint(startingPoint: Point) -> Line {
		let delta = startingPoint - start
		
		return self.translated(by: delta)
	}
}


