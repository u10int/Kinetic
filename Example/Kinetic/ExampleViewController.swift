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
	
	var animation: Animation?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		edgesForExtendedLayout = UIRectEdge.None
		navigationController?.navigationBar.translucent = false
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		playButton = UIButton(type: .RoundedRect)
		playButton.translatesAutoresizingMaskIntoConstraints = false
		playButton.setTitle("Play", forState: .Normal)
		playButton.addTarget(self, action: #selector(ExampleViewController.play), forControlEvents: .TouchUpInside)
		view.addSubview(playButton)
		
		stopButton = UIButton(type: .RoundedRect)
		stopButton.translatesAutoresizingMaskIntoConstraints = false
		stopButton.setTitle("Stop", forState: .Normal)
		stopButton.addTarget(self, action: #selector(ExampleViewController.stop), forControlEvents: .TouchUpInside)
		view.addSubview(stopButton)
		
		pauseButton = UIButton(type: .RoundedRect)
		pauseButton.translatesAutoresizingMaskIntoConstraints = false
		pauseButton.setTitle("Pause", forState: .Normal)
		pauseButton.addTarget(self, action: #selector(ExampleViewController.pause), forControlEvents: .TouchUpInside)
		view.addSubview(pauseButton)
		
		resumeButton = UIButton(type: .RoundedRect)
		resumeButton.translatesAutoresizingMaskIntoConstraints = false
		resumeButton.setTitle("Resume", forState: .Normal)
		resumeButton.addTarget(self, action: #selector(ExampleViewController.resume), forControlEvents: .TouchUpInside)
		view.addSubview(resumeButton)
		
		resetButton = UIButton(type: .RoundedRect)
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setTitle("Reset", forState: .Normal)
		resetButton.addTarget(self, action: #selector(ExampleViewController.reset), forControlEvents: .TouchUpInside)
		view.addSubview(resetButton)
		
		// layout
		let views = ["play": playButton, "stop": stopButton, "pause": pauseButton, "resume": resumeButton, "reset": resetButton]
		let buttonHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[play(==60)]-[stop(==play)]-[pause(==play)]-[resume(==play)]-[reset(==play)]", options: .AlignAllBottom, metrics: nil, views: views)
		let buttonVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[play]-20-|", options: [], metrics: nil, views: views)
		view.addConstraints(buttonHorizontal)
		view.addConstraints(buttonVertical)
    }
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		reset()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func play() {
		if let animation = animation {
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
	}
	
	func hideButtons() {
		playButton.hidden = true
		stopButton.hidden = true
		pauseButton.hidden = true
		resumeButton.hidden = true
		resetButton.hidden = true
	}
	
}
