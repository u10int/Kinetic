//
//  TweenGroup.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import Foundation

class TweenGroup {
	var tweens = [Tween]()
	var properties = [AnimatableProperty]()
	var elapsed: CFTimeInterval = 0
	var delay: CFTimeInterval = 0
	var duration: CFTimeInterval = 1.0
	
	// MARK: Lifecycle
	
	init() {
		
	}
	
	// MARK: Public Methods
	
	func delay(delay: CFTimeInterval) -> TweenGroup {
		for tween in tweens {
			tween.delay(delay)
		}
		return self
	}
	
	func ease(easing: Ease) -> TweenGroup {
		for tween in tweens {
			tween.ease(easing)
		}
		return self
	}
	
	func stagger(offset: CFTimeInterval) -> TweenGroup {
		var delay: CFTimeInterval = 0
		for tween in tweens {
			tween.stagger(delay)
			delay += offset
		}
		return self
	}
	
	func start() {
		for tween in tweens {
			tween.start()
		}
	}
	
	func pause() {
		for tween in tweens {
			tween.pause()
		}
	}
	
	func resume() {
		for tween in tweens {
			tween.resume()
		}
	}
	
	func prepare() {
		elapsed = 0
		
//		for prop in properties {
////			prop.prepare()
//			prop.calc()
//		}
	}
	
	func proceed(dt: CFTimeInterval) -> Bool {
		elapsed += dt
		
		if tweens.count == 0 {
			return true
		}
		
		// proceed each tween
		var done = true
		for tween in tweens {
			if !tween.proceed(dt) {
				done = false
			}
		}
		
		return done
	}
	
	func addTween(tween: Tween) {
		tweens.append(tween)
	}
}