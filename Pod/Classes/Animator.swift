//
//  Animator.swift
//  Pods
//
//  Created by Nicholas Shipes on 5/14/16.
//
//

import Foundation

public protocol Animator {
	var duration: Double { get }
	var timingFunction: TimingFunctionType { get set }
	var additive: Bool { get set }
	var finished: Bool { get }
	func seek(_ time: Double)
	func reset()
	func advance(_ time: Double)
}

final public class BasicAnimator: Animator {
	fileprivate (set) public var from: TweenProp
	fileprivate (set) public var to: TweenProp
	fileprivate (set) public var duration: Double
	
	public var timingFunction: TimingFunctionType = LinearTimingFunction()
	var spring: Spring?
	public var additive: Bool = true
	public var changed: ((BasicAnimator, TweenProp) -> Void)?
	
	public var finished: Bool {
		if let spring = spring {
			return spring.ended
		}
		return (!reversed && elapsed >= duration) || (reversed && elapsed <= 0)
	}
	
	fileprivate (set) public var value: TweenProp
	fileprivate var elapsed: Double = 0.0
	fileprivate var reversed = false
	
	public init(from: TweenProp, to: TweenProp, duration: Double, timingFunction: TimingFunctionType) {
		self.from = from
		self.to = to
		self.duration = duration
		self.timingFunction = timingFunction
		self.value = from
	}
	
	// MARK: Public Methods
	
	public func seek(_ time: Double) {
		elapsed = time
		advance(0)
	}
	
	public func reset() {
		elapsed = 0
		if let spring = spring {
			spring.reset()
		}
	}
	
	public func advance(_ time: Double) {
		elapsed += time
		elapsed = max(0, elapsed)
		reversed = time < 0
		
		var progress = elapsed / duration
		progress = max(progress, 0.0)
		progress = min(progress, 1.0)
		
		
		var adjustedProgress = progress
		if let spring = spring {
			spring.proceed(time / duration)
			adjustedProgress = spring.current
		} else {
			adjustedProgress = timingFunction.solveForTime(progress)
		}
		
		let test = from.value.interpolatable.interpolateTo(to.value.interpolatable, progress: adjustedProgress)
		value.apply(test)
//		print("Animator.advance() - elapsed: \(elapsed), progress: \(progress), from: \(from.value), to: \(to.value)")
		changed?(self, value)
	}
	
	public func onChange(_ block: ((BasicAnimator, TweenProp) -> Void)?) {
		changed = block
	}
}


final public class TransformAnimator: Animator {
	fileprivate (set) public var from: Transform
	fileprivate (set) public var to: Transform
	fileprivate (set) public var duration: Double
	
	public var timingFunction: TimingFunctionType = LinearTimingFunction()
	var spring: Spring?
	public var additive: Bool = true
	public var changed: ((Animator, Transform) -> Void)?
	
	public var finished: Bool {
		return (!reversed && elapsed >= duration) || (reversed && elapsed <= 0)
	}
	
	fileprivate (set) public var value: Transform
	fileprivate var elapsed: Double = 0.0
	fileprivate var reversed = false
	
	public init(from: Transform, to: Transform, duration: Double, timingFunction: TimingFunctionType) {
		self.from = from
		self.to = to
		self.duration = duration
		self.timingFunction = timingFunction
		self.value = from
	}
	
	// MARK: Public Methods
	
	public func seek(_ time: Double) {
		elapsed = time
		advance(0)
	}
	
	public func reset() {
		elapsed = 0
	}
	
	public func advance(_ time: Double) {
		elapsed += time
		elapsed = max(0, elapsed)
		reversed = time < 0
		
		var progress = elapsed / duration
		progress = max(progress, 0.0)
		progress = min(progress, 1.0)
		
		var adjustedProgress = progress
		if let spring = spring {
			spring.proceed(time / duration)
			adjustedProgress = spring.current
		} else {
			adjustedProgress = timingFunction.solveForTime(progress)
		}
		
		let scale = from.scale.value.interpolatable.interpolateTo(to.scale.value.interpolatable, progress: adjustedProgress)
		let rotation = from.rotation.value.interpolatable.interpolateTo(to.rotation.value.interpolatable, progress: adjustedProgress)
		let translation = from.translation.value.interpolatable.interpolateTo(to.translation.value.interpolatable, progress: adjustedProgress)
		
		value.scale.apply(scale)
		value.rotation.apply(rotation as! Rotation)
		value.translation.apply(translation)
		
//		print("Animator.advance() - elapsed: \(elapsed), progress: \(progress), from: \(from), to: \(to)")
//		print("Animator: progress: \(adjustedProgress), current rotation: \(rotation)")
		changed?(self, value)
	}
	
	public func onChange(_ block: ((Animator, Transform) -> Void)?) {
		changed = block
	}
}
