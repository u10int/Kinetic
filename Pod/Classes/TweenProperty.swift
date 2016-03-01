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
	case KeyPath(String, CGFloat)
}

public enum Anchor {
	case Default
	case Center
	case Top
	case TopLeft
	case TopRight
	case Bottom
	case BottomLeft
	case BottomRight
	case Left
	case Right
	
	public func point() -> CGPoint {
		switch self {
		case .Center:
			return CGPoint(x: 0.5, y: 0.5)
		case .Top:
			return CGPoint(x: 0.5, y: 0)
		case .TopLeft:
			return CGPoint(x: 0, y: 0)
		case .TopRight:
			return CGPoint(x: 1, y: 0)
		case .Bottom:
			return CGPoint(x: 0.5, y: 1)
		case .BottomLeft:
			return CGPoint(x: 0, y: 1)
		case .BottomRight:
			return CGPoint(x: 1, y: 1)
		case .Left:
			return CGPoint(x: 0, y: 0.5)
		case .Right:
			return CGPoint(x: 1, y: 0.5)
		default:
			return CGPoint(x: 0.5, y: 0.5)
		}
	}
}

internal struct Scale {
	var x: CGFloat
	var y: CGFloat
	var z: CGFloat
}
internal let ScaleIdentity = Scale(x: 1, y: 1, z: 1)

internal func ScaleEqualToScale(s1: Scale, s2: Scale) -> Bool {
	return (s1.x == s2.x && s1.y == s2.y && s1.z == s2.z)
}

internal struct Rotation {
	var angle: CGFloat
	var x: CGFloat
	var y: CGFloat
	var z: CGFloat
}
internal let RotationIdentity = Rotation(angle: 0, x: 0, y: 0, z: 0)

internal func RotationEqualToRotation(r1: Rotation, r2: Rotation) -> Bool {
	return (r1.angle == r2.angle && r1.x == r2.x && r1.y == r2.y && r1.z == r2.z)
}

internal struct Translation {
	var x: CGFloat
	var y: CGFloat
}
internal let TranslationIdentity = Translation(x: 0, y: 0)

