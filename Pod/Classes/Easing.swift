//
//  Easing.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/18/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

public protocol FloatingPointMath: FloatingPoint {
	var sine: Self { get }
	var cosine: Self { get }
	var powerOfTwo: Self { get }
}

extension Float: FloatingPointMath {
	public var sine: Float {
		return sin(self)
	}
	public var cosine: Float {
		return cos(self)
	}
	public var powerOfTwo: Float {
		return pow(2, self)
	}
}

extension Double: FloatingPointMath {
	public var sine: Double {
		return sin(self)
	}
	public var cosine: Double {
		return cos(self)
	}
	public var powerOfTwo: Double {
		return pow(2, self)
	}
}

public protocol TimingFunction {
	func solve(_ x: Double) -> Double
}

struct TimingFunctionSolver: TimingFunction {
	var solver: (Double) -> Double
	
	init(solver: @escaping (Double) -> Double) {
		self.solver = solver
	}
	
	func solve(_ x: Double) -> Double {
		return solver(x)
	}
}

public protocol EasingType {
	var timingFunction: TimingFunction { get }
}

public struct Linear: EasingType {
	public var timingFunction: TimingFunction {
		return TimingFunctionSolver(solver: { (x) -> Double in
			return x
		})
	}
}

public struct Bezier: EasingType {
	private var bezier: UnitBezier
	
	public init(_ p1x: Double, _ p1y: Double, _ p2x: Double, _ p2y: Double) {
		self.bezier = UnitBezier(p1x, p1y, p2x, p2y)
	}
	
	public var timingFunction: TimingFunction {
		return TimingFunctionSolver(solver: { (x) -> Double in
			return self.bezier.solve(x)
		})
	}
}

public enum Quadratic: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x * x
			}
		case .easeOut:
			fn = { (x) -> Double in
				return -x * (x - 2)
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					return 2 * x * x
				} else {
					return (-2 * x * x) + (4 * x) - 1
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Cubic: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x * x * x
			}
		case .easeOut:
			fn = { (x) -> Double in
				let p = x - 1
				return  p * p * p + 1
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					return 4 * x * x * x
				} else {
					let f = 2 * x - 2
					return 1 / 2 * f * f * f + 1
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Quartic: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x * x * x * x
			}
		case .easeOut:
			fn = { (x) -> Double in
				let f = x - 1
				return f * f * f * (1 - x) + 1
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					return 8 * x * x * x * x
				} else {
					let f = x - 1
					return -8 * f * f * f * f + 1
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Quintic: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x * x * x * x * x
			}
		case .easeOut:
			fn = { (x) -> Double in
				let f = x - 1
				return f * f * f * f * f + 1
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					return 16 * x * x * x * x * x
				} else {
					let f = 2 * x - 2
					return 1 / 2 * f * f * f * f * f + 1
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Sine: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return ((x - 1) * Double.pi / 2).sine + 1
			}
		case .easeOut:
			fn = { (x) -> Double in
				return (x * Double.pi / 2).sine
			}
		case .easeInOut:
			fn = { (x) -> Double in
				return 1 / 2 * (1 - (x * Double.pi).cosine)
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Circular: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return 1 - sqrt(1 - x * x)
			}
		case .easeOut:
			fn = { (x) -> Double in
				return sqrt((2 - x) * x)
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					let h = 1 - sqrt(1 - 4 * x * x)
					return 1 / 2 * h
				} else {
					let f = -(2 * x - 3) * (2 * x - 1)
					let g = sqrt(f)
					return 1 / 2 * (g + 1)
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Exponential: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x == 0 ? x : (10 * (x - 1)).powerOfTwo
			}
		case .easeOut:
			fn = { (x) -> Double in
				return x == 1 ? x : 1 - (-10 * x).powerOfTwo
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x == 0 || x == 1 {
					return x
				}
				
				if x < 1 / 2 {
					return 1 / 2 * (20 * x - 10).powerOfTwo
				} else {
					let h = (-20 * x + 10).powerOfTwo
					return -1 / 2 * h + 1
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Elastic: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return (13 * Double.pi / 2 * x).sine * (10 * (x - 1)).powerOfTwo
			}
		case .easeOut:
			fn = { (x) -> Double in
				let f = (-13 * Double.pi / 2 * (x + 1)).sine
				let g = (-10 * x).powerOfTwo
				return f * g + 1
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					let f = ((13 * Double.pi / 2) * 2 * x).sine
					return 1 / 2 * f * (10 * ((2 * x) - 1)).powerOfTwo
				} else {
					let h = (2 * x - 1) + 1
					let f = (-13 * Double.pi / 2 * h).sine
					let g = (-10 * (2 * x - 1)).powerOfTwo
					return 1 / 2 * (f * g + 2)
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Back: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = { (x) -> Double in
				return x * x * x - x * (x * Double.pi).sine
			}
		case .easeOut:
			fn = { (x) -> Double in
				let f = 1 - x
				return 1 - ( f * f * f - f * (f * Double.pi).sine)
			}
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					let f = 2 * x
					return 1 / 2 * (f * f * f - f * (f * Double.pi).sine)
				} else {
					let f = 1 - (2 * x - 1)
					let g = (f * Double.pi).sine
					let h = f * f * f - f * g
					return 1 / 2 * (1 - h ) + 1 / 2
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
}

public enum Bounce: EasingType {
	case easeIn
	case easeOut
	case easeInOut
	
	public var timingFunction: TimingFunction {
		var fn: (Double) -> Double
		switch self {
		case .easeIn:
			fn = easeIn
		case .easeOut:
			fn = easeOut
		case .easeInOut:
			fn = { (x) -> Double in
				if x < 1 / 2 {
					return 1 / 2 * self.easeIn(2 * x)
				} else {
					let f = self.easeOut(x * 2 - 1) + 1
					return 1 / 2 * f
				}
			}
		}
		return TimingFunctionSolver(solver: fn)
	}
	
	private func easeIn<T: FloatingPoint>(_ x: T) -> T {
		return 1 - easeOut(1 - x)
	}
	
	private func easeOut<T: FloatingPoint>(_ x: T) -> T {
		if x < 4 / 11 {
			return (121 * x * x) / 16
		} else if x < 8 / 11 {
			let f = (363 / 40) * x * x
			let g = (99 / 10) * x
			return f - g + (17 / 5)
		} else if x < 9 / 10 {
			let f = (4356 / 361) * x * x
			let g = (35442 / 1805) * x
			return  f - g + 16061 / 1805
		} else {
			let f = (54 / 5) * x * x
			return f - ((513 / 25) * x) + 268 / 25
		}
	}
}

// MARK: - Unit Bezier
// 
// This implementation is based on WebCore Bezier implmentation
// http://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h

private let epsilon: Double = 1.0 / 1000

private struct UnitBezier {
	public var p1x: Double
	public var p1y: Double
	public var p2x: Double
	public var p2y: Double
	
	init(_ p1x: Double, _ p1y: Double, _ p2x: Double, _ p2y: Double) {
		self.p1x = p1x
		self.p1y = p1y
		self.p2x = p2x
		self.p2y = p2y
	}
	
	func solve(_ x: Double) -> Double {
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
