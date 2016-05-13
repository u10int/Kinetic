//
//  Timeline.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/27/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

internal class TimelineCallback {
	var block: () -> Void
	var called = false
	
	init(block: () -> Void) {
		self.block = block
	}
}

public enum TweenAlign {
	case Normal
	case Sequence
	case Start
}

public class Timeline: Animation, Tweenable {
	public typealias TweenType = Timeline
	public typealias AnimationType = Timeline
	
	public var tweens = [Tween]()
	weak public var timeline: Timeline?
	override public var endTime: CFTimeInterval {
		get {
			var time: CFTimeInterval = startTime
			for tween in tweens {
				time = max(time, tween.startTime + tween.duration)
			}
			return time
		}
	}
	override public var duration: CFTimeInterval {
		get {
			return endTime
		}
		set(newValue) {
			
		}
	}
	override public var totalTime: CFTimeInterval {
		get {
			return runningTime
		}
	}
	override public var totalDuration: CFTimeInterval {
		get {
			return (endTime * CFTimeInterval(repeatCount + 1)) + (repeatDelay * CFTimeInterval(repeatCount))
		}
	}
	public var antialiasing: Bool = true {
		didSet {
			for tween in tweens {
				tween.antialiasing = antialiasing
			}
		}
	}
	
	private var labels = [String: CFTimeInterval]()
	private var callbacks = [CFTimeInterval: TimelineCallback]()
	
	// MARK: Lifecycle
	
	public convenience init(tweens: [Tween], align: TweenAlign = .Normal) {
		self.init()
		add(tweens, position: 0, align: align)
	}
	
	deinit {
		kill()
	}
	
	// MARK: Public Methods
	
	public func add(tween: Tween) -> Timeline {
		add(tween, position: endTime)
		return self
	}
	
	public func add(value: AnyObject, position: AnyObject, align: TweenAlign = .Normal) -> Timeline {
		var tweensToAdd = [Tween]()
		if let tween = value as? Tween {
			tweensToAdd.append(tween)
		} else if let items = value as? [Tween] {
			tweensToAdd = items
		} else {
			assert(false, "Only a single Tween instance or an array of Tween instances can be provided")
			return self
		}
		
		var pos: CFTimeInterval = 0
		for (idx, tween) in tweensToAdd.enumerate() {
			if idx == 0 {
				if let time = position as? CFTimeInterval {
					pos = time
				} else if let label = position as? NSString {
					pos = timeFromString(label, relativeToTime: endTime)
				}
			}
			if align != .Start {
				pos += tween.delay
			}
			tween.startTime = pos
			
			if align == .Sequence {
				pos += tween.totalDuration
			}
			
			// remove tween from existing timeline (if `timeline` is not nil)... assign timeline to this
			if let timeline = tween.timeline {
				timeline.remove(tween)
			}
			tween.timeline = self
			tweens.append(tween)
		}
		
		return self
	}
	
	public func add(tween: Tween, relativeToLabel label: String, offset: CFTimeInterval) -> Timeline {
		if labels[label] == nil {
			addLabel(label)
		}
		
		if let position = labels[label] {
			add(tween, position: position + offset)
		}
		
		return self
	}
	
	public func addLabel(label: String, position: AnyObject = 0) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let time = position as? CFTimeInterval {
			pos = time
		} else if let label = position as? NSString {
			pos = timeFromString(label, relativeToTime: endTime)
		}
		
		labels[label] = pos
		
