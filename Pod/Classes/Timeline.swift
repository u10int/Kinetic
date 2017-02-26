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
	
	init(block: @escaping () -> Void) {
		self.block = block
	}
}

public enum TweenAlign {
	case normal
	case sequence
	case start
}

open class Timeline: Animation, Tweenable {
	public typealias TweenType = Timeline
	public typealias AnimationType = Timeline
	
	open var tweens = [Tween]()
	weak open var timeline: Timeline?
	override open var endTime: CFTimeInterval {
		get {
			var time: CFTimeInterval = startTime
			for tween in tweens {
				time = max(time, tween.startTime + tween.duration)
			}
			return time
		}
	}
	override open var duration: CFTimeInterval {
		get {
			return endTime
		}
	}
	override open var totalTime: CFTimeInterval {
		get {
			return runningTime
		}
	}
	override open var totalDuration: CFTimeInterval {
		get {
			return (endTime * CFTimeInterval(repeatCount + 1)) + (repeatDelay * CFTimeInterval(repeatCount))
		}
	}
	open var antialiasing: Bool = true {
		didSet {
			for tween in tweens {
				tween.antialiasing = antialiasing
			}
		}
	}
	
	fileprivate var labels = [String: CFTimeInterval]()
	fileprivate var callbacks = [CFTimeInterval: TimelineCallback]()
	
	// MARK: Lifecycle
	
	public convenience init(tweens: [Tween], align: TweenAlign = .normal) {
		self.init()
		add(tweens, position: 0, align: align)
	}
	
	deinit {
		kill()
	}
	
	// MARK: Public Methods
	
	@discardableResult
	open func add(_ tween: Tween) -> Timeline {
		add(tween, position: endTime)
		return self
	}
	
