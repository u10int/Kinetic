//
//  Interpolatable.swift
//  Pods
//
//  Created by Nicholas Shipes on 5/13/16.
//
//

import Foundation
import QuartzCore

public enum InterpolatableType {
	case caTransform3D
	case cgAffineTransform
	case cgFloat
	case cgPoint
	case cgRect
	case cgSize
	case colorHSB
	case colorMonochrome
	case colorRGB
	case double
	case int
	case nsNumber
	case uiEdgeInsets
	case vector3
}

public protocol Interpolatable {
	func vectorize() -> InterpolatableValue
}

extension CATransform3D: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .caTransform3D, vectors: m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44)
	}
}

extension CGAffineTransform: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .cgAffineTransform, vectors: a, b, c, d, tx, ty)
	}
}

extension CGFloat: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .cgFloat, vectors: self)
	}
}

extension CGPoint: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .cgPoint, vectors: x, y)
	}
}

extension CGRect: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .cgRect, vectors: origin.x, origin.y, size.width, size.height)
	}
}

extension CGSize: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .cgSize, vectors: width, height)
	}
}

extension Double: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .double, vectors: CGFloat(self))
	}
}

extension Int: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .int, vectors: CGFloat(self))
	}
}

extension NSNumber: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .nsNumber, vectors: CGFloat(self))
	}
}

extension UIColor: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		
		if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
			return InterpolatableValue(type: .colorRGB, vectors: red, green, blue, alpha)
		}
		
		var white: CGFloat = 0
		
		if getWhite(&white, alpha: &alpha) {
			return InterpolatableValue(type: .colorMonochrome, vectors: white, alpha)
		}
		
		var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
		
		getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		return InterpolatableValue(type: .colorHSB, vectors: hue, saturation, brightness, alpha)
	}
}

extension UIEdgeInsets: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .uiEdgeInsets, vectors: top, left, bottom, right)
	}
}

extension Vector3: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .vector3, vectors: CGFloat(x), CGFloat(y), CGFloat(z))
	}
}

public struct InterpolatableValue {
	let type: InterpolatableType
	var vectors: [CGFloat]
	
	init(value: InterpolatableValue) {
		self.vectors = value.vectors
		self.type = value.type
	}
	
	init(type: InterpolatableType, vectors: CGFloat...) {
		self.vectors = vectors
		self.type = type
	}
	
	init(type: InterpolatableType, vectors: [CGFloat]) {
		self.vectors = vectors
		self.type = type
	}
	
	func interpolateTo(_ to: InterpolatableValue, progress: Double) -> InterpolatableValue {
		var diff = [CGFloat]()
		let vectorCount = self.vectors.count
		
		for idx in 0..<vectorCount {
			let val = self.vectors[idx] + (to.vectors[idx] - self.vectors[idx]) * CGFloat(progress)
			diff.append(val)
		}
		
		return InterpolatableValue(type: self.type, vectors: diff)
	}
	
	func toInterpolatable() -> Interpolatable {
		switch type {
		case .caTransform3D:
			return CATransform3D(m11: vectors[0], m12: vectors[1], m13: vectors[2], m14: vectors[3], m21: vectors[4], m22: vectors[5], m23: vectors[6], m24: vectors[7], m31: vectors[8], m32: vectors[9], m33: vectors[10], m34: vectors[11], m41: vectors[12], m42: vectors[13], m43: vectors[14], m44: vectors[15])
		case .cgAffineTransform:
			return CGAffineTransform(a: vectors[0], b: vectors[1], c: vectors[2], d: vectors[3], tx: vectors[4], ty: vectors[5])
		case .cgFloat:
			return vectors[0]
		case .cgPoint:
			return CGPoint(x: vectors[0], y: vectors[1])
		case .cgRect:
			return CGRect(x: vectors[0], y: vectors[1], width: vectors[2], height: vectors[3])
		case .cgSize:
			return CGSize(width: vectors[0], height: vectors[1])
		case .colorRGB:
			return UIColor(red: vectors[0], green: vectors[1], blue: vectors[2], alpha: vectors[3])
		case .colorMonochrome:
			return UIColor(white: vectors[0], alpha: vectors[1])
		case .colorHSB:
			return UIColor(hue: vectors[0], saturation: vectors[1], brightness: vectors[2], alpha: vectors[3])
		case .double:
			return vectors[0]
		case .int:
			return vectors[0]
		case .nsNumber:
			return vectors[0]
		case .uiEdgeInsets:
			return UIEdgeInsetsMake(vectors[0], vectors[1], vectors[2], vectors[3])
		case .vector3:
			return Vector3(Double(vectors[0]), Double(vectors[1]), Double(vectors[2]))
		}
	}
}
