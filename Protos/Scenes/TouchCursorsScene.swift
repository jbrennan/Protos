//
//  TouchCursorsScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-03-27.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope

class TouchCursorsScene {
	
	var cursorLayers: [UITouchID: Layer] = [:]
	
	init() {
		Layer.root.backgroundColor = Color.white
		
		Layer.root.touchBeganHandler = { touch in
			let cursor = Layer()
			cursor.backgroundColor = Color.darkGray
			cursor.size = Size(width: 44, height: 44)
			cursor.cornerRadius = cursor.size.width / 2.0
			
			cursor.position = touch.currentSample.globalLocation
			
			self.cursorLayers[touch.id] = cursor
		}
		
		
		Layer.root.touchMovedHandler = { touch in
			let cursor = self.cursorLayers[touch.id]!
			cursor.position = touch.currentSample.globalLocation
		}
		
		
		Layer.root.touchEndedHandler = { touch in
			let cursor = self.cursorLayers[touch.id]!
			cursor.parent = nil
			
			self.cursorLayers.removeValueForKey(touch.id)
		}
	}
}
