//
//  PhysicsViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 1/22/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class PhysicsViewController: ExampleViewController {
	var square: UIView!
	var tensionSlider: UISlider!
	var frictionSlider: UISlider!
	var tensionValue: UILabel!
	var frictionValue: UILabel!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Physics Tween"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		square = UIView()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor(red: 0.4693, green: 0.0, blue: 1.0, alpha: 1.0)
		view.addSubview(square)
		
		let tensionLabel = UILabel()
		tensionLabel.translatesAutoresizingMaskIntoConstraints = false
		tensionLabel.font = UIFont.systemFont(ofSize: 16)
		tensionLabel.textColor = UIColor(white: 0.1, alpha: 1)
		tensionLabel.text = "Tension"
		view.addSubview(tensionLabel)
		
		tensionValue = UILabel()
		tensionValue.translatesAutoresizingMaskIntoConstraints = false
		tensionValue.font = UIFont.boldSystemFont(ofSize: 16)
		tensionValue.textColor = UIColor(white: 0.1, alpha: 1)
		tensionValue.text = "0"
		view.addSubview(tensionValue)
		
		tensionSlider = UISlider()
		tensionSlider.translatesAutoresizingMaskIntoConstraints = false
		tensionSlider.minimumValue = 0
		tensionSlider.maximumValue = 300
		tensionSlider.addTarget(self, action: #selector(PhysicsViewController.tensionChanged(_:)), for: .valueChanged)
		view.addSubview(tensionSlider)
		
		let frictionLabel = UILabel()
		frictionLabel.translatesAutoresizingMaskIntoConstraints = false
		frictionLabel.font = UIFont.systemFont(ofSize: 16)
		frictionLabel.textColor = UIColor(white: 0.1, alpha: 1)
		frictionLabel.text = "Friction"
		view.addSubview(frictionLabel)
		
		frictionValue = UILabel()
		frictionValue.translatesAutoresizingMaskIntoConstraints = false
		frictionValue.font = UIFont.boldSystemFont(ofSize: 16)
		frictionValue.textColor = UIColor(white: 0.1, alpha: 1)
		frictionValue.text = "0"
		view.addSubview(frictionValue)
		
		frictionSlider = UISlider()
		frictionSlider.translatesAutoresizingMaskIntoConstraints = false
		frictionSlider.minimumValue = 0
		frictionSlider.maximumValue = 50
		frictionSlider.addTarget(self, action: #selector(PhysicsViewController.frictionChanged(_:)), for: .valueChanged)
		view.addSubview(frictionSlider)
		
		// layout
		let views = ["play": playButton, "tension": tensionSlider, "tensionLabel": tensionLabel, "tensionValue": tensionValue, "friction": frictionSlider, "frictionLabel": frictionLabel, "frictionValue": frictionValue] as [String : Any]
		let tensionHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tensionLabel(80)]-10-[tension]-10-[tensionValue(40)]-20-|", options: .alignAllCenterY, metrics: nil, views: views)
		let tensionLabelY = NSLayoutConstraint(item: tensionLabel, attribute: .bottom, relatedBy: .equal, toItem: playButton, attribute: .top, multiplier: 1, constant: -50)
		let frictionHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[frictionLabel(80)]-10-[friction]-10-[frictionValue(40)]-20-|", options: .alignAllCenterY, metrics: nil, views: views)
		let frictionLabelY = NSLayoutConstraint(item: frictionLabel, attribute: .bottom, relatedBy: .equal, toItem: tensionLabel, attribute: .top, multiplier: 1, constant: -30)
		
		view.addConstraints(tensionHorizontal)
		view.addConstraint(tensionLabelY)
		view.addConstraints(frictionHorizontal)
		view.addConstraint(frictionLabelY)
		
		tensionSlider.setValue(70, animated: false)
		tensionValue.text = "\(Int(round(tensionSlider.value)))"
		
		frictionSlider.setValue(10, animated: false)
		frictionValue.text = "\(Int(round(frictionSlider.value)))"
	}
	
	override func play() {
		let tween = Kinetic.animate(square)
			.to(.x(250), .height(100))
			.duration(0.5)
			.spring(tension: Double(tensionSlider.value), friction: Double(frictionSlider.value))
		
		animation = tween
		animation?.play()
	}
	
	override func reset() {
		animation?.stop()
		Kinetic.killTweensOf(square)
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
	}
	
	func tensionChanged(_ sender: UISlider) {
		tensionValue.text = "\(Int(round(sender.value)))"
		reset()
	}
	
	func frictionChanged(_ sender: UISlider) {
		frictionValue.text = "\(Int(round(sender.value)))"
		reset()
	}
	
}
