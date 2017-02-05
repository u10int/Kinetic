//
//  TweenProperty.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public enum Property {
	case X(CGFloat)
	case Y(CGFloat)
	case Position(CGFloat, CGFloat)
	case CenterX(CGFloat)
	case CenterY(CGFloat)
	case Center(CGFloat, CGFloat)
	case Shift(CGFloat, CGFloat)
	case Width(CGFloat)
	case Height(CGFloat)
	case Size(CGFloat, CGFloat)
	case Translate(CGFloat, CGFloat)
	case Scale(CGFloat)
	case ScaleXY(CGFloat, CGFloat)
	case Rotate(CGFloat)
	case RotateX(CGFloat)
	case RotateY(CGFloat)
	case Transform(CATransform3D)
	case Alpha(CGFloat)
	case BackgroundColor(UIColor)
	case FillColor(UIColor)
	case StrokeColor(UIColor)
	case TintColor(UIColor)
	case KeyPath(String, CGFloat)
	
	public func key() -> String? {
		var key: String?
		
		switch self {
		case X:
			key = "frame.origin.x"
		case Y:
			key = "frame.origin.y"
		case Position, Shift:
			key = "frame.origin"
		case CenterX:
			key = "center.x"
		case CenterY:
			key = "center.y"
		case Center:
			key = "center"
		case Width:
			key = "frame.size.width"
		case Height:
			key = "frame.size.height"
		case Size:
			key = "frame.size"
		case Transform, Translate, Scale, ScaleXY, Rotate, RotateX, RotateY:
			key = "transform"
		case Alpha:
			key = "alpha"
		case BackgroundColor:
			key = "backgroundColor"
		case FillColor:
			key = "fillColor"
		case StrokeColor:
			key = "strokeColor"
		case TintColor:
			key = "tintColor"
		case KeyPath(let prop, _):
			key = prop
		default:
			key = nil
		}
		
		return key
	}
}

private struct RGBA {
	var red: CGFloat = 0
	var green: CGFloat = 0
	var blue: CGFloat = 0
	var alpha: CGFloat = 0
	
	static func fromUIColor(color: UIColor) -> RGBA {
		var rgba = RGBA()
		color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
		return rgba
	}
}

public class TweenProperty: Equatable {
	unowned var tweenObject: TweenObject
	var property: Property?
	var mode: TweenMode = .To {
		didSet {
			if mode != .To {
				additive = false
			}
		}
	}
	var duration: CFTimeInterval = 0
	var delay: CFTimeInterval = 0
	var elapsed: CFTimeInterval = 0
	var dt: CFTimeInterval = 0
	var time: CGFloat = 0
	var easing: Ease = Easing.linear
	var spring: Spring?
	var additive: Bool = true
	
	init(target: TweenObject) {
		self.tweenObject = target
	}
	
	func proceed(_ dt: CFTimeInterval, reversed: Bool = false) -> Bool {
		self.dt = dt
		let end = delay + duration
		
		elapsed = min(elapsed + dt, end)
		if elapsed < 0 { elapsed = 0 }
		
		func _go() {
			time = CGFloat((elapsed - delay) / duration)
			if duration == 0 {
				time = 0
			}
			update()
		}

		if spring == nil && (!reversed && elapsed >= end) || (reversed && elapsed <= 0) {
			_go()
			return true
		}
		
		// start animating if elapsed time has reached or surpassed the delay
		if elapsed >= delay {
			_go()
		}
		
		if let spring = spring {
			return spring.ended	
		}
		
		return elapsed >= end
	}
	
	func seek(time: CFTimeInterval) {
		elapsed = delay + time
		proceed(0)
	}
	
	func prepare() {
		calc()
	}
	
	func reset() {
		elapsed = 0
		time = 0
		
		if let spring = spring {
			spring.reset()
		}
	}
	
	func calc() {
		
	}
	
	func update() {
		assert(false, "Subclasses of TweenProperty must override `update`")
	}
	
	// MARK: LERP Calculations
	
	func lerpFloat(from: CGFloat, to: CGFloat) -> CGFloat {
		if let spring = spring {
			spring.proceed(dt / duration)
			return from + (to - from) * CGFloat(spring.current)
		}
		
		var value = easing(t: time, b: from, c: to - from)
		// deal with floating point precision issues when updating the last time interval
		if time == 1.0 {
			value = to
		}
		return value
	}
	
	func lerpPoint(from: CGPoint, to: CGPoint) -> CGPoint {
		return CGPoint(
			x: lerpFloat(from.x, to: to.x),
			y: lerpFloat(from.y, to: to.y)
		)
	}
	
