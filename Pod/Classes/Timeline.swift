//
//  Timeline.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/27/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

internal class TimelineCallback {
	var time: TimeInterval = 0
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

public class Timeline: Animation {
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
	
	fileprivate var labels = [String: CFTimeInterval]()
	fileprivate var callbacks = [CFTimeInterval: TimelineCallback]()
	
	// MARK: Lifecycle
	
	public convenience init(tweens: [Tween], align: TweenAlign = .normal) {
		self.init()
		add(tweens, position: 0, align: align)
	}
	
	public override init() {
		super.init()
		
		repeated.observe { [weak self] (timeline) in
			self?.callbacks.forEach({ (time, fn) in
				fn.called = false
			})
		}
	}
	
	deinit {
		kill()
	}
	
	// MARK: Public Methods
	
	@discardableResult
	public func add(_ tween: Tween) -> Timeline {
		add(tween, position: endTime)
		return self
	}
	
	@discardableResult
	public func add(_ value: Any, position: Any, align: TweenAlign = .normal) -> Timeline {
		var tweensToAdd = [Tween]()
		if let tween = value as? Tween {
			tweensToAdd.append(tween)
		} else if let items = value as? [Tween] {
			tweensToAdd = items
		} else {
			assert(false, "Only a single Tween instance or an array of Tween instances can be provided")
			return self
		}
		
		var pos: TimeInterval = 0
		for (idx, tween) in tweensToAdd.enumerated() {
			if idx == 0 {
				if let label = position as? String {
					pos = time(fromString:label, relativeToTime: endTime)
				} else if let time = Double("\(position)") {
					pos = TimeInterval(time * 1.0)
				}
			}
			
			if align != .start {
				pos += tween.delay
			}
			
			tween.startTime = pos
			print("timeline - added tween at position \(position) with start time \(tween.startTime)")
			
			if align == .sequence {
				pos += tween.totalDuration
			}
			
			// remove tween from existing timeline (if `timeline` is not nil)... assign timeline to this
			if let timeline = tween.timeline {
				timeline.remove(tween: tween)
			}
			
			tween.timeline = self
			tweens.append(tween)
		}
		
		return self
	}
	
	@discardableResult
	public func add(_ tween: Tween, relativeToLabel label: String, offset: CFTimeInterval) -> Timeline {
		if labels[label] == nil {
			add(label: label)
		}
		
		if let position = labels[label] {
			add(tween, position: position + offset)
		}
		
		return self
	}
	
	@discardableResult
	public func add(label: String, position: Any = 0) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let label = position as? String {
			pos = time(fromString:label, relativeToTime: endTime)
		} else if let time = Double("\(position)") {
			pos = CFTimeInterval(time)
		}
		
		labels[label] = pos
		
		return self
	}
	
	@discardableResult
	public func addCallback(_ position: Any, block: @escaping () -> Void) -> Timeline {
		var pos: CFTimeInterval = 0
		
		if let label = position as? String {
			pos = time(fromString:label, relativeToTime: endTime)
		} else if let time = Double("\(position)") {
			pos = CFTimeInterval(time)
		}
		
		callbacks[pos] = TimelineCallback(block: block)
		callbacks[pos]?.time = pos
		
		return self
	}
	
	public func remove(_ label: String) {
		labels[label] = nil
	}
	
	public func time(forLabel label: String) -> CFTimeInterval {
		if let time = labels[label] {
			return time
		}
		return 0
	}
	
	public func seek(toLabel label: String, pause: Bool = false) {
		if let position = labels[label] {
			seek(position)
			if pause {
				self.pause()
			}
		}
	}
	
	@discardableResult
	public func shift(_ amount: CFTimeInterval, afterTime time: CFTimeInterval = 0) -> Timeline {
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
			if tween.state == .running {
				tweens.append(tween)
			}
		}
		
