//
//  TweenGroup.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import Foundation

public class TweenGroup {
	public var tweens = [Tween]()
	public var delay: CFTimeInterval = 0
	public var duration: CFTimeInterval = 1.0
	public var active = false
	
	private var elapsed: CFTimeInterval = 0
	
	// MARK: Lifecycle
	
	init() {
		
	}
	
	// MARK: Public Methods
	
	public func delay(delay: CFTimeInterval) -> TweenGroup {
		for tween in tweens {
			tween.delay(delay)
		}
		return self
	}
	
	public func ease(easing: Ease) -> TweenGroup {
		for tween in tweens {
			tween.ease(easing)
		}
		return self
	}
	
	public func stagger(offset: CFTimeInterval) -> TweenGroup {
		var delay: CFTimeInterval = 0
		for tween in tweens {
			tween.stagger(delay)
			delay += offset
		}
		return self
	}
	
	public func play() {
		for tween in tweens {
			tween.play()
		}
	}
	
	public func pause() {
		for tween in tweens {
			tween.pause()
		}
	}
	
	public func resume() {
		for tween in tweens {
			tween.resume()
		}
	}
	
	public func kill() {
		for tween in tweens {
			tween.kill()
		}
	}
	
	// MARK: Internal Methods
	
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