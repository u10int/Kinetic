//
//  VectorType.swift
//  Pods
//
//  Created by Nicholas Shipes on 3/2/16.
//
//

import Foundation

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
	func interpolatedTo(_ to: Self, progress: Double) -> Self
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
//extension Vector1: InterpolatableProp {
//	public func interpolatedTo(to: Vector1, progress: Double) -> Vector1 {
//		var diff = [Double]()
//		let from = self
//		let to = to
//		let vectorCount = 2
//		
//		for idx in 0..<vectorCount {
//			let val = from[idx] + (to[idx] - from[idx]) * progress
//			diff.append(val)
//		}
//		
//		return Vector1(diff[0])
//	}
//}

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

	init<V: PropertyType>(_ delegatee: V) where V.T == T {
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





public protocol Tweenable {
	var vectors: [CGFloat] { get }
	var interpolatable: InterpolatableValue { get }
	var zero: CGFloat { get }
	mutating func apply(_ prop: Tweenable)
	mutating func apply(_ interpolatable: InterpolatableValue)
	func toInterpolatable() -> Interpolatable
}
extension Tweenable {
	public mutating func apply(_ prop: Tweenable) {
		apply(prop.interpolatable)
	}
}

public protocol TweenProp {
	var key: String { get }
	var value: Tweenable { get set }
}
extension TweenProp {
	public mutating func apply(_ prop: TweenProp) {
		apply(prop.value.interpolatable)
	}
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		value.apply(interpolatable)
	}
}
//public func ==<T: TweenProp>(lhs: T, rhs: T) -> Bool {
//	return lhs.value == rhs.value
//}

//public struct PointValue: Tweenable {
//	public var key: String {
//		return ""
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
//	public mutating func apply(prop: Tweenable) {
//		let v = prop.vectors
//		for (idx, value) in v.enumerate() {
//			vector[idx] = Double(value)
//		}
//	}
//	
//	public mutating func apply(interpolatable: InterpolatableValue) {
//		
//	}
//}

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



let NullValue: CGFloat = -CGFloat.greatestFiniteMagnitude

//public protocol Value {}
public struct Value<T: Interpolatable> {
	var interpolatable: T
}
//extension TweenValue {
//	
//}
//

public protocol Property {
	var key: String { get }
	var value: InterpolatableValue { get set }
}
extension Property {
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		var vectors = value.toInterpolatable().vectorize().vectors
		let applyVectors = interpolatable.vectors
		
		for i in 0..<applyVectors.count {
			if applyVectors[i] > NullValue { vectors[i] = applyVectors[i] }
		}
		
		let type = self.value.type
		self.value = InterpolatableValue(type: type, vectors: vectors)
	}
}

public struct Frame: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame"
	}
	
	init(value: Interpolatable) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: [NullValue])
	}
}

//public struct Property<Value>: TweenValue {
//	typealias Value
//	
//	public init<T: Interpolatable>(value: T) where Value == T {
//		
//	}
//}
//
//
//func testProp() {
//	var size = TweenValue<CGSize>(value: .zero)
//	size.value.width = 50
//	size.value.vectorize().vectors
//}



public struct ValueProp: Tweenable {
	public var interpolatable: InterpolatableValue {
		return value.vectorize()
	}
	public var vectors: [CGFloat] {
		return value.vectorize().vectors
	}
	
	public var zero: CGFloat {
		return NullValue
	}
	
	fileprivate var value: CGFloat
	
	public init(_ value: CGFloat) {
		self.value = value
	}
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		if let value = interpolatable.toInterpolatable() as? CGFloat {
			self.value = value
		}
	}
	
	public func toInterpolatable() -> Interpolatable {
		return value
	}
}

public struct PointProp: Tweenable, Equatable {
	public var interpolatable: InterpolatableValue {
		return value.vectorize()
	}
	public var vectors: [CGFloat] {
		return value.vectorize().vectors
	}
	
	public var zero: CGFloat {
		return NullValue
	}
	
	fileprivate var value: CGPoint
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.value = CGPoint(x: x, y: y)
	}
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		if let point = interpolatable.toInterpolatable() as? CGPoint {
			let vectors = interpolatable.vectors
			if vectors[0] > zero { self.value.x = vectors[0] }
			if vectors[1] > zero { self.value.y = vectors[1] }
		}
	}
	
	public func toInterpolatable() -> Interpolatable {
		return value
	}
}
public func ==(lhs: PointProp, rhs: PointProp) -> Bool {
	return lhs.value == rhs.value
}

public struct SizeProp: Tweenable, Equatable {
	public var interpolatable: InterpolatableValue {
		return value.vectorize()
	}
	public var vectors: [CGFloat] {
		return value.vectorize().vectors
	}
	public var zero: CGFloat {
		return NullValue
	}
	