	func lerpSize(from: CGSize, to: CGSize) -> CGSize {
		return CGSize(width: lerpFloat(
			from.width, to: to.width),
			height: lerpFloat(from.height, to: to.height)
		)
	}
	
	func lerpRect(from: CGRect, to: CGRect) -> CGRect {
		return CGRect(origin: lerpPoint(
			from.origin, to: to.origin),
			size: lerpSize(from.size, to: to.size)
		)
	}
	
	func lerpTransform(from: CATransform3D, to: CATransform3D) -> CATransform3D {
		var transform = CATransform3DIdentity
		
		transform.m11 = lerpFloat(from.m11, to: to.m11)
		transform.m12 = lerpFloat(from.m12, to: to.m12)
		transform.m13 = lerpFloat(from.m13, to: to.m13)
		transform.m14 = lerpFloat(from.m14, to: to.m14)
		
		transform.m21 = lerpFloat(from.m21, to: to.m21)
		transform.m22 = lerpFloat(from.m22, to: to.m22)
		transform.m23 = lerpFloat(from.m23, to: to.m23)
		transform.m24 = lerpFloat(from.m24, to: to.m24)
		
		transform.m31 = lerpFloat(from.m31, to: to.m31)
		transform.m32 = lerpFloat(from.m32, to: to.m32)
		transform.m33 = lerpFloat(from.m33, to: to.m33)
		transform.m34 = lerpFloat(from.m34, to: to.m34)
		
		transform.m41 = lerpFloat(from.m41, to: to.m41)
		transform.m42 = lerpFloat(from.m42, to: to.m42)
		transform.m43 = lerpFloat(from.m43, to: to.m43)
		transform.m44 = lerpFloat(from.m44, to: to.m44)
		
		return transform
	}
	
	func lerpColor(from: UIColor, to: UIColor) -> UIColor {
		let fromRGBA = RGBA.fromUIColor(from)
		let toRGBA = RGBA.fromUIColor(to)
		
		return UIColor(
			red: lerpFloat(fromRGBA.red, to: toRGBA.red),
			green: lerpFloat(fromRGBA.green, to: toRGBA.green),
			blue: lerpFloat(fromRGBA.blue, to: toRGBA.blue),
			alpha: lerpFloat(fromRGBA.alpha, to: toRGBA.alpha)
		)
	}
}

public func ==(lhs: TweenProperty, rhs: TweenProperty) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class ValueProperty: TweenProperty {
	var from: CGFloat = 0
	var to: CGFloat = 0
	var current: CGFloat = 0
	
	init(target: TweenObject, from: CGFloat, to: CGFloat) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func calc() {
		
	}
}

public class StructProperty: ValueProperty {
	var currentValue: CGFloat? {
		get {
			if let frame = tweenObject.frame, let prop = property {
				switch prop {
				case .X(_):
					return CGRectGetMinX(frame)
				case .Y(_):
					return CGRectGetMinY(frame)
				case .CenterX(_):
					return CGRectGetMidX(frame)
				case .CenterY(_):
					return CGRectGetMidY(frame)
				case .Width(_):
					return CGRectGetWidth(frame)
				case .Height(_):
					return CGRectGetHeight(frame)
				default:
					break
				}
			}
			return nil
		}
	}
	
	override func prepare() {
		if let value = currentValue {
			if mode == .To {
				from = value
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpFloat(from, to: to)
		updateTarget(value)
	}
	
	private func updateTarget(value: CGFloat) {
		if var frame = tweenObject.frame, let prop = property {
			switch prop {
			case .X(_):
				frame.origin.x = value
			case .Y(_):
				frame.origin.y = value
			case .Width(_):
				frame.size.width = value
			case .Height(_):
				frame.size.height = value
			default:
				break
			}
			
			tweenObject.frame = frame
		}
	}
}

public class PointProperty: TweenProperty {
	var from: CGPoint = CGPointZero
	var to: CGPoint = CGPointZero
	var current: CGPoint = CGPointZero
	var targetCenter: Bool = false
	
	init(target: TweenObject, from: CGPoint, to: CGPoint) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if let origin = tweenObject.origin, let center = tweenObject.center, let prop = property {
			if additive {
				if let target = tweenObject.target, let lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? PointProperty {
					from = lastProp.to
				}
			} else {
				if mode == .To {
					from = (targetCenter) ? center : origin
				}
			}
			
			switch prop {
			case .X(_):
				if mode == .To {
					to.y = origin.y
				} else if mode == .From {
					from.y = origin.y
				}
			case .Y(_):
				if mode == .To {
					to.x = origin.x
				} else if mode == .From {
					from.x = origin.x
				}
			case .CenterX(_):
				if mode == .To {
					to.y = center.y
				} else if mode == .From {
					from.y = center.y
				}
			case .CenterY(_):
				if mode == .To {
					to.x = center.x
				} else if mode == .From {
					from.x = center.x
				}
			case .Shift(let shiftX, let shiftY):
				if mode == .To {
					to = CGPoint(x: origin.x + shiftX, y: origin.y + shiftY)
				} else if mode == .From {
					from = CGPoint(x: origin.x + shiftX, y: origin.y + shiftY)
				}
			default:
				break
			}
		}
		current = from
		
		super.prepare()
	}
	
	override func update() {
		var point = lerpPoint(from, to: to)
		let value = point
		
		if additive {
			if let origin = tweenObject.origin, let center = tweenObject.center {
				let delta = CGPoint(x: point.x - current.x, y: point.y - current.y)
				point.x = ((targetCenter) ? center.x : origin.x) + delta.x
				point.y = ((targetCenter) ? center.y : origin.y) + delta.y
			}
		}
				
		current = value
		updateTarget(point)
	}
	
	private func updateTarget(value: CGPoint) {
		if targetCenter {
			tweenObject.center = value
		} else {
			tweenObject.origin = value
		}
	}
}

public class SizeProperty: TweenProperty {
	var from: CGSize = CGSizeZero
	var to: CGSize = CGSizeZero
	var current: CGSize = CGSizeZero
	
