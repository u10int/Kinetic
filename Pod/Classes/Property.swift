//
//  VectorType.swift
//  Pods
//
//  Created by Nicholas Shipes on 3/2/16.
//
//

import Foundation

let NullValue: CGFloat = -CGFloat.greatestFiniteMagnitude

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
	
	public mutating func apply(_ prop: Property) {
		self.apply(prop.value)
	}
}

public protocol TransformType {}

public struct X: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame.x"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct Y: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame.y"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct Position: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame.origin"
	}
	
	public init(_ value: Interpolatable) {
		self.value = InterpolatableValue(type: .cgPoint, vectors: value.vectorize().vectors)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.init(CGPoint(x: x, y: y))
	}
}

public struct Center: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "center"
	}
	
	public init(_ value: Interpolatable) {
		self.value = InterpolatableValue(type: .cgPoint, vectors: value.vectorize().vectors)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.init(CGPoint(x: x, y: y))
	}
	
	public init(x: CGFloat) {
		self.init(CGPoint(x: x, y: NullValue))
	}
	
	public init(y: CGFloat) {
		self.init(CGPoint(x: NullValue, y: y))
	}
}

public struct Shift: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "shift"
	}
	
	public init(_ value: Interpolatable) {
		self.value = InterpolatableValue(type: .cgPoint, vectors: value.vectorize().vectors)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.init(CGPoint(x: x, y: y))
	}
	
	public init(x: CGFloat) {
		self.init(CGPoint(x: x, y: NullValue))
	}
	
	public init(y: CGFloat) {
		self.init(CGPoint(x: NullValue, y: y))
	}
}

public struct Size: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame.size"
	}
	
	public init(_ value: CGSize) {
		self.value = InterpolatableValue(type: .cgSize, vectors: value.vectorize().vectors)
	}
	
	public init(_ width: CGFloat, _ height: CGFloat) {
		self.init(CGSize(width: width, height: height))
	}
	
	public init(width: CGFloat) {
		self.init(CGSize(width: width, height: NullValue))
	}
	
	public init(height: CGFloat) {
		self.init(CGSize(width: NullValue, height: height))
	}
}

public struct Frame: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "frame"
	}
	
	public init(_ value: CGRect) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: [NullValue])
	}
}

public struct Alpha: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "alpha"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct BackgroundColor: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "backgroundColor"
	}
	
	public init(_ value: UIColor) {
		self.value = InterpolatableValue(type: .colorRGB, vectors: value.vectorize().vectors)
	}
}

public struct BorderColor: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "borderColor"
	}
	
	public init(_ value: UIColor) {
		self.value = InterpolatableValue(type: .colorRGB, vectors: value.vectorize().vectors)
	}
}

public struct BorderWidth: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "borderWidth"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct CornerRadius: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "cornerRadius"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct FillColor: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "fillColor"
	}
	
	public init(_ value: UIColor) {
		self.value = InterpolatableValue(type: .colorRGB, vectors: value.vectorize().vectors)
	}
}

public struct StrokeColor: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "strokeColor"
	}
	
	public init(_ value: UIColor) {
		self.value = InterpolatableValue(type: .colorRGB, vectors: value.vectorize().vectors)
	}
}

public struct StrokeStart: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "strokeStart"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct StrokeEnd: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "strokeEnd"
	}
	
	public init(_ value: CGFloat) {
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
}

public struct Path: Property {
	public var value: InterpolatableValue
	public var key: String {
		return "path"
	}
	
	public var path: InterpolatablePath
	
	public init(_ path: InterpolatablePath) {
		let value: CGFloat = 1.0
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
		self.path = path
	}
}

public struct Scale: Property, Equatable, TransformType {
	public var value: InterpolatableValue
	public var key: String {
		return "transform.scale"
	}
	
	static var zero: Scale {
		return Scale(NullValue)
	}
	
	public init(_ value: CGFloat) {
		self.init(x: value, y: value, z: value)
	}
	
	public init(x: CGFloat, y: CGFloat, z: CGFloat) {
		let vector = Vector3(Double(x), Double(y), Double(z))
		self.value = InterpolatableValue(type: .vector3, vectors: vector.vectorize().vectors)
	}
}
public func ==(lhs: Scale, rhs: Scale) -> Bool {
	return lhs.value == rhs.value
}

public struct Rotation: Property, Equatable, TransformType {
	public var value: InterpolatableValue
	public var key: String {
		return "transform.rotation"
	}
	
	public var x: Bool
	public var y: Bool
	public var z: Bool
	
	static var zero: Rotation {
		return Rotation(0)
	}
	
	public init(_ value: Interpolatable) {
		self.x = false
		self.y = false
		self.z = true
		self.value = InterpolatableValue(type: .cgFloat, vectors: value.vectorize().vectors)
	}
	
