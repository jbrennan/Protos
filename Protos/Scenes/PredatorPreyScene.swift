//
//  PredatorPreyScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-05-29.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope

class PredatorPreyScene {
	
	let predators: [Predator]
	let prey: [Entity]
	
	var heartBeat: Heartbeat!
	static let updateInterval = 60
	
	init() {
		Layer.root.backgroundColor = Palette.lightBackground
		
		predators = PredatorPreyScene.makePredators()
		prey = PredatorPreyScene.makePrey()
		
		var tickCount = 0
		heartBeat = Heartbeat(handler: { beat in
			
			if tickCount % PredatorPreyScene.updateInterval == 0 {
				for predator in self.predators {
					predator.update()
				}
			}
			
			tickCount += 1
		})
	}

}

extension PredatorPreyScene {
	static func makePredators() -> [Predator] {
		let predators = makeEntitiesWithFace("🐺", type: Predator.self) as! [Predator]
		
		return predators
	}
	
	static func makePrey() -> [Entity] {
		return makeEntitiesWithFace("🐰", type: Entity.self)
	}
	
	static func makeEntitiesWithFace(face: String, type: Entity.Type) -> [Entity] {
		var entities = [Entity]()
		
		for _ in 0..<20 {
			let layer = type.init(emoji: face)
			
			layer.position = randomOnScreenPoint()
			entities.append(layer)
		}
		
		return entities
	}
	
	static func randomOnScreenPoint() -> Point {
		let x = drand48() * Layer.root.width
		let y = drand48() * Layer.root.height
		return Point(x: x, y: y)
	}
}

class Entity: Layer {
	required init(emoji: String) {
		super.init()
		self.image = Image(text: emoji)
	}
	
	func update() {}
	
	private (set) var isDead = false
	func die() {
		isDead = true
		alpha = 0.5
	}
}

class Predator: Entity {
	let labelLayer = TextLayer()
	var hunger = 0 {
		didSet {
			labelLayer.text = "\(hunger)"
		}
	}
	
	required init(emoji: String) {
		super.init(emoji: emoji)
		labelLayer.parent = self
	}
	
	override func update() {
		if isDead {
			return
		}
		
		
		let shouldGetHungrier = Int(drand48() * 5) % 5 == 0
		hunger = hunger + (shouldGetHungrier ? 1 : 0)
		
		let hungerLimit = 5
		if hunger == hungerLimit {
			die()
		}
	}
	
	
}

