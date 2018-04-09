//
//  File.swift
//  Pods
//
//  Created by Nicholas Shipes on 6/17/17.
//
//

import Foundation

public protocol Repeatable: class {	
	var cycle: Int { get }
	var repeatCount: Int { get }
	var repeatDelay: TimeInterval { get }
	var repeatForever: Bool { get }
	
	func repeatCount(_ count: Int) -> Self
	func repeatDelay(_ delay: TimeInterval) -> Self
	func forever() -> Self
}
