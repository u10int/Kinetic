//
//  Motion.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/28/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class Motion {
	
	// MARK: Class Methods
	
	static func to(item: AnyObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: nil, to: options, mode: .To)
		tween.duration = duration
		
		return tween
	}
	
	static func from(item: AnyObject, duration: CFTimeInterval, options: [Property]) -> Tween {
		let tween = Tween(target: item, from: options, to: nil, mode: .From)
		tween.duration = duration
		
		return tween
	}
	
	static func fromTo(item: AnyObject, duration: CFTimeInterval, from: [Property], to: [Property]) -> Tween {
		let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
		tween.duration = duration
		
		return tween
	}
	
	static func itemsTo(items: [AnyObject], duration: CFTimeInterval, options: [Property]) -> TweenGroup {
		let group = TweenGroup()
		
		items.forEach { (item) -> () in
			let tween = Tween(target: item, from: nil, to: options, mode: .To)
			tween.duration = duration
			tween.group = group
			group.addTween(tween)
		}
		
		return group
	}
	
	static func itemsFrom(items: [AnyObject], duration: CFTimeInterval, options: [Property]) -> TweenGroup {
		let group = TweenGroup()
		
		items.forEach { (item) -> () in
			let tween = Tween(target: item, from: options, to: nil, mode: .From)
			tween.duration = duration
			tween.group = group
			group.addTween(tween)
		}
		
		return group
	}
	
	static func itemsFromTo(items: [AnyObject], duration: CFTimeInterval, from: [Property], to: [Property]) -> TweenGroup {
		let group = TweenGroup()
		
		items.forEach { (item) -> () in
			let tween = Tween(target: item, from: from, to: to, mode: .FromTo)
			tween.duration = duration
			tween.group = group
			group.addTween(tween)
		}
		
		return group
	}
	
	static func killTweensOf(target: AnyObject) {
		
	}
}