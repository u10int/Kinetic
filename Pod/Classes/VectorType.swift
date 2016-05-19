//
//  VectorType.swift
//  Pods
//
//  Created by Nicholas Shipes on 3/2/16.
//
//

import Foundation

//public enum PropertyType {
//	case Value
//	case Position
//	case Center
//	case Shift
//	case Size
//}

public protocol PropertyType {
	associatedtype T
	var vector: T { get set }
}

public protocol VectorType {
	static var length: Int { get }
	static var zero: Self { get }
	subscript(index: Int) -> Double { get set }
	func toArray() -> [CGFloat]
}

public protocol InterpolatableProp {
	func interpolatedTo(to: Self, progress: Double) -> Self
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
extension Vector1: InterpolatableProp {
	public func interpolatedTo(to: Vector1, progress: Double) -> Vector1 {
		var diff = [Double]()
		let from = self
		let to = to
		let vectorCount = 2
		
		for idx in 0..<vectorCount {
			let val = from[idx] + (to[idx] - from[idx]) * progress
			diff.append(val)
		}
		
		return Vector1(diff[0])
	}
}

public struct Vector2: VectorType {
	public var x: Double
	public var y: Double
	
	init(_ x: Double, _ y: Double) {
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


//public typealias Prop = (values: CGFloat...) -> Vector
//
//public func PositionType(_ x: CGFloat, _ y: CGFloat) -> Vector {
//	var vector = Position(x, y)
//	vector.type = .Position
//	return vector
//}

//public protocol VectorType2 {
//	associatedtype T
//	
//	static func zero() -> T
//	static func key() -> String
//}
//
//public class AnimationProperty: VectorType2 {
//	public typealias T = AnimationProperty
//	
//	public static func key() -> String {
//		return "point"
//	}
//	
//	public static func zero() -> AnimationProperty {
//		return AnimationProperty()
//	}
//}
//
//public class Position: AnimationProperty {
//	public var x: CGFloat
//	public var y: CGFloat
//	
//	override public static func key() -> String {
//		return "position"
//	}
//	
//	override public static func zero() -> Position {
//		return Position()
//	}
//}
//


/**
 * Hack to work around lack of support for parameterized protocols in Swift
 * Re: https://forums.developer.apple.com/message/18152#18152
 */
public struct AnyPropertyProvider<T>: PropertyType {
	var _vector: () -> T

	init<V: PropertyType where V.T == T>(_ delegatee: V) {
		_vector = {
			return delegatee.vector
		}
	}

	public var vector: T {
		get {
			return _vector()
		}
		set(newValue) {
			_vector = {
				return newValue
			}
		}
	}
}

public struct VectorValue<T>: PropertyType {
	public var vector: T
	
	init(_ vector: T) {
		self.vector = vector
	}
}





public protocol TweenableValue {
	var vectors: [CGFloat] { get }
	var interpolatable: InterpolatableValue { get }
	mutating func apply(prop: TweenableValue)
}

public protocol TweenProp {
	var key: String { get }
	var value: TweenableValue { get set }
}
extension TweenProp {
	public mutating func apply(prop: TweenProp) {
		value.apply(prop.value)
	}
}

public struct PointValue: TweenableValue {
	public var vectors: [CGFloat] {
		return vector.toArray()
	}
	
	public var vector: Vector2 {
		get {
			return _vector.vector
		}
		set(newValue) {
			_vector.vector = newValue
		}
	}
	var _vector: AnyPropertyProvider<Vector2>
	
	public var interpolatable: InterpolatableValue {
		get {
			return InterpolatableValue(type: .CGPoint, vectors: CGFloat(vector.x), CGFloat(vector.y))
		}
	}
	
	public init(_ x: Double, _ y: Double) {
		_vector = AnyPropertyProvider(VectorValue(Vector2.zero))
	}
	
	public init(vector: Vector2) {
		_vector = AnyPropertyProvider(VectorValue(vector))
	}
	
	public mutating func apply(prop: TweenableValue) {
		let v = prop.vectors
		for (idx, value) in v.enumerate() {
			vector[idx] = Double(value)
		}
	}
}

//public struct CenterProp: TweenProp {
//	public var key: String {
//		return "center"
//	}
//	
//	public var vectors: [CGFloat] {
//		return vector.toArray()
//	}
//	
//	public var vector: Vector2 {
//		get {
//			return _vector.vector
//		}
//		set(newValue) {
//			_vector.vector = newValue
//		}
//	}
//	var _vector: AnyPropertyProvider<Vector2>
//	
//	public var interpolatable: InterpolatableValue {
//		get {
//			return InterpolatableValue(type: .CGPoint, vectors: CGFloat(vector.x), CGFloat(vector.y))
//		}
//	}
//	
//	public init(_ x: Double, _ y: Double) {
//		_vector = AnyPropertyProvider(VectorValue(Vector2.zero))
//	}
//	
//	public init(vector: Vector2) {
//		_vector = AnyPropertyProvider(VectorValue(vector))
//	}
//	
//	public mutating func apply(prop: TweenProp) {
//		let v = prop.vectors
//		for (idx, value) in v.enumerate() {
//			vector[idx] = Double(value)
//		}
//	}
//}

public struct PositionProp: TweenProp {
	public var key: String {
		return "position"
	}
	
	public var value: TweenableValue
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.value = PointValue(Double(x), Double(y))
	}
}






public protocol Vector {
	static var key: String { get }
//	var type: PropertyType { get set }
	var key: String { get }
	var interpolatable: InterpolatableValue { get }
	mutating func apply(vector: Vector)
//	func associatedValue() -> Interpolatable
//	static func fromInterpolatable(value: InterpolatableValue) -> Vector
//	func interpolateTo(to: Vector, progress: Double) -> Vector
}

public protocol AssociatedVectorType {
	associatedtype T
	
