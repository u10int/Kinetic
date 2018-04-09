//
//  TimeScalableTests.swift
//  Kinetic_Tests
//
//  Created by Nicholas Shipes on 12/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Kinetic

class TimeScalableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTimeScaleChanges() {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0))

		let tween = Tween(target: view).to(Size(100.0, 100.0)).duration(2.0)
		expect(tween.timeScale).to(equal(1.0))
		
		tween.faster()
		expect(tween.timeScale).to(equal(1.2))
		
		tween.slower()
		expect(tween.timeScale).to(equal(1.0))
		
		tween.slower()
		expect(tween.timeScale).to(equal(0.8))
		
		tween.speed(0.1)
		expect(tween.timeScale).to(equal(0.1))
		
		tween.slower()
		expect(tween.timeScale).to(equal(0.1))
		
    }
    
}
