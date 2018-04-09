//
//  Reversable.swift
//  Pods
//
//  Created by Nicholas Shipes on 6/17/17.
//
//

import Foundation

public enum Direction {
	case forward
	case reversed
}

public protocol Reversable: class {	
	var direction: Direction { get set }
	var reverseOnComplete: Bool { get }
	
	func yoyo() -> Self
}
