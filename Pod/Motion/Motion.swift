//
//  Motion.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/28/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class Motion {
	private static var tweenCache = [NSObject: [Tween]]()
	
	// MARK: Class Methods
	
	static func to(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: nil, to: options, mode: .To)
		tween.duration = duration
		cacheTween(tween, forObject: item)
		
		return tween
	}
	
	static func from(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: options, to: nil, mode: .From)
		tween.duration = duration
		cacheTween(tween, forObject: item)
		
		return tween
	}
	
	static func fromTo(item: NSObject, duration: CFTimeInterval, from: [Property], to: [Property]) -> Tween {
		let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
		tween.duration = duration
		cacheTween(tween, forObject: item)
		
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
			cacheTween(tween, forObject: item)
		}
		
		return timeline
	}
	
	static func staggerFrom(items: [NSObject], duration: CFTimeInterval, options: [Property], stagger: CFTimeInterval) -> Timeline {
		let timeline = Timeline()
		
		for (idx, item) in items.enumerate() {
			let tween = Tween(target: item, from: options, to: nil, mode: .To)
			tween.duration = duration
			timeline.add(tween, position: stagger * CFTimeInterval(idx))
			cacheTween(tween, forObject: item)
		}
		
		return timeline
	}
	
	static func staggerFromTo(items: [NSObject], duration: CFTimeInterval, from: [Property], to: [Property], stagger: CFTimeInterval) -> Timeline {
		let timeline = Timeline()
		
		for (idx, item) in items.enumerate() {
			let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
			tween.duration = duration
			timeline.add(tween, position: stagger * CFTimeInterval(idx))
			cacheTween(tween, forObject: item)
		}
		
		return timeline
	}
	
	static func killTweensOf(target: NSObject) {
		if let tweens = tweenCache[target] {
			for tween in tweens {
				tween.kill()
			}
		}
		tweenCache[target] = nil
	}
	
	static func killAll() {
		for (_, var tweens) in tweenCache {
			for tween in tweens {
				tween.kill()
			}
			tweens.removeAll()
		}
		tweenCache = [NSObject: [Tween]]()
	}
	
	// MARK: Private Methods
	
	static func cacheTween(tween: Tween, forObject object: NSObject) {
		if tweenCache[object] == nil {
			tweenCache[object] = [Tween]()
		}
		tweenCache[object]?.append(tween)
	}
}