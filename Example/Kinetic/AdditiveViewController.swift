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
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AdditiveViewController.handleTap(_:)))
		view.addGestureRecognizer(tapRecognizer)
		
		timeline = Timeline()
		animation = timeline
	}
	
	func handleTap(gestureRecognizer: UITapGestureRecognizer) {
		let point = gestureRecognizer.locationInView(view)				
		let move = Kinetic.animate(square).to(Center(point.x, point.y)).duration(1).ease(.QuadInOut)
		
		move.play()
	}

}
