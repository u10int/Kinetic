//
//  InterpolateTests.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 6/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Kinetic

class InterpolateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testBasicInterpolate() {
		let expectation = XCTestExpectation(description: "animation progress done")
		
		let from = CGPoint(x: 20.0, y: 50.0)
		let to = CGPoint(x: 100.0, y: 80.0)
		let interpolator = Interpolator(from: from, to: to, duration: 1.0, function: Easing(.cubicInOut)) { (value) in
			print(value)
			if (value.x == 100.0 && value.y == 80.0) {
				expectation.fulfill()
			}
		}
		interpolator.run()
		
		wait(for: [expectation], timeout: 1.5)
	}
		
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
