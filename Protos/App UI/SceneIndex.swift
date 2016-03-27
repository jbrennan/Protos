//
//  SceneIndex.swift
//  Protos
//
//  Created by Jason Brennan on 2016-02-16.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Foundation

struct Scene {
	let name: String
	let constructor: () -> AnyObject
	
	static let sceneIndex: [Scene] = [
		Scene(name: "Touch Cursors", constructor: { TouchCursorsScene() })
	]
}