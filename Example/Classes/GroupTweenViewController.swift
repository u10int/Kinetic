//
//  GroupTweenViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 1/1/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

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
		
		let moveX = Kinetic.to(square, duration: 0.5, options: [.X(200)]).ease(Easing.inOutCubic)
		let moveY = Kinetic.to(square, duration: 0.75, options: [.Y(290)]).ease(Easing.outSine)
		let color = Kinetic.to(square, duration: 0.5, options: [.BackgroundColor(UIColor.yellowColor())]).ease(Easing.outSine)
		
		let timeline = Timeline(tweens: [moveX, moveY, color], align: .Start)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
}