internal func TranslationEqualToTranslation(t1: Translation, t2: Translation) -> Bool {
	return (t1.x == t2.x && t1.y == t2.y)
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
	var tweenObject: TweenObject
	var property: Property?
	var mode: TweenMode = .To {
		didSet {
			if mode != .To {
				additive = false
			}
		}
	}
	var tween: Tween?
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
	
	func proceed(dt: CFTimeInterval, reversed: Bool = false) -> Bool {
		self.dt = dt
		let end = delay + duration
		
		elapsed = min(elapsed + dt, end)
		if elapsed < 0 { elapsed = 0 }
		
		func advance() {
			time = CGFloat((elapsed - delay) / duration)
			update()
		}

		if spring == nil && (!reversed && elapsed >= end) || (reversed && elapsed <= 0) {
			advance()
			return true
		}
		
		// start animating if elapsed time has reached or surpassed the delay
		if elapsed >= delay {
			advance()
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
		return easing(t: time, b: from, c: to - from)
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
			if let frame = tweenObject.frame, prop = property {
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
		if let origin = tweenObject.origin, center = tweenObject.center, prop = property {
			if additive {
				if let target = tweenObject.target, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? PointProperty {
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
			if let origin = tweenObject.origin, center = tweenObject.center {
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
		if let size = tweenObject.size, prop = property {
			if additive {
				if let target = tweenObject.target, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? SizeProperty {
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
			if let target = tweenObject.target, prop = property, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? RectProperty {
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
	var updatesTarget: Bool = true
	
	func transformValue() -> CATransform3D {
		return CATransform3DIdentity
	}
	
	func concat(transform: CATransform3D) -> CATransform3D {
		var t = transform
		
		if let currentScale = tweenObject.scale {
			if self is ScaleProperty == false && !ScaleEqualToScale(currentScale, s2: ScaleIdentity) {
				let scale = CATransform3DMakeScale(currentScale.x, currentScale.y, 1)
				t = CATransform3DConcat(scale, t)
			}
		}
		if let currentRotation = tweenObject.rotation {
			if self is RotationProperty == false && !RotationEqualToRotation(currentRotation, r2: RotationIdentity) {
				let rotation = CATransform3DMakeRotation(currentRotation.angle, currentRotation.x, currentRotation.y, currentRotation.z)
				t = CATransform3DConcat(rotation, t)
			}
		}
		if let currentTranslation = tweenObject.translation {
			if self is TranslationProperty == false && !TranslationEqualToTranslation(currentTranslation, t2: TranslationIdentity) {
				let translation = CATransform3DMakeTranslation(currentTranslation.x, currentTranslation.y, 0)
				t = CATransform3DConcat(translation, t)
			}
		}
		
		return t
	}
}

public class ScaleProperty: TransformProperty {
	var from: Scale = ScaleIdentity
	var to: Scale = ScaleIdentity
	var current: Scale = ScaleIdentity
	
	init(target: TweenObject, from: Scale, to: Scale) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let currentScale = tweenObject.scale {
				from = currentScale
			}
		}
		super.prepare()
	}
	
	override func update() {
		var value = ScaleIdentity
		value.x = lerpFloat(from.x, to: to.x)
		value.y = lerpFloat(from.y, to: to.y)
		value.z = lerpFloat(from.z, to: to.z)
		current = value
		
		if updatesTarget {
			var transform = CATransform3DMakeScale(value.x, value.y, value.z)
			transform = concat(transform)
			updateTarget(transform)
		}
	}
	
	override func transformValue() -> CATransform3D {
		return CATransform3DMakeScale(current.x, current.y, current.z)
	}
	
	private func updateTarget(value: CATransform3D) {
		tweenObject.transform = value
	}
}

public class RotationProperty: TransformProperty {
	var from: Rotation = RotationIdentity
	var to: Rotation = RotationIdentity
	var current: Rotation = RotationIdentity
	
	init(target: TweenObject, from: Rotation, to: Rotation) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let currentRotation = tweenObject.rotation {
				from = Rotation(angle: currentRotation.angle, x: to.x, y: to.y, z: to.z)
			}
		}
		super.prepare()
	}
	
	override func update() {
		var value = to
		value.angle = lerpFloat(from.angle, to: to.angle)
		current = value
		
		if updatesTarget {
			var transform = CATransform3DMakeRotation(value.angle, value.x, value.y, value.z)
			transform = concat(transform)
			updateTarget(transform)
		}
	}
	
	override func transformValue() -> CATransform3D {
		return CATransform3DMakeRotation(current.angle, current.x, current.y, current.z)
	}
	
	private func updateTarget(value: CATransform3D) {
		tweenObject.transform = value
	}
}

public class TranslationProperty: TransformProperty {
	var from: Translation = TranslationIdentity
	var to: Translation = TranslationIdentity
	var current: Translation = TranslationIdentity
	
	init(target: TweenObject, from: Translation, to: Translation) {
		super.init(target: target)
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let currentTranslation = tweenObject.translation {
				from = currentTranslation
			}
		}
		super.prepare()
	}
	
	override func update() {
		var value = TranslationIdentity
		value.x = lerpFloat(from.x, to: to.x)
		value.y = lerpFloat(from.y, to: to.y)
		current = value
		
		if updatesTarget {
			var transform = CATransform3DMakeTranslation(value.x, value.y, 0)
			transform = concat(transform)
			updateTarget(transform)
		}
	}
	
	override func transformValue() -> CATransform3D {
		return CATransform3DMakeTranslation(current.x, current.y, 0)
	}
	
	private func updateTarget(value: CATransform3D) {
		tweenObject.transform = value
	}
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
			if let target = tweenObject.target, value = target.valueForKeyPath(keyPath) as? CGFloat {
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

internal class Transformation: TweenProperty {
	var transforms = [TransformProperty]()
	override var duration: CFTimeInterval {
		didSet {
			for t in transforms {
				t.duration = duration
			}
		}
	}
	override var easing: Ease {
		didSet {
			for t in transforms {
				t.easing = easing
			}
		}
	}
	override var spring: Spring? {
		didSet {
			for t in transforms {
				t.spring = spring
			}
		}
	}
	
	override func seek(time: CFTimeInterval) {
		super.seek(time)
		
		for t in transforms {
			t.seek(time)
		}
	}
	
	override func prepare() {
		for t in transforms {
			t.updatesTarget = false
			t.prepare()
		}
		super.prepare()
	}
	
	override func proceed(dt: CFTimeInterval, reversed: Bool) -> Bool {
		for t in transforms {
			t.proceed(dt, reversed: reversed)
		}
		return super.proceed(dt, reversed: reversed)
	}
	
	override func update() {
		var value = CATransform3DIdentity
		for t in transforms {
			t.update()
			value = CATransform3DConcat(value, t.transformValue())
		}
		updateTarget(value)
	}
	
	private func updateTarget(value: CATransform3D) {
		tweenObject.transform = value
	}
}
