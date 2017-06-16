//
//  Scheduler.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

protocol Subscriber {
	var id: UInt32 { get set }
	func advance(_ time: Double) -> Bool
}

//final internal class Subscription {
//	
//	fileprivate final class Token: Hashable {
//		weak var subscription: Subscription?
//		var hashValue: Int {
//			return Unmanaged.passUnretained(self).toOpaque().hashValue
//		}
//		
//		init(subscription: Subscription) {
//			self.subscription = subscription
//		}
//	}
//	
//	fileprivate lazy var token: Token = {
//		return Token(subscription: self)
//	}()
//	
//	internal let target: Tweenable
//	
//	internal init(target: Tweenable) {
//		self.target = target
//	}
//}
//private func ==(lhs: Subscription.Token, rhs: Subscription.Token) -> Bool {
//	return lhs == rhs
//}

final public class Scheduler {
	public static let sharedInstance = Scheduler()
	
	var subscribers = [UInt32: Subscriber]()
	var counter: UInt32
//	var cache: [NSObject: [Subscriber]] {
//		get {
//			return tweenCache
//		}
//	}
	var timestamp: TimeInterval {
		return displayLink.timestamp
	}
	
//	fileprivate var tweenCache = [Tweenable: [Tween]]()
//	fileprivate var tweenObjectCache = [NSObject: Tweenable]()
	fileprivate lazy var displayLink: CADisplayLink = {
		let link = CADisplayLink(target: self, selector: #selector(Scheduler.update(_:)))
		link.isPaused = true
		link.add(to: .current, forMode: .commonModes)
		return link
	}()
	fileprivate var lastLoopTime: CFTimeInterval
	
	// MARK: Lifecycle
	
	init() {
		counter = 0
		lastLoopTime = 0
	}
	
	// MARK: Internal Methods
	
	func add(_ target: Subscriber) {
		guard !contains(target) else { return }
		objc_sync_enter(self)
		defer {
			objc_sync_exit(self)
		}
		
		var subscriber = target
		if subscriber.id == 0 {
			counter += 1
			if counter == 0 {
				counter = 1
			}
			subscriber.id = counter
		}
		subscribers[subscriber.id] = target
		
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
		let dt = max(displayLink.timestamp - lastLoopTime, 0)
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
	
//	func cache(_ tween: Tween, target: Tweenable) {
//		if tweenCache[target] == nil {
//			tweenCache[target] = [Tween]()
//		}
//		if let tweens = tweenCache[target], tweens.contains(tween) == false {
//			tweenCache[target]?.append(tween)
//		}
//	}
//	
//	func removeFromCache(_ tween: Tween, target: Tweenable) {
//		if let tweens = tweenCache[target] {
//			if let index = tweens.index(of: tween) {
//				tweenCache[target]?.remove(at: index)
//			}
//			
//			// remove object reference if all tweens have been removed from cache
//			if tweenCache[target]?.count == 0 {
//				removeFromCache(target)
//			}
//		}
//	}
//	
//	func removeFromCache(_ target: Tweenable) {
//		tweenCache[target] = nil
////		tweenObjectCache[target] = nil
//	}
//	
//	func removeAllFromCache() {
//		tweenCache.removeAll()
////		tweenObjectCache.removeAll()
//	}
//	
//	func tweens(ofTarget target: Tweenable, activeOnly: Bool = false) -> [Tween]? {
//		return tweenCache[target]
//	}
	
//	func cachedUpdater(ofTarget target: NSObject) -> TweenObject {
//		if let obj = tweenObjectCache[target] {
//			return obj
//		}
//		
//		let obj = TweenObject(target: target)
//		tweenObjectCache[target] = obj
//		
//		return obj
//	}
	
	func activeTweenPropsForKey(_ key: String, ofTarget target: Tweenable) -> [FromToValue] {
		var props = [FromToValue]()
		if let tweens = TweenCache.session.tweens(ofTarget: target) {
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
	
	fileprivate func contains(_ target: Subscriber) -> Bool {
		var contains = false
		
		for (_, subscriber) in subscribers {
			if subscriber.id == target.id {
				contains = true
				break
			}
		}
		
		return contains
	}
}
