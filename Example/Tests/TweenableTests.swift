//
//  TweenableTests.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Kinetic

class TweenableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTweenableCAShapeLayer() {
        let layer = CAShapeLayer()
		layer.bounds = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
		layer.strokeColor = UIColor.red.cgColor
		layer.fillColor = UIColor.orange.cgColor
		layer.lineWidth = 2.0
		
		let expectation = XCTestExpectation(description: "animation progress done")
		
		let tween = Tween(target: layer).to(FillColor(UIColor.green)).duration(0.5)
		tween.onUpdate { (tween) in
			print(layer.fillColor)
		}.onComplete { (tween) in
			expectation.fulfill()
		}
		
		tween.play()
		
		wait(for: [expectation], timeout: tween.duration + 1.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
