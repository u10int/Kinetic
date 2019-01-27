//
//  Animatable.swift
//  Pods
//
//  Created by Nicholas Shipes on 6/15/17.
//
//

import Foundation

public enum AnimationState: Equatable {
	case pending
	case running
	case idle
	case cancelled
	case completed
}
public func ==(lhs: AnimationState, rhs: AnimationState) -> Bool {
	switch (lhs, rhs) {
	case (.pending, .pending):
		return true
	case (.running, .running):
		return true
	case (.idle, .idle):
		return true
	case (.cancelled, .cancelled):
		return true
	case (.completed, .completed):
		return true
	default:
		return false
	}
}

public typealias StartClosure = () -> Void
public typealias CompletionClosure = (_ done: Bool) -> Void

public protocol Animatable: class, Hashable {
	var state: AnimationState { get set }
	var duration: TimeInterval { get set }
	var delay: TimeInterval { get set }
	var timeScale: Double { get set }
	var progress: Double { get set }
	var totalProgress: Double { get set }
	
	var startTime: TimeInterval { get set }
	var endTime: TimeInterval { get }
	var totalDuration: TimeInterval { get }
	var totalTime: TimeInterval { get }
	var elapsed: TimeInterval { get }
	var time: TimeInterval { get }
	
	var timingFunction: TimingFunction { get }
	var spring: Spring? { get }
	
	func duration(_ duration: TimeInterval) -> Self
	func delay(_ delay: TimeInterval) -> Self
	func ease(_ easing: EasingType) -> Self
	func spring(tension: Double, friction: Double) -> Self

	func play()
	func stop()
	func pause()
	func resume()
	func seek(_ offset: TimeInterval) -> Self
	func forward() -> Self
	func reverse() -> Self
	func restart(_ includeDelay: Bool)	
}

internal protocol TimeRenderable {
	func render(time: TimeInterval, advance: TimeInterval)
}
