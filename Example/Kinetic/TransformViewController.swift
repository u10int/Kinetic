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
	var orangeSquare: UIView!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Transform"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		greenSquare = UIView()
		greenSquare.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
		greenSquare.backgroundColor = UIColor ( red: 0.0557, green: 0.7144, blue: 0.0677, alpha: 1.0 )
		view.addSubview(greenSquare)
		
		blueSquare = UIView()
		blueSquare.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
		blueSquare.backgroundColor = UIColor ( red: 0.0, green: 0.6126, blue: 0.9743, alpha: 1.0 )
		view.addSubview(blueSquare)
		
		orangeSquare = UIView()
		orangeSquare.frame = CGRect(x: 0, y: 160, width: 100, height: 100)
		orangeSquare.backgroundColor = .orange
		view.addSubview(orangeSquare)
		
		let timeline = Kinetic.animateAll([greenSquare, blueSquare, orangeSquare]).to(Rotation(y: CGFloat(Double.pi / 2))).duration(1)
		timeline.ease(.sineInOut).perspective(1 / -1000).yoyo().repeatCount(3)
		timeline.anchor(.center)
		animation = timeline
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		greenSquare.center.x = view.center.x - 55
		blueSquare.center.x = view.center.x + 55
		orangeSquare.center.x = view.center.x
	}
}