	public init(x angle: CGFloat) {
		self.init(angle)
		self.x = true
		self.y = false
		self.z = false
	}
	
	public init(y angle: CGFloat) {
		self.init(angle)
		self.x = false
		self.y = true
		self.z = false
	}
	
	public mutating func applyAxes(_ rotation: Rotation) {
		self.x = rotation.x
		self.y = rotation.y
		self.z = rotation.z
	}
}
public func ==(lhs: Rotation, rhs: Rotation) -> Bool {
	return (lhs.value == rhs.value && lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z)
}

public struct Translation: Property, Equatable, TransformType {
	public var value: InterpolatableValue
	public var key: String {
		return "transform.translation"
	}
	
	static var zero: Translation {
		return Translation(CGPoint.zero)
	}
	
	public init(_ value: Interpolatable) {
		self.value = InterpolatableValue(type: .cgPoint, vectors: value.vectorize().vectors)
	}
	
	public init(_ x: CGFloat, _ y: CGFloat) {
		self.init(CGPoint(x: x, y: y))
	}
}
public func ==(lhs: Translation, rhs: Translation) -> Bool {
	return lhs.value == rhs.value
}

public struct KeyPath: Property {
	public var value: InterpolatableValue
	public var key: String {
		return _key
	}
	private var _key: String
	
	public init(_ key: String, _ value: Interpolatable) {
		self._key = key
		self.value = InterpolatableValue(type: value.interpolatableType, vectors: value.vectorize().vectors)
	}
}

public struct Transform: Property, Equatable {
	public var value: InterpolatableValue
	public var key: String {
		return "transform"
	}

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
		self.value = InterpolatableValue(type: .cgFloat, vectors: [0.0])
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
		
		if let prop = type as? Property {
			orderedPropKeys.append(prop.key)
		}
		
		if let scale = type as? Scale {
			self.scale.apply(scale.value)
		} else if let rotation = type as? Rotation {
			self.rotation.apply(rotation.value)
			self.rotation.x = rotation.x
			self.rotation.y = rotation.y
			self.rotation.z = rotation.z
		} else if let translation = type as? Translation {
			self.translation.apply(translation.value)
		}
	}
	
	func applyTo(_ target: Tweenable) {
		guard var view = target as? ViewType else { return }
		
		var t = CATransform3DIdentity
		var removeTranslationForRotate = false
		
		let targetScale = view.transform3d.scale()
		let targetRotation = view.transform3d.rotation()
		let targetTranslation = view.transform3d.translation()
		
		// apply any existing transforms that aren't specified in this tween
		if let value = targetScale.value.toInterpolatable() as? Vector3, !orderedPropKeys.contains(targetScale.key) {
			t = CATransform3DScale(t, CGFloat(value.x), CGFloat(value.y), CGFloat(value.z))
		}
		if let angle = targetRotation.value.toInterpolatable() as? CGFloat, !orderedPropKeys.contains(targetRotation.key) {
			t = CATransform3DRotate(t, angle, (targetRotation.x ? 1 : 0), (targetRotation.y ? 1 : 0), (targetRotation.z ? 1 : 0))
		}
		if let value = targetTranslation.value.toInterpolatable() as? CGPoint, !orderedPropKeys.contains(targetTranslation.key) {
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
				if let angle = rotation.value.toInterpolatable() as? CGFloat, let translate = translation.value.toInterpolatable() as? CGPoint {
					// if we have a translation, remove the translation before applying the rotation
					if removeTranslationForRotate && targetTranslation != Translation.zero {
						t = CATransform3DTranslate(t, -translate.x, -translate.y, 0)
					}
					
					t = CATransform3DRotate(t, angle, (rotation.x ? 1 : 0), (rotation.y ? 1 : 0), (rotation.z ? 1 : 0))
					
					// add translation back
					if removeTranslationForRotate && targetTranslation != Translation.zero {
						t = CATransform3DTranslate(t, translate.x, translate.y, 0)
					}
				}
			} else if prop is Translation {
				if let translate = translation.value.toInterpolatable() as? CGPoint {
					t = CATransform3DTranslate(t, translate.x, translate.y, 0)
				}
			}
		}
		
		view.transform3d = t
	}
}

extension CATransform3D {
	
	func scale() -> Scale {
		let x = sqrt((m11 * m11) + (m12 * m12) + (m13 * m13))
		let y = sqrt((m21 * m21) + (m22 * m22) + (m23 * m23))
		
		return Scale(x: x, y: y, z: 1)
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

public struct FromToValue {
	var from: Property?
	var to: Property?
	
	init() {}
	
	init(_ from: Property, _ to: Property) {
		self.from = from
		self.to = to
	}
}