	init(target: TweenObject, from: CGSize, to: CGSize) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if let size = tweenObject.size, let prop = property {
			if additive {
				if let target = tweenObject.target, let lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? SizeProperty {
					from = lastProp.to
				}
			} else {
				if mode == .To {
					from = size
				}
			}
			
			switch prop {
			case .Width(_):
				if mode == .To {
					from.height = size.height
				} else if mode == .From {
					to.height = size.height
				}
			case .Height(_):
				if mode == .To {
					from.width = size.width
				} else if mode == .From {
					to.width = size.width
				}
			default:
				break
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpSize(from, to: to)
		updateTarget(value)
	}
	
	private func updateTarget(value: CGSize) {
		tweenObject.size = value
	}
}

public class RectProperty: TweenProperty {
	var from: CGRect = CGRectZero
	var to: CGRect = CGRectZero
	var current: CGRect = CGRectZero
	
	init(target: TweenObject, from: CGRect, to: CGRect) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let target = tweenObject.target, let prop = property, let lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? RectProperty {
				from = lastProp.to
			}
		} else {
			if let size = tweenObject.frame {
				if mode == .To {
					from = size
				}
			}
		}
		
		super.prepare()
	}
	
	override func update() {
		let value = lerpRect(from, to: to)
		updateTarget(value)
	}
	
	private func updateTarget(value: CGRect) {
		tweenObject.frame = value
	}
}

// MARK: - Transforms

public class TransformProperty: TweenProperty {
	var from = Transform()
	var to = Transform()
	var current = Transform()
	var propsByMode = [TweenMode: [Property]]()
	
	private var propOrder = [String]()
	
