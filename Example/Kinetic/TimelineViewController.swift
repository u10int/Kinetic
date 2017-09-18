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
	var timelineProgressValue: UILabel!
	var timelineProgressSlider: UISlider!
	
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
		progressLabel.text = "Timeline"
		view.addSubview(progressLabel)
		
		timelineProgressValue = UILabel()
		timelineProgressValue.translatesAutoresizingMaskIntoConstraints = false
		timelineProgressValue.font = UIFont.boldSystemFont(ofSize: 16)
		timelineProgressValue.textColor = UIColor(white: 0.1, alpha: 1)
		timelineProgressValue.text = "0%"
		view.addSubview(timelineProgressValue)

		timelineProgressSlider = UISlider()
		timelineProgressSlider.translatesAutoresizingMaskIntoConstraints = false
		timelineProgressSlider.minimumValue = 0.0
		timelineProgressSlider.maximumValue = 1.0
		timelineProgressSlider.addTarget(self, action: #selector(TimelineViewController.timelineProgressChanged(_:)), for: .valueChanged)
		view.addSubview(timelineProgressSlider)
		
		// layout
		let views = ["timelineProgress": timelineProgressSlider, "progressLabel": progressLabel, "timelineProgressValue": timelineProgressValue] as [String : Any]
		let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[progressLabel(60)]-10-[timelineProgress]-10-[timelineProgressValue(50)]-20-|", options: .alignAllCenterY, metrics: nil, views: views)
		let verticalConstraint = NSLayoutConstraint(item: progressLabel, attribute: .bottom, relatedBy: .equal, toItem: progressSlider, attribute: .top, multiplier: 1, constant: -35)
		
		view.addConstraints(horizontalConstraints)
		view.addConstraint(verticalConstraint)
		
		// animation
		let move = Tween(target: square).to(Position(200, 200)).duration(1).ease(.cubicInOut)
		let resize = Tween(target: square).to(Size(150, 150)).duration(1).ease(.cubicInOut)
		let color = Tween(target: square).to(BackgroundColor(UIColor.blue)).duration(0.75)
		
		let timeline = Timeline()
		timeline.add(move, position: 0.5)
		timeline.add(resize, position: 1)
		timeline.add(label: "colorChange", position: 1.3)
		timeline.add(color, relativeToLabel: "colorChange", offset: 0)
		
		timeline.repeatCount(4).yoyo()
		
		timeline.onStart { (animation) in
			print("timeline started")
		}.onComplete { (animation) in
			print("timeline done")
		}
		
		animation = timeline
	}
	
	override func play() {
		super.play()
		
		if let animation = animation {
			animation.onUpdate({ (animation) in
				let progress = Float(animation.progress)
				let totalProgress = Float(animation.totalProgress)
				self.updateProgress(progress)
				self.updateTimelineProgress(totalProgress)
			})
			animation.play()
		}
	}
	
	override func reset() {
		super.reset()
		
		animation?.stop()
		updateProgress(0)
	}
	
	func timelineProgressChanged(_ sender: UISlider) {
		timelineProgressValue.text = "\(Int(round(sender.value * 100)))%"
		
		if let timeline = animation as? Timeline {
			timeline.totalProgress = Double(sender.value)
		}
	}
	
	func updateTimelineProgress(_ value: Float) {		
		timelineProgressSlider.value = value
		timelineProgressValue.text = "\(Int(round(value * 100)))%"
	}
}
