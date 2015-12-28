//
//  Tween.swift
//  Tween
//
//  Created by Nicholas Shipes on 10/22/15.
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
	case KeyPath(String, CGFloat)
}

public enum TweenMode {
	case To
	case From
	case FromTo
}

private enum PropertyKey: String {
	case Position = "frame.origin"
	case Size = "frame.size"
	case Transform = "transform"
}

public class Tween: NSObject {
	weak var target: AnyObject?
	
	var id: UInt32 = 0
	var running = false
	var paused = false
	var animating = false
	var elapsed: CFTimeInterval = 0
	var delay: CFTimeInterval = 0
	var duration: CFTimeInterval = 1.0 {
		didSet {
			for prop in properties {
				prop.duration = duration
			}
			group?.duration = duration
		}
	}
	var repeatCount: Int = 0
	var group: TweenGroup?
	var properties = [AnimatableProperty]()
	
	private var reversed = false
	private var staggerDelay: CFTimeInterval = 0
	private var repeated: Int = 0
	private var repeatForever = false
	private var reverseOnComplete = false
	
	private var startBlock: (() -> Void)?
	private var updateBlock: (() -> Void)?
	private var completionBlock: (() -> Void)?
	private var propertiesByType = [String: AnimatableProperty]()
	private var needsPropertyPrep = false
	
//	// MARK: Class Methods
//	
//	static func to(item: AnyObject, duration: CFTimeInterval, options: [Property]) -> Tween {
//		let tween = Tween(target: item)
//		tween.duration = duration
//		tween.prepare(from: nil, to: options, mode: .To)
//		
//		return tween
//	}
//	
//	static func from(item: AnyObject, duration: CFTimeInterval, options: [Property]) -> Tween {
//		let tween = Tween(target: item)
//		tween.duration = duration
//		tween.prepare(from: options, to: nil, mode: .From)
//		
//		return tween
//	}
//	
//	static func fromTo(item: AnyObject, duration: CFTimeInterval, from: [Property], to: [Property]) -> Tween {
//		let tween = Tween(target: item)
//		tween.duration = duration
//		tween.prepare(from: from, to: to, mode: .FromTo)
//		
//		return tween
//	}
//	
//	static func itemsTo(items: [AnyObject], duration: CFTimeInterval, options: [Property]) -> TweenGroup {
//		let group = TweenGroup()
//		
//		items.forEach { (item) -> () in
//			let tween = Tween(target: item)
//			tween.duration = duration
//			tween.prepare(from: nil, to: options, mode: .To)
//			tween.group = group
//			group.addTween(tween)
//		}
//		
//		return group
//	}
//	
//	static func itemsFrom(items: [AnyObject], duration: CFTimeInterval, options: [Property]) -> TweenGroup {
//		let group = TweenGroup()
//		
//		items.forEach { (item) -> () in
//			let tween = Tween(target: item)
//			tween.duration = duration
//			tween.prepare(from: options, to: nil, mode: .From)
//			tween.group = group
//			group.addTween(tween)
//		}
//		
//		return group
//	}
//	
//	static func itemsFromTo(items: [AnyObject], duration: CFTimeInterval, from: [Property], to: [Property]) -> TweenGroup {
//		let group = TweenGroup()
//		
//		items.forEach { (item) -> () in
//			let tween = Tween(target: item)
//			tween.duration = duration
//			tween.prepare(from: from, to: to, mode: .FromTo)
//			tween.group = group
//			group.addTween(tween)
//		}
//		
//		return group
//	}
//	
//	static func killTweensOf(target: AnyObject) {
//		
//	}
	
	// MARK: Lifecycle
	
	required public init(target: AnyObject, from: [Property]?, to: [Property]?, mode: TweenMode = .To) {
		self.target = target
		super.init()
		
		prepare(from: from, to: to, mode: mode)
	}
	
	// MARK: Public Methods
	
	public func delay(delay: CFTimeInterval) -> Tween {
		self.delay = delay
		return self
	}
	
	public func ease(easing: Ease) -> Tween {
		for prop in properties {
			prop.easing = easing
		}
		return self
	}
	
	public func perspective(value: CGFloat) -> Tween {
		return self
	}
	
	public func anchorPoint(point: CGPoint) -> Tween {
		return self
	}
	
	public func repeatCount(count: Int) -> Tween {
		repeatCount = count
		return self
	}
	
	public func forever() -> Tween {
		repeatForever = true
		return self
	}
	
	public func yoyo() -> Tween {
		reverseOnComplete = true
		return self
	}
	
	public func stagger(offset: CFTimeInterval) -> Tween {
		staggerDelay = offset
		return self
	}
	