		return tweens
	}
	
	public func remove(tween: Tween) {
		if let timeline = tween.timeline, let index = tweens.index(of: tween) {
			if timeline == self {
				tween.timeline = nil
				tweens.remove(at: index)
			}
		}
	}
	
	@discardableResult
	public func from(_ props: Property...) -> Timeline {
		for tween in tweens {
			tween.from(props)
		}
		return self
	}
	
	@discardableResult
	public func to(_ props: Property...) -> Timeline {
		for tween in tweens {
			tween.to(props)
		}
		return self
	}
	
	@discardableResult
	override public func spring(tension: Double, friction: Double) -> Timeline {
		for tween in tweens {
			tween.spring(tension: tension, friction: friction)
		}
		return self
	}
	
	@discardableResult
	public func perspective(_ value: CGFloat) -> Timeline {
		for tween in tweens {
			tween.perspective(value)
		}
		return self
	}
	
	@discardableResult
	public func anchor(_ anchor: AnchorPoint) -> Timeline {
		return anchorPoint(anchor.point())
	}
	
	@discardableResult
	public func anchorPoint(_ point: CGPoint) -> Timeline {
		for tween in tweens {
			tween.anchorPoint(point)
		}
		return self
	}
	
	@discardableResult
	public func stagger(_ offset: CFTimeInterval) -> Timeline {
		for (idx, tween) in tweens.enumerated() {
			tween.startTime = tween.delay + offset * CFTimeInterval(idx)
		}
		return self
	}
	
	public func goToAndPlay(_ label: String) {
		let position = time(forLabel: label)
		seek(position)
		resume()
	}
	
	@discardableResult
	public func goToAndStop(_ label: String) -> Timeline {
		seek(toLabel: label, pause: true)
		
		return self
	}
	
	// MARK: Animation
	
