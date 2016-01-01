//
//  Timeline.swift
//  Tween
//
//  Created by Nicholas Shipes on 12/27/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public class Timeline: Animation {
	public var tweens = [Tween]()
	override var endTime: CFTimeInterval {
		get {
			var time: CFTimeInterval = startTime
			for tween in tweens {
				time = max(time, tween.startTime + tween.duration)
			}
			return time
		}
	}
	override var totalTime: CFTimeInterval {
		get {
			return (elapsed - delay)
		}
	}
	override var totalDuration: CFTimeInterval {
		get {
			return (endTime * CFTimeInterval(repeatCount + 1)) + (repeatDelay * CFTimeInterval(repeatCount))
		}
	}
	
	private var labels = [String: CFTimeInterval]()
	
	// MARK: Public Methods
	
	public func add(tween: Tween) {
		add(tween, position: endTime)
	}
	
	public func add(tween: Tween, position: CFTimeInterval) {
//		if let time = position as? CFTimeInterval {
//			
//		} else if let label = position as? String {
//			let regex = try! NSRegularExpression(pattern: "(\\w+)?(?:+|\\-)=(\\d+)", options: [])
////			let matches = regex.matchesInString(label, options: [], range: NSRange(location: 0, length: label.length))
////			print(matches)
//		}
		
		// set startTime on tween...
		tween.startTime = position + tween.delay
		
		// remove tween from existing timeline (if `timeline` is not nil)... assign timeline to this
		if let timeline = tween.timeline {
			timeline.remove(tween)
		}
		tween.timeline = self
		tweens.append(tween)
		
		// assign references to prev and next tweens...
		
	}
	
	public func add(tween: Tween, relativeToLabel label: String, offset: CFTimeInterval) {
		if labels[label] == nil {
			addLabel(label)
		}
		
		if let position = labels[label] {
			add(tween, position: position + offset)
		}
	}
	
	public func addLabel(label: String, position: CFTimeInterval = 0) {
		labels[label] = position
	}
	
	public func seekToLabel(label: String, pause: Bool = false) {
		if let position = labels[label] {
			seek(position)
			if pause {
				self.pause()
			}
		}
	}
	
	public func getActive() -> [Tween] {
		var tweens = [Tween]()
		for tween in self.tweens {
			if tween.animating && !tween.paused {
				tweens.append(tween)
			}
		}
		
		return tweens
	}
	
	public func remove(tween: Tween) {
		if let timeline = tween.timeline, index = tweens.indexOf(tween) {
			if timeline == self {
				tween.timeline = nil
				tweens.removeAtIndex(index)
			}
		}
	}
	
	// MARK: Animation
	
	override public func play() -> Timeline {
		guard !active else { return self }
		
		super.play()
		TweenManager.sharedInstance.add(self)
		
		for tween in tweens {
			tween.play()
		}
		
		return self
	}
	
	override public func seek(time: CFTimeInterval) -> Timeline {
		super.seek(time)
		
		for tween in tweens {
			let tweenSeek = time - tween.startTime
			if tweenSeek >= 0 {
				tween.seek(tweenSeek)
			}
		}
		return self
	}
	
	override public func reverse() -> Timeline {
		super.reverse()
		
		for tween in tweens {
			tween.reverse()
		}
		
		return self
	}
	
	override public func forward() -> Timeline {
		super.forward()
		
		for tween in tweens {
			tween.forward()
		}
		
		return self
	}
	
	override public func restart(includeDelay: Bool) {
		super.restart(includeDelay)
		
		for tween in tweens {
			tween.restart(includeDelay)
		}
	}
	
	override public func kill() {
		super.kill()
		TweenManager.sharedInstance.remove(self)
	}
	
	// MARK: Internal Methods
	
	override func proceed(var dt: CFTimeInterval, force: Bool = false) -> Bool {
		if !running {
			return true
		}
		if paused {
			return false
		}
		
		if reversed {
			dt *= -1
		}
		elapsed += dt
		
		if elapsed < (delay + repeatDelay) {
			if reversed {
				return completed()
			} else {
				return false
			}
		}
		
		var done = true
		if !animating {
			started()
		}
		
		for tween in tweens {
			if tween.active {
				done = false
			}
		}
		
		// make sure we don't consider timeline done if we currently don't have any tweens playing
		done = (elapsed <= delay || elapsed >= endTime)
		if done {
			return completed()
		}
		return false
	}
}