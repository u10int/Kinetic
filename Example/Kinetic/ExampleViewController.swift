//
//  ExampleViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

class ExampleViewController: UIViewController {
	var playButton: UIButton!
	var stopButton: UIButton!
	var pauseButton: UIButton!
	var resumeButton: UIButton!
	var resetButton: UIButton!
	var progressValue: UILabel?
	var progressSlider: UISlider?
	
	var animation: Animation?
	var showsControls = true
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		edgesForExtendedLayout = UIRectEdge()
		navigationController?.navigationBar.isTranslucent = false
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .white

		playButton = UIButton(type: .roundedRect)
		playButton.translatesAutoresizingMaskIntoConstraints = false
		playButton.setTitle("Play", for: UIControlState())
		playButton.addTarget(self, action: #selector(ExampleViewController.play), for: .touchUpInside)
		view.addSubview(playButton)
		
		stopButton = UIButton(type: .roundedRect)
		stopButton.translatesAutoresizingMaskIntoConstraints = false
		stopButton.setTitle("Stop", for: UIControlState())
		stopButton.addTarget(self, action: #selector(ExampleViewController.stop), for: .touchUpInside)
		view.addSubview(stopButton)
		
		pauseButton = UIButton(type: .roundedRect)
		pauseButton.translatesAutoresizingMaskIntoConstraints = false
		pauseButton.setTitle("Pause", for: UIControlState())
		pauseButton.addTarget(self, action: #selector(ExampleViewController.pause), for: .touchUpInside)
		view.addSubview(pauseButton)
		
		resumeButton = UIButton(type: .roundedRect)
		resumeButton.translatesAutoresizingMaskIntoConstraints = false
		resumeButton.setTitle("Resume", for: UIControlState())
		resumeButton.addTarget(self, action: #selector(ExampleViewController.resume), for: .touchUpInside)
		view.addSubview(resumeButton)
		
		resetButton = UIButton(type: .roundedRect)
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setTitle("Reset", for: UIControlState())
		resetButton.addTarget(self, action: #selector(ExampleViewController.reset), for: .touchUpInside)
		view.addSubview(resetButton)
		
		// layout
		let views: [String: UIView] = ["play": playButton, "stop": stopButton, "pause": pauseButton, "resume": resumeButton, "reset": resetButton]
		let buttonHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[play(==60)]-[stop(==play)]-[pause(==play)]-[resume(==play)]-[reset(==play)]", options: .alignAllBottom, metrics: nil, views: views)
		let buttonVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[play]-20-|", options: [], metrics: nil, views: views)
		view.addConstraints(buttonHorizontal)
		view.addConstraints(buttonVertical)
		
		if showsControls {
			let progressLabel = UILabel()
			progressLabel.translatesAutoresizingMaskIntoConstraints = false
			progressLabel.font = UIFont.systemFont(ofSize: 16)
			progressLabel.textColor = UIColor(white: 0.1, alpha: 1)
			progressLabel.text = "Position"
			view.addSubview(progressLabel)
			
			let valueLabel = UILabel()
			valueLabel.translatesAutoresizingMaskIntoConstraints = false
			valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
			valueLabel.textColor = UIColor(white: 0.1, alpha: 1)
			valueLabel.text = "0%"
			view.addSubview(valueLabel)
			progressValue = valueLabel
			
			let slider = UISlider()
			slider.translatesAutoresizingMaskIntoConstraints = false
			slider.minimumValue = 0.0
			slider.maximumValue = 1.0
			slider.addTarget(self, action: #selector(TimelineViewController.progressChanged(_:)), for: .valueChanged)
			view.addSubview(slider)
			progressSlider = slider
			
			// layout
			let sliderViews: [String: UIView] = ["progress": slider, "progressLabel": progressLabel, "progressValue": valueLabel]
			let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[progressLabel(60)]-10-[progress]-10-[progressValue(50)]-20-|", options: .alignAllCenterY, metrics: nil, views: sliderViews)
			let verticalConstraint = NSLayoutConstraint(item: progressLabel, attribute: .bottom, relatedBy: .equal, toItem: playButton, attribute: .top, multiplier: 1, constant: -50)
			
			view.addConstraints(horizontalConstraints)
			view.addConstraint(verticalConstraint)
		}
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		reset()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func play() {
		if let animation = animation {
			animation.on(.updated) { [weak self] (animation) in
				var progress: Float = 0
				if animation.repeatForever {
					progress = Float(animation.progress)
				} else {
					progress = Float(animation.totalProgress)
				}
				self?.updateProgress(progress)
			}
			animation.play()
		}
	}
	
	func stop() {
		if let animation = animation {
			animation.stop()
		}
	}
	
	func pause() {
		if let animation = animation {
			animation.pause()
		}
	}
	
	func resume() {
		if let animation = animation {
			animation.resume()
		}
	}
	
	func reset() {
		animation?.stop()
		updateProgress(0)
	}
	
	func progressChanged(_ sender: UISlider) {
		progressValue?.text = "\(Int(round(sender.value * 100)))%"
		animation?.totalProgress = Double(sender.value)
	}
	
	func updateProgress(_ value: Float) {
		progressSlider?.value = value
		progressValue?.text = "\(Int(round(value * 100)))%"
	}
	
	func hideControls() {
		playButton.isHidden = true
		stopButton.isHidden = true
		pauseButton.isHidden = true
		resumeButton.isHidden = true
		resetButton.isHidden = true
		
		hideSliderControls()
	}
	
	func hideSliderControls() {
		progressValue?.isHidden = true
		progressSlider?.isHidden = true
	}
	
}