	@discardableResult
	open func add(_ value: Any, position: Any, align: TweenAlign = .normal) -> Timeline {
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
		for (idx, tween) in tweensToAdd.enumerated() {
			if idx == 0 {
				if let time = position as? CFTimeInterval {
					pos = time
				} else if let label = position as? NSString {
					pos = timeFromString(label, relativeToTime: endTime)
				}
			}
			if align != .start {
				pos += tween.delay
			}
			tween.startTime = pos
			
			if align == .sequence {
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
	
	@discardableResult
	open func add(_ tween: Tween, relativeToLabel label: String, offset: CFTimeInterval) -> Timeline {
		if labels[label] == nil {
			addLabel(label)
		}
		
		if let position = labels[label] {
			add(tween, position: position + offset)
		}
		
		return self
	}
	
	@discardableResult
	open func addLabel(_ label: String, position: Any = 0) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let time = position as? CFTimeInterval {
			pos = time
		} else if let label = position as? NSString {
			pos = timeFromString(label, relativeToTime: endTime)
		}
		
		labels[label] = pos
		
		return self
	}
	
	@discardableResult
	open func addCallback(_ position: Any, block: @escaping () -> Void) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let time = position as? CFTimeInterval {
			pos = time
		} else if let label = position as? NSString {
			pos = timeFromString(label, relativeToTime: endTime)
		}
		
		callbacks[pos] = TimelineCallback(block: block)
		
		return self
	}
	
	open func removeLabel(_ label: String) {
		labels[label] = nil
	}
	
	open func timeForLabel(_ label: String) -> CFTimeInterval {
		if let time = labels[label] {
			return time
		}
		return 0
	}
	
	open func seekToLabel(_ label: String, pause: Bool = false) {
		if let position = labels[label] {
			seek(position)
			if pause {
				self.pause()
			}
		}
	}
	
	@discardableResult
	open func shift(_ amount: CFTimeInterval, afterTime time: CFTimeInterval = 0) -> Timeline {
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
	
	open func getActive() -> [Tween] {
		var tweens = [Tween]()
		for tween in self.tweens {
			if tween.animating && !tween.paused {
				tweens.append(tween)
			}
		}
		
		return tweens
	}
	
	open func remove(_ tween: Tween) {
		if let timeline = tween.timeline, let index = tweens.index(of: tween) {
			if timeline == self {
				tween.timeline = nil
				tweens.remove(at: index)
			}
		}
	}
	
	// MARK: Tweenable
	
	@discardableResult
	open func from(_ props: Property...) -> Timeline {
		for tween in tweens {
			tween.from(props)
		}
		return self
	}
	
	@discardableResult
	open func to(_ props: Property...) -> Timeline {
		for tween in tweens {
			tween.to(props)
		}
		return self
	}
	
	@discardableResult
	override open func duration(_ duration: CFTimeInterval) -> Timeline {
		for tween in tweens {
			tween.duration(duration)
		}
		return self
	}
	
	@discardableResult
	open func ease(_ easing: @escaping Ease) -> Timeline {
		for tween in tweens {
			tween.ease(easing)
		}
		return self
	}
	
	@discardableResult
	open func spring(tension: Double, friction: Double) -> Timeline {
		for tween in tweens {
			tween.spring(tension: tension, friction: friction)
		}
		return self
	}
	
	@discardableResult
	open func perspective(_ value: CGFloat) -> Timeline {
		for tween in tweens {
			tween.perspective(value)
		}
		return self
	}
	
	@discardableResult
	open func anchor(_ anchor: Anchor) -> Timeline {
		return anchorPoint(anchor.point())
	}
	
	@discardableResult
	open func anchorPoint(_ point: CGPoint) -> Timeline {
		for tween in tweens {
			tween.anchorPoint(point)
		}
		return self
	}
	
	@discardableResult
	open func stagger(_ offset: CFTimeInterval) -> Timeline {
		for (idx, tween) in tweens.enumerated() {
			tween.startTime = tween.delay + offset * CFTimeInterval(idx)
		}
		return self
	}
	
	// MARK: Animation
	
	@discardableResult
	override open func play() -> Timeline {
		guard !active else { return self }
		
		super.play()
		run()
		
		for tween in tweens {
			tween.play()
		}
		
		return self
	}
	
	@discardableResult
	open func goToAndPlay(_ label: String) -> Timeline {
		let position = timeForLabel(label)
		seek(position)
		resume()
		
		return self
	}
	
	override open func stop() {
		super.stop()
		for tween in tweens {
			tween.stop()
		}
	}
	
	@discardableResult
	open func goToAndStop(_ label: String) -> Timeline {
		seekToLabel(label, pause: true)
		
		return self
	}
	
	override open func pause() {
		super.pause()
		for tween in tweens {
			tween.pause()
		}
	}
	
	override open func resume() {
		super.resume()
		if !running {
			run()
		}
		
		for tween in tweens {
			tween.resume()
		}
	}
	
	@discardableResult
	override open func seek(_ time: CFTimeInterval) -> Timeline {
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
	
	@discardableResult
	override open func reverse() -> Timeline {
		super.reverse()
		for tween in tweens {
			tween.reverse()
		}
		
		return self
	}
	
	@discardableResult
	override open func forward() -> Timeline {
		super.forward()
		for tween in tweens {
			tween.forward()
		}
		
		return self
	}
	
	override open func restart(_ includeDelay: Bool) {
		super.restart(includeDelay)
		for tween in tweens {
			tween.restart(includeDelay)
		}
		for (_, callback) in callbacks {
			callback.called = false
		}
	}
	
	override open func kill() {
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
	
	override func proceed(_ dt: CFTimeInterval, force: Bool = false) -> Bool {
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
			elapsed = min(elapsed, (delay + endTime))
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
		done = (elapsed <= delay || elapsed >= (delay + endTime))
		if done {
			return completed()
		}
		return false
	}
	
	// MARK: Private Methods
	
	fileprivate func run() {
		running = true
		TweenManager.sharedInstance.add(self)
	}
	
	fileprivate func timeFromString(_ string: NSString, relativeToTime time: CFTimeInterval = 0) -> CFTimeInterval {
		var position: CFTimeInterval = time
		
		let regex = try! NSRegularExpression(pattern: "(\\w+)?([\\+,\\-]=)(\\d+)", options: [])
		let match = regex.firstMatch(in: string as String, options: [], range: NSRange(location: 0, length: string.length))
		if let match = match {
			var idx = 1
			var multiplier: CFTimeInterval = 1
			while idx < match.numberOfRanges {
				let range = match.rangeAt(idx)
				if range.length <= string.length && range.location < string.length {
					let val = string.substring(with: range)
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
