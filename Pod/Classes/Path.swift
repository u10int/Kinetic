//
//  Path.swift
//  Pods
//
//  Created by Nicholas Shipes on 7/30/17.
//
//

import Foundation

public protocol InterpolatablePath {
	var start: CGPoint { get set }
	var end: CGPoint { get set }
	
	func interpolate(_ progress: CGFloat) -> CGPoint
}

public struct Line: InterpolatablePath {
	public var start: CGPoint
	public var end: CGPoint
	
	public init(start: CGPoint, end: CGPoint) {
		self.start = start
		self.end = end
	}
	
	public func interpolate(_ progress: CGFloat) -> CGPoint {
		let dx = end.x - start.x
		let dy = end.y - start.y
		
		return CGPoint(x: start.x + dx * progress, y: start.y + dy * progress)
	}
}

public struct CubicBezier: InterpolatablePath {
	public var start: CGPoint
	public var end: CGPoint
	public var cp1: CGPoint
	public var cp2: CGPoint
	
	public init(start: CGPoint, cp1: CGPoint, end: CGPoint, cp2: CGPoint) {
		self.start = start
		self.end = end
		self.cp1 = cp1
		self.cp2 = cp2
	}
	
	public func interpolate(_ progress: CGFloat) -> CGPoint {
		// internal function for calculating a single x or y value
		func _interpolate(from: CGFloat,  c1: CGFloat, to: CGFloat,  c2: CGFloat, progress: CGFloat) -> CGFloat {
			let t: Double = Double(progress)
			let t_: Double = (1.0 - t)
			let tt_: Double = t_ * t_
			let ttt_: Double = t_ * t_ * t_
			let tt: Double = t * t
			let ttt: Double = t * t * t
			
			var result = Double(from) * ttt_
			result += (3.0 * Double(c1) * tt_ * t)
			result += (3.0 * Double(c2) * t_ * tt)
			result += (Double(to) * ttt)
			
			return CGFloat(result)
		}
		
		let x = _interpolate(from: start.x, c1: cp1.x, to: end.x, c2: cp2.x, progress: progress)
		let y = _interpolate(from: start.y, c1: cp1.y, to: end.y, c2: cp2.y, progress: progress)
		
		return CGPoint(x: x, y: y)
	}
}

public struct QuadBezier: InterpolatablePath {
	public var start: CGPoint
	public var end: CGPoint
	public var cp1: CGPoint
	
	public init(start: CGPoint, cp1: CGPoint, end: CGPoint) {
		self.start = start
		self.end = end
		self.cp1 = cp1
	}
	
	public func interpolate(_ progress: CGFloat) -> CGPoint {
		// internal function for calculating a single x or y value
		func _interpolate(from: CGFloat, c1: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
			let t: Double = Double(progress)
			let t_: Double = (1.0 - t)
			let tt_: Double = t_ * t_
			let tt: Double = t * t
			
			var result = Double(from) * tt_
			result += (2.0 * Double(c1) * t_ * t)
			result += (Double(to) * tt)
			
			return CGFloat(result)
		}
		
		let x = _interpolate(from: start.x, c1: cp1.x, to: end.x, progress: progress)
		let y = _interpolate(from: start.y, c1: cp1.y, to: end.y, progress: progress)
		
		return CGPoint(x: x, y: y)
	}
}