		return self
	}
	
	public func addCallback(position: AnyObject, block: () -> Void) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let time = position as? CFTimeInterval {
			pos = time
		} else if let label = position as? NSString {
			pos = timeFromString(label, relativeToTime: endTime)
		}
		
		callbacks[pos] = TimelineCallback(block: block)
		
		return self
	}
	
	public func removeLabel(label: String) {
		labels[label] = nil
	}
	
	public func timeForLabel(label: String) -> CFTimeInterval {
		if let time = labels[label] {
			return time
		}
		return 0
	}
	
	public func seekToLabel(label: String, pause: Bool = false) {
		if let position = labels[label] {
			seek(position)
			if pause {
				self.pause()
			}
		}
	}
	
	public func shift(amount: CFTimeInterval, afterTime time: CFTimeInterval = 0) -> Timeline {
		for tween in tweens {
			if tween.startTime >= time {
				tween.startTime += amount
				if tween.startTime <= 0 {
					tween.startTime = 0
				}
			}
		}
		for (label, var labelTime) in labels {
			if labelTime >= time {
				labelTime += amount
				if labelTime < 0 {
					labelTime = 0
				}
				labels[label] = labelTime
			}
		}
		return self
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
	
	// MARK: Tweenable
	
	public func from(props: Property...) -> Timeline {
		for tween in tweens {
			tween.from(props)
		}
		return self
	}
	
	public func to(props: Property...) -> Timeline {
		for tween in tweens {
			tween.to(props)
		}
		return self
	}
	
	override public func duration(duration: CFTimeInterval) -> Timeline {
		for tween in tweens {
			tween.duration(duration)
		}
		return self
	}
	
	public func ease(easing: Ease) -> Timeline {
		for tween in tweens {
			tween.ease(easing)
		}
		return self
	}
	
	public func spring(tension tension: Double, friction: Double) -> Timeline {
		for tween in tweens {
			tween.spring(tension: tension, friction: friction)
		}
		return self
	}
	
	public func perspective(value: CGFloat) -> Timeline {
		for tween in tweens {
			tween.perspective(value)
		}
		return self
	}
	
	public func anchor(anchor: Anchor) -> Timeline {
		return anchorPoint(anchor.point())
	}
	
	public func anchorPoint(point: CGPoint) -> Timeline {
		for tween in tweens {
			tween.anchorPoint(point)
		}
		return self
	}
	
	public func stagger(offset: CFTimeInterval) -> Timeline {
		for (idx, tween) in tweens.enumerate() {
			tween.startTime = offset * CFTimeInterval(idx)
		}
		return self
	}
	
	// MARK: Animation
	
	override public func play() -> Timeline {
		guard !active else { return self }
		
		super.play()
		run()
		
		for tween in tweens {
			tween.play()
		}
		
		return self
	}
	
	public func goToAndPlay(label: String) -> Timeline {
		let position = timeForLabel(label)
		seek(position)
		resume()
		
		return self
	}
	
	override public func stop() {
		super.stop()
		for tween in tweens {
			tween.stop()
		}
	}
	
	public func goToAndStop(label: String) -> Timeline {
		seekToLabel(label, pause: true)
		
		return self
	}
	
	override public func pause() {
		super.pause()
		for tween in tweens {
			tween.pause()
		}
	}
	
	override public func resume() {
		super.resume()
		if !running {
			run()
		}
		
		for tween in tweens {
			tween.resume()
		}
	}
	
	override public func seek(time: CFTimeInterval) -> Timeline {
		super.seek(time)
		
		let elapsedTime = elapsedTimeFromSeekTime(time)
		for tween in tweens {
			var tweenSeek = elapsedTime - tween.startTime
			
			// make sure tween snaps to 0 or totalDuration value if tweenSeek is beyond bounds
			if tweenSeek < 0 && tween.elapsed > 0 {
				tweenSeek = 0
			} else if tweenSeek > tween.totalDuration && tween.elapsed < tween.totalDuration {
				tweenSeek = tween.totalDuration
			}
			
			if tweenSeek >= 0 && tweenSeek <= tween.totalDuration {
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
		for (_, callback) in callbacks {
			callback.called = false
		}
	}
	
	override public func kill() {
		super.kill()
		
		TweenManager.sharedInstance.remove(self)
		for tween in tweens {
			tween.kill()
		}
	}
	
	// MARK: Internal Methods
	
	override func reset() {
		super.reset()
		for tween in tweens {
			tween.reset()
		}
	}
	
	override func proceed(dt: CFTimeInterval, force: Bool = false) -> Bool {
		if !running {
			return true
		}
		if paused {
			return false
		}
		
		if tweens.count == 0 {
			kill()
		}
		
		let multiplier: CFTimeInterval = reversed ? -1 : 1
		elapsed = elapsed + (dt * multiplier)
		runningTime += dt
		
		// if animation doesn't repeat forever, cap elapsed time to endTime
		if !repeatForever {
			elapsed = min(elapsed, endTime)
		}
		
		// check for callbacks
		if callbacks.count > 0 {
			for (t, callback) in callbacks {
				if elapsed >= t && !callback.called {
					callback.block()
					callback.called = true
				}
			}
		}
		
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
		
		updateBlock?(self)
		
		// make sure we don't consider timeline done if we currently don't have any tweens playing
		done = (elapsed <= delay || elapsed >= endTime)
		if done {
			return completed()
		}
		return false
	}
	
	// MARK: Private Methods
	
	private func run() {
		running = true
		TweenManager.sharedInstance.add(self)
	}
	
	private func timeFromString(string: NSString, relativeToTime time: CFTimeInterval = 0) -> CFTimeInterval {
		var position: CFTimeInterval = time
		
		let regex = try! NSRegularExpression(pattern: "(\\w+)?([\\+,\\-]=)(\\d+)", options: [])
		let match = regex.firstMatchInString(string as String, options: [], range: NSRange(location: 0, length: string.length))
		if let match = match {
			var idx = 1
			var multiplier: CFTimeInterval = 1
			while idx < match.numberOfRanges {
				let range = match.rangeAtIndex(idx)
				if range.length <= string.length && range.location < string.length {
					let val = string.substringWithRange(range)
					// label
					if idx == 1 {
						position = timeForLabel(val)
					} else if idx == 2 {
						if val == "-=" {
							multiplier = -1
						}
					} else if idx == 3 {
						position += CFTimeInterval(val)!
					}
				}
				idx += 1
			}
			position *= multiplier
		}
		
		return position
	}
}