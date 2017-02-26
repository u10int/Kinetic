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
			if let t = transform {
				var value = Translation.zero
				value.x = sqrt(t.m41 * t.m41)
				value.y = sqrt(t.m42 * t.m42)
				
				let inv = CATransform3DInvert(t)
				value.x = inv.m41 * -1
				value.y = inv.m42 * -1
				
//				value.x = (value.x * inv.m11) + (value.y * inv.m21) + (0 * inv.m31) + inv.m41;
//				value.y = (value.x * inv.m12) + (value.y * inv.m22) + (0 * inv.m32) + inv.m42;
//				value.z = (value.x * inv.m13) + (value.y * inv.m23) + (0 * inv.m33) + inv.m43;
//				print("current translation: \(value)")
				
				return value
			}
			return nil
		}
	}
	var scale: Scale? {
		get {
			if let t = transform {
				var value = Scale.zero
				value.x = sqrt((t.m11 * t.m11) + (t.m12 * t.m12) + (t.m13 * t.m13))
				value.y = sqrt((t.m21 * t.m21) + (t.m22 * t.m22) + (t.m23 * t.m23))
				
//				value.x = t.m11
//				value.y = t.m22
				
				return value
			}
			return nil
		}
	}
	var rotation: Rotation? {
		get {
			if let t = transform {
				var value = Rotation.zero
				value.angle = atan2(t.m12, t.m11)
				value.z = 1
				
//				let inv = CATransform3DInvert(t)
//				
				// x rotation
//				value.angle = acos(t.m11)
				
				// y rotation
//				value.angle = asin(t.m12)
				
				return value
			}
			return nil
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
					print("setting fill color to \(value)")
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
	
	func colorForKeyPath(_ keyPath: String) -> UIColor? {
		if let target = target {
			if target.responds(to: Selector(keyPath)) {
				if let color = target.value(forKeyPath: keyPath) as? UIColor {
					if color is CGColor {
						return UIColor(cgColor: color as! CGColor)
					} else {
						return color
					}
				}
			}
		}
		return nil
	}
	
	func setColor(_ color: UIColor, forKeyPath keyPath: String) {
		if let target = target {
			if target.responds(to: Selector(keyPath)) {
				if let layer = target as? CALayer {
					layer.setValue(color.cgColor, forKeyPath: keyPath)
				} else {
					target.setValue(color, forKeyPath: keyPath)
				}
			}
		}
	}
	
	// MARK: Private Methods
	
	fileprivate func performBlockByDisablingActions(_ block: () -> Void) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		block()
		CATransaction.commit()
	}
}
