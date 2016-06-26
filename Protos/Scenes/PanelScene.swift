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
	let fishLayer = Layer()
	let targetLayer = Layer()
	let playButton = Layer()
	
	let fishObject = StageObject(position: Point(), kind: .Circle)
	
	init() {
		Layer.root.backgroundColor = Palette.lightBackground
		
		canvasLayer.size = Size(width: Layer.root.width, height: Layer.root.width)
		canvasLayer.moveToHorizontalCenterOfParentLayer()
		canvasLayer.moveToTopSideOfParentLayer(margin: 100)
		canvasLayer.backgroundColor = .white
		
		fishLayer.backgroundColor = Color(hue: 37, saturation: 86, brightness: 96) // orangy
		fishLayer.size = Size(width: 68, height: 68)
		fishLayer.cornerRadius = fishLayer.width / 2.0
		fishLayer.parent = canvasLayer
		
		fishLayer.moveToCenterOfParentLayer()
		fishLayer.makeDraggable { fish in
			fish.position = fish.position.pointClampedInsideRect(self.canvasLayer.bounds)
			self.fishObject.position = fish.position
		}
		
		targetLayer.image = Image(text: "★", font: UIFont.systemFontOfSize(84), textColor: Color.black)
		targetLayer.parent = canvasLayer
		targetLayer.backgroundColor = Palette.selectedYellow
		
		targetLayer.moveBelowSiblingLayer(fishLayer)
		
		targetLayer.makeDraggable { target in
			target.position = target.position.pointClampedInsideRect(self.canvasLayer.bounds)
		}
		
		playButton.image = Image(text: "Play")
		playButton.moveBelowSiblingLayer(canvasLayer, margin: 20)
		playButton.moveToHorizontalCenterOfParentLayer()
		playButton.touchEndedHandler = { _ in
			self.play()
		}
	}
	
	
	func play() {
		
		// bug here: This is going to move the objects on the editing canvas, not the stage
		// currently nothing's on the stage.
		// this instruction is currently ignored, for the prototype's sake
		let moveToTarget = Instruction.MoveToTarget(stageObject: fishObject)
		let stageLayer = StageLayer(frame: Layer.root.bounds, stageObjects: [fishObject], instructions: [moveToTarget])
		
		
		stageLayer.popIn()
	}
}


class StageLayer: Layer {
	let canvas = Layer()
	private let bg = Layer()
	private let stageRunner: StageRunner
	
	// really I should be given a list of StageObjects, then make views for those objects
	// and then keep the views updated as the program runs
	private let fishLayer = Layer()
	private let targetLayer = Layer()
	
	private let stageObjects: [StageObject]
	
	
	init(frame: Rect, stageObjects: [StageObject], instructions: [Instruction]) {
		
		stageRunner = StageRunner(instructions: instructions)
		self.stageObjects = stageObjects
		
		super.init()
		
		self.frame = frame
		backgroundColor = .black
		
		bg.parent = self
		bg.frame = bounds
		bg.backgroundColor = .black
		bg.touchEndedHandler = { [weak self] _ in
			self?.fadeOutAndRemoveAfterDuration(0.2)
			self?.stageRunner.stop()
		}
		
		canvas.parent = self
		canvas.backgroundColor = .white
		canvas.size = Size(width: width, height: width)
		canvas.moveToCenterOfParentLayer()
		
		canvas.touchBeganHandler = { [weak self] seq in
			self?.stageRunner.target = seq.currentSample.locationInLayer(self!.canvas)
		}
		
		canvas.touchMovedHandler = { [weak self] seq in
			self?.stageRunner.target = seq.currentSample.locationInLayer(self!.canvas)
		}
		
		
		// delete this stuff eventually
		fishLayer.backgroundColor = Color(hue: 37, saturation: 86, brightness: 96) // orangy
		fishLayer.size = Size(width: 68, height: 68)
		fishLayer.cornerRadius = fishLayer.width / 2.0
		fishLayer.parent = canvas
		
		fishLayer.moveToCenterOfParentLayer()
		
		targetLayer.image = Image(text: "★", font: UIFont.systemFontOfSize(84), textColor: Color.black)
		targetLayer.parent = canvas
		targetLayer.backgroundColor = Palette.selectedYellow
		
		targetLayer.moveBelowSiblingLayer(fishLayer)
		
		stageRunner.onEachFrameDidRunHandler = {
			for object in self.stageObjects {
				if object.kind == .Circle {
					self.fishLayer.position = object.position
				}
			}
		}
	}
	
	deinit {
		print("dying")
	}
}


class StageRunner {
	var heartbeat: Heartbeat!
	var target = Point()
	let instructions: [Instruction]
	
	var onEachFrameDidRunHandler: (Void -> Void)?
	
	init(instructions: [Instruction]) {
		
		self.instructions = instructions
		
		heartbeat = Heartbeat { [weak self] beat in
			self?.onEachFrame()
		}
	}
	
	func stop() {
		// ideally deinit should fire
		// but there seems to be a bug either in Prototope or Protos
		// causing this who scene to stay around and not get dealloc'd
		heartbeat.stop()
	}
	
	deinit {
		heartbeat.stop()
	}
	
	
	private func onEachFrame() {
		for instruction in instructions {
			executeInstruction(instruction)
		}
		onEachFrameDidRunHandler?()
	}
	
	private func executeInstruction(instruction: Instruction) {
		switch instruction {
		case let .MoveToTarget(stageObject):
			stageObject.position = target//toEndOfStageObject.position
		}
	}
}


enum Instruction {
	case MoveToTarget(stageObject: StageObject)
}


/// Model for the objects that appear on the stage. These are usually shapes, but can be anything
class StageObject { // maybe this should be a protocol, with different implementors (shapes, lines, targets, etc)?
	
	/// Centre point of the object
	var position: Point
	
	// other properties, like size, colour, scale, rotation, maybe?
	
	enum ObjectKind {
		case Circle
		case Target // or is Target a special case?
		case Line
	}
	
	let kind: ObjectKind
	
	init(position: Point, kind: ObjectKind) {
		self.position = position
		self.kind = kind
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

