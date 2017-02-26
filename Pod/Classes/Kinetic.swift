//
//  Kinetic.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/19/16.
//
//

import UIKit

public func animate(_ target: NSObject) -> Tween {
	assert(target is [NSObject] == false, "Cannot create animation using `animate:` for array target, use `animateAll` instead.")
	let tween = Tween(target: target)
	return tween
}

public func animateAll(_ targets: [NSObject]) -> Timeline {
	let timeline = Timeline()
	
	for (idx, target) in targets.enumerated() {
		let tween = Tween(target: target)
		timeline.add(tween, position: 0)
	}
	
	return timeline
}

public func set(_ target: NSObject, props: Property...) {
	set(target, props: props)
}

public func setAll(_ targets: [NSObject], props: Property...) {
	for (_, target) in targets.enumerated() {
		set(target, props: props)
	}
}

public func tweensOf(_ target: NSObject) -> [Tween]? {
	return TweenManager.sharedInstance.tweensOfTarget(target)
}

public func killTweensOf(_ target: NSObject) {
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

private func set(_ target: NSObject, props: [Property]) {
	let tween = Tween(target: target)
	tween.to(props)
	tween.duration(0)
	tween.seek(tween.duration)
}
