//
//  Animation.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public protocol AnimationType: AnyObject {
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
	
	func ease(easing: Ease) -> Animation
	func spring(tension tension: Double, friction: Double) -> Animation
	func delay(delay: CFTimeInterval) -> Animation
	func repeatCount(count: Int) -> Animation
	func repeatDelay(delay: CFTimeInterval) -> Animation
	func forever() -> Animation
	func yoyo() -> Animation
	
	func play() -> Animation
	func stop()
	func pause()
	func resume()
	func seek(time: CFTimeInterval) -> Animation
	func forward() -> Animation
	func reverse() -> Animation
	func restart(includeDelay: Bool)
	func progress() -> CGFloat
	func time() -> CFTimeInterval
	func kill()
}

public class Animation: NSObject, AnimationType {
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
			return (elapsed - delay)
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
	var repeatForever = false
	var repeatDelay: CFTimeInterval = 0
	var reverseOnComplete = false
	
	var startBlock: ((Animation) -> Void)?
	var updateBlock: ((Animation) -> Void)?
	var completionBlock: ((Animation) -> Void)?
	var repeatBlock: ((Animation) -> Void)?
	
	private var cycle: Int = 0
	private var _animating = false
	private var _reversed = false
	
	// MARK: Options
	
	public func ease(easing: Ease) -> Animation {
		return self
	}
	
	public func spring(tension tension: Double, friction: Double = 3) -> Animation {
		return self
	}
	
	public func delay(delay: CFTimeInterval) -> Animation {
		self.delay = delay
		return self
	}
	
	public func repeatCount(count: Int) -> Animation {
		repeatCount = count
		return self
	}
	
	public func repeatDelay(delay: CFTimeInterval) -> Animation {
		repeatDelay = delay
		return self
	}
	
	public func forever() -> Animation {
		repeatForever = true
		return self
	}
	
	public func yoyo() -> Animation {
		reverseOnComplete = true
		return self
	}
	
	// MARK: Playback
	
	public func play() -> Animation {
		if running {
			return self
		}
		running = true
		elapsed = 0
		cycle = 0
		
		return self
	}
	
	public func stop() {
		kill()
	}
	
	public func pause() {
		paused = true
		_animating = false
	}
	
	public func resume() {
		paused = false
		_animating = false
	}
	
	public func seek(time: CFTimeInterval) -> Animation {
		elapsed += delay + time
		return self
	}
	
	public func forward() -> Animation {
		_reversed = false
		return self
	}
	
	public func reverse() -> Animation {
		_reversed = true
		return self
	}
	
	public func restart(includeDelay: Bool = false) {
		elapsed = includeDelay ? 0 : delay
		play()
	}
	
	public func progress() -> CGFloat {
		return CGFloat(elapsed / (delay + duration))
	}
	
	public func time() -> CFTimeInterval {
		return totalTime - (CFTimeInterval(cycle) * (duration + repeatDelay))
	}
	
	public func kill() {
		running = false
		_animating = false
	}
	
	// MARK: Event Handlers
	
	public func onStart(callback: ((Animation) -> Void)?) -> Animation {
		startBlock = callback
		return self
	}
	
	public func onUpdate(callback: ((Animation) -> Void)?) -> Animation {
		updateBlock = callback
		return self
	}
	
	public func onComplete(callback: ((Animation) -> Void)?) -> Animation {
		completionBlock = callback
		return self
	}
	
	public func onRepeat(callback: ((Animation) -> Void)?) -> Animation {
		repeatBlock = callback
		return self
	}
	
	// MARK: Internal Methods
	
	func proceed(var dt: CFTimeInterval, force: Bool = false) -> Bool {
		if !running {
			return true
		}
		if paused {
			return false
		}
		
		if reversed {
			dt *= -1
		}
		elapsed += dt
		
		return false
	}
	
	func started() {
		_animating = true
		startBlock?(self)
	}
	
	func completed() -> Bool {
		var shouldRepeat = false
//		print("DONE: repeatCount=\(repeatCount), cycle=\(cycle)")
		if repeatForever || (repeatCount > 0 && cycle < repeatCount) {
			shouldRepeat = true
			cycle++
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