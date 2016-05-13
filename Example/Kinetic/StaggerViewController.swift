//
//  StaggerViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 1/22/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class StaggerViewController: ExampleViewController {
	var squares = [UIView]()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Stagger Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		let total = 7
		var y: CGFloat = 50
		for _ in 0..<total {
			let square = UIView()
			square.frame = CGRectMake(50, y, 50, 50)
			square.backgroundColor = UIColor.redColor()
			view.addSubview(square)
			
			squares.append(square)
			y = CGRectGetMaxY(square.frame) + 5
		}
				
		let tween = Kinetic.animateAll(squares).to(.Width(200)).duration(1).stagger(0.08).spring(tension: 100, friction: 12)
		animation = tween
	}
	
	override func reset() {
		super.reset()
		
		for square in squares {
			square.frame.size.width = 50
		}
	}
}
