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
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Basic From Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		square = UIView()
		square.frame = CGRect(x: 200, y: 200, width: 100, height: 100)
		square.backgroundColor = UIColor.red
		view.addSubview(square)
				
		let tween = Kinetic.animate(square)
			.from(.x(50), .height(10))
			.duration(0.5)
			.ease(Easing.inOutQuart)
		
		animation = tween
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRect(x: 200, y: 200, width: 100, height: 100)
	}
}
