//
//  PathTests.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Kinetic

class PathTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinearPathTween() {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0))
		let path = Line(start: CGPoint(x: 20.0, y: 20.0), end: CGPoint(x: 200.0, y: 200.0))
		
		var completeTriggered = false
		
		let tween = Tween(target: view).along(path).duration(2.0).ease(Cubic.easeInOut)
		tween.on(.updated) { (tween) in
			print(view.center)
		}.on(.completed) { (tween) in
			print(view.center)
			completeTriggered = true
		}
		
		expect(tween.duration).to(equal(2.0))
		expect(tween.time).to(equal(0))
		
		tween.play()
		
//		tween.progress = 0.5
//		expect(tween.time).to(equal(1.0))
//		expect(view.frame.size).to(equal(CGSize(width: 75.0, height: 75.0)))
		
		expect(completeTriggered).toEventually(beTrue(), timeout: 2.5)
    }
	
}
