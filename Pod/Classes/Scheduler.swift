//
//  Scheduler.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

internal protocol Subscriber {
	var id: UInt32 { get set }
	
	func advance(_ time: Double)
	func kill()
	func canSubscribe() -> Bool
}

final public class Scheduler {
	public static let shared = Scheduler()
	
	var subscribers = [UInt32: Subscriber]()
	var timestamp: TimeInterval {
		return displayLink.timestamp
	}
	
	fileprivate lazy var displayLink: CADisplayLink = {
		let link = CADisplayLink(target: self, selector: #selector(Scheduler.update(_:)))
		link.isPaused = true
		link.add(to: .current, forMode: .commonModes)
		return link
	}()
	fileprivate var lastLoopTime: CFTimeInterval
	
	// MARK: Lifecycle
	
	init() {
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
	
	func remove(_ tween: Subscriber) {
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
	
	func activeTweenPropsForKey(_ key: String, ofTarget target: Tweenable, excludingTween targetTween: Tween? = nil) -> [FromToValue] {
		var props = [FromToValue]()
		
		if let tweens = TweenCache.session.tweens(ofTarget: target) {
//			let reducedTweens = tweens.reversed()[0..<tweens.count]
			tweens.forEach({ (tween) in
				if tween.state == .running && (targetTween == nil || tween != targetTween) {
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
	
	internal func contains(_ target: Subscriber) -> Bool {
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
