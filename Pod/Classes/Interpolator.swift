//
//  Interpolator.swift .swift
//  Pods
//
//  Created by Nicholas Shipes on 2/4/17.
//
//

import Foundation

public class Interpolator : Subscriber {
	public var id: UInt32 = 0
	public var progress: CGFloat = 0.0 {
		didSet {
			progress = max(0, min(progress, 1.0))
			
			let adjustedProgress = timingFunction.solveForTime(Double(progress))
			current = current.interpolateTo(self.to, progress: adjustedProgress)
			apply?(current.toInterpolatable())
		}
	}
	
	var spring: Spring?
	public var finished: Bool {
		if let spring = spring {
			return spring.ended
		}
		return (!reversed && elapsed >= duration) || (reversed && elapsed <= 0)
	}
	
	fileprivate var current: InterpolatableValue
	fileprivate var from: InterpolatableValue
	fileprivate var to: InterpolatableValue
	fileprivate var duration: CGFloat
	fileprivate var timingFunction: TimingFunctionType
	fileprivate var elapsed: CGFloat = 0.0
	fileprivate var reversed = false
	fileprivate var apply: ((Interpolatable) -> Void)?
	
	public init<T: Interpolatable>(from: T, to: T, duration: CGFloat, function: TimingFunctionType, apply: @escaping ((T) -> Void)) {
		self.from = InterpolatableValue(value: from.vectorize())
		self.to = InterpolatableValue(value: to.vectorize())
		self.current = InterpolatableValue(value: self.from)
		self.duration = duration
		self.timingFunction = function
		self.apply = { let _ = ($0 as? T).flatMap(apply) }
	}
	
	public func run() {
		Scheduler.sharedInstance.add(self)
	}
	
	internal func advance(_ time: Double) -> Bool {
		let direction: CGFloat = reversed ? -1.0 : 1.0
		
		elapsed += CGFloat(time)
		elapsed = max(0, elapsed)
		reversed = time < 0
		
		progress = (elapsed / duration) * direction
		print(progress)
		
		if (direction > 0 && progress >= 1.0) || (direction < 0 && progress <= -1.0) {
			
		}
		
		
		
		return true
	}
}