	func associatedValue() -> T
}

public struct FromToValue {
	var from: TweenProp?
	var to: TweenProp?
	
	init() {}
}

public struct Value {
	public var value: Double
//	public var type: PropertyType
	
	public init(_ value: Double) {
		self.value = value
//		self.type = .Value
	}
}

//extension Value: Vector, Equatable {
//	public static var key: String {
//		return "value"
//	}
//	
////	public var type: InterpolatableType {
////		return .Double
////	}
//	
//	public var key: String {
//		return Value.key
//	}
//	
//	public var interpolatable: InterpolatableValue {
//		return (CGFloat(value)).vectorize()
//	}
//	
//	public mutating func apply(vector: Vector) {
//		let vectors = vector.interpolatable.vectors
//		self.value = Double(vectors[0])
//	}
//	
//	public func associatedValue() -> Interpolatable {
//		return CGFloat(value)
//	}
//	
//	public func interpolateTo(to: Vector, progress: Double) -> Vector {
//		let val = self.interpolatable.interpolateTo(to.interpolatable, progress: progress)
//		return Value.fromInterpolatable(val)
//	}
//	
//	public static func fromInterpolatable(value: InterpolatableValue) -> Vector {
//		let vectors = value.vectors
//		return Value(Double(vectors[0]))
//	}
//}
public func ==(lhs: Value, rhs: Value) -> Bool {
	return lhs.value == rhs.value
}

// MARK: Position

public struct Position {
//	public var type: PropertyType
	public var x: CGFloat
	public var y: CGFloat
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.x = x
		self.y = y
//		self.type = .Position
	}
}

//extension Position: Vector, Equatable {
//	public static var key: String {
//		return "position"
//	}
//	
////	public var type: InterpolatableType {
////		return .CGPoint
////	}
//	
//	public var key: String {
//		return Position.key
//	}
//	
//	public var CGPointValue: CGPoint {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public var interpolatable: InterpolatableValue {
//		return CGPointValue.vectorize()
//	}
//
//	public init(x: CGFloat) {
//		self.init(x, CGFloat.min)
//	}
//	
//	public init(y: CGFloat) {
//		self.init(CGFloat.min, y)
//	}
//	
//	public mutating func apply(vector: Vector) {
//		let vectors = vector.interpolatable.vectors
//		if vectors[0] > CGFloat.min { self.x = vectors[0] }
//		if vectors[1] > CGFloat.min { self.y = vectors[1] }
//	}
//	
//	public func associatedValue() -> Interpolatable {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public func interpolateTo(to: Vector, progress: Double) -> Vector {
//		let val = self.interpolatable.interpolateTo(to.interpolatable, progress: progress)
//		return Position.fromInterpolatable(val)
//	}
//	
//	public static func fromInterpolatable(value: InterpolatableValue) -> Vector {
//		let vectors = value.vectors
//		return Position(vectors[0], vectors[1])
//	}
//}
//public func ==(lhs: Position, rhs: Position) -> Bool {
//	return lhs.x == rhs.x && lhs.y == rhs.y
//}
//
//public struct Center {
////	public var type: PropertyType
//	public var x: CGFloat
//	public var y: CGFloat
//	
//	public init(_ x: CGFloat, _ y: CGFloat) {
//		self.x = x
//		self.y = y
////		self.type = .Position
//	}
//}
//
//extension Center: Vector, Equatable {
//	public static var key: String {
//		return "center"
//	}
//	
////	public var type: InterpolatableType {
////		return .CGPoint
////	}
//	
//	public var key: String {
//		return Center.key
//	}
//	
//	public var CGPointValue: CGPoint {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public var interpolatable: InterpolatableValue {
//		return CGPointValue.vectorize()
//	}
//	
//	public init(x: CGFloat) {
//		self.init(x, CGFloat.min)
//	}
//	
//	public init(y: CGFloat) {
//		self.init(CGFloat.min, y)
//	}
//	
//	public mutating func apply(vector: Vector) {
//		let vectors = vector.interpolatable.vectors
//		if vectors[0] != CGFloat.min { self.x = vectors[0] }
//		if vectors[1] != CGFloat.min { self.y = vectors[1] }
//	}
//	
//	public func associatedValue() -> Interpolatable {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public func interpolateTo(to: Vector, progress: Double) -> Vector {
//		let val = self.interpolatable.interpolateTo(to.interpolatable, progress: progress)
//		return Center.fromInterpolatable(val)
//	}
//	
//	public static func fromInterpolatable(value: InterpolatableValue) -> Vector {
//		let vectors = value.vectors
//		return Center(vectors[0], vectors[1])
//	}
//}
//public func ==(lhs: Center, rhs: Center) -> Bool {
//	return lhs.x == rhs.x && lhs.y == rhs.y
//}
//
//public struct Shift {
////	public var type: PropertyType
//	public var x: CGFloat
//	public var y: CGFloat
//	
//	public init(_ x: CGFloat, _ y: CGFloat) {
//		self.x = x
//		self.y = y
////		self.type = .Position
//	}
//}
//
//extension Shift: Vector, Equatable {
//	public static var key: String {
//		return "shift"
//	}
//	
////	public var type: InterpolatableType {
////		return .CGPoint
////	}
//	
//	public var key: String {
//		return Shift.key
//	}
//	
//	public var CGPointValue: CGPoint {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public var interpolatable: InterpolatableValue {
//		return CGPointValue.vectorize()
//	}
//	
//	public init(x: CGFloat) {
//		self.init(x, CGFloat.min)
//	}
//	
//	public init(y: CGFloat) {
//		self.init(CGFloat.min, y)
//	}
//	
//	public mutating func apply(vector: Vector) {
//		let vectors = vector.interpolatable.vectors
//		if vectors[0] != CGFloat.min { self.x = vectors[0] }
//		if vectors[1] != CGFloat.min { self.y = vectors[1] }
//	}
//	
//	public func associatedValue() -> Interpolatable {
//		return CGPoint(x: x, y: y)
//	}
//	
//	public func interpolateTo(to: Vector, progress: Double) -> Vector {
//		let val = self.interpolatable.interpolateTo(to.interpolatable, progress: progress)
//		return Shift.fromInterpolatable(val)
//	}
//	
//	public static func fromInterpolatable(value: InterpolatableValue) -> Vector {
//		let vectors = value.vectors
//		return Shift(vectors[0], vectors[1])
//	}
//}
//public func ==(lhs: Shift, rhs: Shift) -> Bool {
//	return lhs.x == rhs.x && lhs.y == rhs.y
//}

// MARK: Size

public struct Size {
//	public var type: PropertyType
	public var width: CGFloat
	public var height: CGFloat
	
