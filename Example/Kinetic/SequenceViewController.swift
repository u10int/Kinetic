
//
//  SequenceViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class SequenceViewController: ExampleViewController {
	var square: UIView!

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Sequence"
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
		
		let moveX = Tween(target: square).to(X(110)).duration(0.5).ease(Cubic.easeInOut)
		
		let moveY = Tween(target: square).to(Y(250), BackgroundColor(UIColor.orange)).duration(0.5).ease(Cubic.easeInOut)
		moveY.on(.started) { (animation) -> Void in
			print("starting moveY")
		}
		
		let resize = Tween(target: square).to(Size(width: 200), BackgroundColor(UIColor.blue)).duration(0.5).ease(Circular.easeInOut)
		resize.on(.started) { [weak self] (animation) -> Void in
			print("starting resize")
			self?.perform(#selector(SequenceViewController.slower), with: nil, afterDelay: 2.0)
			self?.perform(#selector(SequenceViewController.faster), with: nil, afterDelay: 4.0)
		}
		
		let timeline = Timeline(tweens: [moveX, moveY, resize], align: .sequence)
		timeline.yoyo().forever()
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor.red
	}

	func slower() {
//		animation?.slower()
		animation?.slowMo(to: 0.3, duration: 0.5)
	}
	
	func faster() {
		animation?.normal()
	}
}
