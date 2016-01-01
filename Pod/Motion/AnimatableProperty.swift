//
//  AnimatableProperty.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

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

public class AnimatableProperty {
	weak var target: AnyObject!
	weak var group: TweenGroup!
	
	var mode: TweenMode = .To
	var duration: CFTimeInterval = 1
	var delay: CFTimeInterval = 0
	var elapsed: CFTimeInterval = 0
	var dt: CFTimeInterval = 0
	var current: CGFloat = 0
	var easing: Ease = Easing.linear
	var spring: Spring?
	var additive: Bool = true
	
	init(target: AnyObject) {
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
			current = CGFloat((elapsed - delay) / duration)
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
	
//	func reverse(reverse: Bool) {
//		reset()
//		calc()
//	}
	
	func reset() {
		elapsed = 0
		current = 0
		
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
		return easing(t: current, b: from, c: to - from)
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

public class ValueProperty: AnimatableProperty {
	var from: CGFloat = 0
	var to: CGFloat = 0
	var toCalc: CGFloat = 0
	
	private var _from: CGFloat = 0
	private var _to: CGFloat = 0
	
	init(target: AnyObject, from: CGFloat, to: CGFloat) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		// cache original values to account for reversed tweens
		self._from = from
		self._to = to
	}
	
	override func calc() {
//		toCalc = from + to
		toCalc = to
	}
	
//	override func reverse(reverse: Bool) {
//		if reverse {
//			from = _to
//			to = _from
//		} else {
//			from = _from
//			to = _to
//		}
//		
//		super.reverse(reverse)
//	}
}

public class PointProperty: AnimatableProperty {
	var from: CGPoint = CGPointZero
	var to: CGPoint = CGPointZero
	var toCalc: CGPoint = CGPointZero
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
	
	init(target: AnyObject, from: CGPoint, to: CGPoint) {
		super.init(target: target)
		self.from = from
		self.to = to
		self._from = from
		self._to = to
	}
	
	override func calc() {
//		toCalc = CGPoint(x: from.x + to.x, y: from.y + to.y)
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let size = currentOrigin {
				if mode == .To {
					from = size
				} else if mode == .From {
					to = size
				}
			}
		}
		
		// cache original values to account for reversed tweens
//		self._from = from
//		self._to = to
		
		super.prepare()
	}
	
//	override func reverse(reverse: Bool) {
//		if reverse {
//			from = _to
//			to = _from
//		} else {
//			from = _from
//			to = _to
//		}
//		
//		super.reverse(reverse)
//	}
	
	override func update() {
		let point = lerpPoint(from, to: to)
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

public class SizeProperty: AnimatableProperty {
	var from: CGSize = CGSizeZero
	var to: CGSize = CGSizeZero
	var toCalc: CGSize = CGSizeZero
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
	
	init(target: AnyObject, from: CGSize, to: CGSize) {
		super.init(target: target)
		self.from = from
		self.to = to
		self._from = from
		self._to = to
	}
	
	override func calc() {
//		toCalc = CGSize(width: from.width + to.width, height: from.height + to.height)
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let size = currentSize {
				if mode == .To {
					from = size
				} else if mode == .From {
					to = size
				}
			}
		}
		
		// cache original values to account for reversed tweens
//		self._from = from
//		self._to = to
		
		super.prepare()
	}
	
//	override func reverse(reverse: Bool) {
//		if reverse {
//			from = _to
//			to = _from
//		} else {
//			from = _from
//			to = _to
//		}
//		
//		print("PROP.reverse - reversed: \(reverse), from: \(from), to: \(to)")
//		
//		super.reverse(reverse)
//	}
	
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

public class TransformProperty: AnimatableProperty {
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
	
	init(target: AnyObject, from: CATransform3D, to: CATransform3D) {
		super.init(target: target)
		self.from = from
		self.to = to
		
		// cache original values to account for reversed tweens
		self._from = from
		self._to = to
	}
	
	override func calc() {
//		toCalc = CATransform3DConcat(from, to)
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
		
		// cache original values to account for reversed tweens
//		self._from = from
//		self._to = to
		
		super.prepare()
	}
	
//	override func reverse(reverse: Bool) {
//		if reverse {
//			from = _to
//			to = _from
//		} else {
//			from = _from
//			to = _to
//		}
//		
//		super.reverse(reverse)
//	}
	
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

public class ObjectProperty: ValueProperty {
	var keyPath: String
	
	init(target: AnyObject, keyPath: String, from: CGFloat, to: CGFloat) {
		assert(target is NSObject, "Target for CustomProperty must be of type NSObject")
		
		self.keyPath = keyPath
		super.init(target: target, from: from, to: to)
		
		if let target = target as? NSObject {
			assert(target.respondsToSelector(Selector(keyPath)), "Target for CustomProperty must contain a public property {\(keyPath)}")
		}
	}
	
	override func calc() {
		toCalc = to
	}
	
	override func prepare() {
		if additive {
			if let target = target as? NSObject, value = target.valueForKeyPath(keyPath) as? CGFloat {
				if mode == .To {
					from = value
				} else if mode == .From {
					to = value
				}
			}
		}
		
		// cache original values to account for reversed tweens
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
		if let target = target as? NSObject {
			target.setValue(value, forKeyPath: keyPath)
		}
	}
}

