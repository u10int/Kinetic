//
//  Timeline.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/27/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class Timeline: Animation {
	private var labels = [String: CFTimeInterval]()
	
	// MARK: Public Methods
	
	public func add(tween: Tween, position: CFTimeInterval) {
//		if let time = position as? CFTimeInterval {
//			
//		} else if let label = position as? String {
//			let regex = try! NSRegularExpression(pattern: "(\\w+)?(?:+|\\-)=(\\d+)", options: [])
////			let matches = regex.matchesInString(label, options: [], range: NSRange(location: 0, length: label.length))
////			print(matches)
//		}
		
		// set startTime on tween...
//		tween.startTime = position + tween.delay
		
		// remove tween from existing timeline (if `timeline` is not nil)... assign timeline to this
		
		// assign references to prev and next tweens...
		
	}
	
	public func add(tween: Tween, relativeToLabel label: String, offset: CFTimeInterval) {
		if labels[label] == nil {
			addLabel(label)
		}
	}
	
	public func addLabel(label: String, position: CFTimeInterval = 0) {
		labels[label] = position
	}
	
	public func remove(tween: Tween) {
		
	}
	
	// MARK: Animation
	
	public override func delay(delay: CFTimeInterval) -> Timeline {
		self.delay = delay
		return self
	}
	
	override public func play() -> Timeline {
		return self
	}
	
	override public func restart(includeDelay: Bool) {
		
	}
	
	override public func kill() {
		
	}
	
	// MARK: Internal Methods
	
	override func proceed(dt: CFTimeInterval) -> Bool {
		if super.proceed(dt) {
			return true
		}
		
		return false
	}
}