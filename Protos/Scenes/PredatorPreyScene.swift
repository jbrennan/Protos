//
//  PredatorPreyScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-05-29.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope

class PredatorPreyScene {
	
	var predators: [Predator]
	let prey: [Entity]
	
	var heartBeat: Heartbeat!
	static let updateInterval = 60
	static let babyInterval = PredatorPreyScene.updateInterval * 5
	
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
			
			if tickCount % PredatorPreyScene.babyInterval == 0 {
				let livingPredators = self.predators.filter { $0.isDead == false }
				for predator in livingPredators {
					let entity = predator.copy()
					entity.position = PredatorPreyScene.randomOnScreenPoint()
					entity.popIn()
					
					self.predators.append(entity as! Predator)
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
	let emoji: String
	
	required init(emoji: String) {
		self.emoji = emoji
		super.init()
		self.image = Image(text: emoji)
	}
	
	func update() {}
	
	private (set) var isDead = false
	func die() {
		isDead = true
		alpha = 0.2
	}
	
	func copy() -> Entity {
		let copy = self.dynamicType.init(emoji: emoji)
		
		return copy
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
		
		let hungryRandomness = 3
		let shouldGetHungrier = Int(drand48() * Double(hungryRandomness)) % hungryRandomness == 0
		hunger = hunger + (shouldGetHungrier ? 1 : 0)
		
		let hungerLimit = 3
		if hunger == hungerLimit {
			die()
		}
	}
	
	
}

// MARK: - Prototope Extensions

extension Layer {
	
	/// Scale up to full size with a spring animation
	func popIn() {
		scale = 0.01
		animators.scale.target = Point(x: 1, y: 1)
	}
}

