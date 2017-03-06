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
	func advance(_ time: Double) -> Bool
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
	var timestamp: TimeInterval {
		return displayLink.timestamp
	}
	
	fileprivate var tweenCache = [NSObject: [Tween]]()
	fileprivate var tweenObjectCache = [NSObject: TweenObject]()
	fileprivate lazy var displayLink: CADisplayLink = {
		let link = CADisplayLink(target: self, selector: #selector(Scheduler.update(_:)))
		link.isPaused = true
		link.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
		return link
	}()
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
		subscribers[tween.id] = tween
		resume()
	}
	
	func pause() {
		displayLink.isPaused = true
	}
	
	func resume() {
		lastLoopTime = CACurrentMediaTime()
		displayLink.isPaused = (subscribers.count == 0)
	}
	
	func stop() {
		displayLink.isPaused = true
//		displayLink.invalidate()
	}
	
	func remove(_ tween: Animation) {
		subscribers[tween.id] = nil
		
		if subscribers.count == 0 {
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
		subscribers.forEach { (id, subscriber) in
			subscriber.advance(dt)
		}
		CATransaction.commit()
		
		if subscribers.count == 0 {
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
		tweenObjectCache[target] = nil
	}
	
	func removeAllFromCache() {
		tweenCache.removeAll()
		tweenObjectCache.removeAll()
	}
	
	func tweens(ofTarget target: NSObject, activeOnly: Bool = false) -> [Tween]? {
		return tweenCache[target]
	}
	
	func cachedUpdater(ofTarget target: NSObject) -> TweenObject {
		if let obj = tweenObjectCache[target] {
			return obj
		}
		return TweenObject(target: target)
	}
	
	func activeTweenPropsForKey(_ key: String, ofTarget target: NSObject) -> [FromToValue] {
		var props = [FromToValue]()
		if let tweens = tweens(ofTarget: target) {
//			let reducedTweens = tweens.reversed()[0..<tweens.count]
			tweens.forEach({ (tween) in
				if tween.state == .running {
					tween.properties.forEach({ (value) in
						if value.to?.key == key {
							props.append(value)
						}
					})
				}
			})
		}
		return props
	}
	
	// MARK: Private Methods
	
	fileprivate func contains(_ animation: Animation) -> Bool {
		var contains = false
		
		for (_, anim) in subscribers {
			if anim == animation {
				contains = true
				break
			}
		}
		
		return contains
	}
}
