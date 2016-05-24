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
	
	for (idx, target) in targets.enumerate() {
		let tween = Tween(target: target)
		timeline.add(tween, position: 0)
	}
	
	return timeline
}

public func set(target: NSObject, props: Property...) {
	set(target, props: props)
}

public func setAll(targets: [NSObject], props: Property...) {
	for (_, target) in targets.enumerate() {
		set(target, props: props)
	}
}

public func tweensOf(target: NSObject) -> [Tween]? {
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

// MARK: Private Methods

private func set(target: NSObject, props: [Property]) {
	let tween = Tween(target: target)
	tween.to(props)
	tween.duration(0)
	tween.seek(tween.duration)
}