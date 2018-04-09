//
//  PropertyTests.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Kinetic

class PropertyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicProperties() {	
		
		let x = X(20.0)
		expect(x).to(beAKindOf(X.self))
		expect(x.value).to(beAKindOf(InterpolatableValue.self))
		expect(x.value.vectors).to(haveCount(1))
		expect(x.value.toInterpolatable()).to(beAKindOf(CGFloat.self))
		expect(x.value.vectors[0]).to(equal(20.0))
		
		let position = Position(100.0, 200.0)
		expect(position).to(beAKindOf(Position.self))
		expect(position.value).to(beAKindOf(InterpolatableValue.self))
		expect(position.value.vectors).to(haveCount(2))
		expect(position.value.toInterpolatable()).to(beAKindOf(CGPoint.self))
		expect(position.value.vectors[0]).to(equal(100.0))
		expect(position.value.vectors[1]).to(equal(200.0))
		
		let center = Center(100.0, 200.0)
		expect(center).to(beAKindOf(Center.self))
		expect(center.value).to(beAKindOf(InterpolatableValue.self))
		expect(center.value.vectors).to(haveCount(2))
		expect(center.value.toInterpolatable()).to(beAKindOf(CGPoint.self))
		expect(center.value.vectors[0]).to(equal(100.0))
		expect(center.value.vectors[1]).to(equal(200.0))
		
		let size = Size(100.0, 200.0)
		expect(size).to(beAKindOf(Size.self))
		expect(size.value).to(beAKindOf(InterpolatableValue.self))
		expect(size.value.vectors).to(haveCount(2))
		expect(size.value.toInterpolatable()).to(beAKindOf(CGSize.self))
		expect(size.value.vectors[0]).to(equal(100.0))
		expect(size.value.vectors[1]).to(equal(200.0))
		
		let bgColor = BackgroundColor(UIColor.red)
		expect(bgColor).to(beAKindOf(BackgroundColor.self))
		expect(bgColor.value).to(beAKindOf(InterpolatableValue.self))
		expect(bgColor.value.vectors).to(haveCount(4))
		expect(bgColor.value.toInterpolatable()).to(beAKindOf(UIColor.self))
		
		let scale = Scale(2.0)
		expect(scale).to(beAKindOf(Scale.self))
		expect(scale.value.vectors).to(haveCount(3))
		expect(scale.value.toInterpolatable()).to(beAKindOf(Vector3.self))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
