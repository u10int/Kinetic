//
//  TimelineViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 1/22/16.
//  Copyright © 2016 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class TimelineViewController: ExampleViewController {
	var square: UIView!
	var progressValue: UILabel!
	var progressSlider: UISlider!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Timeline"
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
		
		let progressLabel = UILabel()
		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.font = UIFont.systemFont(ofSize: 16)
		progressLabel.textColor = UIColor(white: 0.1, alpha: 1)
		progressLabel.text = "Position"
		view.addSubview(progressLabel)
		
		progressValue = UILabel()
		progressValue.translatesAutoresizingMaskIntoConstraints = false
		progressValue.font = UIFont.boldSystemFont(ofSize: 16)
		progressValue.textColor = UIColor(white: 0.1, alpha: 1)
		progressValue.text = "0%"
		view.addSubview(progressValue)
		
		progressSlider = UISlider()
		progressSlider.translatesAutoresizingMaskIntoConstraints = false
		progressSlider.minimumValue = 0.0
		progressSlider.maximumValue = 1.0
		progressSlider.addTarget(self, action: #selector(TimelineViewController.progressChanged(_:)), for: .valueChanged)
		view.addSubview(progressSlider)
		
		// layout
		let views = ["progress": progressSlider, "progressLabel": progressLabel, "progressValue": progressValue] as [String : Any]
		let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[progressLabel(60)]-10-[progress]-10-[progressValue(50)]-20-|", options: .alignAllCenterY, metrics: nil, views: views)
		let verticalConstraint = NSLayoutConstraint(item: progressLabel, attribute: .bottom, relatedBy: .equal, toItem: playButton, attribute: .top, multiplier: 1, constant: -50)
		
		view.addConstraints(horizontalConstraints)
		view.addConstraint(verticalConstraint)
		
		// animation
		let move = Tween(target: square).to(.position(200, 200)).duration(1).ease(Easing.inOutCubic)
		let resize = Tween(target: square).to(.size(150, 150)).duration(1).ease(Easing.inOutCubic)
		let color = Tween(target: square).to(.backgroundColor(.blue)).duration(0.75)
		
		let timeline = Timeline()
		timeline.add(move, position: 0.5)
		timeline.add(resize, position: 1)
		timeline.addLabel("colorChange", position: 1.3)
		timeline.add(color, relativeToLabel: "colorChange", offset: 0)
		
		timeline.repeatCount(4).yoyo()
		
		timeline.onStart { (animation) in
			print("timeline started")
		}.onUpdate { (animation) in
			let progress = Float(animation.totalProgress())
			self.updateProgress(progress)
		}.onComplete { (animation) in
			print("timeline done")
		}
		
		animation = timeline
	}
	
	override func reset() {
		super.reset()
		square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
		square.backgroundColor = UIColor.red
		updateProgress(0)
	}
	
	func progressChanged(_ sender: UISlider) {
		animation?.pause()
		progressValue.text = "\(Int(round(sender.value * 100)))%"
		
		if let timeline = animation as? Timeline {
			timeline.setTotalProgress(Float(sender.value))
		}
	}
	
	func updateProgress(_ value: Float) {
		self.progressSlider.value = value
		self.progressValue.text = "\(Int(round(value * 100)))%"
	}
}
