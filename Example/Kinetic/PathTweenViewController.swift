//
//  PathTweenViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

class PathTweenViewController: ExampleViewController {
	var square: UIView!
	
	var start: UIView!
	var end: UIView!
	var control: UIView!
	var pathLayer: CAShapeLayer!
	var startLineLayer: CAShapeLayer!
	var endLineLayer: CAShapeLayer!
	
	fileprivate var draggingView: UIView?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Path Tween"
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
		
		start = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		start.backgroundColor = UIColor.green
		view.addSubview(start)
		
		end = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		end.backgroundColor = UIColor.green
		view.addSubview(end)
		
		control = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		control.backgroundColor = UIColor.blue
		view.addSubview(control)
		
		let p1 = square.center
		let p2 = CGPoint(x: p1.x + 200, y: p1.y + 300)
		let cp1 = CGPoint(x: p2.x + 100, y: 100)
		let path = QuadBezier(start: p1, cp1: cp1, end: p2)
		
		let tween = Kinetic.animate(square).along(path).duration(1).ease(.quartInOut)
		animation = tween
		
		// add UIBezierPath for debugging animated path
		let bezierPath = UIBezierPath()
		bezierPath.move(to: p1)
		bezierPath.addQuadCurve(to: p2, controlPoint: cp1)
		
		pathLayer = shapeLayer(color: UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
		pathLayer.path = bezierPath.cgPath
		
		start.center = p1
		end.center = p2
		control.center = cp1
		
		startLineLayer = shapeLayer(color: UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.2))
		endLineLayer = shapeLayer(color: UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.2))
		
		update(line: startLineLayer, from: p1, to: cp1)
		update(line: endLineLayer, from: p2, to: cp1)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		start.center = square.center
	}
	
	override func reset() {
		super.reset()
		square.center = start.center
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touchPoint = touches.first?.location(in: view) {
			[start, end, control].forEach { (target) in
				if let target = target, target.frame.contains(touchPoint) {
					draggingView = target
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touchPoint = touches.first?.location(in: view), let target = draggingView {
			target.center = CGPoint(x: touchPoint.x, y: touchPoint.y)
			updatePaths()
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		setTween()
	}
	
	private func shapeLayer(color: UIColor) -> CAShapeLayer {
		let pathLayer = CAShapeLayer()
		pathLayer.frame = view.bounds
		pathLayer.fillColor = UIColor.clear.cgColor
		pathLayer.lineWidth = 2.0
		pathLayer.strokeColor = color.cgColor
		view.layer.addSublayer(pathLayer)
		
		return pathLayer
	}
	
	private func update(line: CAShapeLayer, from: CGPoint, to: CGPoint) {
		let bezierPath = UIBezierPath()
		bezierPath.move(to: from)
		bezierPath.addLine(to: to)
		
		line.path = bezierPath.cgPath
	}
	
	private func updatePaths() {
		let p1 = start.center
		let p2 = end.center
		let cp1 = control.center
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: p1)
		bezierPath.addQuadCurve(to: p2, controlPoint: cp1)
		pathLayer.path = bezierPath.cgPath
		
		update(line: startLineLayer, from: p1, to: cp1)
		update(line: endLineLayer, from: p2, to: cp1)
		
		square.center = p1
	}
	
	private func setTween() {
		let path = QuadBezier(start: start.center, cp1: control.center, end: end.center)
		let tween = Kinetic.animate(square).along(path).duration(1).ease(.quartInOut)
		animation = tween
	}
}
