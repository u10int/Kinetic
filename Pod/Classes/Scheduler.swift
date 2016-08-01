//
//  Scheduler.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

protocol Subscriber: AnyObject {
	var id: UInt32 { get set }
	func advance(time: Double) -> Bool
}

final public class Scheduler {
	public static let sharedInstance = Scheduler()
	
	var subscribers = [UInt32: Animation]()
	var counter: UInt32
	var cache: [NSObject: [Tween]] {
		get {
			return tweenCache
		}
	}
	var timestamp: NSTimeInterval {
		return displayLink.timestamp
	}
	
	private var tweenCache = [NSObject: [Tween]]()
	private lazy var displayLink: CADisplayLink = {
		let link = CADisplayLink(target: self, selector: #selector(Scheduler.update(_:)))
		link.paused = true
		link.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
		return link
	}()
	private var lastLoopTime: CFTimeInterval
	
	// MARK: Lifecycle
	
	init() {
		counter = 0
		lastLoopTime = 0
	}
	
	// MARK: Internal Methods
	
	func add(tween: Animation) {
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
		subscribers[tween.id] = tween
		resume()
	}
	
	func pause() {
		displayLink.paused = true
	}
	
	func resume() {
		lastLoopTime = CACurrentMediaTime()
		displayLink.paused = (subscribers.count == 0)
	}
	
	func stop() {
		displayLink.paused = true
//		displayLink.invalidate()
	}
	
	func remove(tween: Animation) {
		subscribers[tween.id] = nil
		
		if subscribers.count == 0 {
			stop()
		}
	}
	
	@objc func update(displayLink: CADisplayLink) {
		let dt = displayLink.timestamp - lastLoopTime
		defer {
			lastLoopTime = displayLink.timestamp
		}
				
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		subscribers.forEach { (id, subscriber) in
			subscriber.advance(dt)
		}
		CATransaction.commit()
		
		if subscribers.count == 0 {
			stop()
		}
	}
	
	func cache(tween: Tween, target: NSObject) {
		if tweenCache[target] == nil {
			tweenCache[target] = [Tween]()
		}
		if let tweens = tweenCache[target] where tweens.contains(tween) == false {
			tweenCache[target]?.append(tween)
		}
	}
	
	func removeFromCache(tween: Tween, target: NSObject) {
		if let tweens = tweenCache[target] {
			if let index = tweens.indexOf(tween) {
				tweenCache[target]?.removeAtIndex(index)
			}
			
			// remove object reference if all tweens have been removed from cache
			if tweenCache[target]?.count == 0 {
				removeFromCache(target)
			}
		}
	}
	
	func removeFromCache(target: NSObject) {
		tweenCache[target] = nil
	}
	
	func removeAllFromCache() {
		tweenCache.removeAll()
	}
	
	func tweensOfTarget(target: NSObject, activeOnly: Bool = false) -> [Tween]? {
		return tweenCache[target]
	}
	
//	func lastPropertyForTarget(target: NSObject, type: Property) -> TweenProperty? {
//		let props = propertiesForTarget(target, type: type)
//		
//		if props.count > 1 {
//			return props[props.count - 2]
//		}
//		return nil
//	}
	
	// MARK: Private Methods
	
	private func contains(animation: Animation) -> Bool {
		var contains = false
		
		for (_, anim) in subscribers {
			if anim == animation {
				contains = true
				break
			}
		}
		
		return contains
	}
	
//	private func propertiesForTarget(target: NSObject, type: Property) -> [TweenProperty] {
//		var props = [TweenProperty]()
//		
//		if let tweens = tweensOfTarget(target) {
//			for tween in tweens {
//				if let prop = tween.storedPropertyForType(type) {
//					props.append(prop)
//				}
//			}
//		}
//		
//		return props
//	}
}
