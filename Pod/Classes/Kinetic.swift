//
//  Kinetic.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/19/16.
//
//

import UIKit

public func animate(_ target: Tweenable) -> Tween {
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

// MARK: TweenCache

final internal class TweenCache {
	public static let session = TweenCache()
	
	fileprivate var tweenCache = [NSObject: [Tween]]()
	fileprivate var activeKeys = [String: Int]()
	
	internal func cache(_ tween: Tween, target: Tweenable) {
		guard let obj = target as? NSObject else {
			assert(false, "Tween target must be of type NSObject")
			return
		}
		
		if tweenCache[obj] == nil {
			tweenCache[obj] = [Tween]()
		}
		if let tweens = tweenCache[obj], tweens.contains(tween) == false {
			tweenCache[obj]?.append(tween)
		}
	}
	
	internal func removeFromCache(_ tween: Tween, target: Tweenable) {
		guard let obj = target as? NSObject else {
			assert(false, "Tween target must be of type NSObject")
			return
		}
		
		if let tweens = tweenCache[obj] {
			if let index = tweens.index(of: tween) {
				tweenCache[obj]?.remove(at: index)
			}
			
			// remove object reference if all tweens have been removed from cache
			if tweenCache[obj]?.count == 0 {
				removeFromCache(target)
			}
		}
	}
	
	internal func removeFromCache(_ target: Tweenable) {
		guard let obj = target as? NSObject else {
			assert(false, "Tween target must be of type NSObject")
			return
		}
		
		tweenCache[obj] = nil
	}
	
	internal func removeAllFromCache() {
		tweenCache.removeAll()
	}
	
	internal func tweens(ofTarget target: Tweenable, activeOnly: Bool = false) -> [Tween]? {
		guard let obj = target as? NSObject else {
			assert(false, "Tween target must be of type NSObject")
			return nil
		}
		
		return tweenCache[obj]
	}
	
	internal func allTweens() -> [NSObject: [Tween]] {
		return tweenCache
	}
	
	internal func addActiveKeys(keys: [String], toTarget target: Tweenable) {
		keys.forEach { (key) in
			var count = 1
			if let pcount = activeKeys[key] {
				count = pcount + 1
			}
			activeKeys[key] = count
		}
	}
	
	internal func removeActiveKeys(keys: [String], ofTarget target: Tweenable) {
		keys.forEach { (key) in
			var count = 0
			if let pcount = activeKeys[key] {
				count = pcount - 1
			}
			if count <= 0  {
				activeKeys[key] = nil
			} else {
				activeKeys[key] = count
			}
		}
	}
	
	internal func hasActiveTween(forKey key: String, ofTarget target: Tweenable) -> Bool {
		return activeKeys[key] != nil
	}
}
