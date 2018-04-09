//
//  VectorType.swift
//  Pods
//
//  Created by Nicholas Shipes on 6/10/17.
//
//

import Foundation

public protocol VectorType {
	static var length: Int { get }
	static var zero: Self { get }
	subscript(index: Int) -> Double { get set }
	func toArray() -> [CGFloat]
}

public struct Vector1: VectorType {
	public var x: Double
	
	init(_ x: Double) {
		self.x = x
	}
	
	public static var length: Int {
		return 1
	}
	
	public static var zero: Vector1 {
		return Vector1(0)
	}
	
	public subscript(index: Int) -> Double {
		get {
			precondition(index == 0)
			return x
		}
		set {
			precondition(index == 0)
			x = newValue
		}
	}
	
	public func toArray() -> [CGFloat] {
		return [CGFloat(x)]
	}
}

public struct Vector2: VectorType {
	public var x: Double
	public var y: Double
	
	public init(_ x: Double, _ y: Double) {
		self.x = x
		self.y = y
	}
	
	public static var length: Int {
		return 2
	}
	
	public static var zero: Vector2 {
		return Vector2(0, 0)
	}
	
	public subscript(index: Int) -> Double {
		get {
			precondition(index >= 0)
			precondition(index < 2)
			switch index {
			case 0:
				return x
			case 1:
				return y
			default:
				fatalError()
			}
		}
		set {
			precondition(index >= 0)
			precondition(index < 2)
			switch index {
			case 0:
				x = newValue
			case 1:
				y = newValue
			default:
				fatalError()
			}
		}
	}
	
	public func toArray() -> [CGFloat] {
		return [CGFloat(x), CGFloat(y)]
	}
}

public struct Vector3: VectorType {
	public var x: Double
	public var y: Double
	public var z: Double
	
	public init(_ x: Double, _ y: Double, _ z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	public static var length: Int {
		return 3
	}
	
	public static var zero: Vector3 {
		return Vector3(0, 0, 0)
	}
	
	public subscript(index: Int) -> Double {
		get {
			precondition(index >= 0)
			precondition(index < 3)
			switch index {
			case 0:
				return x
			case 1:
				return y
			case 2:
				return z
			default:
				fatalError()
			}
		}
		set {
			precondition(index >= 0)
			precondition(index < 3)
			switch index {
			case 0:
				x = newValue
			case 1:
				y = newValue
			case 2:
				z = newValue
			default:
				fatalError()
			}
		}
	}
	
	public func toArray() -> [CGFloat] {
		return [CGFloat(x), CGFloat(y), CGFloat(z)]
	}
}
