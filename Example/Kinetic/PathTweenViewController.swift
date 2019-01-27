//
//  PathTweenViewController.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 7/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

enum PathType {
	case cubic
	case quadratic
}

class PathTweenViewController: ExampleViewController {
	var control: UISegmentedControl!
	var square: UIView!
	
	var start: UIView!
	var end: UIView!
	var controlPoint1: UIView!
	var controlPoint2: UIView!
	var pathLayer: CAShapeLayer!
	var startLineLayer: CAShapeLayer!
	var endLineLayer: CAShapeLayer!
	
	var pathType: PathType = .quadratic
	
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
		
		control = UISegmentedControl(items: ["Quadratic", "Cubic"])
		control.translatesAutoresizingMaskIntoConstraints = false
		control.selectedSegmentIndex = 0
		control.addTarget(self, action: #selector(PathTweenViewController.pathTypeChanged(control:)), for: .valueChanged)
		view.addSubview(control)
		
		square = UIView()
		square.frame = CGRect(x: 50, y: 100, width: 50, height: 50)
		square.backgroundColor = UIColor.red
		view.addSubview(square)
		
		start = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		start.backgroundColor = UIColor.green
		start.layer.cornerRadius = 10
		view.addSubview(start)
		
		end = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		end.backgroundColor = UIColor.green
		end.layer.cornerRadius = 10
		view.addSubview(end)
		
		controlPoint1 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		controlPoint1.backgroundColor = UIColor.blue
		controlPoint1.layer.cornerRadius = 10
		view.addSubview(controlPoint1)
		
		controlPoint2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		controlPoint2.backgroundColor = UIColor.blue
		controlPoint2.layer.cornerRadius = 10
		view.addSubview(controlPoint2)
		
		// layout
		NSLayoutConstraint.activate([
			control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			control.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			control.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
		])
		
		start.center = square.center
		end.center = CGPoint(x: start.center.x + 200, y: start.center.y + 300)
		controlPoint1.center = CGPoint(x: end.center.x + 30, y: 100)
		controlPoint2.center = CGPoint(x: 200, y: 200)
		
		pathLayer = shapeLayer(color: UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
		startLineLayer = shapeLayer(color: UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.2))
		endLineLayer = shapeLayer(color: UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.2))
		
		setPathType(type: .quadratic)
	}
	
	override func reset() {
		super.reset()
		square.center = start.center
	}
	
	func pathTypeChanged(control: UIControl) {
		if let control = control as? UISegmentedControl {
			let type: PathType = control.selectedSegmentIndex == 1 ? .cubic : .quadratic
			setPathType(type: type)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touchPoint = touches.first?.location(in: view) {
			[start, end, controlPoint1, controlPoint2].forEach { (target) in
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
		draggingView = nil
	}
	
	private func setPathType(type: PathType) {
		pathType = type
		
		if type == .quadratic {
			controlPoint2.isHidden = true
		} else {
			controlPoint2.isHidden = false
		}
		
		updatePaths()
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
		let cp1 = controlPoint1.center
		let cp2 = controlPoint2.center
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: p1)
		
		if pathType == .quadratic {
			bezierPath.addQuadCurve(to: p2, controlPoint: cp1)
		} else {
			bezierPath.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
		}
		
		pathLayer.path = bezierPath.cgPath
		
		if pathType == .quadratic {
			update(line: startLineLayer, from: p1, to: cp1)
			update(line: endLineLayer, from: p2, to: cp1)
		} else {
			update(line: startLineLayer, from: p1, to: cp1)
			update(line: endLineLayer, from: p2, to: cp2)
		}
		
		square.center = p1
	}
	
	private func setTween() {
		var path: InterpolatablePath
		
		if pathType == .cubic {
			path = CubicBezier(start: start.center, cp1: controlPoint1.center, end: end.center, cp2: controlPoint2.center)
		} else {
			path = QuadBezier(start: start.center, cp1: controlPoint1.center, end: end.center)
		}
		
		let tween = Kinetic.animate(square).along(path).duration(1).ease(Quartic.easeInOut)
		animation = tween
	}
}
