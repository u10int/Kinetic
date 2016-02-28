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
	case Translation = "transform.translation"
	case Scale = "transform.scale"
	case Rotation = "transform.rotation"
	case RotationX = "transform.rotation.x"
	case RotationY = "transform.rotation.y"
	case Transform = "transform"
	case Alpha = "alpha"
	case BackgroundColor = "backgroundColor"
}

class TweenUtils {
	
	static func propertyKeyForType(type: Property) -> String? {
		var propKey: String?
		
		switch type {
		case .KeyPath(let key, _):
			propKey = key
		case .Alpha(_):
			propKey = PropertyKey.Alpha.rawValue
		case .BackgroundColor(_):
			propKey = PropertyKey.BackgroundColor.rawValue
		case .X(_):
			propKey = PropertyKey.X.rawValue
		case .Y(_):
			propKey = PropertyKey.Y.rawValue
		case .Position(_, _), .Shift(_, _):
			propKey = PropertyKey.Position.rawValue
		case .CenterX(_):
			propKey = PropertyKey.CenterX.rawValue
		case .CenterY(_):
			propKey = PropertyKey.CenterY.rawValue
		case .Center(_, _):
			propKey = PropertyKey.Center.rawValue
		case .Width(_):
			propKey = PropertyKey.Width.rawValue
		case .Height(_):
			propKey = PropertyKey.Height.rawValue
		case .Size(_, _):
			propKey = PropertyKey.Size.rawValue
		case .Translate(_, _):
			propKey = PropertyKey.Translation.rawValue
		case .Scale(_), .ScaleXY(_, _):
			propKey = PropertyKey.Scale.rawValue
		case .Rotate(_):
			propKey = PropertyKey.Rotation.rawValue
		case .RotateX(_):
			propKey = PropertyKey.RotationX.rawValue
		case .RotateY(_):
			propKey = PropertyKey.RotationY.rawValue
		default:
			propKey = PropertyKey.Transform.rawValue
		}
		
		return propKey
	}
	
	static func sortProperties(props: [TweenProperty]) -> [TweenProperty] {
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