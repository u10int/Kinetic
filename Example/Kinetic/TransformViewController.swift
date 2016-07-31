//
//  TransformViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 1/1/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class TransformViewController: ExampleViewController {
	var greenSquare: UIView!
	var blueSquare: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Transform"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		greenSquare = UIView()
		greenSquare.frame = CGRectMake(0, 50, 100, 100)
		greenSquare.backgroundColor = UIColor ( red: 0.0557, green: 0.7144, blue: 0.0677, alpha: 1.0 )
		view.addSubview(greenSquare)
		
		blueSquare = UIView()
		blueSquare.frame = CGRectMake(0, 50, 100, 100)
		blueSquare.backgroundColor = UIColor ( red: 0.0, green: 0.6126, blue: 0.9743, alpha: 1.0 )
		view.addSubview(blueSquare)
				
		let timeline = Kinetic.animateAll([greenSquare, blueSquare]).to(Rotation(y: CGFloat(M_PI_2))).duration(1)
		timeline.ease(.SineInOut).perspective(1 / -1000).yoyo().repeatCount(3)
		animation = timeline
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		var frame = greenSquare.frame
		frame.origin.x = CGRectGetMidX(view.frame) - CGRectGetWidth(frame) - 2
		greenSquare.frame = frame
		
		frame.origin.x = CGRectGetMidX(view.frame) + 2
		blueSquare.frame = frame
	}
	
	override func reset() {
		super.reset()
		greenSquare.transform = CGAffineTransformIdentity
		blueSquare.transform = CGAffineTransformIdentity
	}

}