	public func play() -> Tween {
		if running {
			return self
		}
		
		running = true
		TweenManager.sharedInstance.add(self)
		
		return self
	}
	
	public func pause() {
		paused = true
		animating = false
	}
	
	public func resume() {
		paused = false
		animating = false
	}
	
	public func restart(includeDelay: Bool = false) {
		elapsed = includeDelay ? 0 : delay
		reversed = false
		for prop in properties {
			prop.reset()
			prop.calc()
		}
	}
	
	public func progress() -> CGFloat {
		return CGFloat(elapsed / (delay + duration))
	}
	
	public func kill() {
		running = false
		animating = false
		TweenManager.sharedInstance.remove(self)
	}
	
	// MARK: Event Handlers
	
	public func onStart(callback: (() -> Void)?) -> Tween {
		startBlock = callback
		return self
	}
	
	public func onUpdate(callback: (() -> Void)?) -> Tween {
		updateBlock = callback
		return self
	}
	
	public func onComplete(callback: (() -> Void)?) -> Tween {
		completionBlock = callback
		return self
	}
	
	// MARK: Private Methods
	
	private func prepare(from from: [Property]?, to: [Property]?, mode: TweenMode) {
		guard let _ = target else { return }
		
		elapsed = 0
		
		if let from = from {
			setupProperties(from, mode: .From)
		}
		if let to = to {
			setupProperties(to, mode: .To)
		}
		
		for (_, prop) in propertiesByType {
			properties.append(prop)
		}
		
		needsPropertyPrep = true
		
//		for (opt, value) in options {
//			var prop: AnimatableProperty?
//			
//			if opt == .X || opt == .Y || opt == .Position {
//				if let origin = targetOrigin(target) {
//					var from = origin, to = origin
//					
//					if mode == .To {
//						if let storedProp = propertyForType(.Position) as? PointProperty {
//							to = storedProp.to
//						}
//						to = adjustedPoint(to, withValue: value, prop: opt)
//					}
//					
//					prop = PointProperty(target: target, from: from, to: to)
//					propertiesByType[.Position] = prop
//				}
//				
//			} else if opt == .Width || opt == .Height || opt == .Size {
//				if let size = targetSize(target) {
//					var from = size, to = size
//					
//					if mode == .To {
//						to = adjustedSize(to, withValue: value, prop: opt)
//					} else if mode == .From {
//						from = adjustedSize(from, withValue: value, prop: opt)
//					}
//					
//					prop = SizeProperty(target: target, from: from, to: to)
//					propertiesByType[.Size] = prop
//				}
//			} else if opt == .ShiftX || opt == .ShiftY || opt == .ShiftXY {
//				if let transform = targetTransform(target) {
//					var from = transform, to = transform
//					
//					if mode == .To {
//						if let value = value as? NSNumber {
//							if opt == .ShiftX {
//								to = CATransform3DTranslate(to, CGFloat(value.floatValue), 0, 0)
//							} else if opt == .ShiftY {
//								to = CATransform3DTranslate(to, 0, CGFloat(value.floatValue), 0)
//							}
//						} else if let value = value as? CGPoint {
//							to = CATransform3DTranslate(to, value.x, value.y, 0)
//						}
//					} else if mode == .From {
//						
//					}
//					
//					prop = TransformProperty(target: target, from: from, to: to)
//					propertiesByType[.Transform] = prop
//				}
//			}
//			
//			if let prop = prop {
//				addProperty(prop)
//			}
//		}
		
		// set anchor point and adjust position if target is UIView or CALayer
		if target is UIView || target is CALayer {
			
		}
		
		restart(true)
		
		group?.prepare()
	}
	
	func proceed(dt: CFTimeInterval) -> Bool {
		if target == nil || !running {
			return true
		}
		if paused {
			return false
		}
		
		elapsed += dt
		
		if elapsed < (delay + staggerDelay) {
			return false
		}
		if properties.count == 0 {
			return true
		}
		
		if !animating {
			animating = true
			startBlock?()
		}
		
		var shouldRepeat = false
		
		// proceed each property
		for prop in properties {
			if needsPropertyPrep {
				prop.prepare()
			}
			if prop.proceed(dt, reversed: reversed) {
				print("DONE: repeatCount=\(repeatCount), repeated=\(repeated)")
				if repeatForever || (repeatCount > 0 && repeated < repeatCount) {
					shouldRepeat = true
				} else {
					completionBlock?()
					return true
				}
			}
		}
		needsPropertyPrep = false
		updateBlock?()
		
		if shouldRepeat {
			if reverseOnComplete {
				reversed = !reversed
				for prop in properties {
					prop.reverse(reversed)
				}
			} else {
				restart()
			}
			repeated++
		}
		
		return false
	}
	
