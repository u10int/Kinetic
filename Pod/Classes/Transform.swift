//
//  Transform.swift
//  Pods
//
//  Created by Nicholas Shipes on 3/2/16.
//
//

import UIKit

public struct Point: VectorType, Equatable {
	public var x: CGFloat
	public var y: CGFloat
	
	public static var key: String {
		return "point"
	}
	
	public static var zero: Point {
		return Point(x: 0, y: 0)
	}
	
	init(x: CGFloat, y: CGFloat) {
		self.x = x
		self.y = y
	}
	
	init(x: CGFloat) {
		self.x = x
		self.y = 0
	}
	
	init(y: CGFloat) {
		self.x = 0
		self.y = y
	}
}
public func ==(lhs: Point, rhs: Point) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

public struct Size: VectorType, Equatable {
	public var width: CGFloat
	public var height: CGFloat
	
	public static var key: String {
		return "size"
	}
	
	public static var zero: Size {
		return Size(width: 0, height: 0)
	}
}
public func ==(lhs: Size, rhs: Size) -> Bool {
	return lhs.width == rhs.width && lhs.height == rhs.height
}

public struct Shift: VectorType, Equatable {
	public var x: CGFloat
	public var y: CGFloat
	
	public static var key: String {
		return "shift"
	}
	
	public static var zero: Shift {
		return Shift(x: 0, y: 0)
	}
	
	init(x: CGFloat, y: CGFloat) {
		self.x = x
		self.y = y
	}
	
	init(x: CGFloat) {
		self.x = x
		self.y = 0
	}
	
	init(y: CGFloat) {
		self.x = 0
		self.y = y
	}
}
public func ==(lhs: Shift, rhs: Shift) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

// MARK: - Transforms

public struct Scale: VectorType, Equatable {
	public var x: CGFloat
	public var y: CGFloat
	public var z: CGFloat
	
	public static var key: String {
		return "scale"
	}
	
	public static var zero: Scale {
		return Scale(x: 1, y: 1, z: 1)
	}
}
public func ==(lhs: Scale, rhs: Scale) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

public struct Rotation: VectorType, Equatable {
	public var angle: CGFloat
	public var x: CGFloat
	public var y: CGFloat
	public var z: CGFloat
	
	public static var key: String {
		return "rotation"
	}
	
	public static var zero: Rotation {
		return Rotation(angle: 0, x: 0, y: 0, z: 0)
	}
}
public func ==(lhs: Rotation, rhs: Rotation) -> Bool {
	return (lhs.angle == rhs.angle && lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z)
}

public struct Translation: VectorType, Equatable {
	public var x: CGFloat
	public var y: CGFloat
	
	public static var key: String {
		return "translation"
	}
	
	public static var zero: Translation {
		return Translation(x: 0, y: 0)
	}
}
public func ==(lhs: Translation, rhs: Translation) -> Bool {
	return (lhs.x == rhs.x && lhs.y == rhs.y)
}

struct Transform {
	var scale: Scale = Scale.zero
	var rotation: Rotation = Rotation.zero
	var translation: Translation = Translation.zero
}