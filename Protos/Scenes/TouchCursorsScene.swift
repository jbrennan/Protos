//
//  TouchCursorsScene.swift
//  Protos
//
//  Created by Jason Brennan on 2016-03-27.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope
import MultipeerConnectivity

class TouchCursorsScene {
	
	var cursorLayers: [UITouchID: Layer] = [:]
	let networking = CursorNetworking()
	var heartbeat: Heartbeat!
	let cursorPositions = CursorPositions()
	
	init() {
		Layer.root.backgroundColor = Color.white
		
		Layer.root.touchBeganHandler = { touch in
			let cursor = Layer()
			cursor.backgroundColor = Color.darkGray
			
			let dimension = 60.0
			cursor.size = Size(width: dimension, height: dimension)
			cursor.cornerRadius = dimension / 2.0
			
			cursor.position = touch.currentSample.globalLocation
			
			self.cursorLayers[touch.id] = cursor
			
			self.cursorPositions.addCursor(touch.id.intID, position: cursor.position)
		}
		
		
		Layer.root.touchMovedHandler = { touch in
			let cursor = self.cursorLayers[touch.id]!
			cursor.position = touch.currentSample.globalLocation
			self.cursorPositions.updateCursor(touch.id.intID, position: cursor.position)
			
		}
		
		
		Layer.root.touchEndedHandler = { touch in
			let cursor = self.cursorLayers[touch.id]!
			cursor.parent = nil
			
			self.cursorLayers.removeValueForKey(touch.id)
			self.cursorPositions.removeCursor(touch.id.intID)
		}
		
		heartbeat = Heartbeat { beat in 
			if self.cursorPositions.hasUpdate {
				
				// Can't send the data in an array over the network, so we're sending it one by one
				// This is kind of silly/expensive. might be worth trying NSCoding next
				self.cursorPositions.encodeEachCursor { data in
					self.networking.sendCursorPositions(data)
				}
				self.cursorPositions.hasUpdate = false
			}
		}
	
	}
	
	deinit {
		heartbeat.stop()
	}
	
}

class CursorPositions {
	private var cursors: [Int: (position: Point, removed: Bool)] = [:]
	var hasUpdate = false
	
	
	func addCursor(id: Int, position: Point) {
		cursors[id] = (position, false)
		hasUpdate = true
	}
	
	func updateCursor(id: Int, position: Point) {
		cursors[id] = (position, false)
		hasUpdate = true
	}
	
	func removeCursor(id: Int) {
//		cursors.removeValueForKey(id)
		cursors[id] = (cursors[id]!.position, true)
		
		hasUpdate = true
	}
	
//	var cursorData: NSData {
//		let lightCursors = cursors.map { (key, value) in
//			return Cursor(id: key, x: value.x, y: value.y)
//		}
//		return encode(lightCursors.first!)
//	}
	
	/// Enumerates each cursor, turns it into data, and calls the given handler with that data.
	/// Trying this because we can't seem to encode an array and have it come out as valid on the other side of the network.
	func encodeEachCursor(handler: NSData -> Void) {
		for (id, value) in cursors {
			let position = value.position
			let removed = value.removed
			
			let lightCursor = Cursor(id: id, x: position.x, y: position.y, removed: removed)
			handler(encode(lightCursor))
		}
	}
	
}


/// Small struct for sending over the wire
struct Cursor {
	let id: Int
	let x: Double
	let y: Double
	let removed: Bool
}

extension UITouchID {
	var intID: Int {
		return (description as NSString).integerValue
	}
}


class CursorNetworking: NSObject, MCSessionDelegate {
	
	static let ServiceType = "touch-cursors"
	let peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
	let peerSession: MCSession
	let peerAssistant: MCAdvertiserAssistant
	
	override init() {
		
		peerSession = MCSession(peer: peerID)
		peerAssistant = MCAdvertiserAssistant(serviceType: CursorNetworking.ServiceType, discoveryInfo: nil, session: peerSession)
		
		super.init()
		
		peerSession.delegate = self
		peerAssistant.start()
	}
	
	func sendCursorPositions(positions: NSData) {

		let peers = peerSession.connectedPeers
		
		try! peerSession.sendData(positions, toPeers: peers, withMode: .Unreliable) // consider .Unreliable if .Reliable has lag
	}
	
	func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
		let message = NSString(data: data, encoding: NSUTF8StringEncoding)
		print(message)
	}
	
	func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
		
	}
	
	func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
		
	}
	
	func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
		switch state {
		case .Connected:
			print("\(peerID) connected")
			
		case .NotConnected:
			print("\(peerID) disconnected")
			
		case .Connecting:
			break // who cares?
		}
	}
	
	func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		
	}
}


func encode<T>(var value: T) -> NSData {
	return withUnsafePointer(&value) { p in
		NSData(bytes: p, length: sizeofValue(value))
	}
}

func decode<T>(data: NSData) -> T {
	let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
	data.getBytes(pointer, length: sizeof(T))
	
	return pointer.move()
}