	// MARK: Private Methods
	
	private func setupProperties(props: [Property], mode: TweenMode) {		
		for prop in props {
			print("adding property for \(prop)")
			let propObj = propertyForType(prop)
			
			switch prop {
			case .X(let x):
				if let point = propObj as? PointProperty {
					if mode == .From {
						point.from.x = x
					} else {
						point.to.x = x
					}
				}
			case .Y(let y):
				if let point = propObj as? PointProperty {
					if mode == .From {
						point.from.y = y
					} else {
						point.to.y = y
					}
				}
			case .Position(let x, let y):
				if let point = propObj as? PointProperty {
					if mode == .From {
						point.from = CGPoint(x: x, y: y)
					} else {
						point.to = CGPoint(x: x, y: y)
					}
				}
			case .Shift(let shiftX, let shiftY):
				if let point = propObj as? PointProperty, target = target, position = targetOrigin(target) {
					if mode == .From {
						point.from.x = position.x + shiftX
						point.from.y = position.y + shiftY
					} else {
						point.to.x = position.x + shiftX
						point.to.y = position.y + shiftY
					}
				}
			case .Width(let width):
				if let size = propObj as? SizeProperty {
					if mode == .From {
						size.from.width = width
					} else {
						size.to.width = width
					}
				}
			case .Height(let height):
				if let size = propObj as? SizeProperty {
					if mode == .From {
						size.from.height = height
					} else {
						size.to.height = height
					}
				}
			case .Size(let width, let height):
				if let size = propObj as? SizeProperty {
					if mode == .From {
						size.from = CGSize(width: width, height: height)
					} else {
						size.to = CGSize(width: width, height: height)
					}
				}
			case .Translate(let shiftX, let shiftY):
				if let transform = propObj as? TransformProperty {
					if mode == .From {
						transform.from = CATransform3DTranslate(transform.from, shiftX, shiftY, 0)
					} else {
						transform.to = CATransform3DTranslate(transform.to, shiftX, shiftY, 0)
					}
				}
			case .Scale(let scale):
				if let transform = propObj as? TransformProperty {
					if mode == .From {
						transform.from = CATransform3DScale(transform.from, scale, scale, 1)
					} else {
						transform.to = CATransform3DScale(transform.to, scale, scale, 1)
					}
				}
			case .ScaleXY(let scaleX, let scaleY):
				if let transform = propObj as? TransformProperty {
					if mode == .From {
						transform.from = CATransform3DScale(transform.from, scaleX, scaleY, 1)
					} else {
						transform.to = CATransform3DScale(transform.to, scaleX, scaleY, 1)
					}
				}
			case .Rotate(let rotation):
				if let transform = propObj as? TransformProperty {
					if mode == .From {
						transform.from = CATransform3DRotate(transform.from, rotation, 0, 0, 1)
					} else {
						transform.to = CATransform3DRotate(transform.to, rotation, 0, 0, 1)
					}
				}
			case .RotateXY(let rotateX, let rotateY):
				if let transform = propObj as? TransformProperty {
					if mode == .From {
						transform.from = CATransform3DRotate(transform.from, rotateX, 1, 0, 0)
						transform.from = CATransform3DRotate(transform.from, rotateY, 0, 1, 0)
					} else {
						transform.to = CATransform3DRotate(transform.to, rotateX, 1, 0, 0)
						transform.to = CATransform3DRotate(transform.to, rotateY, 0, 1, 0)
					}
				}
			case .Transform(let transform):
				if let currentTransform = propObj as? TransformProperty {
					if mode == .From {
						currentTransform.from = transform
					} else {
						currentTransform.to = transform
					}
				}
			case .KeyPath(_, let value):
				if let custom = propObj as? ObjectProperty {
					if mode == .From {
						custom.from = value
					} else {
						custom.to = value
					}
				}
			}
		}
	}
	
	private func resolvedPropertyTypeForType(type: Property) -> Property {
		var resolvedType: Property
		
		switch type {
		case .Translate(let shiftX, let shiftY):
			resolvedType = .Transform(CATransform3DMakeTranslation(shiftX, shiftY, 0))
		case .Scale(let scale):
			resolvedType = .Transform(CATransform3DMakeScale(scale, scale, scale))
		case .ScaleXY(let scaleX, let scaleY):
			resolvedType = .Transform(CATransform3DMakeScale(scaleX, scaleY, 0))
		default:
			resolvedType = type
		}
		
		return resolvedType
	}
	
