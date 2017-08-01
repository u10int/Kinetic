//
//  Animation.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class Animation: Animatable, Repeatable, Reversable, Subscriber {
	public var hashValue: Int {
		return Unmanaged.passUnretained(self).toOpaque().hashValue
	}
	
	public init() {}
	
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
			print("Animation.state changed: \(state), tween \(id)")
			switch state {
			case .pending:
				Scheduler.shared.add(self)
				break
			case .running:
				startBlock?(self)
			case .idle:
				break
			case .cancelled:
				kill()
				break
			case .completed:
				kill()
				completionBlock?(self)
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
			return min(Double(elapsed / (delay + duration)), 1)
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
		}
		
		if state != .running && state != .pending {
			state = .pending
		}
	}
	
	public func stop() {
		if state == .running || state == .pending || state == .idle {
			state = .cancelled
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
		
		let time = delay + elapsedTimeFromSeekTime(offset)
		advance(time)
		
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
		elapsed = 0
		runningTime = 0
		cycle = 0
		state = .idle
	}

	var startBlock: ((Animation) -> Void)?
	var updateBlock: ((Animation) -> Void)?
	var completionBlock: ((Animation) -> Void)?
	var repeatBlock: ((Animation) -> Void)?
	
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
		
		let shouldRepeat = (repeatForever || (repeatCount > 0 && cycle < repeatCount))
		if (direction == .forward && progress >= 1.0) || (direction == .reversed && progress == 0) {
			if shouldRepeat {
//				print("\(self) completed - repeating, reverseOnComplete: \(reverseOnComplete), reversed: \(direction == .reversed), repeat count \(cycle) of \(repeatCount)")
				cycle += 1
				if reverseOnComplete {
					direction = (direction == .forward) ? .reversed : .forward
				} else {
					restart()
				}
				repeatBlock?(self)
			} else {
				if updatesStateOnAdvance {
					state = .completed
				}
			}
		}
	}
	
	internal func shouldAdvance() -> Bool {
		return state == .pending || state == .running || (state == .idle && !Scheduler.shared.contains(self))
	}
	
	// MARK: Event Handlers
	
	@discardableResult
	open func onStart(_ callback: ((Animation) -> Void)?) -> Self {
		startBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onUpdate(_ callback: ((Animation) -> Void)?) -> Self {
		updateBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onComplete(_ callback: ((Animation) -> Void)?) -> Self {
		completionBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onRepeat(_ callback: ((Animation) -> Void)?) -> Self {
		repeatBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	// MARK: Internal Methods
	
	func elapsedTimeFromSeekTime(_ time: TimeInterval) -> TimeInterval {
		var adjustedTime = time
		
		// seek time must be restricted to the duration of the timeline minus repeats and repeatDelays
		// so if the provided time is greater than the timeline's duration, we need to adjust the seek time first
		if adjustedTime > duration {
			// update cycles count
			cycle = Int(adjustedTime / duration)
			
			adjustedTime -= (duration * TimeInterval(cycle))
			
			// if cycles value is odd, then the current state should be reversed
			let isReversed = fmod(Double(cycle), 2) != 0 && reverseOnComplete
			if isReversed {
				adjustedTime = duration - adjustedTime
				reverse()
			} else {
				forward()
			}
		}
		
		return adjustedTime
	}
}

public func ==(lhs: Animation, rhs: Animation) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
