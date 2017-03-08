//
//  Animator.swift
//  Pods
//
//  Created by Nicholas Shipes on 5/14/16.
//
//

import Foundation

//public protocol Animator: class, Equatable {
//	var duration: Double { get }
//	var timingFunction: TimingFunctionType { get set }
//	var additive: Bool { get set }
//	var finished: Bool { get }
//	func seek(_ time: Double)
//	func reset()
//	func advance(_ time: Double)
//}
//public func ==<T: Animator>(lhs: T, rhs: T) -> Bool {
//	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
//}

final public class Animator: Equatable {
	fileprivate (set) public var from: TweenProp
	fileprivate (set) public var to: TweenProp
	fileprivate (set) public var duration: Double
	
	public var timingFunction: TimingFunctionType = LinearTimingFunction()
	var spring: Spring?
	public var additive: Bool = true
	public var changed: ((Animator, TweenProp) -> Void)?
	
	public var finished: Bool {
		if let spring = spring {
			return spring.ended
		}
		return (!reversed && elapsed >= duration) || (reversed && elapsed <= 0)
	}
	
	fileprivate (set) public var current: TweenProp
	fileprivate var additiveCurrent: TweenProp
	fileprivate var elapsed: Double = 0.0
	fileprivate var reversed = false
	fileprivate var presentation: ((TweenProp) -> TweenProp?)?
	
	public init(from: TweenProp, to: TweenProp, duration: Double, timingFunction: TimingFunctionType) {
		self.from = from
		self.to = to
		self.duration = duration
		self.timingFunction = timingFunction
		self.current = from
		self.additiveCurrent = from
	}
	
	// MARK: Public Methods
	
	public func seek(_ time: Double) {
		elapsed = time
		advance(0)
	}
	
	public func reset() {
		elapsed = 0
		current = from
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
		
		var presentationValue: TweenProp = current
		
		if let from = from as? Transform, let to = to as? Transform, var value = current as? Transform {
			let scale = from.scale.value.interpolatable.interpolateTo(to.scale.value.interpolatable, progress: adjustedProgress)
			let rotation = from.rotation.value.interpolatable.interpolateTo(to.rotation.value.interpolatable, progress: adjustedProgress)
			let translation = from.translation.value.interpolatable.interpolateTo(to.translation.value.interpolatable, progress: adjustedProgress)
			
			value.scale.apply(scale)
			value.rotation.apply(rotation)
			value.translation.apply(translation)
			self.current = value
			
		} else {
			var interpolatedValue = from.value.interpolatable.interpolateTo(to.value.interpolatable, progress: adjustedProgress)
			current.apply(interpolatedValue)
			
			if additive {
				// when an animation is additive, its presentation value needs to be adjusted so the transition is smooth
				presentationValue = adjustForAdditive(prop: presentationValue, interpolatable: interpolatedValue)
			} else {
				presentationValue = current
			}
		}
		
//		print("animator - progress: \(progress), current: \(current.value), from: \(from.value), to: \(to.value)")
//		print("Animator.advance() - elapsed: \(elapsed), progress: \(progress), from: \(from.value), to: \(to.value)")
		changed?(self, presentationValue)
	}
	
	public func applyToValue(_ interpolatable: InterpolatableValue) {
		current.apply(interpolatable)
	}
	
	public func onChange(_ block: ((Animator, TweenProp) -> Void)?) {
		changed = block
	}
	
	public func setPresentation(_ block: ((TweenProp) -> TweenProp?)?) {
		presentation = block
	}
	
	/*
	An additive animation requires the linearly-interpolated value (LERP) to be updated to equal the sum of the display object's current presentation value
	and the delta between the animation's current and previous interpolated values. This should only be applied to the display object, *not* to the animation's 
	current interpolated value.
	
	presentation = presentation + (current - previous)
	*/
	private func adjustForAdditive(prop: TweenProp, interpolatable: InterpolatableValue) -> TweenProp {
		if let pres = presentation?(prop) {
			var adjustedValue = prop
			
			var vectors = interpolatable.vectors
			let current = prop.value.vectors
			let pcurrent = pres.value.vectors
			
			for i in 0..<vectors.count {
				let delta = vectors[i] - current[i]
				vectors[i] = pcurrent[i] + delta
			}
			
			let intepolatable = InterpolatableValue(type: interpolatable.type, vectors: vectors)
			adjustedValue.apply(intepolatable)
			
			return adjustedValue
		}
		
		return prop
	}
}
public func ==(lhs: Animator, rhs: Animator) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
