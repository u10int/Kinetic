//
//  Tweenable.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/5/17.
//
//

import UIKit

public protocol Tweenable: class {
	func apply(_ prop: Property)
	func currentProperty(for prop: Property) -> Property?
}
extension Tweenable {
	public func tween() -> Tween {
		return Tween(target: self)
	}
}

extension Array where Element: Tweenable {
	public func tween() -> Timeline {
		return Kinetic.animateAll(self)
	}
}

public protocol KeyPathTweenable : Tweenable {}
extension Tweenable where Self: KeyPathTweenable {
	
	public func apply(_ prop: Property) {
		if let keyPath = prop as? KeyPath, let target = self as? NSObject, target.responds(to:Selector(keyPath.key)) {
			target.setValue(prop.value.toInterpolatable(), forKey: keyPath.key)
		}
	}
	
	public func currentProperty(for prop: Property) -> Property? {
		if prop is KeyPath {
			if let target = self as? NSObject, let value = target.value(forKey: prop.key) as? Interpolatable {
				return KeyPath(prop.key, value)
			}
		}
		
		return nil
	}
}

extension UIView : Tweenable  {
	
	public func apply(_ prop: Property) {
		if let transform = prop as? Transform {
			transform.applyTo(self)
		} else if let value = prop.value.toInterpolatable() as? CGFloat {
			if prop is X {
				frame.origin.x = value
			} else if prop is Y {
				frame.origin.y = value
			} else if prop is Alpha {
				alpha = value
			} else if let pathProp = prop as? Path {
				center = pathProp.path.interpolate(value)
			}
		} else if let value = prop.value.toInterpolatable() as? CGPoint {
			if prop is Position {
				frame.origin = value
			} else if prop is Center {
				center = value
			} else if prop is Shift {
				frame.origin.x += value.x
				frame.origin.y += value.y
			}
		} else if let value = prop.value.toInterpolatable() as? CGSize {
			if prop is Size {
				frame.size = value
			}
		} else if let value = prop.value.toInterpolatable() as? UIColor {
			if prop is BackgroundColor {
				backgroundColor = value
			}
		}
	}
	
	public func currentProperty(for prop: Property) -> Property? {
		var vectorValue: Property?
		
		if prop is X || prop is Y {
			if prop is X {
				vectorValue = X(frame.origin.x)
			} else {
				vectorValue = Y(frame.origin.y)
			}
		} else if prop is Position {
			vectorValue = Position(frame.origin)
		} else if prop is Center {
			vectorValue = Center(center)
		} else if prop is Shift {
			vectorValue = Shift(CGPoint.zero)
		} else if prop is Size {
			vectorValue = Size(frame.size)
		} else if prop is Alpha {
			vectorValue = Alpha(alpha)
		} else if prop is BackgroundColor {
			if let color = backgroundColor {
				vectorValue = BackgroundColor(color)
			} else {
				vectorValue = BackgroundColor(UIColor.clear)
			}
		} else if prop is Scale {
			vectorValue = layer.transform.scale()
		} else if prop is Rotation {
			vectorValue = layer.transform.rotation()
		} else if prop is Translation {
			vectorValue = layer.transform.translation()
		} else if prop is Path {
			var start = prop
			start.value = CGFloat(0.0).vectorize()
			vectorValue = start
		}
		
		return vectorValue
	}
}

extension CALayer : Tweenable {
	
	public func apply(_ prop: Property) {
		// since CALayer has implicit animations when changing its properties, wrap updates in a CATransaction where animations are disabled
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if let transform = prop as? Transform {
			transform.applyTo(self)
		} else if let value = prop.value.toInterpolatable() as? CGFloat {
			if prop is X {
				frame.origin.x = value
			} else if prop is Y {
				frame.origin.y = value
			} else if prop is Alpha {
				opacity = Float(value)
			} else if prop is BorderWidth {
				borderWidth = value
			} else if prop is CornerRadius {
				cornerRadius = value
			} else if prop is StrokeStart, let shapeLayer = self as? CAShapeLayer {
				shapeLayer.strokeStart = value
			} else if prop is StrokeEnd, let shapeLayer = self as? CAShapeLayer {
				shapeLayer.strokeEnd = value
			} else if let pathProp = prop as? Path {
				position = pathProp.path.interpolate(value)
			}
		} else if let value = prop.value.toInterpolatable() as? CGPoint {
			if prop is Position {
				frame.origin = value
			} else if prop is Center {
				position = value
			} else if prop is Shift {
				frame.origin.x += value.x
				frame.origin.y += value.y
			}
		} else if let value = prop.value.toInterpolatable() as? CGSize {
			if prop is Size {
				frame.size = value
			}
		} else if let value = prop.value.toInterpolatable() as? UIColor {
			if prop is BackgroundColor {
				backgroundColor = value.cgColor
			} else if prop is BorderColor {
				borderColor = value.cgColor
			} else if prop is FillColor, let shapeLayer = self as? CAShapeLayer {
				shapeLayer.fillColor = value.cgColor
			} else if prop is StrokeColor, let shapeLayer = self as? CAShapeLayer {
				shapeLayer.strokeColor = value.cgColor
			}
		}
		
		CATransaction.commit()
	}
	
