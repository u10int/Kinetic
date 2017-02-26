//
//  TweenProperty.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public enum Property {
	case x(CGFloat)
	case y(CGFloat)
	case position(CGFloat, CGFloat)
	case centerX(CGFloat)
	case centerY(CGFloat)
	case center(CGFloat, CGFloat)
	case shift(CGFloat, CGFloat)
	case width(CGFloat)
	case height(CGFloat)
	case size(CGFloat, CGFloat)
	case translate(CGFloat, CGFloat)
	case scale(CGFloat)
	case scaleXY(CGFloat, CGFloat)
	case rotate(CGFloat)
	case rotateX(CGFloat)
	case rotateY(CGFloat)
	case transform(CATransform3D)
	case alpha(CGFloat)
	case backgroundColor(UIColor)
	case fillColor(UIColor)
	case strokeColor(UIColor)
	case tintColor(UIColor)
	case keyPath(String, CGFloat)
}

public enum Anchor {
	case `default`
	case center
	case top
	case topLeft
	case topRight
	case bottom
	case bottomLeft
	case bottomRight
	case left
	case right
	
	public func point() -> CGPoint {
		switch self {
		case .center:
			return CGPoint(x: 0.5, y: 0.5)
		case .top:
			return CGPoint(x: 0.5, y: 0)
		case .topLeft:
			return CGPoint(x: 0, y: 0)
		case .topRight:
			return CGPoint(x: 1, y: 0)
		case .bottom:
			return CGPoint(x: 0.5, y: 1)
		case .bottomLeft:
			return CGPoint(x: 0, y: 1)
		case .bottomRight:
			return CGPoint(x: 1, y: 1)
		case .left:
			return CGPoint(x: 0, y: 0.5)
		case .right:
			return CGPoint(x: 1, y: 0.5)
		default:
			return CGPoint(x: 0.5, y: 0.5)
		}
	}
}

private struct RGBA {
	var red: CGFloat = 0
	var green: CGFloat = 0
	var blue: CGFloat = 0
	var alpha: CGFloat = 0
	
	static func fromUIColor(_ color: UIColor) -> RGBA {
		var rgba = RGBA()
		color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
		return rgba
	}
}

