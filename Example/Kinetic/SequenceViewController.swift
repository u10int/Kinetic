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

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Sequence"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		square = UIView()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor.red
		view.addSubview(square)
		
		let moveX = Tween(target: square).to(.x(110)).duration(0.5).ease(Easing.inOutCubic)
		
		let moveY = Tween(target: square).to(.y(250), .backgroundColor(.orange)).duration(0.5).ease(Easing.inOutCubic)
		moveY.onStart { (animation) -> Void in
			print("starting moveY")
		}
		
		let resize = Tween(target: square).to(.width(200), .backgroundColor(.blue)).duration(0.5).ease(Easing.inOutCirc)
		resize.onStart { (animation) -> Void in
			print("starting resize")
		}
		
		let timeline = Timeline(tweens: [moveX, moveY, resize], align: .sequence)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor.red
	}

}
