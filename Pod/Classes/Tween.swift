//
//  Tween.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public enum AnchorPoint {
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

public enum TweenMode {
	case to
	case from
	case fromTo
}

public protocol Tweener {
	associatedtype TweenType
	
	var antialiasing: Bool { get set }
	weak var timeline: Timeline? { get set }
	
	func from(_ props: TweenProp...) -> TweenType
	func to(_ props: TweenProp...) -> TweenType
	
	func ease(_ easing: Easing.EasingType) -> TweenType
	func spring(tension: Double, friction: Double) -> TweenType
	func perspective(_ value: CGFloat) -> TweenType
	func anchor(_ anchor: AnchorPoint) -> TweenType
	func anchorPoint(_ point: CGPoint) -> TweenType
}

open class Tween: Animation, Tweener {
	public typealias TweenType = Tween
	public typealias AnimationType = Tween
	
	open var target: NSObject? {
		get {
			return tweenObject.target
		}
	}
	open var antialiasing: Bool {
		get {
			return tweenObject.antialiasing
		}
		set(newValue) {
			tweenObject.antialiasing = newValue
		}
	}
	override open var duration: CFTimeInterval {
		didSet {
//			for prop in properties {
//				prop.duration = duration
//			}
		}
	}
	override open var totalTime: CFTimeInterval {
		get {
			return (elapsed - delay - staggerDelay)
		}
	}
	open weak var timeline: Timeline?
	
//	var properties: [TweenProperty] {
//		get {
//			return [TweenProperty](propertiesByType.values)
//		}
//	}
	
	var newProperties: [FromToValue] {
		get {
			return [FromToValue](newPropertiesByType.values)
		}
	}
	fileprivate var newPropertiesByType: Dictionary<String, FromToValue> = [String: FromToValue]()
	fileprivate var animators = [String: Animator]()
	
	
	
	var tweenObject: TweenObject
	fileprivate var timingFunction: TimingFunctionType = LinearTimingFunction()
	fileprivate var timeScale: Float = 1
	fileprivate var staggerDelay: CFTimeInterval = 0
//	private var propertiesByType: Dictionary<String, TweenProperty> = [String: TweenProperty]()
	fileprivate var needsPropertyPrep = false
	fileprivate var spring: Spring?

	
	// MARK: Lifecycle
	
//	required public init(target: NSObject, from: [Property]?, to: [Property]?, mode: TweenMode = .To) {
//		self.tweenObject = TweenObject(target: target)
//		super.init()
//		
//		Scheduler.sharedInstance.cache(self, target: target)
//		prepare(from: from, to: to, mode: mode)
//	}
	
	required public init(target: NSObject) {
		self.tweenObject = TweenObject(target: target)
		super.init()
		
		Scheduler.sharedInstance.cache(self, target: target)
	}
	
	deinit {
		kill()
		newPropertiesByType.removeAll()
//		propertiesByType.removeAll()
		tweenObject.target = nil
	}
	
	// MARK: Animation Overrides
	
	override open func duration(_ duration: CFTimeInterval) -> Tween {
		super.duration(duration)
		
//		for prop in properties {
//			prop.duration = duration
//		}
		return self
	}
	
