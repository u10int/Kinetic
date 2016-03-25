//
//  Kinetic.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/19/16.
//
//

import UIKit


public func to(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
	let tween = Tween(target: item, from: nil, to: options, mode: .To)
	tween.duration = duration
	
	return tween
}

public func from(item: NSObject, duration: CFTimeInterval, options: [Property]) -> Tween {
	let tween = Tween(target: item, from: options, to: nil, mode: .From)
	tween.duration = duration
	
	return tween
}

public func fromTo(item: NSObject, duration: CFTimeInterval, from: [Property], to: [Property]) -> Tween {
	let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
	tween.duration = duration
	
	return tween
}

public func set(item: NSObject, options: [Property]) -> Tween {
	let tween = Tween(target: item, from: nil, to: options, mode: .To)
	tween.duration = 0
	tween.seek(tween.duration)
	
	return tween
}

public func itemsTo(items: [NSObject], duration: CFTimeInterval, options: [Property]) -> Timeline {
	return staggerTo(items, duration: duration, options: options, stagger: 0)
}

public func itemsFrom(items: [NSObject], duration: CFTimeInterval, options: [Property]) -> Timeline {
	return staggerFrom(items, duration: duration, options: options, stagger: 0)
}

public func itemsFromTo(items: [NSObject], duration: CFTimeInterval, from: [Property], to: [Property]) -> Timeline {
	return staggerFromTo(items, duration: duration, from: from, to: to, stagger: 0)
}

public func itemsSet(items: [NSObject], options: [Property]) {
	for (_, item) in items.enumerate() {
		let tween = Tween(target: item, from: nil, to: options, mode: .To)
		tween.duration = 0
		tween.seek(tween.duration)
	}
}

public func staggerTo(items: [NSObject], duration: CFTimeInterval, options: [Property], stagger: CFTimeInterval) -> Timeline {
	let timeline = Timeline()
	
	for (idx, item) in items.enumerate() {
		let tween = Tween(target: item, from: nil, to: options, mode: .To)
		tween.duration = duration
		timeline.add(tween, position: stagger * CFTimeInterval(idx))
	}
	
	return timeline
}

public func staggerFrom(items: [NSObject], duration: CFTimeInterval, options: [Property], stagger: CFTimeInterval) -> Timeline {
	let timeline = Timeline()
	
	for (idx, item) in items.enumerate() {
		let tween = Tween(target: item, from: options, to: nil, mode: .To)
		tween.duration = duration
		timeline.add(tween, position: stagger * CFTimeInterval(idx))
	}
	
	return timeline
}

public func staggerFromTo(items: [NSObject], duration: CFTimeInterval, from: [Property], to: [Property], stagger: CFTimeInterval) -> Timeline {
	let timeline = Timeline()
	
	for (idx, item) in items.enumerate() {
		let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
		tween.duration = duration
		timeline.add(tween, position: stagger * CFTimeInterval(idx))
	}
	
	return timeline
}

public func getTweensOf(target: NSObject) -> [Tween]? {
	return TweenManager.sharedInstance.tweensOfTarget(target)
}

public func killTweensOf(target: NSObject) {
	if let tweens = TweenManager.sharedInstance.tweensOfTarget(target) {
		for tween in tweens {
			tween.kill()
			tween.timeline?.remove(tween)
		}
	}
	TweenManager.sharedInstance.removeFromCache(target)
}

public func killAll() {
	for (_, var tweens) in TweenManager.sharedInstance.cache {
		for tween in tweens {
			tween.kill()
			tween.timeline?.remove(tween)
		}
		tweens.removeAll()
	}
	TweenManager.sharedInstance.removeAllFromCache()
}
