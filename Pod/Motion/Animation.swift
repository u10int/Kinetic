//
//  Animation.swift
//  Motion
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class Animation: NSObject {
	var id: UInt32 = 0
	
	public var running = false
	public var paused = false
	public var animating = false
	public var delay: CFTimeInterval = 0
	public var duration: CFTimeInterval = 1.0
	public var repeatCount: Int = 0
	
	var startTime: CFTimeInterval = 0
	var endTime: CFTimeInterval {
		get {
			return startTime + totalDuration
		}
	}
	var totalTime: CFTimeInterval {
		get {
			return (elapsed - delay)
		}
	}
	var totalDuration: CFTimeInterval {
		get {
			return (duration * CFTimeInterval(repeatCount + 1)) + (repeatDelay * CFTimeInterval(repeatCount))
		}
	}
	var elapsed: CFTimeInterval = 0
	var repeatForever = false
	var repeatDelay: CFTimeInterval = 0
	var reverseOnComplete = false
	
	var startBlock: (() -> Void)?
	var updateBlock: (() -> Void)?
	var completionBlock: (() -> Void)?
	var repeatBlock: (() -> Void)?
	
	// MARK: Options
	
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
		
		return self
	}
	
	public func pause() {
		paused = true
		animating = false
	}
	
	public func resume() {
		paused = false
		animating = false
	}
	
	public func seek(time: CFTimeInterval) -> Animation {
		elapsed += delay + time
		return self
	}
	
	public func restart(includeDelay: Bool = false) {
		
	}
	
	public func kill() {
		
	}
	
	// MARK: Event Handlers
	
	public func onStart(callback: (() -> Void)?) -> Animation {
		startBlock = callback
		return self
	}
	
	public func onUpdate(callback: (() -> Void)?) -> Animation {
		updateBlock = callback
		return self
	}
	
	public func onComplete(callback: (() -> Void)?) -> Animation {
		completionBlock = callback
		return self
	}
	
	public func onRepeat(callback: (() -> Void)?) -> Animation {
		repeatBlock = callback
		return self
	}
	
	// MARK: Internal Methods
	
	func proceed(dt: CFTimeInterval, force: Bool = false) -> Bool {
		if !running {
			return true
		}
		if paused {
			return false
		}
		
		elapsed += dt
		
		return false
	}
}