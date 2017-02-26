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

// MARK: - Easing

public typealias Ease = (_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat

public struct Easing {
	public static let linear:Ease = { (t: CGFloat, b: CGFloat, c: CGFloat) -> CGFloat in
		return c * t + b
	}
	
	// return easing with cubic bezier curve
	public static func cubicBezier(_ c1x: CGFloat, _ c1y: CGFloat, _ c2x: CGFloat, _ c2y: CGFloat) -> Ease {
		let bezier = UnitBezier(p1x: c1x, p1y: c1y, p2x: c2x, p2y: c2y)
		return { (t: CGFloat, b: CGFloat, c: CGFloat) -> CGFloat in
			let y = bezier.solve(t)
			return c * y + b
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
	public static let swiftOut:Ease = Easing.cubicBezier(0.4, 0.0, 0.2, 1)
}

// MARK: - Unit Bezier
// 
// This implementation is based on WebCore Bezier implmentation
// http://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h

private let epsilon: CGFloat = 1.0 / 1000

struct UnitBezier {
	var ax: CGFloat
	var ay: CGFloat
	var bx: CGFloat
	var by: CGFloat
	var cx: CGFloat
	var cy: CGFloat
	
	init(p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat) {
		cx = 3 * p1x
		bx = 3 * (p2x - p1x) - cx
		ax = 1 - cx - bx
		cy = 3 * p1y
		by = 3 * (p2y - p1y) - cy
		ay = 1.0 - cy - by
	}
	
	func sampleCurveX(_ t: CGFloat) -> CGFloat {
		return ((ax * t + bx) * t + cx) * t
	}
	
	func sampleCurveY(_ t: CGFloat) -> CGFloat {
		return ((ay * t + by) * t + cy) * t
	}
	
	func sampleCurveDerivativeX(_ t: CGFloat) -> CGFloat {
		return (3.0 * ax * t + 2.0 * bx) * t + cx
	}
	
	func solveCurveX(_ x: CGFloat) -> CGFloat {
		var t0, t1, t2, x2, d2: CGFloat
		
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
	
	func solve(_ x: CGFloat) -> CGFloat {
		return sampleCurveY(solveCurveX(x))
	}
}
