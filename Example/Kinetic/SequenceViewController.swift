//
//  SequenceViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class SequenceViewController: ExampleViewController {
	var square: UIView!

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Sequence"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		square = UIView()
		square.frame = CGRectMake(50, 50, 50, 50)
		square.backgroundColor = UIColor.redColor()
		view.addSubview(square)
		
		let moveX = Kinetic.to(square, duration: 0.5, options: [.X(110)]).ease(Easing.inOutCubic)
		let moveY = Kinetic.to(square, duration: 0.5, options: [.Y(250), .BackgroundColor(UIColor.orangeColor())]).ease(Easing.inOutCubic)
		moveY.onStart { (animation) -> Void in
			print("starting moveY")
		}
		let resize = Kinetic.to(square, duration: 0.5, options: [.Width(200), .BackgroundColor(UIColor.blueColor())]).ease(Easing.inOutCirc)
		resize.onStart { (animation) -> Void in
			print("starting resize")
		}
		
		let timeline = Timeline(tweens: [moveX, moveY, resize], align: .Sequence)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRectMake(50, 50, 50, 50)
		square.backgroundColor = UIColor.redColor()
	}

}
