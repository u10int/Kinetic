//
//  TweenUtils.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 1/22/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import Foundation

enum PropertyKey: String {
	case X = "frame.origin.x"
	case Y = "frame.origin.y"
	case Position = "frame.origin"
	case CenterX = "center.x"
	case CenterY = "center.y"
	case Center = "center"
	case Width = "frame.size.width"
	case Height = "frame.size.height"
	case Size = "frame.size"
	case Frame = "frame"
	case Transform = "transform"
	case Alpha = "alpha"
	case BackgroundColor = "backgroundColor"
	case FillColor = "fillColor"
	case StrokeColor = "strokeColor"
	case TintColor = "tintColor"
}

class TweenUtils {
	
	static func propertyKeyForType(_ type: Property) -> String? {
		var propKey: String?
		
		switch type {
		case .keyPath(let key, _):
			propKey = key
		case .alpha(_):
			propKey = PropertyKey.Alpha.rawValue
		case .backgroundColor(_):
			propKey = PropertyKey.BackgroundColor.rawValue
		case .fillColor(_):
			propKey = PropertyKey.FillColor.rawValue
		case .strokeColor(_):
			propKey = PropertyKey.StrokeColor.rawValue
		case .tintColor(_):
			propKey = PropertyKey.TintColor.rawValue
		case .x(_):
			propKey = PropertyKey.X.rawValue
		case .y(_):
			propKey = PropertyKey.Y.rawValue
		case .position(_, _), .shift(_, _):
			propKey = PropertyKey.Position.rawValue
		case .centerX(_):
			propKey = PropertyKey.CenterX.rawValue
		case .centerY(_):
			propKey = PropertyKey.CenterY.rawValue
		case .center(_, _):
			propKey = PropertyKey.Center.rawValue
		case .width(_):
			propKey = PropertyKey.Width.rawValue
		case .height(_):
			propKey = PropertyKey.Height.rawValue
		case .size(_, _):
			propKey = PropertyKey.Size.rawValue
		case .translate(_, _):
			propKey = PropertyKey.Transform.rawValue
		case .scale(_), .scaleXY(_, _):
			propKey = PropertyKey.Transform.rawValue
		case .rotate(_):
			propKey = PropertyKey.Transform.rawValue
		case .rotateX(_):
			propKey = PropertyKey.Transform.rawValue
		case .rotateY(_):
			propKey = PropertyKey.Transform.rawValue
		default:
			propKey = PropertyKey.Transform.rawValue
		}
		
		return propKey
	}
	
	static func sortProperties(_ props: [TweenProperty]) -> [TweenProperty] {
		var sorted = [TweenProperty]()
		var transform: TransformProperty?
		
		for prop in props {
			if let prop = prop as? TransformProperty {
				transform = prop
			} else {
				sorted.append(prop)
			}
		}
		
		if let transform = transform {
			sorted.append(transform)
		}
		
		return sorted
	}
}
