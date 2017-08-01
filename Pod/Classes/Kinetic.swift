//
//  Kinetic.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/19/16.
//
//

import UIKit

public func animate(_ target: Tweenable) -> Tween {
	assert(target is [NSObject] == false, "Cannot create animation using `animate:` for array target, use `animateAll` instead.")
	let tween = Tween(target: target)
	return tween
}

public func animateAll(_ targets: [Tweenable]) -> Timeline {
	let timeline = Timeline()
	
	for (_, target) in targets.enumerated() {
		let tween = Tween(target: target)
		timeline.add(tween, position: 0)
	}
	
	return timeline
}

public func set(_ target: Tweenable, props: Property...) {
	let tween = Tween(target: target)
	tween.from(props).to(props)
	tween.duration = 0
	tween.seek(tween.duration)
}

public func setAll(_ targets: [Tweenable], props: Property...) {
	for (_, item) in targets.enumerated() {
		let tween = Tween(target: item)
		tween.from(props).to(props)
		tween.duration = 0
		tween.seek(tween.duration)
	}
}

public func tweensOf(_ target: Tweenable) -> [Tween]? {
	return TweenCache.session.tweens(ofTarget: target)
}

public func killTweensOf(_ target: Tweenable) {
	if let tweens = TweenCache.session.tweens(ofTarget: target) {
		for tween in tweens {
			tween.timeline?.remove(tween: tween)
			tween.kill()
		}
	}
	TweenCache.session.removeFromCache(target)
}

public func killAll() {
	for (_, var tweens) in TweenCache.session.allTweens() {
		for tween in tweens {
			tween.timeline?.remove(tween: tween)
			tween.kill()
		}
		tweens.removeAll()
	}
	TweenCache.session.removeAllFromCache()
}
