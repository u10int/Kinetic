//
//  TimelineViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 1/22/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class TimelineViewController: ExampleViewController {
	var square: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Timeline"
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
		
		let move = Kinetic.to(square, duration: 1, options: [.Position(200,200)]).ease(Easing.inOutCubic)
		let resize = Kinetic.to(square, duration: 1, options: [.Size(150,100)]).ease(Easing.inOutCubic)
		let color = Kinetic.to(square, duration: 0.75, options: [.BackgroundColor(UIColor.blueColor())])
		
		let timeline = Timeline()
		timeline.add(move, position: 0.5)
		timeline.add(resize, position: 1)
		timeline.addLabel("colorChange", position: 1.3)
		timeline.add(color, relativeToLabel: "colorChange", offset: 0)
		
		timeline.repeatCount(4).yoyo()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRectMake(50, 50, 50, 50)
	}
}
