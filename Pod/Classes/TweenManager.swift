//
//  TweenManager.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

open class TweenManager {
	open static let sharedInstance = TweenManager()
	
	var tweens = [UInt32: Animation]()
	var counter: UInt32
	var cache: [NSObject: [Tween]] {
		get {
			return tweenCache
		}
	}
	
	fileprivate var tweenCache = [NSObject: [Tween]]()
	fileprivate var displayLink: CADisplayLink?
	fileprivate var lastLoopTime: CFTimeInterval
	
	// MARK: Lifecycle
	
	init() {
		counter = 0
		lastLoopTime = 0
	}
	
	// MARK: Internal Methods
	
	func add(_ tween: Animation) {
		guard !contains(tween) else { return }
		objc_sync_enter(self)
		defer {
			objc_sync_exit(self)
		}
		
		if tween.id == 0 {
			counter += 1
			if counter == 0 {
				counter = 1
			}
			tween.id = counter
		}
		tweens[tween.id] = tween
		
		if displayLink == nil {
			displayLink = CADisplayLink(target: self, selector: #selector(TweenManager.update(_:)))
			lastLoopTime = CACurrentMediaTime()
			displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
		}
	}
	
	func pause() {
		guard let displayLink = displayLink else { return }
		displayLink.isPaused = true
	}
	
	func resume() {
		guard let displayLink = displayLink else { return }
		lastLoopTime = CACurrentMediaTime()
		displayLink.isPaused = false
	}
	
	func stop() {
		guard let displayLink = displayLink else { return }
		displayLink.invalidate()
		self.displayLink = nil
	}
	
	func remove(_ tween: Animation) {
		tweens[tween.id] = nil
		
		if tweens.count == 0 {
			stop()
		}
	}
	
	@objc func update(_ displayLink: CADisplayLink) {
		let dt = displayLink.timestamp - lastLoopTime
		defer {
			lastLoopTime = displayLink.timestamp
		}
				
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		for (_, tween) in tweens {
			if tween.proceed(dt) {
				tween.kill()
			}
		}
		CATransaction.commit()
		
		if tweens.count == 0 {
			stop()
		}
	}
	
	func cache(_ tween: Tween, target: NSObject) {
		if tweenCache[target] == nil {
			tweenCache[target] = [Tween]()
		}
		if let tweens = tweenCache[target], tweens.contains(tween) == false {
			tweenCache[target]?.append(tween)
		}
	}
	
	func removeFromCache(_ tween: Tween, target: NSObject) {
		if let tweens = tweenCache[target] {
			if let index = tweens.index(of: tween) {
				tweenCache[target]?.remove(at: index)
			}
			
			// remove object reference if all tweens have been removed from cache
			if tweenCache[target]?.count == 0 {
				removeFromCache(target)
			}
		}
	}
	
	func removeFromCache(_ target: NSObject) {
		tweenCache[target] = nil
	}
	
	func removeAllFromCache() {
		tweenCache.removeAll()
	}
	
	func tweensOfTarget(_ target: NSObject, activeOnly: Bool = false) -> [Tween]? {
		return tweenCache[target]
	}
	
	func lastPropertyForTarget(_ target: NSObject, type: Property) -> TweenProperty? {
		let props = propertiesForTarget(target, type: type)
		
		if props.count > 1 {
			return props[props.count - 2]
		}
		return nil
	}
	
	// MARK: Private Methods
	
	fileprivate func contains(_ animation: Animation) -> Bool {
		var contains = false
		
		for (_, anim) in tweens {
			if anim == animation {
				contains = true
				break
			}
		}
		
		return contains
	}
	
	fileprivate func propertiesForTarget(_ target: NSObject, type: Property) -> [TweenProperty] {
		var props = [TweenProperty]()
		
		if let tweens = tweensOfTarget(target) {
			for tween in tweens {
				if let prop = tween.storedPropertyForType(type) {
					props.append(prop)
				}
			}
		}
		
		return props
	}
}