	fileprivate var value: CGSize
	
	public init(_ width: CGFloat, _ height: CGFloat) {
		self.value = CGSize(width: width, height: height)
	}
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		if let size = interpolatable.toInterpolatable() as? CGSize {
			let vectors = interpolatable.vectors
			if vectors[0] > zero { self.value.width = vectors[0] }
			if vectors[1] > zero { self.value.height = vectors[1] }
		}
	}
	
	public func toInterpolatable() -> Interpolatable {
		return value
	}
}
public func ==(lhs: SizeProp, rhs: SizeProp) -> Bool {
	return lhs.value == rhs.value
}

public struct ColorProp: Tweenable {
	public var interpolatable: InterpolatableValue {
		return value.vectorize()
	}
	public var vectors: [CGFloat] {
		return value.vectorize().vectors
	}
	public var zero: CGFloat {
		return 0
	}
	
	fileprivate var value: UIColor
	
	public init(_ color: UIColor) {
		self.value = color
	}
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		if let color = interpolatable.toInterpolatable() as? UIColor {
			let vectors = interpolatable.vectors
			switch interpolatable.type {
			case .colorRGB:
				self.value = UIColor(red: vectors[0], green: vectors[1], blue: vectors[2], alpha: vectors[3])
			case .colorHSB:
				self.value = UIColor(hue: vectors[0], saturation: vectors[1], brightness: vectors[2], alpha: vectors[3])
			case .colorMonochrome:
				self.value = UIColor(white: vectors[0], alpha: vectors[1])
			default:
				let s = ""
			}
		}
	}
	
	public func toInterpolatable() -> Interpolatable {
		return value
	}
}


public struct Vector3Prop: Tweenable {
	public var interpolatable: InterpolatableValue {
		return value.vectorize()
	}
	public var vectors: [CGFloat] {
		return value.vectorize().vectors
	}
	public var zero: CGFloat {
		return NullValue
	}
	
	fileprivate var value: CGSize
	
	public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
		self.value = CGSize(width: x, height: y)
	}
	
	public mutating func apply(_ interpolatable: InterpolatableValue) {
		if let size = interpolatable.toInterpolatable() as? CGSize {
			let vectors = interpolatable.vectors
			if vectors[0] > zero { self.value.width = vectors[0] }
			if vectors[1] > zero { self.value.height = vectors[1] }
		}
	}
	
	public func toInterpolatable() -> Interpolatable {
		return value
	}
}


public struct Alpha: TweenProp {
	public var key: String {
		return "alpha"
	}
	public var value: Tweenable
	
	public init(_ value: CGFloat) {
		self.value = ValueProp(value)
	}
}

public struct X: TweenProp {
	public var key: String {
		return "position.x"
	}
	public var value: Tweenable
	
	public init(_ value: CGFloat) {
		self.value = ValueProp(value)
	}
}

public struct Y: TweenProp {
	public var key: String {
		return "position.y"
	}
	public var value: Tweenable
	
	public init(_ value: CGFloat) {
		self.value = ValueProp(value)
	}
}

public struct Position: TweenProp {
	public var key: String {
		return "position"
	}
	public var value: Tweenable
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.value = PointProp(x, y)
	}
	
	public init(x: CGFloat) {
		self.value = PointProp(x, NullValue)
	}
	
	public init(y: CGFloat) {
		self.value = PointProp(NullValue, y)
	}
}

public struct Center: TweenProp {
	public var key: String {
		return "center"
	}
	public var value: Tweenable
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.value = PointProp(x, y)
	}
	
	public init(x: CGFloat) {
		self.init(x, NullValue)
	}
	
	public init(y: CGFloat) {
		self.init(NullValue, y)
	}
}

public struct Size: TweenProp {
	public var key: String {
		return "size"
	}
	public var value: Tweenable
	
	public init(_ width: CGFloat, _ height: CGFloat) {
		self.value = SizeProp(width, height)
	}
	
	public init(width: CGFloat) {
		self.init(width, NullValue)
	}
	
	public init(height: CGFloat) {
		self.init(NullValue, height)
	}
}

public struct BackgroundColor: TweenProp {
	public var key: String {
		return "backgroundColor"
	}
	public var value: Tweenable
	
	public init(_ color: UIColor) {
		self.value = ColorProp(color)
	}
}

public struct FillColor: TweenProp {
	public var key: String {
		return "fillColor"
	}
	public var value: Tweenable
	
	public init(_ color: UIColor) {
		self.value = ColorProp(color)
	}
}

