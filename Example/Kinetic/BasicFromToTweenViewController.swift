//
//  BasicFromToTweenViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 2/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

class BasicFromToTweenViewController: ExampleViewController {
	var square: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Basic From/To Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		square = UIView()
		square.frame = CGRect(x: 0, y: 200, width: 50, height: 50)
		square.backgroundColor = UIColor.red
		view.addSubview(square)
		
		let tween = Kinetic.animate(square)
			.from(.position(50,50))
			.to(.position(200,200), .scale(2))
			.duration(0.5)
			.ease(Easing.inOutCubic)
			.delay(0.5)
		
		animation = tween
	}
	
	override func reset() {
		super.reset()
		square.layer.transform = CATransform3DIdentity
		square.frame = CGRect(x: 0, y: 200, width: 50, height: 50)
	}
}
