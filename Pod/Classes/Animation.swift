//
//  Animation.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class Animation: Animatable, Repeatable, Reversable, Subscriber {
	fileprivate static var counter: UInt32 = 0
	public var hashValue: Int {
		return Unmanaged.passUnretained(self).toOpaque().hashValue
	}
	
	public init() {
		Animation.counter += 1
		self.id = Animation.counter
	}
	
	deinit {
		kill()
	}
	
	// MARK: Animatable
	
	public var state: AnimationState = .idle {
		willSet {
			guard newValue != state else { return }
			if newValue == .running && (state == .completed || state == .cancelled) {
				reset()
			}
		}
		didSet {
			guard oldValue != state else { return }
			//print("Animation.state changed: \(state), tween \(id)")
			switch state {
			case .pending:
				if canSubscribe() {
					Scheduler.shared.add(self)
				}
				break
			case .running:
				started.trigger(self)
//				started.close(self)
			case .idle:
				break
			case .cancelled:
				kill()
				cancelled.trigger(self)
				break
			case .completed:
//				kill()
				Scheduler.shared.remove(self)
				completed.trigger(self)
//				completed.close(self)
				break
			}
		}
	}
	public var duration: TimeInterval = 1.0 {
		didSet {
			if duration == 0 {
				duration = 0.001
			}
		}
	}
	public var delay: TimeInterval = 0
	public var timeScale: Double = 1.0
	public var progress: Double {
		get {
			return min(Double(elapsed / (delay + duration)), 1.0)
		}
		set {
			seek(duration * TimeInterval(newValue))
		}
	}
	public var totalProgress: Double {
		get {
			return Double(min(Float(totalTime / totalDuration), Float(1.0)))
		}
		set {
			seek(totalDuration * TimeInterval(newValue))
		}
	}
	
	public var startTime: TimeInterval = 0
	public var endTime: TimeInterval {
		return startTime + totalDuration
	}
	public var totalDuration: TimeInterval {
		return (duration * TimeInterval(repeatCount + 1)) + (repeatDelay * TimeInterval(repeatCount))
	}
	public var totalTime: TimeInterval {
		return min(runningTime, totalDuration)
	}
	internal(set) public var elapsed: TimeInterval = 0
	public var time: TimeInterval {
		return (elapsed - delay)
	}
	internal var runningTime: TimeInterval = 0
	
	internal(set) public var timingFunction: TimingFunctionType = LinearTimingFunction()
	internal(set) public var spring: Spring?
	
	@discardableResult
	public func duration(_ duration: TimeInterval) -> Self {
		self.duration = duration
		return self
	}
	
	@discardableResult
	public func delay(_ delay: TimeInterval) -> Self {
		self.delay = delay
		return self
	}
	
	@discardableResult
	public func ease(_ easing: Easing.EasingType) -> Self {
		timingFunction = Easing(easing)
		return self
	}
	
	@discardableResult
	public func spring(tension: Double, friction: Double = 3) -> Self {
		spring = Spring(tension: tension, friction: friction)
		return self
	}
	
	public func play() {
		// if animation is currently paused, reset it since play() starts from the beginning
		if state == .idle {
			stop()
		} else if state == .completed {
			reset()
		}
		
		if state != .running && state != .pending {
			state = .pending
		}
	}
	
	public func stop() {
		if state == .running || state == .pending || isPaused() {
			state = .cancelled
		} else {
			reset()
		}
	}
	
	public func pause() {
		if state == .running || state == .pending {
			state = .idle
		}
	}
	
	public func resume() {
		if state == .idle {
			state = .running
		}
	}
	
	@discardableResult
	public func seek(_ offset: TimeInterval) -> Self {
		pause()
		state = .idle
				
//		var advanceBy = 0.0
		let time = delay + elapsedTimeFromSeekTime(offset)
		
//		print("\(self).\(self.id).seek - offset: \(offset), time: \(time), elapsed: \(elapsed), duration: \(duration)")
		render(time: time)
		
//		if time < 0 {
//			if elapsed != 0 {
//				advanceBy = 0 - elapsed
//			}
//		} else if time <= duration {
//			// update offset to be difference between calculated time and our current time since advance() adds to current time
//			advanceBy = direction == .reversed ? abs(time - elapsed) : time - elapsed
//			
//			if direction == .reversed {
//				if time > elapsed {
//					advanceBy = elapsed - time
//				}
//			}
//		}
//		
//		print("\(self).\(self.id).seek - offset: \(offset), time: \(time), elapsed: \(elapsed), duration: \(duration), advanceBy: \(advanceBy)")
//
//		advance(advanceBy)
		
		return self
	}
	
	@discardableResult
	public func forward() -> Self {
		direction = .forward
		return self
	}
	
	@discardableResult
	public func reverse() -> Self {
		direction = .reversed
		return self
	}
	
	public func restart(_ includeDelay: Bool = false) {
		reset()
		elapsed = includeDelay ? 0 : delay
		play()
	}
	
	internal func reset() {
		seek(0)
		
		runningTime = 0
		cycle = 0
		progress = 0
		state = .idle
		direction = .forward
		
		updated.trigger(self)
	}
	
	var started = Event<Animation>()
	var updated = Event<Animation>()
	var completed = Event<Animation>()
	var cancelled = Event<Animation>()
	var repeated = Event<Animation>()
	
	// MARK: Repeatable
	
	private(set) public var cycle: Int = 0
	private(set) public var repeatCount: Int = 0
	private(set) public var repeatDelay: TimeInterval = 0.0
	private(set) public var repeatForever: Bool = false
	
	@discardableResult
	public func repeatCount(_ count: Int) -> Self {
		repeatCount = count
		return self
	}
	
	@discardableResult
	public func repeatDelay(_ delay: TimeInterval) -> Self {
		repeatDelay = delay
		return self
	}
	
	@discardableResult
	public func forever() -> Self {
		repeatForever = true
		return self
	}
	
	// MARK: Reversable
	
	public var direction: Direction = .forward
	private(set) public var reverseOnComplete: Bool = false
	
	@discardableResult
	public func yoyo() -> Self {
		reverseOnComplete = true
		return self
	}
	
	// MARK: TimeRenderable
	
	internal func render(time: TimeInterval, advance: TimeInterval = 0) {
		elapsed = time
		updated.trigger(self)
	}
	
	// MARK: - Subscriber
	
	internal var id: UInt32 = 0
	internal var updatesStateOnAdvance = true
	
	internal func kill() {
		reset()
		Scheduler.shared.remove(self)
	}
	
	internal func advance(_ time: Double) {
		guard shouldAdvance() else { return }
		
		let end = delay + duration
		let multiplier: TimeInterval = direction == .reversed ? -timeScale : timeScale
		elapsed = max(0, min(elapsed + (time * multiplier), end))
		runningTime += time
		
		// if animation doesn't repeat forever, cap elapsed time to endTime
		if !repeatForever {
			elapsed = min(elapsed, (delay + endTime))
		}
		
		if state == .pending && elapsed >= delay {
			state = .running
		}
		
//		print("\(self).advance - time: \(time), elapsed: \(elapsed), end: \(end), duration: \(duration), progress: \(progress), cycle: \(cycle)")
		render(time: elapsed, advance: time)
		onRender()
	}
	
	internal func canSubscribe() -> Bool {
		return true
	}
	
	internal func shouldAdvance() -> Bool {
		return state == .pending || state == .running || !isPaused()
	}
	
	internal func isAnimationComplete() -> Bool {
		return true
	}
	
	// MARK: Event Handlers
	
	@discardableResult
	public func on(_ event: Animation.EventType, observer: @escaping Event<Animation>.Observer) -> Self {
		switch event {
		case .started:
			started.observe(observer)
		case .updated:
			updated.observe(observer)
		case .completed:
			completed.observe(observer)
		case .repeated:
			repeated.observe(observer)
		case .cancelled:
			cancelled.observe(observer)
		}
		
		return self
	}
	
	fileprivate func onRender() {
		let end = delay + duration
		let shouldRepeat = (repeatForever || (repeatCount > 0 && cycle < repeatCount))
		
		if state == .running && ((direction == .forward && elapsed >= end) || (direction == .reversed && elapsed == 0)) && updatesStateOnAdvance {
			if shouldRepeat {
				print("\(self) completed - repeating, reverseOnComplete: \(reverseOnComplete), reversed: \(direction == .reversed), repeat count \(cycle) of \(repeatCount)")
				cycle += 1
				if reverseOnComplete {
					direction = (direction == .forward) ? .reversed : .forward
				} else {
//					restart()
					elapsed = 0
				}
				repeated.trigger(self)
			} else {
				if isAnimationComplete() && state == .running {
					state = .completed
				}
			}
		}
	}
	
	// MARK: Internal Methods
	
	func isPaused() -> Bool {
		return (state == .idle && Scheduler.shared.contains(self))
	}
	
	func elapsedTimeFromSeekTime(_ time: TimeInterval) -> TimeInterval {
		var adjustedTime = time
		var adjustedCycle = cycle
		
		// seek time must be restricted to the duration of the timeline minus repeats and repeatDelays
		// so if the provided time is greater than the timeline's duration, we need to adjust the seek time first
		if adjustedTime > duration {
			if repeatCount > 0 && fmod(adjustedTime, duration) != 0.0 {
				// determine which repeat cycle the seek time will be in for the specified time
				adjustedCycle = Int(adjustedTime / duration)
				adjustedTime -= (duration * TimeInterval(adjustedCycle))
			} else {
				adjustedTime = duration
			}
		} else {
			adjustedCycle = 0
		}
		
		// determine if we should reverse the direction of the timeline based on calculated adjustedCycle
		let shouldReverse = adjustedCycle != cycle && reverseOnComplete
		if shouldReverse {
			if direction == .forward {
				reverse()
			} else {
				forward()
			}
		}
		
		// if direction is reversed, then adjusted time needs to start from end of animation duration instead of 0
		if direction == .reversed {
			adjustedTime = duration - adjustedTime
		}
		
		cycle = adjustedCycle
		
		return adjustedTime
	}
}
public func ==(lhs: Animation, rhs: Animation) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

extension Animation {
	public enum EventType {
		case started
		case updated
		case cancelled
		case completed
		case repeated
	}
}
