//
//  TweenObject.swift
//  Pods
//
//  Created by Nicholas Shipes on 2/28/16.
//
//

import Foundation

class TweenObject {
	weak var target: NSObject?
	
	init(target: NSObject) {
		self.target = target
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
				if let layer = target as? CALayer {
					layer.transform = value
				} else if let view = target as? UIView {
					view.layer.transform = value
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
	
	// MARK: Colors
	
	var backgroundColor: UIColor? {
		get {
			if let layer = target as? CALayer, color = layer.backgroundColor {
				return UIColor(CGColor: color)
			} else if let view = target as? UIView {
				return view.backgroundColor
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CALayer {
					layer.backgroundColor = value.CGColor
				} else if let view = target as? UIView {
					view.backgroundColor = value
				}
			}
		}
	}
	
	var fillColor: UIColor? {
		get {
			if let layer = target as? CAShapeLayer, color = layer.fillColor {
				return UIColor(CGColor: color)
			}
			return nil
		}
		set(newValue) {
			if let value = newValue {
				if let layer = target as? CAShapeLayer {
					layer.fillColor = value.CGColor
				}
			}
		}
	}
	
	// MARK: Public Methods
	
	func colorForKeyPath(keyPath: String) -> UIColor? {
		if let target = target {
			if target.respondsToSelector(Selector(keyPath)) {
				if let color = target.valueForKeyPath(keyPath) as? UIColor {
					if color is CGColorRef {
						return UIColor(CGColor: color as! CGColorRef)
					} else {
						return color
					}
				}
			}
		}
		return nil
	}
	
	func setColor(color: UIColor, forKeyPath keyPath: String) {
		if let target = target {
			if target.respondsToSelector(Selector(keyPath)) {
				if let layer = target as? CALayer {
					layer.setValue(color.CGColor, forKeyPath: keyPath)
				} else {
					target.setValue(color, forKeyPath: keyPath)
				}
			}
		}
	}
}