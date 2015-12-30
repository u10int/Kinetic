//
//  ViewController.swift
//  Tween
//
//  Created by Nicholas Shipes on 10/22/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class TestObject: NSObject {
	var value: CGFloat = 0
}

class ViewController: UIViewController {
	var square: UIView!
	var square2: UIView!
	var label: UILabel!
	
	private var originalSquareFrame = CGRectZero
	private var originalSquare2Frame = CGRectZero

	override func viewDidLoad() {
		super.viewDidLoad()
		
		square = UIView()
		square.frame = CGRectMake(50, 50, 50, 50)
		square.backgroundColor = UIColor.redColor()
		view.addSubview(square)
		
		square2 = UIView()
		square2.frame = CGRectMake(200, 200, 50, 50)
		square2.backgroundColor = UIColor.blueColor()
		view.addSubview(square2)
		
		var testTransform = CATransform3DIdentity
		testTransform = CATransform3DTranslate(testTransform, 0, 50, 0)
		testTransform = CATransform3DRotate(testTransform, CGFloat(M_PI_4), 0, 0, 1)
		let testSquare = UIView()
		testSquare.frame = square2.frame
		testSquare.backgroundColor = UIColor.greenColor()
		testSquare.layer.anchorPoint = CGPointMake(0.5, 0.5)
		testSquare.layer.transform = testTransform
		view.addSubview(testSquare)
		
		label = UILabel()
		label.frame = CGRectMake(20, 30, 200, 20)
		label.font = UIFont.systemFontOfSize(14)
		label.textColor = UIColor.blackColor()
		view.addSubview(label)
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: "animate:")
		view.addGestureRecognizer(tapRecognizer)
		
		originalSquareFrame = square.frame
		originalSquare2Frame = square2.frame
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func animate(gestureRecognizer: UITapGestureRecognizer) {
		let duration: CFTimeInterval = 1
		let delay: CFTimeInterval = 0
		reset()
		
		let move = Motion.to(square, duration: duration, options: [.Shift(100, 100), .Width(200)])
		move.ease(Easing.inOutQuart).delay(delay).play()
		
		var timer: CFTimeInterval = 0
		var startTimer: CFTimeInterval = 0
		let resize = Motion.to(square, duration: duration, options: [.Scale(0.5), .Rotate(CGFloat(M_PI_4))])
		resize.ease(Easing.inOutQuart).delay(delay + duration).onStart { () -> Void in
			print("started")
			startTimer = CACurrentMediaTime()
			timer = CACurrentMediaTime()
		}.onUpdate({ () -> Void in
			timer = CACurrentMediaTime()
		}).onComplete { () -> Void in
			print("completed: diff=\(timer - startTimer)")
		}.yoyo().repeatCount(4).play()
		print("TWEEN: start=\(resize.startTime), end=\(resize.endTime), total=\(resize.totalDuration)")
		
		
		
		let testObject = TestObject()
		testObject.value = 50
		label.text = "\(round(testObject.value))"
		
		let increment = Motion.to(testObject, duration: duration, options: [.KeyPath("value", 100)])
		increment.ease(Easing.outQuart).onUpdate { () -> Void in
			self.label.text = "\(round(testObject.value))"
		}.onComplete({ () -> Void in
			self.label.text = "\(round(testObject.value))"
		}).play()
		
//		let move = Motion.itemsTo([square, square2], duration: duration, options: [.Shift(100, 100)])
//		move.ease(Easing.inOutQuart).delay(delay).stagger(0.1).play()
	}
	
	func reset() {
		square.layer.transform = CATransform3DIdentity
		square.frame = originalSquareFrame
		square2.layer.transform = CATransform3DIdentity
		square2.frame = originalSquare2Frame
		
		Motion.killAll()
	}
}