public struct StrokeColor: TweenProp {
	public var key: String {
		return "strokeColor"
	}
	public var value: Tweenable
	
	public init(_ color: UIColor) {
		self.value = ColorProp(color)
	}
}

public struct KeyPath: TweenProp {
	public var key: String
	public var value: Tweenable
	
	public init(_ keyPath: String, _ value: Any) {
		self.key = keyPath
		
		if let number = value as? CGFloat {
			self.value = ValueProp(number)
		} else if let number = value as? Float {
			self.value = ValueProp(CGFloat(number))
		} else if let number = value as? Double {
			self.value = ValueProp(CGFloat(number))
		} else if let number = value as? Int {
			self.value = ValueProp(CGFloat(number))
		} else if let number = value as? NSNumber {
			self.value = ValueProp(CGFloat(number))
		} else if let point = value as? CGPoint {
			self.value = PointProp(point.x, point.y)
		} else if let size = value as? CGSize {
			self.value = SizeProp(size.width, size.height)
		} else if let color = value as? UIColor {
			self.value = ColorProp(color)
		} else {
			self.value = ValueProp(NullValue)
		}
	}
}



public protocol TransformType {}

public struct Scale: TweenProp, TransformType, Equatable {
	public var key: String {
		return "transform.scale"
	}
	public var value: Tweenable
	
	static var zero: Scale {
		return Scale(1, 1, 1)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
		self.value = Vector3Prop(x, y, z)
	}
	
	public init(x: CGFloat) {
		self.init(x, 1, 1)
	}
	
	public init(y: CGFloat) {
		self.init(1, y, 1)
	}
}
public func ==(lhs: Scale, rhs: Scale) -> Bool {
	if let lhs = lhs.value as? Vector3Prop, let rhs = rhs.value as? Vector3Prop {
		return lhs.value == rhs.value
	}
	return false
}

public struct Rotation: TweenProp, TransformType, Equatable {
	public var key: String {
		return "transform.rotation"
	}
	public var value: Tweenable
	
	public var x: Bool
	public var y: Bool
	public var z: Bool
	
	static var zero: Rotation {
		return Rotation(0)
	}
	
	public init(_ angle: CGFloat) {
		self.value = ValueProp(angle)
		self.x = false
		self.y = false
		self.z = true
	}
	
	public init(x angle: CGFloat) {
		self.value = ValueProp(angle)
		self.x = true
		self.y = false
		self.z = false
	}
	
	public init(y angle: CGFloat) {
		self.value = ValueProp(angle)
		self.x = false
		self.y = true
		self.z = false
	}
}
extension Rotation {	
	public mutating func apply(_ rotation: Rotation) {
		apply(rotation.value.interpolatable)
		self.x = rotation.x
		self.y = rotation.y
		self.z = rotation.z
	}
	
	public mutating func applyAxes(_ rotation: Rotation) {
		self.x = rotation.x
		self.y = rotation.y
		self.z = rotation.z
	}
}
public func ==(lhs: Rotation, rhs: Rotation) -> Bool {
	if let a1 = lhs.value as? ValueProp, let a2 = rhs.value as? ValueProp {
		return (a1.value == a2.value && lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z)
	}
	return false
}

public struct Translation: TweenProp, TransformType, Equatable {
	public var key: String {
		return "transform.translation"
	}
	public var value: Tweenable
	
	static var zero: Translation {
		return Translation(0, 0)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.value = PointProp(x, y)
	}
	
	public init(x: CGFloat) {
		self.value = PointProp(x, NullValue)
	}
	
	public init(y: CGFloat) {
		self.value = PointProp(NullValue, y)
	}
}
public func ==(lhs: Translation, rhs: Translation) -> Bool {
	if let lhs = lhs.value as? PointProp, let rhs = rhs.value as? PointProp {
		return lhs.value == rhs.value
	}
	return false
}

public struct Transform: TweenProp, Equatable {
	public var key: String {
		return "transform"
	}
	public var value: Tweenable

	public var scale: Scale
	public var rotation: Rotation
	public var translation: Translation
	
	fileprivate var orderedProps = [TransformType]()
	fileprivate var orderedPropKeys = [String]()
	
	public static var zero: Transform {
		return Transform()
	}
	
	public init() {
		self.scale = Scale.zero
		self.rotation = Rotation.zero
		self.translation = Translation.zero
		self.value = ValueProp(NullValue)
	}
	
	public init(_ transform: CATransform3D) {
		self.init()
		self.scale = transform.scale()
		self.rotation = transform.rotation()
		self.translation = transform.translation()
	}
	
