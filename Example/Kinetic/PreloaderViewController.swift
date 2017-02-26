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
	var colors: [UIColor]!
	
	fileprivate var dotCount: Int = 10
	fileprivate var colorIndex = 0
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Preloader"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		colors = [UIColor(red:0.533, green:0.807, blue:0.004, alpha:1), UIColor.orange, UIColor.blue, UIColor.red]
		
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
			Kinetic.set(dot, props: .rotate(deg2rad(rotation)), .translate(-offsetX, 0))
			
			if idx < dotCount {
//				timeline.add(Kinetic.from(dot, duration: 0.5, options: [ .Alpha(0), .Scale(0.01) ]).ease(Easing.outQuart), position: Float(idx) * 0.1)
				
				let t = Tween(target: dot).to(.rotate(deg2rad(rotation - 360))).duration(2).ease(Easing.inOutQuart)
				timeline.add(t, position: Float(idx) * 0.15)
				timeline.addCallback(Float(idx) * 0.15 + 1.5, block: { [unowned self] in
					Kinetic.animate(dot).to(.fillColor(self.colors[self.colorIndex])).duration(0.5).play()
				})
			}
		}
		
		timeline.forever().repeatDelay(5)
		timeline.onRepeat { [unowned self] (timeline) in
			self.colorIndex += 1
			if self.colorIndex >= self.colors.count {
				self.colorIndex = 0
			}
		}
		
		colorIndex = 1
		animation = timeline
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		preloaderView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2 - 50)
	}
	
	override func reset() {
		super.reset()
		
		for (idx, dot) in dots.enumerated() {
			let rotation = CGFloat(360 / dotCount) * CGFloat(idx)
			let offsetX = (preloaderView.bounds.width - dot.bounds.width) / 2
			dot.transform = CATransform3DIdentity
			Kinetic.set(dot, props: .rotate(deg2rad(rotation)), .translate(-offsetX, 0))
		}
	}
	
	// MARK: Private Methods
	
	fileprivate func deg2rad(_ degrees: CGFloat) -> CGFloat {
		return CGFloat(M_PI) * (degrees) / 180.0
	}
	
	fileprivate func createDot(_ rotation: CGFloat) -> CAShapeLayer {
		let dot = CAShapeLayer()
		dot.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
		dot.position = CGPoint(x: preloaderView.bounds.width / 2, y: preloaderView.bounds.height / 2)
		dot.path = UIBezierPath(ovalIn: dot.bounds).cgPath
		dot.fillColor = UIColor(red:0.533, green:0.807, blue:0.004, alpha:1).cgColor
		dots.append(dot)
		
		return dot
	}
}
