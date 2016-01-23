//
//  Kinetic.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/28/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class Kinetic {
	
	// MARK: Class Methods
	
	static func to(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: nil, to: options, mode: .To)
		tween.duration = duration
		TweenManager.sharedInstance.cache(tween, target: item)
		
		return tween
	}
	
	static func from(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: options, to: nil, mode: .From)
		tween.duration = duration
		TweenManager.sharedInstance.cache(tween, target: item)
		
		return tween
	}
	
	static func fromTo(item: NSObject, duration: CFTimeInterval, from: [Property], to: [Property]) -> Tween {
		let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
		tween.duration = duration
		TweenManager.sharedInstance.cache(tween, target: item)
		
		return tween
	}
	
	static func itemsTo(items: [NSObject], duration: CFTimeInterval, options: [Property]) -> Timeline {
		return staggerTo(items, duration: duration, options: options, stagger: 0)
	}
	
	static func itemsFrom(items: [NSObject], duration: CFTimeInterval, options: [Property]) -> Timeline {
		return staggerFrom(items, duration: duration, options: options, stagger: 0)
	}
	
	static func itemsFromTo(items: [NSObject], duration: CFTimeInterval, from: [Property], to: [Property]) -> Timeline {
		return staggerFromTo(items, duration: duration, from: from, to: to, stagger: 0)
	}
	
	static func staggerTo(items: [NSObject], duration: CFTimeInterval, options: [Property], stagger: CFTimeInterval) -> Timeline {
		let timeline = Timeline()
		
		for (idx, item) in items.enumerate() {
			let tween = Tween(target: item, from: nil, to: options, mode: .To)
			tween.duration = duration
			timeline.add(tween, position: stagger * CFTimeInterval(idx))
			TweenManager.sharedInstance.cache(tween, target: item)
		}
		
		return timeline
	}
	
	static func staggerFrom(items: [NSObject], duration: CFTimeInterval, options: [Property], stagger: CFTimeInterval) -> Timeline {
		let timeline = Timeline()
		
		for (idx, item) in items.enumerate() {
			let tween = Tween(target: item, from: options, to: nil, mode: .To)
			tween.duration = duration
			timeline.add(tween, position: stagger * CFTimeInterval(idx))
			TweenManager.sharedInstance.cache(tween, target: item)
		}
		
		return timeline
	}
	
	static func staggerFromTo(items: [NSObject], duration: CFTimeInterval, from: [Property], to: [Property], stagger: CFTimeInterval) -> Timeline {
		let timeline = Timeline()
		
		for (idx, item) in items.enumerate() {
			let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
			tween.duration = duration
			timeline.add(tween, position: stagger * CFTimeInterval(idx))
			TweenManager.sharedInstance.cache(tween, target: item)
		}
		
		return timeline
	}
	
	static func getTweensOf(target: NSObject) -> [Tween]? {
		return TweenManager.sharedInstance.tweensOfTarget(target)
	}
	
	static func killTweensOf(target: NSObject) {
		if let tweens = TweenManager.sharedInstance.tweensOfTarget(target) {
			for tween in tweens {
				tween.kill()
			}
		}
		TweenManager.sharedInstance.removeFromCache(target)
	}
	
	static func killAll() {
		for (_, var tweens) in TweenManager.sharedInstance.cache {
			for tween in tweens {
				tween.kill()
			}
			tweens.removeAll()
		}
		TweenManager.sharedInstance.removeAllFromCache()
	}
}