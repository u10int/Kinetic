//
//  Easing.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//
//  Easing.swift used and adapted from Cheetah library under the MIT license, https://github.com/suguru/Cheetah
//  Created by Suguru Namura on 2015/08/19.
//  Copyright © 2015年 Suguru Namura.

import UIKit

public protocol TimingFunctionType {
	func solveForTime(_ x: Double) -> Double
}

public struct LinearTimingFunction: TimingFunctionType {
	public init() {}
	
	public func solveForTime(_ x: Double) -> Double {
		return x
	}
}

extension UnitBezier: TimingFunctionType {
	
	public func solveForTime(_ x: Double) -> Double {
		return solve(x)
	}
}

// MARK: - Easing

public typealias Ease = (_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat

public struct Easing: TimingFunctionType {
	var bezier: UnitBezier
	
	public enum EasingType {
		case sineIn
		case sineOut
		case sineInOut
		
		case quadIn
		case quadOut
		case quadInOut
		
		case cubicIn
		case cubicOut
		case cubicInOut
		
		case quartIn
		case quartOut
		case quartInOut
		
		case quintIn
		case quintOut
		case quintInOut
		
		case expoIn
		case expoOut
		case expoInOut
		
		case circIn
		case circOut
		case circInOut
		
		case backIn
		case backOut
		case backInOut
	}
	
	public init(_ easing: EasingType) {
		switch easing {
		case .sineIn:
			bezier = UnitBezier(0.47, 0, 0.745, 0.715)
		case .sineOut:
			bezier = UnitBezier(0.39, 0.575, 0.565, 1)
		case .sineInOut:
			bezier = UnitBezier(0.455, 0.03, 0.515, 0.955)
			
		case .quadIn:
			bezier = UnitBezier(0.55, 0.085, 0.68, 0.53)
		case .quadOut:
			bezier = UnitBezier(0.25, 0.46, 0.45, 0.94)
		case .quadInOut:
			bezier = UnitBezier(0.455, 0.03, 0.515, 0.955)
			
		case .cubicIn:
			bezier = UnitBezier(0.55, 0.055, 0.675, 0.19)
		case .cubicOut:
			bezier = UnitBezier(0.215, 0.61, 0.355, 1)
		case .cubicInOut:
			bezier = UnitBezier(0.645, 0.045, 0.355, 1)
		
		case .quartIn:
			bezier = UnitBezier(0.895, 0.03, 0.685, 0.22)
		case .quartOut:
			bezier = UnitBezier(0.165, 0.84, 0.44, 1)
		case .quartInOut:
			bezier = UnitBezier(0.77, 0, 0.175, 1)
			
		case .quintIn:
			bezier = UnitBezier(0.755, 0.05, 0.855, 0.06)
		case .quintOut:
			bezier = UnitBezier(0.23, 1, 0.32, 1)
		case .quintInOut:
			bezier = UnitBezier(0.86,0,0.07,1)
			
		case .expoIn:
			bezier = UnitBezier(0.95, 0.05, 0.795, 0.035)
		case .expoOut:
			bezier = UnitBezier(0.19, 1, 0.22, 1)
		case .expoInOut:
			bezier = UnitBezier(1, 0, 0, 1)
			
		case .circIn:
			bezier = UnitBezier(0.6, 0.04, 0.98, 0.335)
		case .circOut:
			bezier = UnitBezier(0.075, 0.82, 0.165, 1)
		case .circInOut:
			bezier = UnitBezier(0.785, 0.135, 0.15, 0.86)
			
		case .backIn:
			bezier = UnitBezier(0.6, -0.28, 0.735, 0.045)
		case .backOut:
			bezier = UnitBezier(0.175, 0.885, 0.32, 1.275)
		case .backInOut:
			bezier = UnitBezier(0.68, -0.55, 0.265, 1.55)
		}
	}
	
	public func solveForTime(_ x: Double) -> Double {
		return bezier.solve(x)
	}
	
	
	public static let linear:Ease = { (t: CGFloat, b: CGFloat, c: CGFloat) -> CGFloat in
		return c * t + b
	}
	
	// return easing with cubic bezier curve
	public static func cubicBezier(_ c1x: Double, _ c1y: Double, _ c2x: Double, _ c2y: Double) -> Ease {
		let bezier = UnitBezier(c1x, c1y, c2x, c2y)
		return { (t: CGFloat, b: CGFloat, c: CGFloat) -> CGFloat in
			let y = bezier.solve(Double(t))
			return c * CGFloat(y) + b
		}
	}
	
	// Easing curves are from https://github.com/ai/easings.net/
	public static let inSine:Ease = Easing.cubicBezier(0.47,0,0.745,0.715)
	public static let outSine:Ease = Easing.cubicBezier(0.39,0.575,0.565, 1)
	public static let inOutSine:Ease = Easing.cubicBezier(0.455,0.03,0.515,0.955)
	
	public static let inQuad:Ease = Easing.cubicBezier(0.55, 0.085, 0.68, 0.53)
	public static let outQuad:Ease = Easing.cubicBezier(0.25, 0.46, 0.45, 0.94)
	public static let inOutQuad:Ease = Easing.cubicBezier(0.455, 0.03, 0.515, 0.955)
	
	public static let inCubic:Ease = Easing.cubicBezier(0.55, 0.055, 0.675, 0.19)
	public static let outCubic:Ease = Easing.cubicBezier(0.215, 0.61, 0.355, 1)
	public static let inOutCubic:Ease = Easing.cubicBezier(0.645, 0.045, 0.355, 1)
	
	public static let inQuart:Ease = Easing.cubicBezier(0.895, 0.03, 0.685, 0.22)
	public static let outQuart:Ease = Easing.cubicBezier(0.165, 0.84, 0.44, 1)
	public static let inOutQuart:Ease = Easing.cubicBezier(0.77, 0, 0.175, 1)
	
	public static let inQuint:Ease = Easing.cubicBezier(0.755, 0.05, 0.855, 0.06)
	public static let outQuint:Ease = Easing.cubicBezier(0.23, 1, 0.32, 1)
	public static let inOutQuint:Ease = Easing.cubicBezier(0.86,0,0.07,1)
	
	public static let inExpo:Ease = Easing.cubicBezier(0.95, 0.05, 0.795, 0.035)
	public static let outExpo:Ease = Easing.cubicBezier(0.19, 1, 0.22, 1)
	public static let inOutExpo:Ease = Easing.cubicBezier(1, 0, 0, 1)
	
	public static let inCirc:Ease = Easing.cubicBezier(0.6, 0.04, 0.98, 0.335)
	public static let outCirc:Ease = Easing.cubicBezier(0.075, 0.82, 0.165, 1)
	public static let inOutCirc:Ease = Easing.cubicBezier(0.785, 0.135, 0.15, 0.86)
	
	public static let inBack:Ease = Easing.cubicBezier(0.6, -0.28, 0.735, 0.045)
	public static let outBack:Ease = Easing.cubicBezier(0.175, 0.885, 0.32, 1.275)
	public static let inOutBack:Ease = Easing.cubicBezier(0.68, -0.55, 0.265, 1.55)
}

// MARK: - Unit Bezier
// 
// This implementation is based on WebCore Bezier implmentation
// http://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h

private let epsilon: Double = 1.0 / 1000

public struct UnitBezier {
	public var p1x: Double
	public var p1y: Double
	public var p2x: Double
	public var p2y: Double
	
	public init(_ p1x: Double, _ p1y: Double, _ p2x: Double, _ p2y: Double) {
		self.p1x = p1x
		self.p1y = p1y
		self.p2x = p2x
		self.p2y = p2y
	}
	
	public func solve(_ x: Double) -> Double {
		return UnitBezierSover(bezier: self).solve(x)
	}
}

private struct UnitBezierSover {
	var ax: Double
	var ay: Double
	var bx: Double
	var by: Double
	var cx: Double
	var cy: Double
	
	init(bezier: UnitBezier) {
		self.init(p1x: bezier.p1x, p1y: bezier.p1y, p2x: bezier.p2x, p2y: bezier.p2y)
	}
	
	init(p1x: Double, p1y: Double, p2x: Double, p2y: Double) {
		cx = 3 * p1x
		bx = 3 * (p2x - p1x) - cx
		ax = 1 - cx - bx
		cy = 3 * p1y
		by = 3 * (p2y - p1y) - cy
		ay = 1.0 - cy - by
	}
	
	func sampleCurveX(_ t: Double) -> Double {
		return ((ax * t + bx) * t + cx) * t
	}
	
	func sampleCurveY(_ t: Double) -> Double {
		return ((ay * t + by) * t + cy) * t
	}
	
	func sampleCurveDerivativeX(_ t: Double) -> Double {
		return (3.0 * ax * t + 2.0 * bx) * t + cx
	}
	
	func solveCurveX(_ x: Double) -> Double {
		var t0, t1, t2, x2, d2: Double
		
		// first try a few iterations of Newton's method -- normally very fast
		t2 = x
		for _ in 0..<8 {
			x2 = sampleCurveX(t2) - x
			if fabs(x2) < epsilon {
				return t2
			}
			d2 = sampleCurveDerivativeX(t2)
			if fabs(x2) < 1e-6 {
				break
			}
			t2 = t2 - x2 / d2
		}
		
		// fall back to the bisection method for reliability
		t0 = 0
		t1 = 1
		t2 = x
		
		if t2 < t0 {
			return t0
		}
		if t2 > t1 {
			return t1
		}
		
		while t0 < t1 {
			x2 = sampleCurveX(t2)
			if fabs(x2 - x) < epsilon {
				return t2
			}
			if x > x2 {
				t0 = t2
			} else {
				t1 = t2
			}
			t2 = (t1 - t0) * 0.5 + t0
		}
		
		// failure
		return t2
	}
	
	func solve(_ x: Double) -> Double {
		return sampleCurveY(solveCurveX(x))
	}
}