open class TweenProperty: Equatable {
	unowned var tweenObject: TweenObject
	var property: Property?
	var mode: TweenMode = .to {
		didSet {
			if mode != .to {
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
	
	func seek(_ time: CFTimeInterval) {
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
	
	func lerpFloat(_ from: CGFloat, to: CGFloat) -> CGFloat {
		if let spring = spring {
			spring.proceed(dt / duration)
			return from + (to - from) * CGFloat(spring.current)
		}
		
		var value = easing(time, from, to - from)
		// deal with floating point precision issues when updating the last time interval
		if time == 1.0 {
			value = to
		}
		return value
	}
	
	func lerpPoint(_ from: CGPoint, to: CGPoint) -> CGPoint {
		return CGPoint(
			x: lerpFloat(from.x, to: to.x),
			y: lerpFloat(from.y, to: to.y)
		)
	}
	
	func lerpSize(_ from: CGSize, to: CGSize) -> CGSize {
		return CGSize(width: lerpFloat(
			from.width, to: to.width),
			height: lerpFloat(from.height, to: to.height)
		)
	}
	
	func lerpRect(_ from: CGRect, to: CGRect) -> CGRect {
		return CGRect(origin: lerpPoint(
			from.origin, to: to.origin),
			size: lerpSize(from.size, to: to.size)
		)
	}
	
	func lerpTransform(_ from: CATransform3D, to: CATransform3D) -> CATransform3D {
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
	
	func lerpColor(_ from: UIColor, to: UIColor) -> UIColor {
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

open class ValueProperty: TweenProperty {
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

open class StructProperty: ValueProperty {
	var currentValue: CGFloat? {
		get {
			if let frame = tweenObject.frame, let prop = property {
				switch prop {
				case .x(_):
					return frame.minX
				case .y(_):
					return frame.minY
				case .centerX(_):
					return frame.midX
				case .centerY(_):
					return frame.midY
				case .width(_):
					return frame.width
				case .height(_):
					return frame.height
				default:
					break
				}
			}
			return nil
		}
	}
	
	override func prepare() {
		if let value = currentValue {
			if mode == .to {
				from = value
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpFloat(from, to: to)
		updateTarget(value)
	}
	
	fileprivate func updateTarget(_ value: CGFloat) {
		if var frame = tweenObject.frame, let prop = property {
			switch prop {
			case .x(_):
				frame.origin.x = value
			case .y(_):
				frame.origin.y = value
			case .width(_):
				frame.size.width = value
			case .height(_):
				frame.size.height = value
			default:
				break
			}
			
			tweenObject.frame = frame
		}
	}
}

open class PointProperty: TweenProperty {
	var from: CGPoint = CGPoint.zero
	var to: CGPoint = CGPoint.zero
	var current: CGPoint = CGPoint.zero
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
				if mode == .to {
					from = (targetCenter) ? center : origin
				}
			}
			
			switch prop {
			case .x(_):
				if mode == .to {
					to.y = origin.y
				} else if mode == .from {
					from.y = origin.y
				}
			case .y(_):
				if mode == .to {
					to.x = origin.x
				} else if mode == .from {
					from.x = origin.x
				}
			case .centerX(_):
				if mode == .to {
					to.y = center.y
				} else if mode == .from {
					from.y = center.y
				}
			case .centerY(_):
				if mode == .to {
					to.x = center.x
				} else if mode == .from {
					from.x = center.x
				}
			case .shift(let shiftX, let shiftY):
				if mode == .to {
					to = CGPoint(x: origin.x + shiftX, y: origin.y + shiftY)
				} else if mode == .from {
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
	
	fileprivate func updateTarget(_ value: CGPoint) {
		if targetCenter {
			tweenObject.center = value
		} else {
			tweenObject.origin = value
		}
	}
}

open class SizeProperty: TweenProperty {
	var from: CGSize = CGSize.zero
	var to: CGSize = CGSize.zero
	var current: CGSize = CGSize.zero
	
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
				if mode == .to {
					from = size
				}
			}
			
			switch prop {
			case .width(_):
				if mode == .to {
					from.height = size.height
				} else if mode == .from {
					to.height = size.height
				}
			case .height(_):
				if mode == .to {
					from.width = size.width
				} else if mode == .from {
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
	
	fileprivate func updateTarget(_ value: CGSize) {
		tweenObject.size = value
	}
}

open class RectProperty: TweenProperty {
	var from: CGRect = CGRect.zero
	var to: CGRect = CGRect.zero
	var current: CGRect = CGRect.zero
	
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
				if mode == .to {
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
	
	fileprivate func updateTarget(_ value: CGRect) {
		tweenObject.frame = value
	}
}

// MARK: - Transforms

open class TransformProperty: TweenProperty {
	var from = Transform()
	var to = Transform()
	var current = Transform()
	var propsByMode = [TweenMode: [Property]]()
	
	fileprivate var propOrder = [String]()
	
	func addProp(_ prop: Property, mode: TweenMode) {
		if propsByMode[mode] == nil {
			propsByMode[mode] = [Property]()
		}
		propsByMode[mode]?.append(prop)
	}
	
	override func prepare() {
		var scaleFrom = false, scaleTo = false
		var rotateFrom = false, rotateTo = false
		var translateFrom = false, translateTo = false
		
		for (mode, props) in propsByMode {
			propOrder.removeAll()
			
			for prop in props {
				switch prop {
				case .translate(_, _):
					if mode == .from {
						translateFrom = true
					} else {
						translateTo = true
					}
					propOrder.append(Translation.key)
				case .scale(_), .scaleXY(_, _):
					if mode == .from {
						scaleFrom = true
					} else {
						scaleTo = true
					}
					propOrder.append(Scale.key)
				case .rotate(_), .rotateX(_), .rotateY(_):
					if mode == .from {
						rotateFrom = true
					} else {
						rotateTo = true
					}
					propOrder.append(Rotation.key)
				default:
					let _ = to
				}
			}
		}
		
		// if we dont' have a transform property specified for either `from` or `to`, then we need to set it to their current values
		if let scale = tweenObject.scale {
			if !scaleFrom {
				from.scale = scale
			}
			if !scaleTo {
				to.scale = scale
			}
		}
		if let rotation = tweenObject.rotation {
			if !rotateFrom {
				from.rotation = rotation
			}
			if !rotateTo {
				to.rotation = rotation
			}
		}
		if let translation = tweenObject.translation {
			if !translateFrom {
				from.translation = translation
			}
			if !translateTo {
				to.translation = translation
			}
		}
		
//		print("PREPARE: \(tweenObject.target) - from - \(from)")
//		print("PREPARE: \(tweenObject.target) - to - \(to)")
		
		super.prepare()
	}
	
	override func update() {
		var t = Transform()
		
		t.scale.x = lerpFloat(from.scale.x, to: to.scale.x)
		t.scale.y = lerpFloat(from.scale.y, to: to.scale.y)
		t.scale.z = lerpFloat(from.scale.z, to: to.scale.z)
		
		t.rotation.angle = lerpFloat(from.rotation.angle, to: to.rotation.angle)
		t.rotation.x = mode == .from ? from.rotation.x : to.rotation.x
		t.rotation.y = mode == .from ? from.rotation.y : to.rotation.y
		t.rotation.z = mode == .from ? from.rotation.z : to.rotation.z
		
		t.translation.x = lerpFloat(from.translation.x, to: to.translation.x)
		t.translation.y = lerpFloat(from.translation.y, to: to.translation.y)
		
		current = t
//		print("\(tweenObject.target) - \(t)")
		
		updateTarget(t)
	}
	
	fileprivate func updateTarget(_ value: Transform) {
		tweenObject.transform = transformValue(value)
	}
	
	fileprivate func transformValue(_ value: Transform) -> CATransform3D {
		var t = CATransform3DIdentity
		var removeTranslationForRotate = false
		
		// apply any existing transforms that aren't specified in this tween
		if !propOrder.contains(Scale.key) {
			t = CATransform3DScale(t, value.scale.x, value.scale.y, value.scale.z)
		}
		if !propOrder.contains(Rotation.key) {
			t = CATransform3DRotate(t, value.rotation.angle, value.rotation.x, value.rotation.y, value.rotation.z)
		}
		if !propOrder.contains(Translation.key) {
			t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
			removeTranslationForRotate = true
		}
		
		// make sure transforms are combined in the order in which they're specified for the tween
		for key in propOrder {
			switch key {
			case Scale.key:
				t = CATransform3DScale(t, value.scale.x, value.scale.y, value.scale.z)
			case Rotation.key:
				// if we have a translation, remove the translation before applying the rotation
				if let translation = tweenObject.translation {
					if removeTranslationForRotate && translation != Translation.zero {
						t = CATransform3DTranslate(t, -value.translation.x, -value.translation.y, 0)
					}
				}
				
				t = CATransform3DRotate(t, value.rotation.angle, value.rotation.x, value.rotation.y, value.rotation.z)
				
				// add translation back
				if let translation = tweenObject.translation {
					if removeTranslationForRotate && translation != Translation.zero {
						t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
					}
				}
			case Translation.key:
				t = CATransform3DTranslate(t, value.translation.x, value.translation.y, 0)
			default:
				let _ = t
			}
		}
//		print("\(tweenObject.target) - \(t)")
		
		return t
	}
}

// MARK: - Color

open class ColorProperty: TweenProperty {
	var keyPath: String
	var from: UIColor = UIColor.black
	var to: UIColor = UIColor.black
	
	init(target: TweenObject, property: String, from: UIColor, to: UIColor) {
		self.keyPath = property
		super.init(target: target)
		
		if let target = tweenObject.target {
			assert(target.responds(to: Selector(property)), "Target for ColorProperty must contain a public property {\(property)}")
		}
		
		self.from = from
		self.to = to
	}
	
	override func prepare() {
		if additive {
			if let color = tweenObject.colorForKeyPath(keyPath) {
				if mode == .to {
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
	
	fileprivate func updateTarget(_ value: UIColor) {
		tweenObject.setColor(value, forKeyPath: keyPath)
	}
}

// MARK: Custom Objects

open class ObjectProperty: ValueProperty {
	var keyPath: String
	
	init(target: TweenObject, keyPath: String, from: CGFloat, to: CGFloat) {
		self.keyPath = keyPath
		super.init(target: target, from: from, to: to)
		
		if let target = tweenObject.target {
			assert(target.responds(to: Selector(keyPath)), "Target for CustomProperty must contain a public property {\(keyPath)}")
		}
	}
	
	override func prepare() {
		if additive {
			if let target = tweenObject.target, let value = target.value(forKeyPath: keyPath) as? CGFloat {
				if mode == .to {
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
	
	fileprivate func updateTarget(_ value: CGFloat) {
		if let target = tweenObject.target {
			target.setValue(value, forKeyPath: keyPath)
		}
	}
}