	override open func delay(_ delay: CFTimeInterval) -> Tween {
		super.delay(delay)
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	override open func restart(_ includeDelay: Bool = false) {
		super.restart(includeDelay)
		
//		for prop in properties {
//			prop.reset()
//			prop.calc()
//		}
		run()
	}
	
	override open func kill() {
		super.kill()
		
		Scheduler.sharedInstance.remove(self)
		if let target = target {
			Scheduler.sharedInstance.removeFromCache(self, target: target)
		}
	}
	
	// MARK: Tweenable
	
	open func fromTest(_ props: TweenProp...) -> Tween {
		for prop in props {
			var value = newPropertiesByType[prop.key]
			if value == nil {
//				var v = FromToValue()
//				
//				if let position = tweenObject.position where prop is Position {
//					v.from = position
//				}
//				
//				value = v
//				newPropertiesByType[prop.key] = v
				value = FromToValue()
			}
//			value?.from.apply(prop)
			value?.from = prop
			newPropertiesByType[prop.key] = value
		}
		return self
	}
	
	open func toTest(_ props: TweenProp...) -> Tween {
		for prop in props {
			var value = newPropertiesByType[prop.key]
			if value == nil {
//				var v = FromToValue()
//				
//				if let position = tweenObject.position where prop is Position {
//					v.to = position
//				}
//				
//				value = v
				value = FromToValue()
			}
			value?.to = prop
//			value?.to.apply(prop)
			newPropertiesByType[prop.key] = value
		}
		return self
	}
	
	open func from(_ props: TweenProp...) -> Tween {
		return from(props )
	}
	
	open func to(_ props: TweenProp...) -> Tween {
		return to(props )
	}
	
	// internal `from` and `to` methods that support a single array of Property types since we can't forward variadic arguments
	func from(_ props: [TweenProp]) -> Tween {
//		prepare(from: props, to: nil, mode: .From)
		for prop in props {
			add(prop, mode: .from)
		}
		return self
	}
	
	func to(_ props: [TweenProp]) -> Tween {
//		prepare(from: nil, to: props, mode: .To)
		for prop in props {
			add(prop, mode: .to)
		}
		return self
	}
	
	open func ease(_ easing: Easing.EasingType) -> Tween {
		timingFunction = Easing(easing)
//		for prop in properties {
//			prop.easing = easing
//		}
		return self
	}
	
	open func spring(tension: Double, friction: Double = 3) -> Tween {
		spring = Spring(tension: tension, friction: friction)
//		for prop in properties {
//			prop.spring = Spring(tension: tension, friction: friction)
//		}
		return self
	}
	
	open func perspective(_ value: CGFloat) -> Tween {
		tweenObject.perspective = value
		return self
	}
	
	open func anchor(_ anchor: AnchorPoint) -> Tween {
		return anchorPoint(anchor.point())
	}
	
	open func anchorPoint(_ point: CGPoint) -> Tween {
		tweenObject.anchorPoint = point
		return self
	}
	
	open func stagger(_ offset: CFTimeInterval) -> Tween {
		staggerDelay = offset
		
		if timeline == nil {
			startTime = delay + staggerDelay
		}
		
		return self
	}
	
	open func timeScale(_ scale: Float) -> Tween {
		timeScale = scale
		return self
	}
	
	override open func play() -> Tween {
		guard !active else { return self }
		
		super.play()
		
		if let target = target {
			Scheduler.sharedInstance.cache(self, target: target)
		}
		
		for (key, animator) in animators {
			animator.reset()
		}
		
		// properties must be sorted so that the first in the array is the transform property, if exists
		// so that each property afterwards isn't set with a transform in place
//		for prop in TweenUtils.sortProperties(properties).reverse() {
//			prop.reset()
//			prop.calc()
//			
//			if prop.mode == .From || prop.mode == .FromTo {
//				prop.seek(0)
//			}
//		}
		run()
		
		return self
	}
	
	override open func resume() {
		super.resume()
		if !running {
			run()
		}
	}
	
	override open func reverse() -> Tween {
		super.reverse()
		run()
		
		return self
	}
	
	override open func forward() -> Tween {
		super.forward()
		run()
		
		return self
	}
	
	override open func seek(_ time: CFTimeInterval) -> Tween {
		super.seek(time)
		
		let elapsedTime = elapsedTimeFromSeekTime(time)
		elapsed = delay + staggerDelay + elapsedTime
		
		setupAnimatorsIfNeeded()
		
		for (key, animator) in animators {
			animator.seek(elapsedTime)
		}
		
//		for prop in TweenUtils.sortProperties(properties).reverse() {
//			if needsPropertyPrep {
//				prop.prepare()
//			}
//			prop.seek(elapsedTime)
//		}
//		needsPropertyPrep = false
		
		return self
	}
	
//	public func updateTo(options: [Property], restart: Bool = false) {
//		
//	}
	
	// MARK: Private Methods
	
	fileprivate func add(_ prop: TweenProp, mode: TweenMode) {
		var value = newPropertiesByType[prop.key] ?? FromToValue()
		
		if mode == .from {
			value.from = prop
		} else {
			value.to = prop
		}
		
		newPropertiesByType[prop.key] = value
	}
	
//	private func prepare(from from: [Property]?, to: [Property]?, mode: TweenMode) {
//		guard let _ = target else { return }
//		
//		var tweenMode = mode
//		// use .FromTo mode if passed `mode` is .To and we already have properties setup
//		if tweenMode == .To && propertiesByType.count > 0 {
//			tweenMode = .FromTo
//		}
//		
////		if let from = from {
////			setupProperties(from, mode: .From)
////		}
////		if let to = to {
////			setupProperties(to, mode: .To)
////		}
//		
//		needsPropertyPrep = true
//		for (_, prop) in propertiesByType {
//			prop.mode = tweenMode
//			prop.reset()
//			prop.calc()
//			
//			if prop.mode == .From || prop.mode == .FromTo {
//				if needsPropertyPrep {
//					prop.prepare()
//				}
//				prop.seek(0)
//				needsPropertyPrep = false
//			}
//		}
//	}
	
	override func advance(_ time: Double) -> Bool {
//		print("Tween.advance() - id: \(id), running: \(running), paused: \(paused), startTime: \(startTime)")
		if target == nil || !running {
			return false
		}
		if paused {
			return false
		}
		if newProperties.count == 0 {
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
		elapsed = max(0, min(elapsed + (time * multiplier), end))
		runningTime += time
//		print("Tween.advance() - time: \(runningTime), elapsed: \(elapsed)")
		
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
		
		setupAnimatorsIfNeeded()
		
		var done = true
		for (key, animator) in animators {
			animator.advance(time * multiplier)
			if !animator.finished {
				done = false
			}
		}
		
//		for (key, prop) in newPropertiesByType {
////			print("\(key): \(prop)")
//			var animator = animators[key]
//			
//			if animator == nil {
//				var from: TweenProp?
//				var to: TweenProp?
//				var type = prop.to ?? prop.from
//				
//				if let type = type, value = tweenObject.currentValueForTweenProp(type) {
//					from = value
//					to = value
//					
//					if let tweenFrom = prop.from {
//						from?.apply(tweenFrom)
//					}
//					if let tweenTo = prop.to {
//						to?.apply(tweenTo)
//					}
//				}
//				
////				print("ANIMATE - from: \(from), to: \(to)")
//				
//				if let from = from, to = to {
//					animator = BasicAnimator(from: from, to: to, duration: duration, timingFunction: timingFunction)
//					animator?.onChange({ [unowned self] (animator, value) in
////						print("changed: \(value)")
//						self.tweenObject.update(value)
//					})
//					animators[key] = animator
////					print("setting animator for key: \(key)")
//				}
//			}
//			
//			if let animator = animator {
//				animator.advance(time * multiplier)
//				if !animator.finished {
//					done = false
//				}
//			} else {
//				print("No animator found for property \(prop)")
//			}
//		}
		updateBlock?(self)
//		print("...done: \(done)")
		
		if done {
			return completed()
		}
		return false
	}
	
//	override func proceed(dt: CFTimeInterval, force: Bool = false) -> Bool {
//		return advance(dt)
//		
//		if target == nil || !running {
//			return true
//		}
//		if paused {
//			return false
//		}
//		if properties.count == 0 {
//			return true
//		}
//		
//		// if tween belongs to a timeline, don't start animating until the timeline's playhead reaches the tween's startTime
//		if let timeline = timeline {
//			if (!timeline.reversed && timeline.time() < startTime) || (timeline.reversed && timeline.time() > endTime) {
//				return false
//			}
//		}
//		
//		let end = delay + duration
//		let multiplier: CFTimeInterval = reversed ? -1 : 1
//		elapsed = min(elapsed + (dt * multiplier), end)
//		runningTime += dt
//		
//		if elapsed < 0 {
//			elapsed = 0
//		}
//		
//		let delayOffset = delay + staggerDelay + repeatDelay
//		if timeline == nil {
//			if elapsed < delayOffset {
//				// if direction is reversed, then don't allow playhead to go below the tween's delay and call completed handler
//				if reversed {
//					completed()
//				} else {
//					return false
//				}
//			}
//		}
//		
//		// now we can finally animate
//		if !animating {
//			started()
//		}
//		
//		// proceed each property
//		var done = false
//		for prop in properties {
//			if needsPropertyPrep {
//				prop.prepare()
//			}
//			if prop.proceed(dt * multiplier, reversed: reversed) {
//				done = true
//			}
//		}
//		needsPropertyPrep = false
//		updateBlock?(self)
//		
//		if done {
//			return completed()
//		}
//		
//		return false
//	}
	
//	func storedPropertyForType(type: Property) -> TweenProperty? {
//		if let key = type.key() {
//			return propertiesByType[key]
//		}
//		return nil
//	}
	
	// MARK: Private Methods
	
	fileprivate func run() {
		running = true
		Scheduler.sharedInstance.add(self)
	}
	
	fileprivate func setupAnimatorsIfNeeded() {
		var transformFrom = Transform.zero
		var transformTo = Transform.zero
		
		if let transform = tweenObject.transform {
			transformFrom = Transform(transform)
			transformTo = Transform(transform)
		}
		
		var tweenedProps = [String: TweenProp]()
		for (key, prop) in newPropertiesByType {
			var animator = animators[key]
			
			if animator == nil {
				print("--------- tween.id: \(id) ------------")
				var from: TweenProp?
				var to: TweenProp?
				var type = prop.to ?? prop.from
				
				if let type = type, let value = tweenObject.currentValueForTweenProp(type) {
					from = value
					to = value
					
					if let tweenFrom = prop.from {
//						print("applying tweenFrom: \(tweenFrom)")
						from?.apply(tweenFrom)
					} else if let previousTo = tweenedProps[key] {
						from = previousTo
//						print("no `from` value, using prevous tweened value \(previousTo)")
					}
					
					if let tweenTo = prop.to {
//						print("applying tweenTo: \(tweenTo)")
						to?.apply(tweenTo)
					}
					
					// need to update axes which are to be animated based on destination value
					if type is Rotation {
						if var _from = from as? Rotation, var _to = to as? Rotation, let tweenTo = prop.to as? Rotation {
							_to.applyAxes(tweenTo)
							_from.applyAxes(tweenTo)
							from = _from
							to = _to
						}
					}
					
					tweenedProps[key] = to
				}
				print(tweenedProps)				
				print("ANIMATE - from: \(from), to: \(to)")
				
				if let from = from, let to = to {
					if let from = from as? TransformType, let to = to as? TransformType {
						transformFrom.apply(from)
						transformTo.apply(to)
						print("updating transform properties...")
					} else {
						let basicAnimator = BasicAnimator(from: from, to: to, duration: duration, timingFunction: timingFunction)
						basicAnimator.spring = spring
						basicAnimator.onChange({ [unowned self] (animator, value) in
							self.tweenObject.update(value)
						})
						animator = basicAnimator
						animators[key] = basicAnimator
						print("setting animator for key: \(key)")
					}
				} else {
					print("Could not create animator for property \(prop)")
				}
			}
		}
		
		if transformFrom != Transform.zero || transformTo != Transform.zero {
			let key = "transform"
			if animators[key] == nil {
//				print("ANIMATE - transform - from: \(transformFrom), to: \(transformTo)")
				let animator = TransformAnimator(from: transformFrom, to: transformTo, duration: duration, timingFunction: timingFunction)
				animator.spring = spring
				animator.onChange({ [weak self] (animator, transform) in
					if let target = self?.tweenObject {
						transform.applyTo(target)
					}
				})
				animators[key] = animator
			}
		}
		
	}
	
//	private func setupProperties(props: [Property], mode: TweenMode) {
//		for prop in props {
//			let propObj = propertyForType(prop)
//			propObj?.mode = mode
//			
//			switch prop {
//			case .X(let x):
//				if let point = propObj as? StructProperty {
//					if mode == .From {
//						point.from = x
//					} else {
//						point.to = x
//					}
//				}
//			case .Y(let y):
//				if let point = propObj as? StructProperty {
//					if mode == .From {
//						point.from = y
//					} else {
//						point.to = y
//					}
//				}
//			case .Position(let x, let y):
//				if let point = propObj as? PointProperty {
//					if mode == .From {
//						point.from = CGPoint(x: x, y: y)
//					} else {
//						point.to = CGPoint(x: x, y: y)
//					}
//				}
//			case .CenterX(let x):
//				if let point = propObj as? StructProperty {
//					if mode == .From {
//						point.from = x
//					} else {
//						point.to = x
//					}
//				}
//			case .CenterY(let y):
//				if let point = propObj as? StructProperty {
//					if mode == .From {
//						point.from = y
//					} else {
//						point.to = y
//					}
//				}
//			case .Center(let x, let y):
//				if let point = propObj as? PointProperty {
//					point.targetCenter = true
//					if mode == .From {
//						point.from = CGPoint(x: x, y: y)
//					} else {
//						point.to = CGPoint(x: x, y: y)
//					}
//				}
//			case .Shift(let shiftX, let shiftY):
//				if let point = propObj as? PointProperty, position = tweenObject.origin {
//					if mode == .From {
//						point.from.x = position.x + shiftX
//						point.from.y = position.y + shiftY
//					} else {
//						point.to.x = position.x + shiftX
//						point.to.y = position.y + shiftY
//					}
//				}
//			case .Width(let width):
//				if let size = propObj as? StructProperty {
//					if mode == .From {
//						size.from = width
//					} else {
//						size.to = width
//					}
//				}
//			case .Height(let height):
//				if let size = propObj as? StructProperty {
//					if mode == .From {
//						size.from = height
//					} else {
//						size.to = height
//					}
//				}
//			case .Size(let width, let height):
//				if let size = propObj as? SizeProperty {
//					if mode == .From {
//						size.from = CGSize(width: width, height: height)
//					} else {
//						size.to = CGSize(width: width, height: height)
//					}
//				}
//			case .Translate(let shiftX, let shiftY):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.translation = Translation(x: shiftX, y: shiftY)
//					} else {
//						transform.to.translation = Translation(x: shiftX, y: shiftY)
//					}
//				}
//			case .Scale(let scale):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.scale = Scale(x: scale, y: scale, z: 1)
//					} else {
//						transform.to.scale = Scale(x: scale, y: scale, z: 1)
//					}
//				}
//			case .ScaleXY(let scaleX, let scaleY):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.scale = Scale(x: scaleX, y: scaleY, z: 1)
//					} else {
//						transform.to.scale = Scale(x: scaleX, y: scaleY, z: 1)
//					}
//				}
//			case .Rotate(let angle):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.rotation = Rotation(angle: angle, x: 0, y: 0, z: 1)
//					} else {
//						transform.to.rotation = Rotation(angle: angle, x: 0, y: 0, z: 1)
//					}
//				}
//			case .RotateX(let angle):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.rotation = Rotation(angle: angle, x: 1, y: 0, z: 0)
//					} else {
//						transform.to.rotation = Rotation(angle: angle, x: 1, y: 0, z: 0)
//					}
//				}
//			case .RotateY(let angle):
//				if let transform = propObj as? TransformProperty {
//					if mode == .From {
//						transform.from.rotation = Rotation(angle: angle, x: 0, y: 1, z: 0)
//					} else {
//						transform.to.rotation = Rotation(angle: angle, x: 0, y: 1, z: 0)
//					}
//				}
//			case .Alpha(let alpha):
//				if let currentAlpha = propObj as? ValueProperty {
//					if mode == .From {
//						currentAlpha.from = alpha
//					} else {
//						currentAlpha.to = alpha
//					}
//				}
//			case .BackgroundColor(let color):
//				if let currentColor = propObj as? ColorProperty {
//					if mode == .From {
//						currentColor.from = color
//					} else {
//						currentColor.to = color
//					}
//				}
//			case .FillColor(let color):
//				if let currentColor = propObj as? ColorProperty {
//					if mode == .From {
//						currentColor.from = color
//					} else {
//						currentColor.to = color
//					}
//				}
//			case .StrokeColor(let color):
//				if let currentColor = propObj as? ColorProperty {
//					if mode == .From {
//						currentColor.from = color
//					} else {
//						currentColor.to = color
//					}
//				}
//			case .TintColor(let color):
//				if let currentColor = propObj as? ColorProperty {
//					if mode == .From {
//						currentColor.from = color
//					} else {
//						currentColor.to = color
//					}
//				}
//			case .KeyPath(_, let value):
//				if let custom = propObj as? ObjectProperty {
//					if mode == .From {
//						custom.from = value
//					} else {
//						custom.to = value
//					}
//				}
//			default:
//				if let _ = target {
//					
//				}
//			}
//			
//			if let transform = propObj as? TransformProperty {
//				transform.addProp(prop, mode: mode)
//			}
//		}
//		
//		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, origin = tweenObject.origin {
//			let prop = PointProperty(target: tweenObject, from: origin, to: origin)
//			prop.from = CGPoint(x: x.from, y: y.from)
//			prop.to = CGPoint(x: x.to, y: y.to)
//			propertiesByType[PropertyKey.Position.rawValue] = prop
//			
//			// delete x and y properties from cache
//			propertiesByType[PropertyKey.X.rawValue] = nil
//			propertiesByType[PropertyKey.Y.rawValue] = nil
//		}
//		
//		if let x = propertiesByType[PropertyKey.X.rawValue] as? StructProperty, centerY = propertiesByType[PropertyKey.CenterY.rawValue] as? StructProperty, frame = tweenObject.frame {
//			let offset: CGFloat = frame.height / 2
//			let prop = PointProperty(target: tweenObject, from: frame.origin, to: frame.origin)
//			prop.from = CGPoint(x: x.from, y: centerY.from - offset)
//			prop.to = CGPoint(x: x.to, y: centerY.to - offset)
//			propertiesByType[PropertyKey.Position.rawValue] = prop
//			
//			// delete x and center.y properties from cache
//			propertiesByType[PropertyKey.X.rawValue] = nil
//			propertiesByType[PropertyKey.CenterY.rawValue] = nil
//		}
//		if let centerX = propertiesByType[PropertyKey.CenterX.rawValue] as? StructProperty, y = propertiesByType[PropertyKey.Y.rawValue] as? StructProperty, frame = tweenObject.frame {
//			let offset: CGFloat = frame.width / 2
//			let prop = PointProperty(target: tweenObject, from: frame.origin, to: frame.origin)
//			prop.from = CGPoint(x: centerX.from - offset, y: y.from)
//			prop.to = CGPoint(x: centerX.to - offset, y: y.to)
//			propertiesByType[PropertyKey.Position.rawValue] = prop
//			
//			// delete center.x and y properties from cache
//			propertiesByType[PropertyKey.CenterX.rawValue] = nil
//			propertiesByType[PropertyKey.Y.rawValue] = nil
//		}
//		
//		// if we have both a SizeProperty and PositionProperty, merge them into a single FrameProperty
//		if let size = propertiesByType[PropertyKey.Size.rawValue] as? SizeProperty, origin = propertiesByType[PropertyKey.Position.rawValue] as? PointProperty, frame = tweenObject.frame {
//			let prop = RectProperty(target: tweenObject, from: frame, to: frame)
//			prop.from = CGRect(origin: origin.from, size: size.from)
//			prop.to = CGRect(origin: origin.to, size: size.to)
//			propertiesByType[PropertyKey.Frame.rawValue] = prop
//			
//			// delete size and position properties from cache
//			propertiesByType[PropertyKey.Size.rawValue] = nil
//			propertiesByType[PropertyKey.Position.rawValue] = nil
//		}
//	}
//	
//	private func propertyForType(type: Property) -> TweenProperty? {
//		if let key = type.key() {
//			var prop = propertiesByType[key]
//			
//			if prop == nil {
//				switch type {
//				case .Position:
//					if let origin = tweenObject.origin {
//						prop = PointProperty(target: tweenObject, from: origin, to: origin)
//					} else {
//						assert(false, "Cannot tween non-existent property `origin` for target.")
//					}
//				case .Center:
//					if let center = tweenObject.center {
//						prop = PointProperty(target: tweenObject, from: center, to: center)
//						if let pointProp = prop as? PointProperty {
//							pointProp.targetCenter = true
//						}
//					} else {
//						assert(false, "Cannot tween non-existent property `center` for target.")
//					}
//				case .Size:
//					if let size = tweenObject.size {
//						prop = SizeProperty(target: tweenObject, from: size, to: size)
//					} else {
//						assert(false, "Cannot tween non-existent property `size` for target.")
//					}
//				case .Transform, .Translate, .Scale, .ScaleXY, .Rotate, .RotateX, .RotateY:
//					prop = TransformProperty(target: tweenObject)
//				case .Alpha:
//					if let alpha = tweenObject.alpha {
//						let key = (target is CALayer) ? "opacity" : "alpha"
//						prop = ObjectProperty(target: tweenObject, keyPath: key, from: alpha, to: alpha)
//					} else {
//						assert(false, "Cannot tween non-existent property `alpha` for target.")
//					}
//				case .BackgroundColor:
//					if let color = tweenObject.backgroundColor {
//						prop = ColorProperty(target: tweenObject, property: "backgroundColor", from: color, to: color)
//					} else {
//						assert(false, "Cannot tween property `backgroundColor`, initial value for object is nil.")
//					}
//				case .FillColor:
//					if let color = tweenObject.fillColor {
//						prop = ColorProperty(target: tweenObject, property: "fillColor", from: color, to: color)
//					} else {
//						assert(false, "Cannot tween property `fillColor`, initial value for object is nil.")
//					}
//				case .StrokeColor:
//					if let color = tweenObject.strokeColor {
//						prop = ColorProperty(target: tweenObject, property: "strokeColor", from: color, to: color)
//					} else {
//						assert(false, "Cannot tween property `strokeColor`, initial value for object is nil.")
//					}
//				case .TintColor:
//					if let color = tweenObject.tintColor {
//						prop = ColorProperty(target: tweenObject, property: "tintColor", from: color, to: color)
//					} else {
//						assert(false, "Cannot tween property `tintColor`, initial value for object is nil.")
//					}
//				case .X:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetMinX(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				case .Y:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetMinY(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				case .CenterX:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetMidX(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				case .CenterY:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetMidY(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				case .Width:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetWidth(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				case .Height:
//					if let frame = tweenObject.frame {
//						let value = CGRectGetHeight(frame)
//						prop = StructProperty(target: tweenObject, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `frame` for target.")
//					}
//				default:
//					if let target = tweenObject.target, value = target.valueForKeyPath(key) as? CGFloat {
//						prop = ObjectProperty(target: tweenObject, keyPath: key, from: value, to: value)
//					} else {
//						assert(false, "Cannot tween non-existent property `\(key)` for target.")
//					}
//				}
//				
//				prop?.property = type
//				propertiesByType[key] = prop
//			}
//			
//			return prop
//		}
//		
//		return nil
//	}
//	
//	private func transformProperties() -> [String: TransformProperty] {
//		var transforms = [String: TransformProperty]()
//		
//		for (key, prop) in propertiesByType {
//			if let t = prop as? TransformProperty {
//				transforms[key] = t
//			}
//		}
//		
//		return transforms
//	}
}
