//
//  Interpolator.swift .swift
//  Pods
//
//  Created by Nicholas Shipes on 2/4/17.
//
//

import Foundation

public class Interpolator {
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
	
	public init(from: Interpolatable, to: Interpolatable, duration: CGFloat, function: TimingFunctionType, apply: @escaping ((Interpolatable) -> Void)) {
		self.from = InterpolatableValue(value: from.vectorize())
		self.to = InterpolatableValue(value: to.vectorize())
		self.current = InterpolatableValue(value: self.from)
		self.duration = duration
		self.timingFunction = function
		self.apply = { let _ = ($0 as? Interpolatable).flatMap(apply) }
	}
	
	fileprivate func advance(_ time: Double) {
		let direction: CGFloat = reversed ? -1.0 : 1.0
		
		elapsed += CGFloat(time)
		elapsed = max(0, elapsed)
		reversed = time < 0
		
		progress = (elapsed / duration) * direction
		
		if (direction > 0 && progress >= 1.0) || (direction < 0 && progress <= -1.0) {
			
		}
		
	}
}