	public func currentProperty(for prop: Property) -> Property? {
		var vectorValue: Property?
		
		if prop is X || prop is Y {
			if prop is X {
				vectorValue = X(frame.origin.x)
			} else {
				vectorValue = Y(frame.origin.y)
			}
		} else if prop is Position {
			vectorValue = Position(frame.origin)
		} else if prop is Center {
			vectorValue = Center(position)
		} else if prop is Shift {
			vectorValue = Shift(CGPoint.zero)
		} else if prop is Size {
			vectorValue = Size(frame.size)
		} else if prop is Alpha {
			vectorValue = Alpha(CGFloat(opacity))
		} else if prop is BackgroundColor {
			if let color = backgroundColor {
				vectorValue = BackgroundColor(UIColor(cgColor: color))
			} else {
				vectorValue = BackgroundColor(UIColor.clear)
			}
		} else if prop is BorderColor {
			if let color = borderColor {
				vectorValue = BorderColor(UIColor(cgColor: color))
			} else {
				vectorValue = BorderColor(UIColor.clear)
			}
		} else if prop is FillColor, let shapeLayer = self as? CAShapeLayer {
			if let color = shapeLayer.fillColor {
				vectorValue = FillColor(UIColor(cgColor: color))
			} else {
				vectorValue = FillColor(UIColor.clear)
			}
		} else if prop is StrokeColor, let shapeLayer = self as? CAShapeLayer {
			if let color = shapeLayer.strokeColor {
				vectorValue = StrokeColor(UIColor(cgColor: color))
			} else {
				vectorValue = StrokeColor(UIColor.clear)
			}
		} else if prop is StrokeStart, let shapeLayer = self as? CAShapeLayer {
			vectorValue = StrokeStart(shapeLayer.strokeStart)
		} else if prop is StrokeEnd, let shapeLayer = self as? CAShapeLayer {
			vectorValue = StrokeEnd(shapeLayer.strokeEnd)
		} else if prop is Scale {
			vectorValue = transform.scale()
		} else if prop is Rotation {
			vectorValue = transform.rotation()
		} else if prop is Translation {
			vectorValue = transform.translation()
		} else if prop is Path {
			var start = prop
			start.value = CGFloat(0.0).vectorize()
			vectorValue = start
		}
		
		return vectorValue
	}
}

public protocol ViewType {
	var anchorPoint: CGPoint { get set }
	var perspective: CGFloat { get set }
	var antialiasing: Bool { get set }
	var transform3d: CATransform3D { get set }
}

extension UIView : ViewType {}
extension ViewType where Self: UIView {
	
	public var anchorPoint: CGPoint {
		get {
			return layer.anchorPoint
		}
		set {
			// adjust the layer's anchorPoint without moving the view
			// re: https://www.hackingwithswift.com/example-code/calayer/how-to-change-a-views-anchor-point-without-moving-it
			var newPoint = CGPoint(x: bounds.size.width * newValue.x, y: bounds.size.height * newValue.y)
			var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
			
			newPoint = newPoint.applying(transform)
			oldPoint = oldPoint.applying(transform)
			
			var position = layer.position
			
			position.x -= oldPoint.x
			position.x += newPoint.x
			
			position.y -= oldPoint.y
			position.y += newPoint.y
			
			layer.position = position
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
	
	public var transform3d: CATransform3D {
		get {
			return layer.transform
		}
		set {
			layer.transform = newValue
		}
	}
}

extension CALayer : ViewType {}
extension ViewType where Self: CALayer {
	
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
	
	public var transform3d: CATransform3D {
		get {
			return transform
		}
		set {
			transform = newValue
		}
	}
}

public class TransformContainerView: UIView {
	
	public init(view: UIView) {
		super.init(frame: .zero)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		
		NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: self.topAnchor),
									 self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
									 self.leftAnchor.constraint(equalTo: view.leftAnchor),
									 self.rightAnchor.constraint(equalTo: view.rightAnchor)])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
