//
//  TweenManager.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class TweenManager {
	public static let sharedInstance = TweenManager()
	
	var tweens = [UInt32: Tween]()
	var counter: UInt32
	
	private var displayLink: CADisplayLink?
	private var lastLoopTime: CFTimeInterval
	
	// MARK: Lifecycle
	
	init() {
		counter = 0
		lastLoopTime = 0
	}
	
	// MARK: Public Methods
	
	func add(tween: Tween) {
		objc_sync_enter(self)
		defer {
			objc_sync_exit(self)
		}
		
		if tween.id == 0 {
			if ++counter == 0 {
				counter = 1
			}
			tween.id = counter
		}
		
		tweens[tween.id] = tween
		print("adding tween, id: \(tween.id)")
		
		if displayLink == nil {
			displayLink = CADisplayLink(target: self, selector: "update:")
			lastLoopTime = CACurrentMediaTime()
			displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
		}
	}
	
	func pause() {
		guard let displayLink = displayLink else { return }
		displayLink.paused = true
	}
	
	func resume() {
		guard let displayLink = displayLink else { return }
		lastLoopTime = CACurrentMediaTime()
		displayLink.paused = false
	}
	
	func stop() {
		guard let displayLink = displayLink else { return }
		displayLink.invalidate()
		self.displayLink = nil
	}
	
	func remove(tween: Tween) {
		tweens[tween.id] = nil
		
		if tweens.count == 0 {
			stop()
		}
	}
	
	@objc func update(displayLink: CADisplayLink) {
		let dt = displayLink.timestamp - lastLoopTime
		defer {
			lastLoopTime = displayLink.timestamp
		}
		
		for (_, tween) in tweens {
			if tween.proceed(dt) {
				tween.kill()
			}
		}
		
		if tweens.count == 0 {
			stop()
		}
	}
}