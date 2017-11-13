//
//  TimelineTests.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Kinetic

class TimelineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTotalDuration() {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0))
		
        let timeline = Timeline()
		expect(timeline.totalDuration).to(equal(0))
		
		let moveX = Tween(target: view).to(X(110)).duration(0.5)
		let moveY = Tween(target: view).to(Y(250)).duration(0.5)
		let resize = Tween(target: view).to(Size(width: 200)).duration(0.5)
		
		timeline.add(moveX)
		expect(timeline.totalDuration).to(equal(0.5))
		
		timeline.add(moveY, position: 0.25)
		expect(timeline.totalDuration).to(equal(0.75))
		
		timeline.add(resize, position: "+=1.5")
		expect(timeline.totalDuration).to(equal(2.75))
		
		expect(timeline.tweens).to(haveCount(3))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
