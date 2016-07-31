//
//  BasicFromTweenViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 2/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

class BasicFromTweenViewController: ExampleViewController {
	var square: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Basic From Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		square = UIView()
		square.frame = CGRectMake(200, 200, 100, 100)
		square.backgroundColor = UIColor.redColor()
		view.addSubview(square)
				
		let tween = Kinetic.animate(square).from(Position(x: 50), Size(height: 10)).duration(0.5).ease(.QuartInOut)
		animation = tween
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRectMake(200, 200, 100, 100)
	}
}
