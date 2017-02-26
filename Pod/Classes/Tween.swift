//
//  Tween.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public enum TweenMode {
	case to
	case from
	case fromTo
}

public protocol Tweenable {
	associatedtype TweenType
	
	var antialiasing: Bool { get set }
	weak var timeline: Timeline? { get set }
	
	func from(_ props: Property...) -> TweenType
	func to(_ props: Property...) -> TweenType
	
	func ease(_ easing: @escaping Ease) -> TweenType
	func spring(tension: Double, friction: Double) -> TweenType
	func perspective(_ value: CGFloat) -> TweenType
	func anchor(_ anchor: Anchor) -> TweenType
	func anchorPoint(_ point: CGPoint) -> TweenType
}

open class Tween: Animation, Tweenable {
	public typealias TweenType = Tween
	public typealias AnimationType = Tween
	
	public var target: NSObject? {
		get {
			return tweenObject.target
		}
	}
	public var antialiasing: Bool {
		get {
			return tweenObject.antialiasing
		}
		set(newValue) {
			tweenObject.antialiasing = newValue
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
			return [TweenProperty](propertiesByType.values)
		}
	}
	
	var tweenObject: TweenObject
	
	fileprivate (set) public var easing: Ease = Easing.linear
	
	fileprivate var timeScale: Float = 1
	fileprivate var staggerDelay: CFTimeInterval = 0
	fileprivate var propertiesByType: Dictionary<String, TweenProperty> = [String: TweenProperty]()
	fileprivate var needsPropertyPrep = false

	
	// MARK: Lifecycle
	
	required public init(target: NSObject, from: [Property]?, to: [Property]?, mode: TweenMode = .to) {
		self.tweenObject = TweenObject(target: target)
		super.init()
		
		TweenManager.sharedInstance.cache(self, target: target)
		prepare(from: from, to: to, mode: mode)
	}
	
	required public init(target: NSObject) {
		self.tweenObject = TweenObject(target: target)
		super.init()
		
		TweenManager.sharedInstance.cache(self, target: target)
	}
	
	deinit {
		kill()
		propertiesByType.removeAll()
		tweenObject.target = nil
	}
	
	// MARK: Animation Overrides
	
	@discardableResult
	override open func duration(_ duration: CFTimeInterval) -> Tween {
		super.duration(duration)
		
		for prop in properties {
			prop.duration = self.duration
		}
		return self
	}
	
