//
//  TweenObject.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/28/16.
//
//

import UIKit

class TweenObject {
	weak var target: NSObject?
	
	init(target: NSObject) {
		self.target = target
		antialiasing = true
	}
	
	var origin: CGPoint? {
		get {
			if let layer = target as? CALayer {
				return layer.frame.origin
			} else if let view = target as? UIView {
				return view.frame.origin
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.frame.origin = value
				} else if let view = target as? UIView {
					view.frame.origin = value
				}
			}
		}
	}

	var center: CGPoint? {
		get {
			if let layer = target as? CALayer {
				return layer.position
			} else if let view = target as? UIView {
				return view.center
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.position = value
				} else if let view = target as? UIView {
					view.center = value
				}
			}
		}
	}
	
	var size: CGSize? {
		get {
			if let layer = target as? CALayer {
				return layer.bounds.size
			} else if let view = target as? UIView {
				return view.frame.size
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.bounds.size = value
				} else if let view = target as? UIView {
					view.frame.size = value
				}
			}
		}
	}
	
	var frame: CGRect? {
		get {
			if let layer = target as? CALayer {
				return layer.frame
			} else if let view = target as? UIView {
				return view.frame
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.frame = value
				} else if let view = target as? UIView {
					view.frame = value
				}
			}
		}
	}
	
	var alpha: CGFloat? {
		get {
			if let layer = target as? CALayer {
				return CGFloat(layer.opacity)
			} else if let view = target as? UIView {
				return view.alpha
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.opacity = Float(value)
				} else if let view = target as? UIView {
					view.alpha = value
				}
			}
		}
	}
	
	var anchorPoint: CGPoint? {
		get {
			if let layer = target as? CALayer {
				return layer.anchorPoint
			} else if let view = target as? UIView {
				return view.layer.anchorPoint
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.anchorPoint = value
				} else if let view = target as? UIView {
					view.layer.anchorPoint = value
				}
			}
		}
	}
	
	var antialiasing: Bool {
		get {
			if let layer = target as? CALayer {
				return layer.allowsEdgeAntialiasing
			} else if let view = target as? UIView {
				return view.layer.allowsEdgeAntialiasing
			}
			return false
		}
		set(newValue) {
			if let layer = target as? CALayer {
				layer.allowsEdgeAntialiasing = newValue
			} else if let view = target as? UIView {
				view.layer.allowsEdgeAntialiasing = newValue
			}
		}
	}
	
	// MARK: Transforms 
	
	var transform: CATransform3D? {
		get {
			if let layer = target as? CALayer {
				return layer.transform
			} else if let view = target as? UIView {
				return view.layer.transform
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = self.target as? CALayer {
					layer.transform = value
				} else if let view = self.target as? UIView {
					view.layer.transform = value
				}
			}
		}
	}
	
	var translation: Translation? {
		get {
			return transform?.translation()
		}
	}
	var scale: Scale? {
		get {
			return transform?.scale()
		}
	}
	var rotation: Rotation? {
		get {
			return transform?.rotation()
		}
	}
	
	var perspective: CGFloat {
		get {
			var targetLayer: CALayer?
			if let layer = target as? CALayer {
				targetLayer = layer
			} else if let view = target as? UIView {
				targetLayer = view.layer
			}
			
			if let layer = targetLayer, let transform = layer.superlayer?.sublayerTransform {
				return transform.m34
			}
			return 0
		}
		set(newValue) {
			var targetLayer: CALayer?
			if let layer = target as? CALayer {
				targetLayer = layer
			} else if let view = target as? UIView {
				targetLayer = view.layer
			}
			
			if let layer = targetLayer, var transform = layer.superlayer?.sublayerTransform {
				transform.m34 = newValue
				layer.superlayer?.sublayerTransform = transform
			}
		}
	}
	
	// MARK: Colors
	
	var backgroundColor: UIColor? {
		get {
			if let layer = target as? CALayer, let color = layer.backgroundColor {
				return UIColor(cgColor: color)
			} else if let view = target as? UIView {
				return view.backgroundColor
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.backgroundColor = value.cgColor
				} else if let view = target as? UIView {
					view.backgroundColor = value
				}
			}
		}
	}
	
	var tintColor: UIColor? {
		get {
			if let view = target as? UIView {
				return view.tintColor
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let view = target as? UIView {
					view.tintColor = value
				}
			}
		}
	}
	
	var fillColor: UIColor? {
		get {
			if let layer = target as? CAShapeLayer, let color = layer.fillColor {
				return UIColor(cgColor: color)
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CAShapeLayer {
					layer.fillColor = value.cgColor
				}
			}
		}
	}
	
	var strokeColor: UIColor? {
		get {
			if let layer = target as? CAShapeLayer, let color = layer.strokeColor {
				return UIColor(cgColor: color)
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CAShapeLayer {
					layer.strokeColor = value.cgColor
				}
			}
		}
	}
	
	// MARK: Public Methods
	
	func colorForKeyPath(keyPath: String) -> UIColor? {
		if let target = target, target.responds(to:Selector(keyPath)) {
			if let color = target.value(forKeyPath: keyPath) as? UIColor {
				if color is CGColor {
					return UIColor(cgColor: color as! CGColor)
				} else {
					return color
				}
			}
		}
		return nil
	}
	
	func setColor(color: UIColor, forKeyPath keyPath: String) {
		if let target = target, target.responds(to:Selector(keyPath)) {
			if let layer = target as? CALayer {
				layer.setValue(color.cgColor, forKeyPath: keyPath)
			} else {
				target.setValue(color, forKeyPath: keyPath)
			}
		}
	}
	
	// MARK: VectorType Utilities
	
	func update(_ prop: TweenProp) {
		if let prop = prop as? X, let value = prop.value.toInterpolatable() as? CGFloat {
			self.origin?.x = value
		} else if let prop = prop as? Y, let value = prop.value.toInterpolatable() as? CGFloat {
			self.origin?.y = value
		} else if let prop = prop as? Position, let point = prop.value.toInterpolatable() as? CGPoint {
			self.origin = point
		} else if let prop = prop as? Center, let center = prop.value.toInterpolatable() as? CGPoint {
			self.center = center
		} else if let prop = prop as? Size, let size = prop.value.toInterpolatable() as? CGSize {
			self.size = size
		} else if let prop = prop as? Alpha, let value = prop.value.toInterpolatable() as? CGFloat {
			self.alpha = value
		} else if let prop = prop as? BackgroundColor, let value = prop.value.toInterpolatable() as? UIColor {
			self.backgroundColor = value
		} else if let prop = prop as? FillColor, let value = prop.value.toInterpolatable() as? UIColor {
			self.fillColor = value
		}
	}
	
	func currentValueForTweenProp(_ prop: TweenProp) -> TweenProp? {
		var vectorValue: TweenProp?
		
		if let position = origin, prop is X || prop is Y {
			if prop is X {
				vectorValue = X(position.x)
			} else {
				vectorValue = Y(position.y)
			}
		} else if let position = origin, prop is Position {
			vectorValue = Position(position.x, position.y)
		} else if let center = center, prop is Center {
			vectorValue = Center(center.x, center.y)
		} else if let size = size, prop is Size {
			vectorValue = Size(size.width, size.height)
		} else if let alpha = alpha, prop is Alpha {
			vectorValue = Alpha(alpha)
		} else if let color = backgroundColor, prop is BackgroundColor {
			vectorValue = BackgroundColor(color)
		} else if let color = fillColor, prop is FillColor {
			vectorValue = FillColor(color)
		} else if let scale = scale, prop is Scale {
			vectorValue = scale
		} else if let rotation = rotation, prop is Rotation {
			vectorValue = rotation
		} else if let translation = translation, prop is Translation {
			vectorValue = translation
		}
		
		return vectorValue
	}
	
	// MARK: Private Methods
	
	private func performBlockByDisablingActions(block: () -> Void) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		block()
		CATransaction.commit()
	}
}
