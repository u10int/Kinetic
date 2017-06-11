//
//  Tweenable.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/5/17.
//
//

import UIKit

public protocol Tweenable {
	var origin: CGPoint { get set }
	var center: CGPoint { get set }
	var size: CGSize { get set }
	var frame: CGRect { get set }
	var alpha: CGFloat { get set }
	var anchorPoint: CGPoint { get set }
	var perspective: CGFloat { get set }
	var antialiasing: Bool { get set }
	var bgColor: UIColor { get set }
	var transform3d: CATransform3D { get set }
	var translation: Translation { get }
	var scale: Scale { get }
	var rotation: Rotation { get }
}

extension Tweenable {
	
	mutating func update(_ prop: Property) {
		if let transform = prop as? Transform {
			transform.applyTo(self)
		} else if let keyPath = prop as? KeyPath {
			if let target = self as? NSObject, target.responds(to:Selector(keyPath.key)) {
				target.setValue(prop.value.toInterpolatable(), forKey: keyPath.key)
			}
		} else if let value = prop.value.toInterpolatable() as? CGFloat {
			if prop is X {
				origin.x = value
			} else if prop is Y {
				origin.y = value
			} else if prop is Alpha {
				alpha = value
			}
		} else if let value = prop.value.toInterpolatable() as? CGPoint {
			if prop is Position {
				origin = value
			} else if prop is Center {
				center = value
			}
		} else if let value = prop.value.toInterpolatable() as? CGSize {
			if prop is Size {
				size = value
			}
		} else if let value = prop.value.toInterpolatable() as? UIColor {
			if prop is BackgroundColor {
				bgColor = value
			}
		}
	}
	
	func currentProperty(for prop: Property) -> Property? {
		var vectorValue: Property?
		
		if prop is X || prop is Y {
			if prop is X {
				vectorValue = X(origin.x)
			} else {
				vectorValue = Y(origin.y)
			}
		} else if prop is Position {
			vectorValue = Position(origin)
		} else if prop is Center {
			vectorValue = Center(center)
		} else if prop is Size {
			vectorValue = Size(size)
		} else if prop is Alpha {
			vectorValue = Alpha(alpha)
		} else if prop is BackgroundColor {
			vectorValue = BackgroundColor(bgColor)
		} else if prop is Scale {
			vectorValue = scale
		} else if prop is Rotation {
			vectorValue = rotation
		} else if prop is Translation {
			vectorValue = translation
		} else if prop is KeyPath {
			if let target = self as? NSObject, let value = target.value(forKey: prop.key) as? Interpolatable {
				vectorValue = KeyPath(prop.key, value)
			}
		}
		
		return vectorValue
	}
}

extension Tweenable {
	
	public var translation: Translation {
		get {
			return transform3d.translation()
		}
	}
	
	public var scale: Scale {
		get {
			return transform3d.scale()
		}
	}
	
	public var rotation: Rotation {
		get {
			return transform3d.rotation()
		}
	}
}

extension Tweenable where Self: UIView {
	
}

extension Tweenable where Self: CALayer {
	
}

extension Tweenable where Self: CAShapeLayer {
	
}


extension UIView : Tweenable {
	public var origin: CGPoint {
		get {
			return frame.origin
		}
		set {
			frame.origin = newValue
		}
	}
	
	public var size: CGSize {
		get {
			return frame.size
		}
		set {
			frame.size = newValue
		}
	}
	
	public var anchorPoint: CGPoint {
		get {
			return layer.anchorPoint
		}
		set {
			layer.anchorPoint = newValue
		}
	}
	
	public var perspective: CGFloat {
		get {
			if let superlayer = layer.superlayer {
				return superlayer.sublayerTransform.m34
			}
			return 0
		}
		set {
			if let superlayer = layer.superlayer {
				superlayer.sublayerTransform.m34 = newValue
			}
		}
	}
	
	public var antialiasing: Bool {
		get {
			return layer.allowsEdgeAntialiasing
		}
		set {
			layer.allowsEdgeAntialiasing = newValue
		}
	}
	
	public var bgColor: UIColor {
		get {
			if let color = backgroundColor {
				return color
			}
			return UIColor.clear
		}
		set {
			backgroundColor = newValue
		}
	}
	
	public var transform3d: CATransform3D {
		get {
			return layer.transform
		}
		set {
			layer.transform = newValue
		}
	}
}

extension CALayer : Tweenable {
	public var origin: CGPoint {
		get {
			return frame.origin
		}
		set {
			frame.origin = newValue
		}
	}
	
	public var center: CGPoint {
		get {
			return position
		}
		set {
			position = newValue
		}
	}
	
	public var size: CGSize {
		get {
			return frame.size
		}
		set {
			frame.size = newValue
		}
	}
	
	public var alpha: CGFloat {
		get {
			return CGFloat(opacity)
		}
		set {
			opacity = Float(newValue)
		}
	}
	
	public var perspective: CGFloat {
		get {
			if let superlayer = superlayer {
				return superlayer.sublayerTransform.m34
			}
			return 0
		}
		set {
			if let superlayer = superlayer {
				superlayer.sublayerTransform.m34 = newValue
			}
		}
	}
	
	public var antialiasing: Bool {
		get {
			return allowsEdgeAntialiasing
		}
		set {
			allowsEdgeAntialiasing = newValue
		}
	}
	
	public var bgColor: UIColor {
		get {
			let color = backgroundColor ?? UIColor.clear.cgColor
			return UIColor(cgColor: color)
		}
		set {
			self.backgroundColor = newValue.cgColor
		}
	}
	
	public var transform3d: CATransform3D {
		get {
			return transform
		}
		set {
			transform = newValue
		}
	}
}

extension CAShapeLayer {
	
	func update(_ prop: Property) {
		if let value = prop.value.toInterpolatable() as? UIColor {
			if prop is FillColor {
				fillColor = value.cgColor
			}
		} else {
			super.update(prop)
		}
	}
}
