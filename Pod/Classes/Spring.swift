//
//  Spring.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 12/30/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//
//  Spring.swift used and adapted from Cheetah library under the MIT license, https://github.com/suguru/Cheetah
//  Created by Suguru Namura on 2015/08/19.
//  Copyright © 2015年 Suguru Namura.

import UIKit

public class Spring {
	let tension: Double
	let friction: Double
	
	var velocity: Double = 0
	var current: Double = 0
	var elapsed: Double = 0
	var ended: Bool = false
	
	fileprivate let tolerence: Double = 1 / 100000
	fileprivate let maxDT: Double = 16 / 1000
	
	init(tension: Double = 500, friction: Double = 20) {
		self.tension = tension
		self.friction = friction
	}
	
	fileprivate func acceleration(forX x: Double, v: Double) -> Double {
		return (-tension * x) - (friction * v)
	}
	
	fileprivate func proceedStep(_ stepSize: Double) {
		elapsed += stepSize
		
		if ended {
			return
		}
		
		let x = current - 1
		let v = velocity
		
		let ax = v
		let av = acceleration(forX: x, v: v)
		
		let bx = v + av * stepSize * 0.5
		let bv = acceleration(forX: x + ax * stepSize * 0.5, v: bx)
		
		let cx = v + bv * stepSize * 0.5
		let cv = acceleration(forX: x + bx * stepSize * 0.5, v: cx)
		
		let dx = v + cv * stepSize
		let dv = acceleration(forX: x + cx * stepSize, v: dx)
		
		let dxdt = 1.0 / 6.0 * (ax + 2.0 * (bx + cx) + dx)
		let dvdt = 1.0 / 6.0 * (av + 2.0 * (bv + cv) + dv)
		let afterx = x + dxdt * stepSize
		let afterv = v + dvdt * stepSize
		
		ended = abs(afterx) < tolerence && abs(afterv) < tolerence
		
		if ended {
			current = 1
			velocity = 0
		} else {
			current = 1 + afterx
			velocity = afterv
		}
	}
	
	func proceed(_ dt: Double) {
		var dt = dt
		while dt > maxDT {
			proceedStep(maxDT)
			dt -= maxDT
		}
		if dt > 0 {
			proceedStep(dt)
		}
	}
	
	func reset() {
		current = 0
		velocity = 0
		elapsed = 0
		ended = false
	}
}
