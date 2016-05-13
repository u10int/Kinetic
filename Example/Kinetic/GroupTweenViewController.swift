//
//  GroupTweenViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 1/1/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class GroupTweenViewController: ExampleViewController {
	var square: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Grouped Tween"
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
		
		let moveX = Tween(target: square).to(.X(200)).duration(0.5).ease(Easing.inOutCubic)
		let moveY = Tween(target: square).to(.Y(290)).duration(0.75).ease(Easing.outSine)
		let color = Tween(target: square).to(.BackgroundColor(UIColor.yellowColor())).duration(0.5).ease(Easing.outSine)
		
		let timeline = Timeline(tweens: [moveX, moveY, color], align: .Start)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRectMake(50, 50, 50, 50)
		square.backgroundColor = UIColor.redColor()
	}
	
}