	func addProp(prop: Property, mode: TweenMode) {
		if propsByMode[mode] == nil {
			propsByMode[mode] = [Property]()
		}
		propsByMode[mode]?.append(prop)
	}
	
//	override func prepare() {
//		var scaleFrom = false, scaleTo = false
//		var rotateFrom = false, rotateTo = false
//		var translateFrom = false, translateTo = false
//		
//		for (mode, props) in propsByMode {
//			propOrder.removeAll()
//			
//			for prop in props {
//				switch prop {
//				case .Translate(_, _):
//					if mode == .From {
//						translateFrom = true
//					} else {
//						translateTo = true
//					}
//					propOrder.append(Translation.key)
//				case .Scale(_), .ScaleXY(_, _):
//					if mode == .From {
//						scaleFrom = true
//					} else {
//						scaleTo = true
//					}
//					propOrder.append(Scale.key)
//				case .Rotate(_), .RotateX(_), .RotateY(_):
//					if mode == .From {
//						rotateFrom = true
//					} else {
//						rotateTo = true
//					}
//					propOrder.append(Rotation.key)
//				default:
//					let _ = to
//				}
//			}
//		}
//		
//		// if we dont' have a transform property specified for either `from` or `to`, then we need to set it to their current values
//		if let scale = tweenObject.scale {
//			if !scaleFrom {
//				from.scale = scale
//			}
//			if !scaleTo {
//				to.scale = scale
//			}
//		}
//		if let rotation = tweenObject.rotation {
//			if !rotateFrom {
//				from.rotation = rotation
//			}
//			if !rotateTo {
//				to.rotation = rotation
//			}
//		}
//		if let translation = tweenObject.translation {
//			if !translateFrom {
//				from.translation = translation
//			}
//			if !translateTo {
//				to.translation = translation
//			}
//		}
//		
////		print("PREPARE: \(tweenObject.target) - from - \(from)")
////		print("PREPARE: \(tweenObject.target) - to - \(to)")
//		
//		super.prepare()
//	}
//	
//	override func update() {
//		var t = Transform()
//		
//		t.scale.x = lerpFloat(from.scale.x, to: to.scale.x)
//		t.scale.y = lerpFloat(from.scale.y, to: to.scale.y)
//		t.scale.z = lerpFloat(from.scale.z, to: to.scale.z)
//		
//		t.rotation.angle = lerpFloat(from.rotation.angle, to: to.rotation.angle)
//		t.rotation.x = to.rotation.x
//		t.rotation.y = to.rotation.y
//		t.rotation.z = to.rotation.z
//		
//		t.translation.x = lerpFloat(from.translation.x, to: to.translation.x)
//		t.translation.y = lerpFloat(from.translation.y, to: to.translation.y)
//		
//		current = t
////		print("\(tweenObject.target) - \(t)")
//		
//		updateTarget(t)
//	}
//	
//	private func updateTarget(value: Transform) {
//		tweenObject.transform = transformValue(value)
//	}
//	
//	private func transformValue(value: Transform) -> CATransform3D {
//		var t = CATransform3DIdentity
//		var removeTranslationForRotate = false
//		
//		// apply any existing transforms that aren't specified in this tween
//		if !propOrder.contains(Scale.key) {
//			t = CATransform3DScale(t, value.scale.x, value.scale.y, value.scale.z)
//		}
//		if !propOrder.contains(Rotation.key) {
//			t = CATransform3DRotate(t, value.rotation.angle, value.rotation.x, value.rotation.y, value.rotation.z)
//		}
//		if !propOrder.contains(Translation.key) {
//			t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
//			removeTranslationForRotate = true
//		}
//		
//		// make sure transforms are combined in the order in which they're specified for the tween
//		for key in propOrder {
//			switch key {
//			case Scale.key:
//				t = CATransform3DScale(t, value.scale.x, value.scale.y, value.scale.z)
//			case Rotation.key:
//				// if we have a translation, remove the translation before applying the rotation
//				if let translation = tweenObject.translation {
//					if removeTranslationForRotate && translation != Translation.zero {
//						t = CATransform3DTranslate(t, -value.translation.x, -value.translation.y, 0)
//					}
//				}
//				
//				t = CATransform3DRotate(t, value.rotation.angle, value.rotation.x, value.rotation.y, value.rotation.z)
//				
//				// add translation back
//				if let translation = tweenObject.translation {
//					if removeTranslationForRotate && translation != Translation.zero {
//						t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
//					}
//				}
//			case Translation.key:
//				t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
//			default:
//				let _ = t
//			}
//		}
////		print("\(tweenObject.target) - \(t)")
//		
//		return t
//	}
}

// MARK: - Color

public class ColorProperty: TweenProperty {
	var keyPath: String
	var from: UIColor = UIColor.blackColor()
	var to: UIColor = UIColor.blackColor()
	
	init(target: TweenObject, property: String, from: UIColor, to: UIColor) {
		self.keyPath = property
		super.init(target: target)
		
		if let target = tweenObject.target {
			assert(target.respondsToSelector(Selector(property)), "Target for ColorProperty must contain a public property {\(property)}")
		}
		
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let color = tweenObject.colorForKeyPath(keyPath) {
				if mode == .To {
					from = color
				}
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpColor(from, to: to)
		updateTarget(value)
	}
	
	private func updateTarget(value: UIColor) {
		tweenObject.setColor(value, forKeyPath: keyPath)
	}
}

// MARK: Custom Objects

public class ObjectProperty: ValueProperty {
	var keyPath: String
	
	init(target: TweenObject, keyPath: String, from: CGFloat, to: CGFloat) {
		self.keyPath = keyPath
		super.init(target: target, from: from, to: to)
		
		if let target = tweenObject.target {
			assert(target.respondsToSelector(Selector(keyPath)), "Target for CustomProperty must contain a public property {\(keyPath)}")
		}
	}
	
	override func prepare() {
		if additive {
			if let target = tweenObject.target, let value = target.valueForKeyPath(keyPath) as? CGFloat {
				if mode == .To {
					from = value
				}
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpFloat(from, to: to)
		updateTarget(value)
	}
	
	private func updateTarget(value: CGFloat) {
		if let target = tweenObject.target {
			target.setValue(value, forKeyPath: keyPath)
		}
	}
}
