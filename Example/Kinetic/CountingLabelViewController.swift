//
//  CountingLabelViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 2/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

class CustomObject: NSObject, KeyPathTweenable {
	var value: Float = 0
}

class CountingLabelViewController: ExampleViewController {
	var textLabel: UILabel!
	var testObject: CustomObject!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Counting Label"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		textLabel = UILabel()
		textLabel.font = UIFont.systemFont(ofSize: 40)
		textLabel.textColor = UIColor.black
		textLabel.frame = CGRect(x: 50, y: 50, width: 200, height: 50)
		view.addSubview(textLabel)
		
		testObject = CustomObject()
		testObject.value = 50
		textLabel.text = "\(testObject.value)"
				
		let tween = Kinetic.animate(testObject)
			.to(KeyPath("value", 250.0))
			.duration(2)
			.ease(Exponential.easeOut)
		
		tween.on(.updated) { (animation) -> Void in
			self.textLabel.text = "\(String(format:"%.1f", self.testObject.value))"
		}.on(.completed) { (animation) -> Void in
			print("DONE")
		}
		
		animation = tween
	}
}
