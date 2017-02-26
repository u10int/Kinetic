//
//  Animation.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public protocol Animatable: AnyObject {
	associatedtype AnimationType
	
	var active: Bool { get }
	var paused: Bool { get }
	var animating: Bool { get }
	var reversed: Bool { get }
	var delay: CFTimeInterval { get }
	var duration: CFTimeInterval { get }
	var repeatCount: Int { get set }
	var startTime: CFTimeInterval { get set }
	var endTime: CFTimeInterval { get }
	var totalTime: CFTimeInterval { get }
	var totalDuration: CFTimeInterval { get }
	var elapsed: CFTimeInterval { get }
	
	func duration(_ duration: CFTimeInterval) -> AnimationType
	func delay(_ delay: CFTimeInterval) -> AnimationType
	func repeatCount(_ count: Int) -> AnimationType
	func repeatDelay(_ delay: CFTimeInterval) -> AnimationType
	func forever() -> AnimationType
	func yoyo() -> AnimationType
	
	func play() -> AnimationType
	func stop()
	func pause()
	func resume()
	func seek(_ time: CFTimeInterval) -> AnimationType
	func forward() -> AnimationType
	func reverse() -> AnimationType
	func restart(_ includeDelay: Bool)
	func progress() -> Float
	func setProgress(_ progress: Float) -> AnimationType
	func totalProgress() -> Float
	func setTotalProgress(_ progress: Float) -> AnimationType
	func time() -> CFTimeInterval
	
	func kill()
}

open class Animation: NSObject, Animatable {
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
	fileprivate (set) public var delay: CFTimeInterval = 0
	fileprivate (set) public var duration: CFTimeInterval = 1.0 {
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
	
	fileprivate var cycle: Int = 0
	fileprivate var _animating = false
	fileprivate var _reversed = false
	
	// MARK: Lifecycle
	
	deinit {
		
	}
	
	// MARK: Animatable
	
	@discardableResult
	open func duration(_ duration: CFTimeInterval) -> AnimationType {
		self.duration = duration
		return self
	}
	
	@discardableResult
	open func delay(_ delay: CFTimeInterval) -> AnimationType {
		self.delay = delay
		return self
	}
	
	@discardableResult
	open func repeatCount(_ count: Int) -> AnimationType {
		repeatCount = count
		return self
	}
	
	@discardableResult
	open func repeatDelay(_ delay: CFTimeInterval) -> AnimationType {
		repeatDelay = delay
		return self
	}
	
	@discardableResult
	open func forever() -> AnimationType {
		repeatForever = true
		return self
	}
	
	@discardableResult
	open func yoyo() -> AnimationType {
		reverseOnComplete = true
		return self
	}
	
	// MARK: Playback
	
	@discardableResult
	open func play() -> AnimationType {
		if running {
			return self
		}
		running = true
		paused = false
		
		return self
	}
	
	open func stop() {
		reset()
		kill()
	}
	
	open func pause() {
		paused = true
		_animating = false
	}
	
	open func resume() {
		paused = false
		_animating = true
	}
	
	@discardableResult
	open func seek(_ time: CFTimeInterval) -> AnimationType {
		let adjustedTime = elapsedTimeFromSeekTime(time)
		elapsed = delay + adjustedTime
		runningTime = time
		return self
	}
	
	@discardableResult
	open func forward() -> AnimationType {
		_reversed = false
		return self
	}
	
	@discardableResult
	open func reverse() -> AnimationType {
		_reversed = true
		return self
	}
	
	open func restart(_ includeDelay: Bool = false) {
		reset()
		elapsed = includeDelay ? 0 : delay
		play()
	}
	
	open func progress() -> Float {
		return min(Float(elapsed / (delay + duration)), 1)
	}
	
	@discardableResult
	open func setProgress(_ progress: Float) -> AnimationType {
		seek(duration * CFTimeInterval(progress))
		return self
	}
	
	open func totalProgress() -> Float {
		return min(Float(totalTime / totalDuration), 1)
	}
	
	@discardableResult
	open func setTotalProgress(_ progress: Float) -> AnimationType {
		seek(totalDuration * CFTimeInterval(progress))
		return self
	}
	
	open func time() -> CFTimeInterval {
		return (elapsed - delay)
	}
	
	open func kill() {
		reset()
	}
	
	// MARK: Event Handlers
	
	@discardableResult
	open func onStart(_ callback: ((Animation) -> Void)?) -> AnimationType {
		startBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onUpdate(_ callback: ((Animation) -> Void)?) -> AnimationType {
		updateBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onComplete(_ callback: ((Animation) -> Void)?) -> AnimationType {
		completionBlock = { (animation) in
			callback?(animation)
		}
		return self
	}
	
	@discardableResult
	open func onRepeat(_ callback: ((Animation) -> Void)?) -> AnimationType {
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
	
	func proceed(_ dt: CFTimeInterval, force: Bool = false) -> Bool {
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
	
	func elapsedTimeFromSeekTime(_ time: CFTimeInterval) -> CFTimeInterval {
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