	@discardableResult
	override open func delay(_ delay: CFTimeInterval) -> Tween {
		super.delay(delay)
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	override open func restart(_ includeDelay: Bool = false) {
		super.restart(includeDelay)
		
		for prop in properties {
			prop.reset()
			prop.calc()
		}
		run()
	}
	
	override open func kill() {
		super.kill()
		
		TweenManager.sharedInstance.remove(self)
		if let target = target {
			TweenManager.sharedInstance.removeFromCache(self, target: target)
		}
	}
	
	// MARK: Tweenable
	
	@discardableResult
	open func from(_ props: Property...) -> Tween {
		return from(props)
	}
	
	@discardableResult
	open func to(_ props: Property...) -> Tween {
		return to(props)
	}
	
	// internal `from` and `to` methods that support a single array of Property types since we can't forward variadic arguments
	@discardableResult
	func from(_ props: [Property]) -> Tween {
		prepare(from: props, to: nil, mode: .from)
		return self
	}
	
	@discardableResult
	func to(_ props: [Property]) -> Tween {
		prepare(from: nil, to: props, mode: .to)
		return self
	}
	
	@discardableResult
	open func ease(_ easing: @escaping Ease) -> TweenType {
		self.easing = easing
		
		for prop in properties {
			prop.easing = easing
		}
		return self
	}
	
	@discardableResult
	open func spring(tension: Double, friction: Double = 3) -> Tween {
		for prop in properties {
			prop.spring = Spring(tension: tension, friction: friction)
		}
		return self
	}
	
	@discardableResult
	open func perspective(_ value: CGFloat) -> Tween {
		tweenObject.perspective = value
		return self
	}
	
	@discardableResult
	open func anchor(_ anchor: Anchor) -> Tween {
		return anchorPoint(anchor.point())
	}
	
	@discardableResult
	open func anchorPoint(_ point: CGPoint) -> Tween {
		tweenObject.anchorPoint = point
		return self
	}
	
	@discardableResult
	open func stagger(_ offset: CFTimeInterval) -> Tween {
		staggerDelay = offset
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	@discardableResult
	open func timeScale(_ scale: Float) -> Tween {
		timeScale = scale
		return self
	}
	
	@discardableResult
	override open func play() -> Tween {
		guard !active else { return self }
		
		super.play()
		
		if let target = target {
			TweenManager.sharedInstance.cache(self, target: target)
		}
		
		// properties must be sorted so that the first in the array is the transform property, if exists
		// so that each property afterwards isn't set with a transform in place
		for prop in TweenUtils.sortProperties(properties).reversed() {
			prop.reset()
			prop.calc()
			
			if prop.mode == .from || prop.mode == .fromTo {
				prop.seek(0)
			}
		}
		run()
		
		return self
	}
	
	override open func resume() {
		super.resume()
		if !running {
			run()
		}
	}
	
	@discardableResult
	override open func reverse() -> Tween {
		super.reverse()
		run()
		
		return self
	}
	
	@discardableResult
	override open func forward() -> Tween {
		super.forward()
		run()
		
		return self
	}
	
	@discardableResult
	override open func seek(_ time: CFTimeInterval) -> Tween {
		super.seek(time)
		
		let elapsedTime = elapsedTimeFromSeekTime(time)
		elapsed = delay + staggerDelay + elapsedTime
		
		for prop in TweenUtils.sortProperties(properties).reversed() {
			if needsPropertyPrep {
				prop.prepare()
			}
			prop.seek(elapsedTime)
		}
		needsPropertyPrep = false
		
		return self
	}
	
	open func updateTo(_ options: [Property], restart: Bool = false) {
		
	}
	
	// MARK: Private Methods
	
	fileprivate func prepare(from: [Property]?, to: [Property]?, mode: TweenMode) {
		guard let _ = target else { return }
		
		var tweenMode = mode
		// use .FromTo mode if passed `mode` is .To and we already have properties setup
		if tweenMode == .to && propertiesByType.count > 0 {
			tweenMode = .fromTo
		}
		
		if let from = from {
			setupProperties(from, mode: .from)
		}
		if let to = to {
			setupProperties(to, mode: .to)
		}
		
		needsPropertyPrep = true
		for (_, prop) in propertiesByType {
			prop.mode = tweenMode
			prop.duration = duration
			prop.easing = easing
			prop.reset()
			prop.calc()
			
			if prop.mode == .from || prop.mode == .fromTo {
				if needsPropertyPrep {
					prop.prepare()
				}
				prop.seek(0)
				needsPropertyPrep = false
			}
		}
	}
	
	override func proceed(_ dt: CFTimeInterval, force: Bool = false) -> Bool {
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
			if (!timeline.reversed && timeline.time() < startTime) || (timeline.reversed && timeline.time() > endTime) {
				return false
			}
		}
		
		let end = delay + duration
		let multiplier: CFTimeInterval = reversed ? -1 : 1
		elapsed = min(elapsed + (dt * multiplier), end)
		runningTime += dt
		
		if elapsed < 0 {
			elapsed = 0
		}
		
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
			if prop.proceed(dt * multiplier, reversed: reversed) {
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
	
	func storedPropertyForType(_ type: Property) -> TweenProperty? {
		if let key = TweenUtils.propertyKeyForType(type) {
			return propertiesByType[key]
		}
		return nil
	}
	
	// MARK: Private Methods
	
	fileprivate func run() {
		running = true
		TweenManager.sharedInstance.add(self)
	}
	
	fileprivate func setupProperties(_ props: [Property], mode: TweenMode) {
		for prop in props {
			let propObj = propertyForType(prop)
			propObj?.mode = mode
			
			switch prop {
			case .x(let x):
				if let point = propObj as? StructProperty {
					if mode == .from {
						point.from = x
					} else {
						point.to = x
					}
				}
			case .y(let y):
				if let point = propObj as? StructProperty {
					if mode == .from {
						point.from = y
					} else {
						point.to = y
					}
				}
			case .position(let x, let y):
				if let point = propObj as? PointProperty {
					if mode == .from {
						point.from = CGPoint(x: x, y: y)
					} else {
						point.to = CGPoint(x: x, y: y)
					}
				}
			case .centerX(let x):
				if let point = propObj as? StructProperty {
					if mode == .from {
						point.from = x
					} else {
						point.to = x
					}
				}
			case .centerY(let y):
				if let point = propObj as? StructProperty {
					if mode == .from {
						point.from = y
					} else {
						point.to = y
					}
				}
			case .center(let x, let y):
				if let point = propObj as? PointProperty {
					point.targetCenter = true
					if mode == .from {
						point.from = CGPoint(x: x, y: y)
					} else {
						point.to = CGPoint(x: x, y: y)
					}
				}
			case .shift(let shiftX, let shiftY):
				if let point = propObj as? PointProperty, let position = tweenObject.origin {
					if mode == .from {
						point.from.x = position.x + shiftX
						point.from.y = position.y + shiftY
					} else {
						point.to.x = position.x + shiftX
						point.to.y = position.y + shiftY
					}
				}
			case .width(let width):
				if let size = propObj as? StructProperty {
					if mode == .from {
						size.from = width
					} else {
						size.to = width
					}
				}
			case .height(let height):
				if let size = propObj as? StructProperty {
					if mode == .from {
						size.from = height
					} else {
						size.to = height
					}
				}
			case .size(let width, let height):
				if let size = propObj as? SizeProperty {
					if mode == .from {
						size.from = CGSize(width: width, height: height)
					} else {
						size.to = CGSize(width: width, height: height)
					}
				}
			case .translate(let shiftX, let shiftY):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.translation = Translation(x: shiftX, y: shiftY)
					} else {
						transform.to.translation = Translation(x: shiftX, y: shiftY)
					}
				}
			case .scale(let scale):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.scale = Scale(x: scale, y: scale, z: 1)
					} else {
						transform.to.scale = Scale(x: scale, y: scale, z: 1)
					}
				}
			case .scaleXY(let scaleX, let scaleY):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.scale = Scale(x: scaleX, y: scaleY, z: 1)
					} else {
						transform.to.scale = Scale(x: scaleX, y: scaleY, z: 1)
					}
				}
			case .rotate(let angle):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.rotation = Rotation(angle: angle, x: 0, y: 0, z: 1)
					} else {
						transform.to.rotation = Rotation(angle: angle, x: 0, y: 0, z: 1)
					}
				}
			case .rotateX(let angle):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.rotation = Rotation(angle: angle, x: 1, y: 0, z: 0)
					} else {
						transform.to.rotation = Rotation(angle: angle, x: 1, y: 0, z: 0)
					}
				}
			case .rotateY(let angle):
				if let transform = propObj as? TransformProperty {
					if mode == .from {
						transform.from.rotation = Rotation(angle: angle, x: 0, y: 1, z: 0)
					} else {
						transform.to.rotation = Rotation(angle: angle, x: 0, y: 1, z: 0)
					}
				}
			case .alpha(let alpha):
				if let currentAlpha = propObj as? ValueProperty {
					if mode == .from {
						currentAlpha.from = alpha
					} else {
						currentAlpha.to = alpha
					}
				}
			case .backgroundColor(let color):
				if let currentColor = propObj as? ColorProperty {
					if mode == .from {
						currentColor.from = color
					} else {
						currentColor.to = color
					}
				}
			case .fillColor(let color):
				if let currentColor = propObj as? ColorProperty {
					if mode == .from {
						currentColor.from = color
					} else {
						currentColor.to = color
					}
				}
			case .strokeColor(let color):
				if let currentColor = propObj as? ColorProperty {
					if mode == .from {
						currentColor.from = color
					} else {
						currentColor.to = color
					}
				}
			case .tintColor(let color):
				if let currentColor = propObj as? ColorProperty {
					if mode == .from {
						currentColor.from = color
					} else {
						currentColor.to = color
					}
				}
			case .keyPath(_, let value):
				if let custom = propObj as? ObjectProperty {
					if mode == .from {
						custom.from = value
					} else {
						custom.to = value
					}
				}
			default:
				if let _ = target {
					
				}
			}
			
			if let transform = propObj as? TransformProperty {
				transform.addProp(prop, mode: mode)
			}
		}
		
		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, let y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, let origin = tweenObject.origin {
			let prop = PointProperty(target: tweenObject, from: origin, to: origin)
			prop.from = CGPoint(x: x.from, y: y.from)
			prop.to = CGPoint(x: x.to, y: y.to)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete x and y properties from cache
			propertiesByType[PropertyKey.X.rawValue] = nil
			propertiesByType[PropertyKey.Y.rawValue] = nil
		}
		
		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, let centerY = propertiesByType[PropertyKey.CenterY.rawValue] as? StructProperty, let frame = tweenObject.frame {
			let offset: CGFloat = frame.height / 2
			let prop = PointProperty(target: tweenObject, from: frame.origin, to: frame.origin)
			prop.from = CGPoint(x: x.from, y: centerY.from - offset)
			prop.to = CGPoint(x: x.to, y: centerY.to - offset)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete x and center.y properties from cache
			propertiesByType[PropertyKey.X.rawValue] = nil
			propertiesByType[PropertyKey.CenterY.rawValue] = nil
		}
		if let centerX = propertiesByType[PropertyKey.CenterX.rawValue] as? StructProperty, let y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, let frame = tweenObject.frame {
			let offset: CGFloat = frame.width / 2
			let prop = PointProperty(target: tweenObject, from: frame.origin, to: frame.origin)
			prop.from = CGPoint(x: centerX.from - offset, y: y.from)
			prop.to = CGPoint(x: centerX.to - offset, y: y.to)
			propertiesByType[PropertyKey.Position.rawValue] = prop
			
			// delete center.x and y properties from cache
			propertiesByType[PropertyKey.CenterX.rawValue] = nil
			propertiesByType[PropertyKey.Y.rawValue] = nil
		}
		
		// if we have both a SizeProperty and PositionProperty, merge them into a single FrameProperty
		if let size = propertiesByType[PropertyKey.Size.rawValue] as? SizeProperty, let origin = propertiesByType[PropertyKey.Position.rawValue] as? PointProperty, let frame = tweenObject.frame {
			let prop = RectProperty(target: tweenObject, from: frame, to: frame)
			prop.from = CGRect(origin: origin.from, size: size.from)
			prop.to = CGRect(origin: origin.to, size: size.to)
			propertiesByType[PropertyKey.Frame.rawValue] = prop
			
			// delete size and position properties from cache
			propertiesByType[PropertyKey.Size.rawValue] = nil
			propertiesByType[PropertyKey.Position.rawValue] = nil
		}
	}
	
	fileprivate func propertyForType(_ type: Property) -> TweenProperty? {
		if let key = TweenUtils.propertyKeyForType(type) {
			var prop = propertiesByType[key]
			
			if prop == nil {
				switch key {
				case PropertyKey.Position.rawValue:
					if let origin = tweenObject.origin {
						prop = PointProperty(target: tweenObject, from: origin, to: origin)
					} else {
						assert(false, "Cannot tween non-existent property `origin` for target.")
					}
				case PropertyKey.Center.rawValue:
					if let center = tweenObject.center {
						prop = PointProperty(target: tweenObject, from: center, to: center)
						if let pointProp = prop as? PointProperty {
							pointProp.targetCenter = true
						}
					} else {
						assert(false, "Cannot tween non-existent property `center` for target.")
					}
				case PropertyKey.Size.rawValue:
					if let size = tweenObject.size {
						prop = SizeProperty(target: tweenObject, from: size, to: size)
					} else {
						assert(false, "Cannot tween non-existent property `size` for target.")
					}
				case PropertyKey.Transform.rawValue:
					prop = TransformProperty(target: tweenObject)
				case PropertyKey.Alpha.rawValue:
					if let alpha = tweenObject.alpha {
						let key = (target is CALayer) ? "opacity" : "alpha"
						prop = ObjectProperty(target: tweenObject, keyPath: key, from: alpha, to: alpha)
					} else {
						assert(false, "Cannot tween non-existent property `alpha` for target.")
					}
				case PropertyKey.BackgroundColor.rawValue:
					if let color = tweenObject.backgroundColor {
						prop = ColorProperty(target: tweenObject, property: "backgroundColor", from: color, to: color)
					} else {
						assert(false, "Cannot tween property `backgroundColor`, initial value for object is nil.")
					}
				case PropertyKey.FillColor.rawValue:
					if let color = tweenObject.fillColor {
						prop = ColorProperty(target: tweenObject, property: "fillColor", from: color, to: color)
					} else {
						assert(false, "Cannot tween property `fillColor`, initial value for object is nil.")
					}
				case PropertyKey.StrokeColor.rawValue:
					if let color = tweenObject.strokeColor {
						prop = ColorProperty(target: tweenObject, property: "strokeColor", from: color, to: color)
					} else {
						assert(false, "Cannot tween property `strokeColor`, initial value for object is nil.")
					}
				case PropertyKey.TintColor.rawValue:
					if let color = tweenObject.tintColor {
						prop = ColorProperty(target: tweenObject, property: "tintColor", from: color, to: color)
					} else {
						assert(false, "Cannot tween property `tintColor`, initial value for object is nil.")
					}
				case PropertyKey.X.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.minX
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				case PropertyKey.Y.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.minY
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				case PropertyKey.CenterX.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.midX
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				case PropertyKey.CenterY.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.midY
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				case PropertyKey.Width.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.width
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				case PropertyKey.Height.rawValue:
					if let frame = tweenObject.frame {
						let value = frame.height
						prop = StructProperty(target: tweenObject, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `frame` for target.")
					}
				default:
					if let target = tweenObject.target, let value = target.value(forKeyPath: key) as? CGFloat {
						prop = ObjectProperty(target: tweenObject, keyPath: key, from: value, to: value)
					} else {
						assert(false, "Cannot tween non-existent property `\(key)` for target.")
					}
				}
				
				prop?.property = type
				propertiesByType[key] = prop
			}
			
			return prop
		}
		
		return nil
	}
	
	fileprivate func transformProperties() -> [String: TransformProperty] {
		var transforms = [String: TransformProperty]()
		
		for (key, prop) in propertiesByType {
			if let t = prop as? TransformProperty {
				transforms[key] = t
			}
		}
		
		return transforms
	}
}
