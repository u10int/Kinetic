//
//  Animation.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public protocol Animatable: AnyObject {
	typealias AnimationType
	
	var active: Bool { get }
	var paused: Bool { get }
	var animating: Bool { get }
	var reversed: Bool { get }
	var delay: CFTimeInterval { get set }
	var duration: CFTimeInterval { get set }
	var repeatCount: Int { get set }
	var startTime: CFTimeInterval { get set }
	var endTime: CFTimeInterval { get }
	var totalTime: CFTimeInterval { get }
	var totalDuration: CFTimeInterval { get }
	var elapsed: CFTimeInterval { get }
	
	func duration(duration: CFTimeInterval) -> AnimationType
	func delay(delay: CFTimeInterval) -> AnimationType
	func repeatCount(count: Int) -> AnimationType
	func repeatDelay(delay: CFTimeInterval) -> AnimationType
	func forever() -> AnimationType
	func yoyo() -> AnimationType
	
	func play() -> AnimationType
	func stop()
	func pause()
	func resume()
	func seek(time: CFTimeInterval) -> AnimationType
	func forward() -> AnimationType
	func reverse() -> AnimationType
	func restart(includeDelay: Bool)
	func progress() -> Float
	func setProgress(progress: Float) -> AnimationType
	func totalProgress() -> Float
	func setTotalProgress(progress: Float) -> AnimationType
	func time() -> CFTimeInterval
	
	func kill()
}

public class Animation: NSObject, Animatable {
	public typealias AnimationType = Animation
	
	public var active: Bool {
		get {
			return running
		}
	}
	public var paused = false
	public var animating: Bool {
		get {
			return _animating
		}
	}
	public var reversed: Bool {
		get {
			return _reversed
		}
	}
	public var delay: CFTimeInterval = 0
	public var duration: CFTimeInterval = 1.0 {
		didSet {
			if duration == 0 {
				duration = 0.001
			}
		}
	}
	public var repeatCount: Int = 0
	public var startTime: CFTimeInterval = 0
	public var endTime: CFTimeInterval {
		get {
			return startTime + totalDuration
		}
	}
	public var totalTime: CFTimeInterval {
		get {
			return min(runningTime, totalDuration)
		}
	}
	public var totalDuration: CFTimeInterval {
		get {
			return (duration * CFTimeInterval(repeatCount + 1)) + (repeatDelay * CFTimeInterval(repeatCount))
		}
	}
	public var elapsed: CFTimeInterval = 0
	
	var id: UInt32 = 0
	var running = false
	var runningTime: CFTimeInterval = 0
	var repeatForever = false
	var repeatDelay: CFTimeInterval = 0
	var reverseOnComplete = false
	
	var startBlock: ((AnimationType) -> Void)?
	var updateBlock: ((AnimationType) -> Void)?
	var completionBlock: ((AnimationType) -> Void)?
	var repeatBlock: ((AnimationType) -> Void)?
	
	private var cycle: Int = 0
	private var _animating = false
	private var _reversed = false
	
	// MARK: Lifecycle
	
	deinit {
		
	}
	
	// MARK: Animatable
	
	public func duration(duration: CFTimeInterval) -> AnimationType {
		self.duration = duration
		return self
	}
	
//	public func ease(easing: Ease) -> Animation {
//		return self
//	}
//	
//	public func spring(tension tension: Double, friction: Double = 3) -> Animation {
//		return self
//	}
	
	public func delay(delay: CFTimeInterval) -> AnimationType {
		self.delay = delay
		return self
	}
	
	public func repeatCount(count: Int) -> AnimationType {
		repeatCount = count
		return self
	}
	
	public func repeatDelay(delay: CFTimeInterval) -> AnimationType {
		repeatDelay = delay
		return self
	}
	
	public func forever() -> AnimationType {
		repeatForever = true
		return self
	}
	
	public func yoyo() -> AnimationType {
		reverseOnComplete = true
		return self
	}
	
	// MARK: Playback
	
	public func play() -> AnimationType {
		if running {
			return self
		}
		running = true
		paused = false
//		elapsed = 0
//		runningTime = 0
//		cycle = 0
		
		return self
	}
	
	public func stop() {
		reset()
		kill()
	}
	
	public func pause() {
		paused = true
		_animating = false
	}
	
	public func resume() {
		paused = false
		_animating = true
	}
	
	public func seek(time: CFTimeInterval) -> AnimationType {
		let adjustedTime = elapsedTimeFromSeekTime(time)
		elapsed = delay + adjustedTime
		runningTime = time
		return self
	}
	
	public func forward() -> AnimationType {
		_reversed = false
		return self
	}
	
	public func reverse() -> AnimationType {
		_reversed = true
		return self
	}
	
	public func restart(includeDelay: Bool = false) {
		reset()
		elapsed = includeDelay ? 0 : delay
		play()
	}
	
	public func progress() -> Float {
		return min(Float(elapsed / (delay + duration)), 1)
	}
	
	public func setProgress(progress: Float) -> AnimationType {
		seek(duration * CFTimeInterval(progress))
		return self
	}
	
	public func totalProgress() -> Float {
		return min(Float(totalTime / totalDuration), 1)
	}
	
	public func setTotalProgress(progress: Float) -> AnimationType {
		seek(totalDuration * CFTimeInterval(progress))
		return self
	}
	
	public func time() -> CFTimeInterval {
		return (elapsed - delay)
	}
	
	public func kill() {
		reset()
	}
	
	// MARK: Event Handlers
	
	public func onStart(callback: ((Animation) -> Void)?) -> AnimationType {
		startBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	public func onUpdate(callback: ((Animation) -> Void)?) -> AnimationType {
		updateBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	public func onComplete(callback: ((Animation) -> Void)?) -> AnimationType {
		completionBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	public func onRepeat(callback: ((Animation) -> Void)?) -> AnimationType {
		repeatBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	// MARK: Internal Methods
	
	func reset() {
		_animating = false
		running = false
		elapsed = 0
		runningTime = 0
		cycle = 0
	}
	
	func proceed(dt: CFTimeInterval, force: Bool = false) -> Bool {
		if !running {
			return true
		}
		if paused {
			return false
		}
		
		let multiplier: CFTimeInterval = reversed ? -1 : 1
		elapsed += (dt * multiplier)
		runningTime += dt
		
		return false
	}
	
	func elapsedTimeFromSeekTime(time: CFTimeInterval) -> CFTimeInterval {
		var adjustedTime = time
		
		// seek time must be restricted to the duration of the timeline minus repeats and repeatDelays
		// so if the provided time is greater than the timeline's duration, we need to adjust the seek time first
		if adjustedTime > duration {
			// update cycles count
			cycle = Int(adjustedTime / duration)
			
			adjustedTime -= (duration * CFTimeInterval(cycle))
			
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
	
	func started() {
		_animating = true
		startBlock?(self)
	}
	
	func completed() -> Bool {
		var shouldRepeat = false
		if repeatForever || (repeatCount > 0 && cycle < repeatCount) {
			shouldRepeat = true
			cycle += 1
		}
		
		if shouldRepeat {
			repeatBlock?(self)
			if reverseOnComplete {
				if reversed {
					forward()
				} else {
					reverse()
				}
			} else {
				restart()
			}
		} else {
			_animating = false
			_reversed = false
			running = false
			completionBlock?(self)
			return true
		}
		
		return false
	}
}