	private func propertyForType(type: Property) -> AnimatableProperty? {
		let propType = type
		var propKey: String?
		
		switch propType {
		case .KeyPath(let key, _):
			propKey = key
		case .Position(_, _), .X(_), .Y(_), .Shift(_, _):
			propKey = PropertyKey.Position.rawValue
		case .Size(_, _), .Width(_), .Height(_):
			propKey = PropertyKey.Size.rawValue
		default:
			propKey = PropertyKey.Transform.rawValue
		}
		
		if let key = propKey {
			var prop = propertiesByType[key]
			
			if let key = propKey where prop == nil {
				switch key {
				case PropertyKey.Position.rawValue:
					if let target = target, origin = targetOrigin(target) {
						prop = PointProperty(target: target, from: origin, to: origin)
					}
				case PropertyKey.Size.rawValue:
					if let target = target, size = targetSize(target) {
						prop = SizeProperty(target: target, from: size, to: size)
					}
				case PropertyKey.Transform.rawValue:
					if let target = target, transform = targetTransform(target) {
						prop = TransformProperty(target: target, from: transform, to: transform)
					}
				default:
					if let target = target as? NSObject, value = target.valueForKeyPath(key) as? CGFloat {
						prop = ObjectProperty(target: target, keyPath: key, from: value, to: value)
					}
				}
				
				propertiesByType[key] = prop
			}
			
			return prop
		}
		
		return nil
	}
	
//	private func adjustedPoint(var point: CGPoint, withValue value: Any, prop: TweenProp) -> CGPoint {
//		if let value = value as? NSNumber {
//			if prop == .X {
//				point.x = CGFloat(value.floatValue)
//			} else if prop == .Y {
//				point.y = CGFloat(value.floatValue)
//			}
//		} else if let value = value as? CGPoint {
//			point = value
//		}
//		
//		return point
//	}
//	
//	private func adjustedSize(var size: CGSize, withValue value: Any, prop: TweenProp) -> CGSize {
//		if let value = value as? NSNumber {
//			if prop == .Width {
//				size.width = CGFloat(value.floatValue)
//			} else if prop == .Height {
//				size.height = CGFloat(value.floatValue)
//			}
//		} else if let value = value as? CGSize {
//			size = value
//		}
//		
//		return size
//	}
//	
//	private func adjustedTransform(var transform: CATransform3D, withValue value: Any, prop: TweenProp) -> CATransform3D {
//		if let value = value as? NSNumber {
//			let val = CGFloat(value.floatValue)
//			switch prop {
//			case .ShiftX:
//				transform = CATransform3DTranslate(transform, val, 0, 0)
//			case .ShiftY:
//				transform = CATransform3DTranslate(transform, 0, val, 0)
//			case .Rotate:
//				transform = CATransform3DRotate(transform, val, 0, 0, 1)
//			case .Scale, .ScaleX, .ScaleY:
//				let x = (prop == .Scale || prop == .ScaleX) ? val : 1
//				let y = (prop == .Scale || prop == .ScaleY) ? val : 1
//				transform = CATransform3DScale(transform, x, y, 1)
//			default:
//				break
//			}
//		} else if let value = value as? CGPoint {
//			if prop == .ShiftXY {
//				transform = CATransform3DTranslate(transform, value.x, value.y, 0)
//			}
//		} else if let value = value as? CATransform3D {
//			transform = CATransform3DConcat(transform, value)
//		}
//		
//		return transform
//	}
	
	private func targetOrigin(target: AnyObject) -> CGPoint? {
		var origin: CGPoint?
		
		if let layer = target as? CALayer {
			origin = layer.frame.origin
		} else if let view = target as? UIView {
			origin = view.frame.origin
		}
		
		return origin
	}
	
	private func targetSize(target: AnyObject) -> CGSize? {
		var size: CGSize?
		
		if let layer = target as? CALayer {
			size = layer.bounds.size
		} else if let view = target as? UIView {
			size = view.frame.size
		}
		
		return size
	}
	
	private func targetFrame(target: AnyObject) -> CGRect? {
		var frame: CGRect?
		
		if let layer = target as? CALayer {
			frame = layer.frame
		} else if let view = target as? UIView {
			frame = view.frame
		}
		
		return frame
	}
	
	private func targetTransform(target: AnyObject) -> CATransform3D? {
		var transform: CATransform3D?
		
		if let layer = target as? CALayer {
			transform = layer.transform
		} else if let view = target as? UIView {
			transform = view.layer.transform
		}
		
		return transform
	}
}