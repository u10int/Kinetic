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
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Stagger Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		let total = 7
		var y: CGFloat = 50
		for _ in 0..<total {
			let square = UIView()
			square.frame = CGRect(x: 50, y: y, width: 50, height: 50)
			square.backgroundColor = UIColor.red
			view.addSubview(square)
			
			squares.append(square)
			y = square.frame.maxY + 5
		}
				
		let tween = Kinetic.animateAll(squares)
			.to(.width(200))
			.duration(1)
			.stagger(0.08)
			.spring(tension: 100, friction: 12)
		
		animation = tween
	}
	
	override func reset() {
		super.reset()
		
		for square in squares {
			square.frame.size.width = 50
		}
	}
}
