//
//  AdditiveViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 1/1/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class AdditiveViewController: ExampleViewController {
	var square: UIView!
	var timeline: Timeline!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Additive"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		hideButtons()
		
		square = UIView()
		square.frame = CGRectMake(50, 50, 50, 50)
		square.backgroundColor = UIColor.redColor()
		view.addSubview(square)
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
		view.addGestureRecognizer(tapRecognizer)
		
		timeline = Timeline()
		animation = timeline
	}
	
	func handleTap(gestureRecognizer: UITapGestureRecognizer) {
		let point = gestureRecognizer.locationInView(view)
		
//		let moveX = Kinetic.to(square, duration: 1, options: [.X(point.x)]).ease(Easing.inOutQuad)
//		let moveY = Kinetic.to(square, duration: 1, options: [.Y(point.y)]).ease(Easing.inOutQuad)
//		timeline.add([moveX, moveY], position: timeline.totalTime, align: .Start)
//		timeline.play()
		
		let move = Kinetic.to(square, duration: 1, options: [.Position(point.x, point.y)]).ease(Easing.inOutQuad)
		move.play()
	}

}
