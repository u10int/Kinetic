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
		let views = ["play": playButton, "stop": stopButton, "pause": pauseButton, "resume": resumeButton, "reset": resetButton]
		let buttonHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[play(==60)]-[stop(==play)]-[pause(==play)]-[resume(==play)]-[reset(==play)]", options: .alignAllBottom, metrics: nil, views: views)
		let buttonVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[play]-20-|", options: [], metrics: nil, views: views)
		view.addConstraints(buttonHorizontal)
		view.addConstraints(buttonVertical)
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
		playButton.isHidden = true
		stopButton.isHidden = true
		pauseButton.isHidden = true
		resumeButton.isHidden = true
		resetButton.isHidden = true
	}
	
}
