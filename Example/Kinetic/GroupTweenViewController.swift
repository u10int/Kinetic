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
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Grouped Tween"
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
		
		let moveX = Tween(target: square).to(.x(200)).duration(0.5).ease(Easing.inOutCubic)
		let moveY = Tween(target: square).to(.y(290)).duration(0.75).ease(Easing.outSine)
		let color = Tween(target: square).to(.backgroundColor(.yellow)).duration(0.5).ease(Easing.outSine)
		
		let timeline = Timeline(tweens: [moveX, moveY, color], align: .start)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor.red
	}
	
}
