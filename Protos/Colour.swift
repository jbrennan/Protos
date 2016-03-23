//
//  Color.swift
//  Protos
//
//  Created by Jason Brennan on 3/23/16.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import Prototope

extension Color {
	
	/** HSB colour with values on the natural scale. Hue betwee 0-360, saturation between 0-100, brightness between 0-100. */
	init(hue: Int = 0, saturation: Int = 0, brightness: Int = 0) {
		self.init(hue: Double(hue) / 360.0, saturation: Double(saturation) / 100.0, brightness: Double(brightness) / 100.0)
	}
}


/// Colour palette for the app
struct Palette {
	static var red: Color { return Color(hue: 353, saturation: 99, brightness: 82) }
	
	// Really 49.39, 76.4, 100
	static var selectedYellow: Color { return Color(hue: 49, saturation: 76, brightness: 100) }
}
