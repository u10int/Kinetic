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

public enum TweenState: Equatable {
	case pending
	case running
	case cancelled
	case completed
}

public func ==(lhs: TweenState, rhs: TweenState) -> Bool {
	switch (lhs, rhs) {
	case (.pending, .pending):
		return true
	case (.running, .running):
		return true
	case (.cancelled, .cancelled):
		return true
	case (.completed, .completed):
		return true
	default:
		return false
	}
}

public protocol Tweener {
	associatedtype TweenType
	
	var antialiasing: Bool { get set }
	weak var timeline: Timeline? { get set }
	
	func from(_ props: Property...) -> TweenType
	func to(_ props: Property...) -> TweenType
	
	func ease(_ easing: Easing.EasingType) -> TweenType
	func spring(tension: Double, friction: Double) -> TweenType
	func perspective(_ value: CGFloat) -> TweenType
	func anchor(_ anchor: AnchorPoint) -> TweenType
	func anchorPoint(_ point: CGPoint) -> TweenType
}

open class Tween: Animation, Tweener {
	public typealias TweenType = Tween
	public typealias AnimationType = Tween
	
	private(set) public var target: Tweenable
	private(set) public var state: TweenState = .pending
	public var antialiasing: Bool {
		get {
			if let view = target as? ViewType {
				return view.antialiasing
			}
			return false
		}
		set(newValue) {
			if var view = target as? ViewType {
				view.antialiasing = newValue
			}
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
	
	var properties: [FromToValue] {
		get {
			return [FromToValue](propertiesByType.values)
		}
	}
	fileprivate var propertiesByType: Dictionary<String, FromToValue> = [String: FromToValue]()
	private(set) var animators = [String: Animator]()
	
	fileprivate var timingFunction: TimingFunctionType = LinearTimingFunction()
	fileprivate var timeScale: Float = 1
	fileprivate var staggerDelay: CFTimeInterval = 0
	fileprivate var needsPropertyPrep = false
	fileprivate var spring: Spring?
	
	open var additive = true;

	
	// MARK: Lifecycle
	
	required public init(target: Tweenable) {
//		self.tweenObject = TweenObject(target: target)
//		self.tweenObject = Scheduler.sharedInstance.cachedUpdater(ofTarget: target)
		self.target = target
		super.init()
		
		TweenCache.session.cache(self, target: target)
	}
	
	deinit {
		kill()
		propertiesByType.removeAll()
//		tweenObject.target = nil
	}
	
	// MARK: Animation Overrides
	
	@discardableResult
	override open func duration(_ duration: CFTimeInterval) -> Tween {
		super.duration(duration)
		
//		for prop in properties {
//			prop.duration = duration
//		}
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
		
//		for prop in properties {
//			prop.reset()
//			prop.calc()
//		}
		run()
	}
	
	override open func kill() {
		super.kill()
		
		Scheduler.sharedInstance.remove(self)
		TweenCache.session.removeFromCache(self, target: target)
		
		let keys = propertiesByType.map { return $0.key }
		TweenCache.session.removeActiveKeys(keys: keys, ofTarget: target)
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
		for prop in props {
			add(prop, mode: .from)
		}
		return self
	}
	
	@discardableResult
	func to(_ props: [Property]) -> Tween {
//		prepare(from: nil, to: props, mode: .To)
		for prop in props {
			add(prop, mode: .to)
		}
		return self
	}
	
	@discardableResult
	open func ease(_ easing: Easing.EasingType) -> Tween {
		timingFunction = Easing(easing)
//		for prop in properties {
//			prop.easing = easing
//		}
		return self
	}
	
	@discardableResult
	open func spring(tension: Double, friction: Double = 3) -> Tween {
		spring = Spring(tension: tension, friction: friction)
		for (_, animator) in animators {
			animator.spring = spring
		}
		return self
	}
	
	@discardableResult
	open func perspective(_ value: CGFloat) -> Tween {
		if var view = target as? ViewType {
			view.perspective = value
		}
		return self
	}
	
	@discardableResult
	open func anchor(_ anchor: AnchorPoint) -> Tween {
		return anchorPoint(anchor.point())
	}
	
	@discardableResult
	open func anchorPoint(_ point: CGPoint) -> Tween {
		if var view = target as? ViewType {
			view.anchorPoint = point
		}
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
		
		print("--------- tween.id: \(id) - play ------------")
		super.play()
		
		TweenCache.session.cache(self, target: target)
		
		for (_, animator) in animators {
			animator.reset()
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
		
		setupAnimatorsIfNeeded()
		
		for (_, animator) in animators {
			animator.seek(elapsedTime)
		}
		
		return self
	}
	
//	public func updateTo(options: [Property], restart: Bool = false) {
//		
//	}
	
	// MARK: Private Methods
	
	fileprivate func add(_ prop: Property, mode: TweenMode) {
		var value = propertiesByType[prop.key] ?? FromToValue()
		
		if mode == .from {
			value.from = prop
			// immediately set initial state for this property
			if var current = target.currentProperty(for: prop) {
				if value.to == nil {
					value.to = current
				}
				current.apply(prop)
				target.apply(current)
			}
		} else {
			value.to = prop
		}
		
		propertiesByType[prop.key] = value
	}
	
	override func advance(_ time: Double) -> Bool {
//		print("Tween.advance() - id: \(id), running: \(running), paused: \(paused), startTime: \(startTime)")
		if !running {
			return false
		}
		if paused {
			return false
		}
		if propertiesByType.count == 0 {
			return true
		}
		
		// if tween belongs to a timeline, don't start animating until the timeline's playhead reaches the tween's startTime
		if let timeline = timeline {
//			print("Tween.advance() - id: \(id), timeline.time: \(timeline.time()), startTime: \(startTime), endTime: \(endTime), elapsed: \(elapsed), reversed: \(timeline.reversed)")
			if timeline.time() < startTime || timeline.time() > endTime {
				return false
			}
		}
		
		let end = delay + duration
		let multiplier: CFTimeInterval = reversed ? -1 : 1
		elapsed = max(0, min(elapsed + (time * multiplier), end))
		runningTime += time
//		print("Tween.advance() - id: \(id), time: \(runningTime), elapsed: \(elapsed), reversed: \(reversed)")
		
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
		
		setupAnimatorsIfNeeded()
		
		// now we can finally animate
		if !animating {
			started()
		}
		
		var done = true
		for (_, animator) in animators {
			animator.advance(time * multiplier)
			if !animator.finished {
				done = false
			}
		}

		updateBlock?(self)
		
		if done {
			return completed()
		}
		return false
	}
	
	override func started() {
		super.started()
		state = .running
	}
	
	@discardableResult
	override func completed() -> Bool {
		let done = super.completed()
		
		if done {
			state = .completed
			kill()
		}
		
		return done
	}
	
	// MARK: Private Methods
	
	fileprivate func run() {
		running = true
		Scheduler.sharedInstance.add(self)
	}
	
	fileprivate func setupAnimatorsIfNeeded() {
		var transformFrom: Transform?
		var transformTo: Transform?
		print("setupAnimatorsIfNeeded...")
		print(animators)
		
		var tweenedProps = [String: Property]()
		for (key, prop) in propertiesByType {
			var animator = animators[key]
			
			if animator == nil {
				print("--------- tween.id: \(id) - animator key: \(key) ------------")
				var from: Property?
				var to: Property?
				let type = prop.to ?? prop.from
//				let additive = (prop.from == nil && !prop.isAutoTo)
				
				var isAdditive = self.additive
				
				// if we have any currently running animations for this same property, animation needs to be additive
				// but animation should not be additive if we have a `from` value
				if isAdditive {
					isAdditive = (prop.from != nil) ? false : TweenCache.session.hasActiveTween(forKey: key, ofTarget: target)
				}
//				print("active tween props for key \(key): \(activeTweens.count), additive: \(additive)")
				
				if let type = type, let value = target.currentProperty(for: type) {
					from = value
					to = value
					
					if let tweenFrom = prop.from {
						print("applying tweenFrom: \(tweenFrom)")
						from?.apply(tweenFrom)
					} else if let previousTo = tweenedProps[key] {
						from = previousTo
						print("no `from` value, using prevous tweened value \(previousTo)")
					} else if prop.to != nil {
						let activeTweens = Scheduler.sharedInstance.activeTweenPropsForKey(key, ofTarget: target)
						if activeTweens.count > 0 {
							from = activeTweens.last?.to
							print("no `from` value, using last active tween value \(activeTweens.last?.to)")
						}
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
//				print(tweenedProps)				
				print("ANIMATE - \(key) - from: \(from?.value.vectors), to: \(to?.value.vectors), additive: \(isAdditive)")
				
				if let from = from, let to = to {
					// update stored from/to property that other tweens may reference
					propertiesByType[key] = FromToValue(from, to)
					TweenCache.session.addActiveKeys(keys: [key], toTarget: target)
					
					if let from = from as? TransformType, let to = to as? TransformType {
						if let view = target as? ViewType {
							if transformFrom == nil && transformTo == nil {
								transformFrom = Transform(view.transform3d)
								transformTo = Transform(view.transform3d)
							}
							transformFrom?.apply(from)
							transformTo?.apply(to)
							print("updating transform properties...")
						}
					} else {
						let tweenAnimator = Animator(from: from, to: to, duration: duration, timingFunction: timingFunction)
						tweenAnimator.additive = isAdditive
						tweenAnimator.spring = spring
						tweenAnimator.setPresentation({ (prop) -> Property? in
							return self.target.currentProperty(for: prop)
						})
						tweenAnimator.onChange({ [unowned self] (animator, value) in
//							print("update: \(value)")
							if self.additive {
								// update running animator's `additive` property based on existance of other running animators for the same property
								animator.additive = TweenCache.session.hasActiveTween(forKey: animator.key, ofTarget: self.target)
							}
							self.target.apply(value)
						})
						animator = tweenAnimator
						animators[key] = tweenAnimator
						print("setting animator for key: \(key)")
					}
				} else {
					print("Could not create animator for property \(prop)")
				}
			}
		}
		
		if let transformFrom = transformFrom, let transformTo = transformTo {
			let key = "transform"
			if animators[key] == nil {
//				print("ANIMATE - transform - from: \(transformFrom), to: \(transformTo)")
				let animator = Animator(from: transformFrom, to: transformTo, duration: duration, timingFunction: timingFunction)
				animator.spring = spring
				animator.onChange({ [weak self] (animator, value) in
					self?.target.apply(value)
				})
				animators[key] = animator
			}
		}
	}
}

final internal class TweenCache {
	public static let session = TweenCache()
	
	fileprivate var tweenCache = [NSObject: [Tween]]()
	fileprivate var activeKeys = [String: Int]()
	
	fileprivate func cache(_ tween: Tween, target: Tweenable) {
		guard let obj = target as? NSObject else { assert(false, "Tween target must be of type NSObject") }
		
		if tweenCache[obj] == nil {
			tweenCache[obj] = [Tween]()
		}
		if let tweens = tweenCache[obj], tweens.contains(tween) == false {
			tweenCache[obj]?.append(tween)
		}
	}
	
	internal func removeFromCache(_ tween: Tween, target: Tweenable) {
		guard let obj = target as? NSObject else { assert(false, "Tween target must be of type NSObject") }
		
		if let tweens = tweenCache[obj] {
			if let index = tweens.index(of: tween) {
				tweenCache[obj]?.remove(at: index)
			}
			
			// remove object reference if all tweens have been removed from cache
			if tweenCache[obj]?.count == 0 {
				removeFromCache(target)
			}
		}
	}
	
	internal func removeFromCache(_ target: Tweenable) {
		guard let obj = target as? NSObject else { assert(false, "Tween target must be of type NSObject") }
		
		tweenCache[obj] = nil
	}
	
	internal func removeAllFromCache() {
		tweenCache.removeAll()
	}
	
	internal func tweens(ofTarget target: Tweenable, activeOnly: Bool = false) -> [Tween]? {
		guard let obj = target as? NSObject else { assert(false, "Tween target must be of type NSObject") }
		
		return tweenCache[obj]
	}
	
	internal func allTweens() -> [NSObject: [Tween]] {
		return tweenCache
	}
	
	fileprivate func addActiveKeys(keys: [String], toTarget target: Tweenable) {
		keys.forEach { (key) in
			var count = 1
			if let pcount = activeKeys[key] {
				count = pcount + 1
			}
			activeKeys[key] = count
		}
	}
	
	fileprivate func removeActiveKeys(keys: [String], ofTarget target: Tweenable) {
		keys.forEach { (key) in
			var count = 0
			if let pcount = activeKeys[key] {
				count = pcount - 1
			}
			if count <= 0  {
				activeKeys[key] = nil
			} else {
				activeKeys[key] = count
			}
		}
	}
	
	fileprivate func hasActiveTween(forKey key: String, ofTarget target: Tweenable) -> Bool {
		return activeKeys[key] != nil
	}
}
