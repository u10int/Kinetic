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
	case Shift(CGFloat, CGFloat)
	case Width(CGFloat)
	case Height(CGFloat)
	case Size(CGFloat, CGFloat)
	case Translate(CGFloat, CGFloat)
	case Scale(CGFloat)
	case ScaleXY(CGFloat, CGFloat)
	case Rotate(CGFloat)
	case RotateXY(CGFloat, CGFloat)
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
	weak var target: NSObject!
	
	var property: Property?
	var mode: TweenMode = .To {
		didSet {
			if mode != .To {
				additive = false
			}
		}
	}
	var tween: Tween?
	var duration: CFTimeInterval = 1
	var delay: CFTimeInterval = 0
	var elapsed: CFTimeInterval = 0
	var dt: CFTimeInterval = 0
	var time: CGFloat = 0
	var easing: Ease = Easing.linear
	var spring: Spring?
	var additive: Bool = true
	
	init(target: NSObject) {
		self.target = target
	}
	
	func proceed(dt: CFTimeInterval, reversed: Bool = false) -> Bool {
		self.dt = dt
		let end = delay + duration
		
		elapsed = min(elapsed + dt, end)
		if elapsed < 0 { elapsed = 0 }

		if spring == nil && (!reversed && elapsed >= end) || (reversed && elapsed <= 0) {
			return true
		}
		
		if elapsed >= delay {
			time = CGFloat((elapsed - delay) / duration)
			update()
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
		
	}
	
	func willStart() {
		
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
	var toCalc: CGFloat = 0
	var current: CGFloat = 0
	
	private var _from: CGFloat = 0
	private var _to: CGFloat = 0
	
	init(target: NSObject, from: CGFloat, to: CGFloat) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
}

public class StructProperty: ValueProperty {
	var currentFrame: CGRect? {
		get {
			if let view = target as? UIView {
				return view.frame
			} else if let layer = target as? CALayer {
				return layer.frame
			}
			return nil
		}
	}
	var currentValue: CGFloat? {
		get {
			if let frame = currentFrame, prop = property {
				switch prop {
				case .X(_):
					return CGRectGetMinX(frame)
				case .Y(_):
					return CGRectGetMinY(frame)
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
			} else if mode == .From {
				to = value
			}
		}
		super.prepare()
	}
	
	override func update() {
		let value = lerpFloat(from, to: to)
		updateTarget(value)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: CGFloat) {
		if var frame = currentFrame, let prop = property {
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
			
			if let view = target as? UIView {
				return view.frame = frame
			} else if let layer = target as? CALayer {
				return layer.frame = frame
			}
		}
	}
}

public class PointProperty: TweenProperty {
	var from: CGPoint = CGPointZero
	var to: CGPoint = CGPointZero
	var toCalc: CGPoint = CGPointZero
	var current: CGPoint = CGPointZero
	
	var currentOrigin: CGPoint? {
		get {
			if let view = target as? UIView {
				return view.frame.origin
			} else if let layer = target as? CALayer {
				return layer.frame.origin
			}
			return nil
		}
	}
	
	private var _from: CGPoint = CGPointZero
	private var _to: CGPoint = CGPointZero
	
	init(target: NSObject, from: CGPoint, to: CGPoint) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if let origin = currentOrigin, prop = property {
			if additive {
				if let target = target, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? PointProperty {
					from = lastProp.to
				}
			} else {
				if mode == .To {
					from = origin
				} else if mode == .From {
					to = origin
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
		var point = lerpPoint(from, to: toCalc)
		let newPoint = point
		
		if additive {
			if let origin = currentOrigin {
				let delta = CGPoint(x: point.x - current.x, y: point.y - current.y)
				point.x = origin.x + delta.x
				point.y = origin.y + delta.y
			}
		}
				
		current = newPoint
		updateTarget(point)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: CGPoint) {
		if let view = target as? UIView {
			view.frame = CGRect(origin: value, size: view.frame.size)
		} else if let layer = target as? CALayer {
			layer.frame = CGRect(origin: value, size: layer.frame.size)
		}
	}
}

public class SizeProperty: TweenProperty {
	var from: CGSize = CGSizeZero
	var to: CGSize = CGSizeZero
	var toCalc: CGSize = CGSizeZero
	var current: CGSize = CGSizeZero
	
	var currentSize: CGSize? {
		get {
			if let view = target as? UIView {
				return view.bounds.size
			} else if let layer = target as? CALayer {
				return layer.bounds.size
			}
			return nil
		}
	}
	
	private var _from: CGSize = CGSizeZero
	private var _to: CGSize = CGSizeZero
	
	init(target: NSObject, from: CGSize, to: CGSize) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if let size = currentSize, prop = property {
			if additive {
				if let target = target, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? SizeProperty {
					from = lastProp.to
				}
			} else {
				if mode == .To {
					from = size
				} else if mode == .From {
					to = size
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
		let size = lerpSize(from, to: toCalc)
		updateTarget(size)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: CGSize) {
		if let view = target as? UIView {
			view.bounds = CGRect(origin: CGPointZero, size: value)
		} else if let layer = target as? CALayer {
			layer.bounds = CGRect(origin: CGPointZero, size: value)
		}
	}
}

public class RectProperty: TweenProperty {
	var from: CGRect = CGRectZero
	var to: CGRect = CGRectZero
	var toCalc: CGRect = CGRectZero
	var current: CGRect = CGRectZero
	
	var currentRect: CGRect? {
		get {
			if let view = target as? UIView {
				return view.frame
			} else if let layer = target as? CALayer {
				return layer.frame
			}
			return nil
		}
	}
	
	private var _from: CGRect = CGRectZero
	private var _to: CGRect = CGRectZero
	
	init(target: NSObject, from: CGRect, to: CGRect) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let target = target, prop = property, lastProp = TweenManager.sharedInstance.lastPropertyForTarget(target, type: prop) as? RectProperty {
				from = lastProp.to
			}
		} else {
			if let size = currentRect {
				if mode == .To {
					from = size
				} else if mode == .From {
					to = size
				}
			}
		}
		
		super.prepare()
	}
	
	override func update() {
		let size = lerpRect(from, to: to)
		updateTarget(size)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: CGRect) {
		if let view = target as? UIView {
			view.frame = value
		} else if let layer = target as? CALayer {
			layer.frame = value
		}
	}
}

public class TransformProperty: TweenProperty {
	var from: CATransform3D = CATransform3DIdentity
	var to: CATransform3D = CATransform3DIdentity
	var toCalc: CATransform3D = CATransform3DIdentity
	var currentTransform: CATransform3D? {
		get {
			if let view = target as? UIView {
				return view.layer.transform
			} else if let layer = target as? CALayer {
				return layer.transform
			}
			return nil
		}
	}
	
	private var _from: CATransform3D = CATransform3DIdentity
	private var _to: CATransform3D = CATransform3DIdentity
	
	init(target: NSObject, from: CATransform3D, to: CATransform3D) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let transform = currentTransform {
				if mode == .To {
					from = transform
					to = CATransform3DConcat(transform, to)
				} else if mode == .From {
					from = CATransform3DConcat(transform, from)
					to = transform
				}
				toCalc = to
			}
		}
		super.prepare()
	}
	
	override func update() {
		let transform = lerpTransform(from, to: toCalc)
		updateTarget(transform)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: CATransform3D) {
		if let view = target as? UIView {
			view.layer.transform = value
		} else if let layer = target as? CALayer {
			layer.transform = value
		}
	}
}

public class ColorProperty: TweenProperty {
	var keyPath: String
	var from: UIColor = UIColor.blackColor()
	var to: UIColor = UIColor.blackColor()
	var toCalc: UIColor = UIColor.blackColor()
	var currentColor: UIColor? {
		get {
			if target.respondsToSelector(Selector(keyPath)) {
				if let color = target.valueForKeyPath(keyPath) as? UIColor {
					return color
				}
			}
			return nil
		}
	}
	
	private var _from: UIColor = UIColor.blackColor()
	private var _to: UIColor = UIColor.blackColor()
	
	init(target: NSObject, property: String, from: UIColor, to: UIColor) {
		self.keyPath = property
		super.init(target: target)
		
		assert(target.respondsToSelector(Selector(property)), "Target for ColorProperty must contain a public property {\(property)}")
		
		self.from = from
		self.to = to
		
		self._from = from
		self._to = to
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let color = currentColor {
				if mode == .To {
					from = color
				} else if mode == .From {
					to = color
				}
			}
		}
		
		super.prepare()
	}
	
	override func update() {
		let color = lerpColor(from, to: to)
		updateTarget(color)
	}
	
	override func reset() {
		super.reset()
		updateTarget(_from)
	}
	
	private func updateTarget(value: UIColor) {
		if let target = target {
			target.setValue(value, forKeyPath: keyPath)
		}
	}
}

public class ObjectProperty: ValueProperty {
	var keyPath: String
	
	init(target: NSObject, keyPath: String, from: CGFloat, to: CGFloat) {
		self.keyPath = keyPath
		super.init(target: target, from: from, to: to)
		
		assert(target.respondsToSelector(Selector(keyPath)), "Target for CustomProperty must contain a public property {\(keyPath)}")
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let target = target, value = target.valueForKeyPath(keyPath) as? CGFloat {
				if mode == .To {
					from = value
				} else if mode == .From {
					to = value
				}
			}
		}
		
		self._from = from
		self._to = to
		
		super.prepare()
	}
	
	override func update() {
		let value = lerpFloat(from, to: toCalc)
		updateTarget(value)
	}
	
	override func reset() {
		super.reset()
		updateTarget(from)
	}
	
	private func updateTarget(value: CGFloat) {
		if let target = target {
			target.setValue(value, forKeyPath: keyPath)
		}
	}
}

