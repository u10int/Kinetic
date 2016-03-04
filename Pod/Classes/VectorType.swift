//
//  VectorType.swift
//  Pods
//
//  Created by Nicholas Shipes on 3/2/16.
//
//

import Foundation

public protocol VectorType: Equatable {
	static var zero: Self { get }
	static var key: String { get }
}