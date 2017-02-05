//
//  Kinetic.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/19/16.
//
//

import UIKit

public func animate(target: NSObject) -> Tween {
	assert(target is [NSObject] == false, "Cannot create animation using `animate:` for array target, use `animateAll` instead.")
	let tween = Tween(target: target)
	return tween
}

public func animateAll(targets: [NSObject]) -> Timeline {
	let timeline = Timeline()
	
	for (idx, target) in targets.enumerated() {
		let tween = Tween(target: target)
		timeline.add(tween, position: 0)
	}
	
	return timeline
}

public func set(target: NSObject, props: TweenProp...) {
	let tween = Tween(target: target)
	tween.to(props as! TweenProp)
	tween.duration = 0
	tween.seek(tween.duration)
}

public func setAll(targets: [NSObject], props: TweenProp...) {
	for (_, item) in targets.enumerated() {
		let tween = Tween(target: item)
		tween.to(props as! TweenProp)
		tween.duration = 0
		tween.seek(tween.duration)
	}
}

public func tweensOf(target: NSObject) -> [Tween]? {
	return Scheduler.sharedInstance.tweens(ofTarget: target)
}

public func killTweensOf(target: NSObject) {
	if let tweens = Scheduler.sharedInstance.tweens(ofTarget: target) {
		for tween in tweens {
			tween.kill()
			tween.timeline?.remove(tween: tween)
		}
	}
	Scheduler.sharedInstance.removeFromCache(target)
}

public func killAll() {
	for (_, var tweens) in Scheduler.sharedInstance.cache {
		for tween in tweens {
			tween.kill()
			tween.timeline?.remove(tween: tween)
		}
		tweens.removeAll()
	}
	Scheduler.sharedInstance.removeAllFromCache()
}
