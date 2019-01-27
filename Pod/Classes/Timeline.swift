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

public class TweenRange {
	var tween: Tween
	var start: TimeInterval
	var end: TimeInterval {
		return start + tween.delay + tween.duration
	}
	
	init(tween: Tween, position: TimeInterval) {
		self.tween = tween
		self.start = position
	}
}

public class Timeline: Animation {
	private(set) public var children = [TweenRange]()
	weak public var timeline: Timeline?
	override public var endTime: TimeInterval {
		get {
			var time: TimeInterval = 0
			children.forEach { (range) in
				time = max(time, range.end)
			}
			return time
		}
	}
	override public var duration: TimeInterval {
		get {
			return endTime
		}
		set(newValue) {
			
		}
	}
	override public var totalTime: TimeInterval {
		get {
			return runningTime
		}
	}
	override public var totalDuration: TimeInterval {
		get {
			return (endTime * TimeInterval(repeatCount + 1)) + (repeatDelay * TimeInterval(repeatCount))
		}
	}
	public var antialiasing: Bool = true {
		didSet {
			children.forEach { (range) in
				range.tween.antialiasing = antialiasing
			}
		}
	}
	
	fileprivate var labels = [String: TimeInterval]()
	fileprivate var callbacks = [TimeInterval: TimelineCallback]()
	
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
		
		// by default, new tweens are added to the end of the timeline
		var pos: TimeInterval = totalDuration
		
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
			
			let range = TweenRange(tween: tween, position: pos)
//			print("timeline - added tween at position \(position) with start time \(range.start), end time \(range.end)")
			
			// remove tween from existing timeline (if `timeline` is not nil)... assign timeline to this
			if let timeline = tween.timeline {
				timeline.remove(tween: tween)
			}
			tween.timeline = self
			children.append(range)
			
			// increment position if items are being added sequentially
			if align == .sequence {
				pos += tween.totalDuration
			}
		}
		
		return self
	}
	
	@discardableResult
	public func add(_ tween: Tween, relativeToLabel label: String, offset: TimeInterval) -> Timeline {
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
		var pos: TimeInterval = 0
		
		if let label = position as? String {
			pos = time(fromString:label, relativeToTime: endTime)
		} else if let time = Double("\(position)") {
			pos = TimeInterval(time)
		}
		
		labels[label] = pos
		
		return self
	}
	
	@discardableResult
	public func addCallback(_ position: Any, block: @escaping () -> Void) -> Timeline {
		var pos: TimeInterval = 0
		
		if let label = position as? String {
			pos = time(fromString:label, relativeToTime: endTime)
		} else if let time = Double("\(position)") {
			pos = TimeInterval(time)
		}
		
		callbacks[pos] = TimelineCallback(block: block)
		callbacks[pos]?.time = pos
		
		return self
	}
	
	public func remove(_ label: String) {
		labels[label] = nil
	}
	
	public func time(forLabel label: String) -> TimeInterval {
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
	public func shift(_ amount: TimeInterval, afterTime time: TimeInterval = 0) -> Timeline {
		children.forEach { (range) in
			if range.start >= time {
				range.start += amount
				
				if range.start < 0 {
					range.start = 0
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
		
		children.forEach { (range) in
			if range.tween.state == .running {
				tweens.append(range.tween)
			}
		}
		
		return tweens
	}
	
	public func remove(tween: Tween) {
		if let timeline = tween.timeline {
			if timeline == self {
				tween.timeline = nil
				children.enumerated().forEach({ (index, range) in
					if range.tween == tween {
						children.remove(at: index)
					}
				})
			}
		}
	}
	
	@discardableResult
	public func from(_ props: Property...) -> Timeline {
		children.forEach { (range) in
			range.tween.from(props)
		}
		return self
	}
	
	@discardableResult
	public func to(_ props: Property...) -> Timeline {
		children.forEach { (range) in
			range.tween.to(props)
		}
		return self
	}
	
	@discardableResult
	override public func spring(tension: Double, friction: Double) -> Timeline {
		children.forEach { (range) in
			range.tween.spring(tension: tension, friction: friction)
		}
		return self
	}
	
	@discardableResult
	public func perspective(_ value: CGFloat) -> Timeline {
		children.forEach { (range) in
			range.tween.perspective(value)
		}
		return self
	}
	
	@discardableResult
	public func anchor(_ anchor: AnchorPoint) -> Timeline {
		return anchorPoint(anchor.point())
	}
	
	@discardableResult
	public func anchorPoint(_ point: CGPoint) -> Timeline {
		children.forEach { (range) in
			range.tween.anchorPoint(point)
		}
		return self
	}
	
	@discardableResult
	public func stagger(_ offset: TimeInterval) -> Timeline {
		children.enumerated().forEach { (index, range) in
			range.start = offset * TimeInterval(index)
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
	
	@discardableResult
	override public func duration(_ duration: TimeInterval) -> Timeline {
		children.forEach { (range) in
			range.tween.duration(duration)
		}
		return self
	}
	
	@discardableResult
	override public func ease(_ easing: EasingType) -> Timeline {
		children.forEach { (range) in
			range.tween.ease(easing)
		}
		return self
	}
	
	@discardableResult
	override public func seek(_ time: TimeInterval) -> Timeline {
		super.seek(time)
		
		children.forEach { (range) in
			let tween = range.tween
			var tweenSeek = max(0, min(elapsed - range.start, tween.totalDuration))
			tweenSeek = elapsed - range.start
			
			// if timeline is reversed, then the tween's seek time should be relative to its end time
			if direction == .reversed {
				tweenSeek = range.end - elapsed
			}
			
			tween.seek(tweenSeek)
		}
		
		return self
	}
	
	override public func restart(_ includeDelay: Bool) {
		super.restart(includeDelay)
		
		for (_, callback) in callbacks {
			callback.called = false
		}
	}
	
	// MARK: TimeRenderable
	
	override internal func render(time: TimeInterval, advance: TimeInterval = 0) {
		super.render(time: time, advance: advance)
		
		children.forEach { (range) in
			if (elapsed >= range.start && (elapsed <= range.end || range.tween.spring != nil)) {
				if range.tween.state != .running {
					range.tween.play()
					range.tween.state = .running
				}
				range.tween.render(time: elapsed - range.start, advance: advance)
			} else if (elapsed < range.start) {
				range.tween.render(time: 0, advance: advance)
			} else if (elapsed > range.end) {
				range.tween.render(time: elapsed - range.start, advance: advance)
			}
		}
		
		// check for callbacks
		callbacks.forEach({ (time, fn) in
			if elapsed >= time && !fn.called {
				fn.block()
				fn.called = true
			}
		})
		
		updated.trigger(self)
	}
	
	// MARK: Subscriber
	
	override func advance(_ time: Double) {
		guard shouldAdvance() else { return }
		
		if children.count == 0 {
			kill()
		}
		
		super.advance(time)
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
