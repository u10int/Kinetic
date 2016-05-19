//
//  Animator.swift
//  Pods
//
//  Created by Nicholas Shipes on 5/14/16.
//
//

import Foundation

final public class BasicAnimator {
	private (set) public var from: TweenableValue
	private (set) public var to: TweenableValue
	private (set) public var duration: Double
	
	public var timingFunction: TimingFunctionType = LinearTimingFunction()
	var spring: Spring?
	public var additive: Bool = true
	public var changed: ((BasicAnimator) -> Void)?
	
	public var finished: Bool {
		return elapsed >= duration
	}
	
	private (set) public var value: TweenableValue
	private var elapsed: Double = 0.0
	
	public init(from: TweenableValue, to: TweenableValue, duration: Double, timingFunction: TimingFunctionType) {
		self.from = from
		self.to = to
		self.duration = duration
		self.timingFunction = timingFunction
		self.value = from
	}
	
	// MARK: Public Methods
	
	func seek(time: Double) {
		advance(time)
	}
	
	func reset() {
		elapsed = 0
	}
	
	func advance(time: Double) {
		elapsed += time
		
		var progress = elapsed / duration
		progress = max(progress, 0.0)
		progress = min(progress, 1.0)
		
		let adjustedProgress = timingFunction.solveForTime(progress)
//		value = from.interpolatable.interpolateTo(to.interpolatable, progress: adjustedProgress)
		
		
		print("Animator.advance() - elapsed: \(elapsed), progress: \(progress), adjusted: \(adjustedProgress)")
		changed?(self)
	}
	
	func onChange(block: ((BasicAnimator) -> Void)?) {
		changed = block
	}
}