	public init(_ props: TransformType...) {
		self.init()
		
		self.orderedProps = props
		
		for prop in props {
			if let scale = prop as? Scale {
				self.scale = scale
			} else if let rotation = prop as? Rotation {
				self.rotation = rotation
			} else if let translation = prop as? Translation {
				self.translation = translation
			}
		}
	}
}
public func ==(lhs: Transform, rhs: Transform) -> Bool {
	return (lhs.scale == rhs.scale && lhs.rotation == rhs.rotation && lhs.translation == rhs.translation)
}

extension Transform {
	mutating func apply(_ type: TransformType) {
		orderedProps.append(type)
		
		if let prop = type as? TweenProp {
			orderedPropKeys.append(prop.key)
		}
		
		if let scale = type as? Scale {
			self.scale.value.apply(scale.value.interpolatable)
		} else if let rotation = type as? Rotation {
			self.rotation.value.apply(rotation.value.interpolatable)
			self.rotation.x = rotation.x
			self.rotation.y = rotation.y
			self.rotation.z = rotation.z
		} else if let translation = type as? Translation {
			self.translation.value.apply(translation.value.interpolatable)
		}
	}
	
	func applyTo(_ tweenObject: TweenObject) {
		var t = CATransform3DIdentity
		var removeTranslationForRotate = false
				
		// apply any existing transforms that aren't specified in this tween
		if let currentScale = tweenObject.scale, let value = currentScale.value.toInterpolatable() as? Vector3, !orderedPropKeys.contains(currentScale.key) {
			t = CATransform3DScale(t, CGFloat(value.x), CGFloat(value.y), CGFloat(value.z))
		}
		if let currentRotation = tweenObject.rotation, let angle = currentRotation.value.toInterpolatable() as? CGFloat, !orderedPropKeys.contains(currentRotation.key) {
			t = CATransform3DRotate(t, angle, (currentRotation.x ? 1 : 0), (currentRotation.y ? 1 : 0), (currentRotation.z ? 1 : 0))
		}
		if let currentTranslation = tweenObject.translation, let value = currentTranslation.value.toInterpolatable() as? CGPoint, !orderedPropKeys.contains(currentTranslation.key) {
			t = CATransform3DTranslate(t, value.x, value.y, 0)
			removeTranslationForRotate = true
		}
		
		// make sure transforms are combined in the order in which they're specified for the tween
		for prop in orderedProps {
			if prop is Scale {
				if let scale = scale.value.toInterpolatable() as? Vector3 {
					t = CATransform3DScale(t, CGFloat(scale.x), CGFloat(scale.y), CGFloat(scale.z))
				}
			} else if prop is Rotation {
				if let angle = rotation.value.toInterpolatable() as? CGFloat, let originalTranslation = tweenObject.translation, let translation = translation.value.toInterpolatable() as? CGPoint {
					// if we have a translation, remove the translation before applying the rotation
					if removeTranslationForRotate && originalTranslation != Translation.zero {
						t = CATransform3DTranslate(t, -translation.x, -translation.y, 0)
					}
					
					t = CATransform3DRotate(t, angle, (rotation.x ? 1 : 0), (rotation.y ? 1 : 0), (rotation.z ? 1 : 0))
					
					// add translation back
					if removeTranslationForRotate && originalTranslation != Translation.zero {
						t = CATransform3DTranslate(t, translation.x, translation.y, 0)
					}
				}
			} else if prop is Translation {
				if let translation = translation.value.toInterpolatable() as? CGPoint {
					t = CATransform3DTranslate(t, translation.x, translation.y, 0)
				}
			}
		}
//		print(t)
		tweenObject.transform = t
	}
}

extension CATransform3D {
	
	func scale() -> Scale {
		let x = sqrt((m11 * m11) + (m12 * m12) + (m13 * m13))
		let y = sqrt((m21 * m21) + (m22 * m22) + (m23 * m23))
		
		return Scale(x, y, 1)
	}
	
	func rotation() -> Rotation {
		return Rotation(atan2(m12, m11))
	}
	
	func translation() -> Translation {
		var x = sqrt(m41 * m41)
		var y = sqrt(m42 * m42)
		
		let inv = CATransform3DInvert(self)
		if x != 0 { x = inv.m41 * -1 }
		if y != 0 { y = inv.m42 * -1 }
		
		return Translation(x, y)
	}
}



public protocol Vector {
	static var key: String { get }
//	var type: PropertyType { get set }
	var key: String { get }
	var interpolatable: InterpolatableValue { get }
	mutating func apply(_ vector: Vector)
//	func associatedValue() -> Interpolatable
//	static func fromInterpolatable(value: InterpolatableValue) -> Vector
//	func interpolate(to: Vector, progress: Double) -> Vector
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
