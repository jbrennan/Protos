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
	var prey: [Entity]
	
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
				
				let livingPrey = self.prey.filter { !$0.isDead }
				for prey in livingPrey {
					let entity = prey.copy()
					entity.position = PredatorPreyScene.randomOnScreenPoint()
					entity.popIn()
					
					self.prey.append(entity)
				}
			}
			
			// wolves should hunt a bit on each tick:
			//	- find closet prey
			//		- if distance is very small, move to it and eat it
			//		- if distance is decent, move towards the prey
			//		- else, move to a random spot
			let livingPredators = self.predators.filter { $0.isDead == false }
			for predator in livingPredators {
				let closestPrey = self.nearestPreyToPredator(predator)
				let distanceToPrey = fabs(predator.position.distanceToPoint(closestPrey.position))
				
				let eatingDistance = 5.0
				let chasingDistance = 50.0
				
				if distanceToPrey < eatingDistance {
					predator.position = closestPrey.position
					closestPrey.die()
					predator.hunger = 0
					
				} else if distanceToPrey < chasingDistance {
					predator.position = self.pointAlongLineOfStartingPoint(predator.position, endingPoint: closestPrey.position)
				} else {
					predator.position = self.randomPointWithinDistance(2, ofPoint: predator.position)
				}
			}
			
			
			// bunnies should just wander, I think
			//	- maybe eventually they should evade predators
			let livingPrey = self.prey.filter { !$0.isDead }
			for prey in livingPrey {
				prey.position = self.randomPointWithinDistance(2, ofPoint: prey.position)
			}
			tickCount += 1
		})
	}
	
	func nearestPreyToPredator(predator: Predator) -> Entity {
		var shortestDistance = Double.infinity
		var closestPrey = prey.first!
		let livingPrey = prey.filter { !$0.isDead }
		
		for bunny in livingPrey {
			let distanceToPrey = fabs(predator.position.distanceToPoint(bunny.position))
			
			if distanceToPrey < shortestDistance {
				shortestDistance = distanceToPrey
				closestPrey = bunny
			}
		}
		
		return closestPrey
	}
	
	/** Returns a `Point` positioned on the line between the given starting and ending points. */
	func pointAlongLineOfStartingPoint(startingPoint: Point, endingPoint: Point) -> Point {
		let delta = endingPoint - startingPoint
		let hypotenuse = sqrt(delta.x * delta.x + delta.y * delta.y)
		
		let distanceOnHyp = 5.0 // arbitrary.. should be passed in!
		
		let percentageOnHyp = distanceOnHyp / hypotenuse
		return Point(x: startingPoint.x + percentageOnHyp * delta.x,
		             y: startingPoint.y + percentageOnHyp * delta.y)
	}
	
	/// Returns a point whose x,y values are randome between the current point and up to `distance` away in any direction
	func randomPointWithinDistance(distance: Double, ofPoint point: Point) -> Point {
		// we double the distance, get a random number from 0 < doubleDistance,
		// then subtract one half (ie distance) from that
		// so the range becomes -distance < x < distance
		// finally, add the current x or y to the new random value
		let doubleDistance = distance * 2
		let x = (drand48() * doubleDistance) - distance + point.x
		let y = (drand48() * doubleDistance) - distance + point.y
		
		return Point(x: x, y: y)
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