//	override public var state: AnimationState {
//		didSet {
//			if state == .completed {
//				tweens.forEach({ (tween) in
//					tween.state = .completed
//				})
//			}
//		}
//	}
	
	@discardableResult
	override public func duration(_ duration: CFTimeInterval) -> Timeline {
		for tween in tweens {
			tween.duration(duration)
		}
		return self
	}
	
	@discardableResult
	override public func ease(_ easing: Easing.EasingType) -> Timeline {
		for tween in tweens {
			tween.ease(easing)
		}
		return self
	}
	
	override public func play() {
		guard state != .running && state != .cancelled else { return }
		
		super.play()

		tweens.forEach { (tween) in
			tween.play()
		}
	}
	
	override public func stop() {
		super.stop()
		
		tweens.forEach { (tween) in
			tween.stop()
		}
	}
	
	override public func pause() {
		super.pause()
		
		tweens.forEach { (tween) in
			tween.pause()
		}
	}
	
	override public func resume() {
		super.resume()
		
		for tween in tweens {
			tween.resume()
		}
	}
	
	@discardableResult
	override public func seek(_ time: CFTimeInterval) -> Timeline {
		super.seek(time)
		
//		let elapsedTime = elapsedTimeFromSeekTime(time)
		let elapsedTime = elapsed
//		print("timeline.seek - elapsedTime: \(elapsedTime), totalDuration: \(totalDuration), endTime: \(endTime), cycle: \(cycle)")
		for tween in tweens {
//			print("-----")
			var tweenSeek = max(0, min(elapsedTime - tween.startTime, tween.totalDuration))
			tweenSeek = elapsedTime - tween.startTime
			
			// if timeline is reversed, then the tween's seek time should be relative to its end time
			if direction == .reversed {
				tweenSeek = tween.endTime - elapsedTime
			}
//			print("tween.\(tween.id) seek - tweenSeek: \(tweenSeek), tween.start: \(tween.startTime), tween.end: \(tween.startTime + tween.totalDuration), tween.totalDuration: \(tween.totalDuration), tween.elapsed: \(tween.elapsed),")
			
			// make sure tween snaps to 0 or totalDuration value if tweenSeek is beyond bounds
//			if tweenSeek < 0 && tween.elapsed > 0 {
//				tweenSeek = 0
//			} else if tweenSeek > tween.totalDuration && tween.elapsed < tween.totalDuration {
//				tweenSeek = tween.totalDuration
//			}
//			
//			if tweenSeek >= 0 && tweenSeek <= tween.totalDuration {
//				tween.seek(tweenSeek)
//			}
			
			tween.seek(tweenSeek)
		}
		return self
	}
	
	@discardableResult
	override public func reverse() -> Timeline {
		super.reverse()
		
		for tween in tweens {
			tween.reverse()
		}
		
		return self
	}
	
	@discardableResult
	override public func forward() -> Timeline {
		super.forward()
		
		for tween in tweens {
			tween.forward()
		}
		
		return self
	}
	
	override public func restart(_ includeDelay: Bool) {
		super.restart(includeDelay)
		
		for tween in tweens {
			tween.restart(includeDelay)
		}
		
		for (_, callback) in callbacks {
			callback.called = false
		}
	}
	
	override func reset() {
		super.reset()
		
		for tween in tweens {
			tween.reset()
		}
	}
	
	override public func kill() {
		super.kill()
		
		for tween in tweens {
			tween.kill()
		}
	}
	
	// MARK: Reversable
	
	override public var direction: Direction {
		didSet {
			tweens.forEach { (tween) in
				tween.direction = direction
			}
		}
	}
	
	// MARK: TimeRenderable
	
	override internal func render(time: TimeInterval, advance: TimeInterval = 0) {
		super.render(time: time, advance: advance)

		for tween in tweens {
			var tweenAdvance = advance
			var tweenTime = max(0, min(elapsed - tween.startTime, tween.totalDuration))
			
			tweenTime = elapsed - tween.startTime
			
			if tweenTime < 0 {
				tweenAdvance = 0
				tween.state = .pending
			} else if tweenTime > tween.totalDuration {
				tweenAdvance = 0
				tween.state = .completed
			} else {
				tween.state = .running
			}
			
			tween.render(time: tweenTime, advance: tweenAdvance)
		}
	}
	
	// MARK: Subscriber
	
	override func advance(_ time: Double) {
		guard shouldAdvance() else { return }
		
		if tweens.count == 0 {
			kill()
		}
		
		super.advance(time)
		
//		print("Timeline.advance() - time: \(time), elapsed: \(elapsed), endTime: \(endTime), delay: \(delay), duration: \(duration), repeatDelay: \(repeatDelay), reversed: \(direction == .reversed), progress: \(progress)")
		
		// check for callbacks
		callbacks.forEach({ (time, fn) in
			if elapsed >= time && !fn.called {
				fn.block()
				fn.called = true
			}
		})
		
//		updateBlock?(self)
		updated.trigger(self)
	}
	
	// MARK: Private Methods
	
	fileprivate func time(fromString str: String, relativeToTime time: TimeInterval = 0) -> TimeInterval {
		var position: TimeInterval = time
		let string = NSString(string: str)
		
		let regex = try! NSRegularExpression(pattern: "(\\w+)?([\\+,\\-\\+]=)([\\d\\.]+)", options: [])
		let match = regex.firstMatch(in: string as String, options: [], range: NSRange(location: 0, length: string.length))
		if let match = match {
			var idx = 1
			var multiplier: TimeInterval = 1
			while idx < match.numberOfRanges {
				let range = match.rangeAt(idx)
				if range.length <= string.length && range.location < string.length {
					let val = string.substring(with: range)
					// label
					if idx == 1 {
						position = self.time(forLabel:val)
					} else if idx == 2 {
						if val == "-=" {
							multiplier = -1
						}
					} else if idx == 3 {
						if let offset = Double("\(val)") {
							position += TimeInterval(offset)
						}
					}
				}
				idx += 1
			}
			position *= multiplier
		}
		
		return position
	}
}
