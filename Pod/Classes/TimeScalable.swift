//
//  TimeScalable.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/2/17.
//

import Foundation

public protocol TimeScalable: class {
	var timeScale: Double { get set }
}

extension TimeScalable {
	
	public func normal() {
		timeScale = 1.0
	}
	
	public func slower() {
		timeScale -= 0.5
		timeScale = max(timeScale, 0.1)
	}
	
	public func faster() {
		timeScale += 0.5
	}
	
	public func speed(_ value: Double) {
		timeScale = value
	}
	
	public func slomo(to value: Double, duration: TimeInterval = 0.2) {
		let interpolator = Interpolator(from: timeScale, to: value, duration: duration, function: LinearTimingFunction()) { [weak self] (value) in
			self?.timeScale = value
		}
		interpolator.run()
	}
}
