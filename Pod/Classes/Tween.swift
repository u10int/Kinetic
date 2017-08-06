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

public class Tween: Animation {
	private(set) public var target: Tweenable
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
	override public var totalTime: TimeInterval {
		return (elapsed - delay)
	}
	public weak var timeline: Timeline?
	
	internal var properties: [FromToValue] {
		return [FromToValue](propertiesByType.values)
	}
	fileprivate var propertiesByType: Dictionary<String, FromToValue> = [String: FromToValue]()
	private(set) var animators = [String: Animator]()
	
//	fileprivate var timeScale: Float = 1
	fileprivate var needsPropertyPrep = false
	
	public var additive = true;
	
	// MARK: Lifecycle
	
	required public init(target: Tweenable) {
		self.target = target
		super.init()
		
		TweenCache.session.cache(self, target: target)
	}
	
	deinit {
		propertiesByType.removeAll()
	}
	
	// MARK: Tween
	
	@discardableResult
	public func from(_ props: Property...) -> Tween {
		return from(props)
	}
	
	@discardableResult
	public func to(_ props: Property...) -> Tween {
		return to(props)
	}
	
	@discardableResult
	public func along(_ path: InterpolatablePath) -> Tween {
		add(Path(path), mode: .to)
		return self
	}
	
	// internal `from` and `to` methods that support a single array of Property types since we can't forward variadic arguments
	@discardableResult
	internal func from(_ props: [Property]) -> Tween {
		props.forEach { (prop) in
			add(prop, mode: .from)
		}
		return self
	}
	
	@discardableResult
	internal func to(_ props: [Property]) -> Tween {
		props.forEach { (prop) in
			add(prop, mode: .to)
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
	
	// MARK: Animation
	
	override public var timingFunction: TimingFunctionType {
		didSet {
			animators.forEach { (_, animator) in
				animator.timingFunction = timingFunction
			}
		}
	}
	override public var spring: Spring? {
		didSet {
			animators.forEach { (_, animator) in
				animator.spring = spring
			}
		}
	}
	
	@discardableResult
	override public func delay(_ delay: CFTimeInterval) -> Tween {
		super.delay(delay)
		
		if timeline == nil {
			startTime = delay
		}
		
		return self
	}
	
	override public func kill() {
		super.kill()
		
		let keys = propertiesByType.map { return $0.key }
		TweenCache.session.removeActiveKeys(keys: keys, ofTarget: target)
		TweenCache.session.removeFromCache(self, target: target)
	}
	
	override public func play() {
		guard state != .running && state != .cancelled else { return }
		
		TweenCache.session.cache(self, target: target)
		animators.forEach { (_, animator) in
			animator.reset()
		}
		
		super.play()
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
	
	// MARK: - Subscriber
	
	override func advance(_ time: Double) {
		guard shouldAdvance() else { return }
		
		updatesStateOnAdvance = timeline == nil
		
		if propertiesByType.count == 0 {
			return
		}
		
		// if tween belongs to a timeline, don't start animating until the timeline's playhead reaches the tween's startTime
		if let timeline = timeline {
//			if timeline.time < startTime {
//				elapsed = 0
//			} else if timeline.time > endTime {
//				elapsed = duration
//			}
			
//			print("Tween.advance() - id: \(id), timeline.time: \(timeline.time()), startTime: \(startTime), endTime: \(endTime), elapsed: \(elapsed), reversed: \(timeline.reversed)")
			if timeline.time < startTime || timeline.time > endTime {
				return
			}
		} else {
			// parent Animation class handles updating the elapsed and runningTimes accordingly
//			super.advance(time)
		}
		
//		setupAnimatorsIfNeeded()
//		
//		let multiplier: TimeInterval = direction == .reversed ? -timeScale : timeScale
//		animators.forEach { (_, animator) in
//			animator.advance(time * multiplier)
//		}
//		
//		updateBlock?(self)
		print("Tween.advance() - id: \(id), duration: \(duration), time: \(runningTime), elapsed: \(elapsed), reversed: \(direction == .reversed), progress: \(progress)")
		
		// parent Animation class handles updating the elapsed and runningTimes accordingly
		super.advance(time)
		
		let delayOffset = delay + repeatDelay
		if timeline == nil {
			if elapsed < delayOffset {
				// if direction is reversed, then don't allow playhead to go below the tween's delay and call completed handler
				if direction == .reversed {
					state = .completed
				} else {
					return
				}
			}
		}
	}
	
	override internal func canSubscribe() -> Bool {
		return timeline == nil
	}
	
	override internal func render(time: TimeInterval, advance: TimeInterval = 0) {
		super.render(time: time, advance: advance)
		
		setupAnimatorsIfNeeded()
		
//		let multiplier: TimeInterval = direction == .reversed ? -timeScale : timeScale
		animators.forEach { (_, animator) in
			animator.render(time, advance: advance)
		}
		
		updateBlock?(self)
	}
	
	override internal func isAnimationComplete() -> Bool {
		var done = true
		
		animators.forEach { (_, animator) in
			if !animator.finished {
				done = false
			}
		}
		
		return done
	}
	
	fileprivate func setupAnimatorsIfNeeded() {
		var transformFrom: Transform?
		var transformTo: Transform?
		var tweenedProps = [String: Property]()
		
		for (key, prop) in propertiesByType {
			var animator = animators[key]
			
			if animator == nil {
//				print("--------- tween.id: \(id) - animator key: \(key) ------------")
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
				
				// there's no real presentation value when animating along a path, so disable additive 
				if prop.from is Path || prop.to is Path {
					isAdditive = false
					self.additive = false
				}
				
				if let type = type, let value = target.currentProperty(for: type) {
					from = value
					to = value
					
					if let tweenFrom = prop.from {
						from?.apply(tweenFrom)
					} else if let previousTo = tweenedProps[key] {
						from = previousTo
					} else if prop.to != nil {
						let activeTweens = Scheduler.shared.activeTweenPropsForKey(key, ofTarget: target, excludingTween: self)
						if activeTweens.count > 0 {
							from = activeTweens.last?.to
						}
					}
					
					if let tweenTo = prop.to {
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
						}
					} else {
						let tweenAnimator = Animator(from: from, to: to, duration: duration, timingFunction: timingFunction)
						tweenAnimator.additive = isAdditive
						tweenAnimator.spring = spring
						tweenAnimator.setPresentation({ (prop) -> Property? in
							return self.target.currentProperty(for: prop)
						})
						tweenAnimator.onChange({ [unowned self] (animator, value) in
							if self.additive {
								// update running animator's `additive` property based on existance of other running animators for the same property
								animator.additive = TweenCache.session.hasActiveTween(forKey: animator.key, ofTarget: self.target)
							}
							self.target.apply(value)
						})
						animator = tweenAnimator
						animators[key] = tweenAnimator
					}
				} else {
					print("Could not create animator for property \(prop)")
				}
			}
		}
		
		if let transformFrom = transformFrom, let transformTo = transformTo {
			let key = "transform"
			if animators[key] == nil {
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
