//
//  PanelScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-06-24.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope


class PanelScene {
	
	let canvasLayer = Layer()
	let fish = Layer()
	let targetLayer = Layer()
	
	init() {
		Layer.root.backgroundColor = Palette.lightBackground
		
		canvasLayer.size = Size(width: Layer.root.width, height: Layer.root.width)
		canvasLayer.moveToHorizontalCenterOfParentLayer()
		canvasLayer.originY = 0
		canvasLayer.backgroundColor = .white
		
		fish.backgroundColor = Color(hue: 37, saturation: 86, brightness: 96)
		fish.size = Size(width: 68, height: 68)
		fish.cornerRadius = fish.width / 2.0
		fish.parent = canvasLayer
		
		fish.moveToCenterOfParentLayer()
		
		targetLayer.image = Image(text: "★", font: UIFont.systemFontOfSize(84), textColor: Color.black)
		targetLayer.parent = canvasLayer
		targetLayer.backgroundColor = Palette.selectedYellow
		
		targetLayer.moveBelowSiblingLayer(fish)
		
		targetLayer.makeDraggable { target in
			target.position = target.position.pointClampedInsideRect(self.canvasLayer.bounds)
		}
	}
}


extension Layer {
	
	/// Make the receiver draggable, with proper moving behaviour.
	/// Optionally, pass a `didUpdateHandler`, which is called after the view has been moved
	func makeDraggable(didUpdateHandler: ((Layer) -> ())? = nil) {
		var initialPositionInLayer = Point()
		touchBeganHandler = { touchSequence in
			initialPositionInLayer = touchSequence.currentSample.locationInLayer(self)
		}
		
		touchMovedHandler = { touchSequence in
			let currentLocation = touchSequence.currentSample.locationInLayer(self.parent!)
			
			// I want this to do "locationInLayer(rect)" but AT THE TIME of the first sample.
			// But this takes the first sample and tries to get its location of where the layer is NOW
			// which doesn't do what I want at all
			//			let firstLocation = touchSequence.firstSample.locationInLayer(rect)
			
			self.origin = currentLocation - initialPositionInLayer
			didUpdateHandler?(self)
		}
	}
}


extension Point {
	func pointClampedInsideRect(rect: Rect) -> Point {
		var point = self
		if point.x < rect.minX { point.x = rect.minX }
		if point.x > rect.maxX { point.x = rect.maxX }
		
		if point.y < rect.minY { point.y = rect.minY }
		if point.y > rect.maxY { point.y = rect.maxY }
		
		return point
	}
}