	public init(_ width: CGFloat, _ height: CGFloat) {
		self.width = width
		self.height = height
//		self.type = .Size
	}
}

//extension Size: Vector, Equatable {
//	public static var key: String {
//		return "size"
//	}
//	
////	public var type: InterpolatableType {
////		return .CGSize
////	}
//	
//	public var key: String {
//		return Size.key
//	}
//	
//	public var CGSizeValue: CGSize {
//		return CGSize(width: width, height: height)
//	}
//	
//	public var interpolatable: InterpolatableValue {
//		return CGSizeValue.vectorize()
//	}
//	
//	public init(width: CGFloat) {
//		self.init(width, CGFloat.min)
//	}
//	
//	public init(height: CGFloat) {
//		self.init(CGFloat.min, height)
//	}
//	
//	public mutating func apply(vector: Vector) {
//		let vectors = vector.interpolatable.vectors
//		if vectors[0] != CGFloat.min { self.width = vectors[0] }
//		if vectors[1] != CGFloat.min { self.height = vectors[1] }
//	}
//	
//	public func associatedValue() -> Interpolatable {
//		return CGSize(width: width, height: height)
//	}
//	
//	public func interpolateTo(to: Vector, progress: Double) -> Vector {
//		let val = self.interpolatable.interpolateTo(to.interpolatable, progress: progress)
//		return Size.fromInterpolatable(val)
//	}
//	
//	public static func fromInterpolatable(value: InterpolatableValue) -> Vector {
//		let vectors = value.vectors
//		return Size(vectors[0], vectors[1])
//	}
//}
public func ==(lhs: Size, rhs: Size) -> Bool {
	return lhs.width == rhs.width && lhs.height == rhs.height
}
