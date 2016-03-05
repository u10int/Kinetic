//
//  PreloaderViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 2/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

/**
 * Preloader Animation similar to http://greensock.com/circular-preloader
 */
class PreloaderViewController: ExampleViewController {
	var dots = [CAShapeLayer]()
	var preloaderView: UIView!
	
	private var dotCount: Int = 10
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Preloader"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		let container = UIView()
		container.frame = CGRect(x: 100, y: 100, width: 90, height: 90)
		view.addSubview(container)
		preloaderView = container
		
		let timeline = Timeline()
		
		for idx in 0..<dotCount {
			var rotation = CGFloat(360 / dotCount) * CGFloat(idx)
			let dot = createDot(rotation)
			container.layer.addSublayer(dot)
			
			// need to use negative angles when rotation > 180 so that adding 360 deg during the animation only rotates once
			if rotation > 180 {
				rotation = -(180 + (180 - rotation))
			}
			
			let offsetX = (container.bounds.width - dot.bounds.width) / 2
			Kinetic.set(dot, options: [ .Rotate(deg2rad(rotation)), .Translate(-offsetX, 0) ])
			
			if idx < dotCount {
//				timeline.add(Kinetic.from(dot, duration: 0.5, options: [ .Alpha(0), .Scale(0.01) ]).ease(Easing.outQuart), position: Float(idx) * 0.1)
				timeline.add(Kinetic.to(dot, duration: 2, options: [ .Rotate(deg2rad(rotation - 360)) ]).ease(Easing.inOutQuart), position: Float(idx) * 0.15)
			}
		}
		
		timeline.forever().repeatDelay(5)
		
		animation = timeline
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		preloaderView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2 - 50)
	}
	
	override func reset() {
		super.reset()
		
		for (idx, dot) in dots.enumerate() {
			let rotation = CGFloat(360 / dotCount) * CGFloat(idx)
			let offsetX = (preloaderView.bounds.width - dot.bounds.width) / 2
			dot.transform = CATransform3DIdentity
			Kinetic.set(dot, options: [ .Rotate(deg2rad(rotation)), .Translate(-offsetX, 0) ])
		}
	}
	
	// MARK: Private Methods
	
	private func deg2rad(degrees: CGFloat) -> CGFloat {
		return CGFloat(M_PI) * (degrees) / 180.0
	}
	
	private func createDot(rotation: CGFloat) -> CAShapeLayer {
		let dot = CAShapeLayer()
		dot.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
		dot.position = CGPoint(x: preloaderView.bounds.width / 2, y: preloaderView.bounds.height / 2)
		dot.path = UIBezierPath(ovalInRect: dot.bounds).CGPath
		dot.fillColor = UIColor.redColor().CGColor
		dot.strokeColor = UIColor.blackColor().CGColor
		dots.append(dot)
		
		return dot
	}
}
