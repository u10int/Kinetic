//
//  ExampleViewController.swift
//  Motion
//
//  Created by Nicholas Shipes on 12/31/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
	var playButton: UIButton!
	var stopButton: UIButton!
	var pauseButton: UIButton!
	var resumeButton: UIButton!
	
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
		playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
		view.addSubview(playButton)
		
		stopButton = UIButton(type: .RoundedRect)
		stopButton.translatesAutoresizingMaskIntoConstraints = false
		stopButton.setTitle("Stop", forState: .Normal)
		stopButton.addTarget(self, action: "stop", forControlEvents: .TouchUpInside)
		view.addSubview(stopButton)
		
		pauseButton = UIButton(type: .RoundedRect)
		pauseButton.translatesAutoresizingMaskIntoConstraints = false
		pauseButton.setTitle("Pause", forState: .Normal)
		pauseButton.addTarget(self, action: "pause", forControlEvents: .TouchUpInside)
		view.addSubview(pauseButton)
		
		resumeButton = UIButton(type: .RoundedRect)
		resumeButton.translatesAutoresizingMaskIntoConstraints = false
		resumeButton.setTitle("Resume", forState: .Normal)
		resumeButton.addTarget(self, action: "resume", forControlEvents: .TouchUpInside)
		view.addSubview(resumeButton)
		
		// layout
		let views = ["play": playButton, "stop": stopButton, "pause": pauseButton, "resume": resumeButton]
		let buttonHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("|-10-[play(==70)]-[stop(==play)]-[pause(==play)]-[resume(==play)]", options: .AlignAllBottom, metrics: nil, views: views)
		let buttonVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[play]-20-|", options: [], metrics: nil, views: views)
		view.addConstraints(buttonHorizontal)
		view.addConstraints(buttonVertical)
    }
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		
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
	
}
