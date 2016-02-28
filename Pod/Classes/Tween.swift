//
//  Tween.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public enum TweenMode {
	case To
	case From
	case FromTo
}

public class Tween: Animation {
	public weak var target: NSObject?
	override public var duration: CFTimeInterval {
		didSet {
			for prop in properties {
				prop.duration = duration
			}
		}
	}
	override public var totalTime: CFTimeInterval {
		get {
			return (elapsed - delay - staggerDelay)
		}
	}
	public weak var timeline: Timeline?
	
	var properties: [TweenProperty] {
		get {
			return _properties
		}
	}
	var _properties = [TweenProperty]()
	
	private var timeScale: Float = 1
	private var staggerDelay: CFTimeInterval = 0
	private var propertiesByType = [String: TweenProperty]()
	private var needsPropertyPrep = false
	
	// MARK: Lifecycle
	
	required public init(target: NSObject, from: [Property]?, to: [Property]?, mode: TweenMode = .To) {
		self.target = target
		super.init()
		
		prepare(from: from, to: to, mode: mode)
	}
	
	// MARK: Animation Overrides
	
	override public func delay(delay: CFTimeInterval) -> Tween {
		super.delay(delay)
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	override public func repeatCount(count: Int) -> Tween {
		super.repeatCount(count)
		return self
	}
	
	override public func repeatDelay(delay: CFTimeInterval) -> Tween {
		super.repeatDelay(delay)
		return self
	}
	
	override public func forever() -> Tween {
		super.forever()
		return self
	}
	
	override public func yoyo() -> Tween {
		super.yoyo()
		return self
	}
	
	override public func restart(includeDelay: Bool = false) {
		super.restart(includeDelay)
		
		for prop in properties {
			prop.reset()
			prop.calc()
		}
		run()
	}
	
	override public func kill() {
		super.kill()
		TweenManager.sharedInstance.remove(self)
	}
	
	// MARK: Public Methods
	
	override public func ease(easing: Ease) -> Tween {
		for prop in properties {
			prop.easing = easing
		}
		return self
	}
	
	override public func spring(tension tension: Double, friction: Double = 3) -> Tween {
		for prop in properties {
			prop.spring = Spring(tension: tension, friction: friction)
		}
		return self
	}
	
	override public func perspective(value: CGFloat) -> Tween {
		var layer: CALayer?
		
		if let targetLayer = target as? CALayer {
			layer = targetLayer
		} else if let view = target as? UIView {
			layer = view.layer
		}
		
		if let layer = layer, var transform = layer.superlayer?.sublayerTransform {
			transform.m34 = value
			layer.superlayer?.sublayerTransform = transform
		}
		
		return self
	}
	
	public func anchor(anchor: Anchor) -> Tween {
		if let layer = target as? CALayer {
			layer.anchorPoint = anchor.point()
		} else if let view = target as? UIView {
			view.layer.anchorPoint = anchor.point()
		}
		return self
	}
	
	public func stagger(offset: CFTimeInterval) -> Tween {
		staggerDelay = offset
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	public func timeScale(scale: Float) -> Tween {
		timeScale = scale
		return self
	}
	
	override public func play() -> Tween {
		guard !active else { return self }
		
		super.play()
		
		// properties must be sorted so that the first in the array is the transform property, if exists
		// so that each property afterwards isn't set with a transform in place
		for prop in TweenUtils.sortProperties(properties).reverse() {
			prop.reset()
			prop.calc()
			
			if prop.mode == .From || prop.mode == .FromTo {
				prop.update()
			}
		}
		run()
		
		return self
	}
	
	override public func reverse() -> Tween {
		super.reverse()
		run()
		
		return self
	}
	
	override public func forward() -> Animation {
		super.forward()
		run()
		
		return self
	}
	
	override public func seek(time: CFTimeInterval) -> Tween {
		elapsed += delay + staggerDelay + time
		for prop in properties {
			prop.seek(time)
		}
		return self
	}
	
	public func updateTo(options: [Property], restart: Bool = false) {
		
	}
	
	// MARK: Private Methods
	
	private func prepare(from from: [Property]?, to: [Property]?, mode: TweenMode) {
		guard let _ = target else { return }
		
		if let from = from {
			setupProperties(from, mode: .From)
		}
		if let to = to {
			setupProperties(to, mode: .To)
		}
		
		for (_, prop) in propertiesByType {
			_properties.append(prop)
			prop.mode = mode
			prop.reset()
			prop.calc()
		}
		needsPropertyPrep = true
		
		// set anchor point and adjust position if target is UIView or CALayer
		if target is UIView || target is CALayer {
			
		}
	}
	
	override func proceed(var dt: CFTimeInterval, force: Bool = false) -> Bool {
		if target == nil || !running {
			return true
		}
		if paused {
			return false
		}
		if properties.count == 0 {
			return true
		}
		
		// if tween belongs to a timeline, don't start animating until the timeline's playhead reaches the tween's startTime
		if let timeline = timeline {
			if (!timeline.reversed && timeline.totalTime < startTime) || (timeline.reversed && timeline.totalTime > endTime) {
				return false
			}
		}
		
		let end = delay + duration
		if reversed {
			dt *= -1
		}
		elapsed = min(elapsed + dt, end)
		if elapsed < 0 {
			elapsed = 0
		}
//		print("TWEEN - elapsed: \(elapsed), dt: \(dt), reversed: \(reversed)")
		
		let delayOffset = delay + staggerDelay + repeatDelay
		if timeline == nil {
			if elapsed < delayOffset {
				// if direction is reversed, then don't allow playhead to go below the tween's delay and call completed handler
				if reversed {
					completed()
				} else {
					return false
				}
			}
		}
		
		// now we can finally animate
		if !animating {
			started()
		}
		
		// proceed each property
		var done = false
		for prop in properties {
			if needsPropertyPrep {
				prop.prepare()
			}
			if prop.proceed(dt, reversed: reversed) {
				done = true
			}
		}
		needsPropertyPrep = false
		updateBlock?(self)
		
		if done {
			return completed()
		}
		
		return false
	}
	
	func storedPropertyForType(type: Property) -> TweenProperty? {
		if let key = TweenUtils.propertyKeyForType(type) {
			return propertiesByType[key]
		}
		
		return nil
	}
	
	// MARK: Private Methods
	
	private func run() {
		running = true
		TweenManager.sharedInstance.add(self)
	}
	
	private func setupProperties(props: [Property], mode: TweenMode) {
		for prop in props {
			let propObj = propertyForType(prop)
			propObj?.mode = mode
			
			switch prop {
			case .X(let x):
				if let point = propObj as? StructProperty {
					if mode == .From {
						point.from = x
					} else {
						point.to = x
					}
				}
			case .Y(let y):
				if let point = propObj as? StructProperty {
					if mode == .From {
						point.from = y
					} else {
						point.to = y
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
			case .CenterX(let x):
				if let point = propObj as? StructProperty {
					if mode == .From {
						point.from = x
					} else {
						point.to = x
					}
				}
			case .CenterY(let y):
				if let point = propObj as? StructProperty {
					if mode == .From {
						point.from = y
					} else {
						point.to = y
					}
				}
			case .Center(let x, let y):
				if let point = propObj as? PointProperty {
					point.targetCenter = true
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
				if let size = propObj as? StructProperty {
					if mode == .From {
						size.from = width
					} else {
						size.to = width
					}
				}
			case .Height(let height):
				if let size = propObj as? StructProperty {
					if mode == .From {
						size.from = height
					} else {
						size.to = height
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
			case .Alpha(let alpha):
				if let currentAlpha = propObj as? ValueProperty {
					if mode == .From {
						currentAlpha.from = alpha
					} else {
						currentAlpha.to = alpha
					}
				}
			case .BackgroundColor(let color):
				if let currentColor = propObj as? ColorProperty {
					if mode == .From {
						currentColor.from = color
					} else {
						currentColor.to = color
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
		
		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, target = target, origin = targetOrigin(target) {
			let prop = PointProperty(target: target, from: origin, to: origin)
			prop.from = CGPoint(x: x.from, y: y.from)
			prop.to = CGPoint(x: x.to, y: y.to)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete x and y properties from cache
			propertiesByType[PropertyKey.X.rawValue] = nil
			propertiesByType[PropertyKey.Y.rawValue] = nil
		}
		
		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, centerY = propertiesByType[PropertyKey.CenterY.rawValue] as? StructProperty, target = target, frame = targetFrame(target) {
			let offset: CGFloat = frame.height / 2
			let prop = PointProperty(target: target, from: frame.origin, to: frame.origin)
			prop.from = CGPoint(x: x.from, y: centerY.from - offset)
			prop.to = CGPoint(x: x.to, y: centerY.to - offset)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete x and center.y properties from cache
			propertiesByType[PropertyKey.X.rawValue] = nil
			propertiesByType[PropertyKey.CenterY.rawValue] = nil
		}
		if let centerX = propertiesByType[PropertyKey.CenterX.rawValue] as? StructProperty, y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, target = target, frame = targetFrame(target) {
			let offset: CGFloat = frame.width / 2
			let prop = PointProperty(target: target, from: frame.origin, to: frame.origin)
			prop.from = CGPoint(x: centerX.from - offset, y: y.from)
			prop.to = CGPoint(x: centerX.to - offset, y: y.to)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete center.x and y properties from cache
			propertiesByType[PropertyKey.CenterX.rawValue] = nil
			propertiesByType[PropertyKey.Y.rawValue] = nil
		}
		
		// if we have both a SizeProperty and PositionProperty, merge them into a single FrameProperty
		if let size = propertiesByType[PropertyKey.Size.rawValue] as? SizeProperty, origin = propertiesByType[PropertyKey.Position.rawValue] as? PointProperty, target = target, frame = targetFrame(target) {
			let prop = RectProperty(target: target, from: frame, to: frame)
			prop.from = CGRect(origin: origin.from, size: size.from)
			prop.to = CGRect(origin: origin.to, size: size.to)
			propertiesByType[PropertyKey.Frame.rawValue] = prop
			
			// delete size and position properties from cache
			propertiesByType[PropertyKey.Size.rawValue] = nil
			propertiesByType[PropertyKey.Position.rawValue] = nil
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
	
	private func propertyForType(type: Property) -> TweenProperty? {
		if let key = TweenUtils.propertyKeyForType(type) {
			var prop = propertiesByType[key]
			
			if prop == nil {
				switch key {
				case PropertyKey.Position.rawValue:
					if let target = target, origin = targetOrigin(target) {
						prop = PointProperty(target: target, from: origin, to: origin)
					}
				case PropertyKey.Center.rawValue:
					if let target = target, center = targetCenter(target) {
						prop = PointProperty(target: target, from: center, to: center)
						if let pointProp = prop as? PointProperty {
							pointProp.targetCenter = true
						}
					}
				case PropertyKey.Size.rawValue:
					if let target = target, size = targetSize(target) {
						prop = SizeProperty(target: target, from: size, to: size)
					}
				case PropertyKey.Transform.rawValue:
					if let target = target, transform = targetTransform(target) {
						prop = TransformProperty(target: target, from: transform, to: transform)
					}
				case PropertyKey.Alpha.rawValue:
					if let target = target, alpha = targetAlpha(target) {
						let key = (target is CALayer) ? "opacity" : "alpha"
						prop = ObjectProperty(target: target, keyPath: key, from: alpha, to: alpha)
					}
				case PropertyKey.BackgroundColor.rawValue:
					if let target = target, color = targetColor(target, keyPath: "backgroundColor") {
						prop = ColorProperty(target: target, property: "backgroundColor", from: color, to: color)
					}
				case PropertyKey.X.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetMinX(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				case PropertyKey.Y.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetMinY(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				case PropertyKey.CenterX.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetMidX(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				case PropertyKey.CenterY.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetMidY(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				case PropertyKey.Width.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetWidth(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				case PropertyKey.Height.rawValue:
					if let target = target, frame = targetFrame(target) {
						let value = CGRectGetHeight(frame)
						prop = StructProperty(target: target, from: value, to: value)
					}
				default:
					if let target = target, value = target.valueForKeyPath(key) as? CGFloat {
						prop = ObjectProperty(target: target, keyPath: key, from: value, to: value)
					}
				}
				
				prop?.property = type
				prop?.tween = self
				propertiesByType[key] = prop
			}
			
			return prop
		}
		
		return nil
	}
	
	private func targetOrigin(target: NSObject) -> CGPoint? {
		var origin: CGPoint?
		
		if let layer = target as? CALayer {
			origin = layer.frame.origin
		} else if let view = target as? UIView {
			origin = view.frame.origin
		}
		
		return origin
	}
	
	private func targetCenter(target: NSObject) -> CGPoint? {
		var center: CGPoint?
		
		if let layer = target as? CALayer {
			center = layer.position
		} else if let view = target as? UIView {
			center = view.center
		}
		
		return center
	}
	
	private func targetSize(target: NSObject) -> CGSize? {
		var size: CGSize?
		
		if let layer = target as? CALayer {
			size = layer.bounds.size
		} else if let view = target as? UIView {
			size = view.frame.size
		}
		
		return size
	}
	
	private func targetFrame(target: NSObject) -> CGRect? {
		var frame: CGRect?
		
		if let layer = target as? CALayer {
			frame = layer.frame
		} else if let view = target as? UIView {
			frame = view.frame
		}
		
		return frame
	}
	
	private func targetTransform(target: NSObject) -> CATransform3D? {
		var transform: CATransform3D?
		
		if let layer = target as? CALayer {
			transform = layer.transform
		} else if let view = target as? UIView {
			transform = view.layer.transform
		}
		
		return transform
	}
	
	private func targetAlpha(target: NSObject) -> CGFloat? {
		var alpha: CGFloat?
		
		if let layer = target as? CALayer {
			alpha = CGFloat(layer.opacity)
		} else if let view = target as? UIView {
			alpha = view.alpha
		}
		
		return alpha
	}
	
	private func targetColor(target: NSObject, keyPath: String) -> UIColor? {
		var color: UIColor?
		
		if target.respondsToSelector(Selector(keyPath)) {
			if let c = target.valueForKeyPath(keyPath) as? UIColor {
				color = c
			}
		}
		
		return color
	}
}