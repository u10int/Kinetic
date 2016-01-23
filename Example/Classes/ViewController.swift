//
//  ViewController.swift
//  Tween
//
//  Created by Nicholas Shipes on 10/22/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit

class TestObject: NSObject {
	var value: CGFloat = 0
}

class ViewController: UIViewController {
	var square: UIView!
	var square2: UIView!
	var label: UILabel!
	
	private var originalSquareFrame = CGRectZero
	private var originalSquare2Frame = CGRectZero
	
	var tableView: UITableView!
	var rows = [UIViewController]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Motion"
		view.backgroundColor = UIColor.whiteColor()
		
		tableView = UITableView()
		tableView.frame = view.bounds
		tableView.dataSource = self
		tableView.delegate = self
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Row")
		view.addSubview(tableView)
		
		rows.append(BasicTweenViewController())
		rows.append(GroupTweenViewController())
		rows.append(SequenceViewController())
		rows.append(TransformViewController())
		rows.append(AdditiveViewController())
		
//		square = UIView()
//		square.frame = CGRectMake(50, 50, 50, 50)
//		square.backgroundColor = UIColor.redColor()
//		view.addSubview(square)
//		
//		square2 = UIView()
//		square2.frame = CGRectMake(200, 200, 50, 50)
//		square2.backgroundColor = UIColor.blueColor()
//		view.addSubview(square2)
//		
//		var testTransform = CATransform3DIdentity
//		testTransform = CATransform3DTranslate(testTransform, 0, 50, 0)
//		testTransform = CATransform3DRotate(testTransform, CGFloat(M_PI_4), 0, 0, 1)
//		let testSquare = UIView()
//		testSquare.frame = square2.frame
//		testSquare.backgroundColor = UIColor.greenColor()
//		testSquare.layer.anchorPoint = CGPointMake(0.5, 0.5)
//		testSquare.layer.transform = testTransform
//		view.addSubview(testSquare)
//		
//		label = UILabel()
//		label.frame = CGRectMake(20, 30, 200, 20)
//		label.font = UIFont.systemFontOfSize(14)
//		label.textColor = UIColor.blackColor()
//		view.addSubview(label)
//		
//		let tapRecognizer = UITapGestureRecognizer(target: self, action: "animateTimeline:")
//		view.addGestureRecognizer(tapRecognizer)
//		
//		originalSquareFrame = square.frame
//		originalSquare2Frame = square2.frame
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func animate(gestureRecognizer: UITapGestureRecognizer) {
		let duration: CFTimeInterval = 1
		let delay: CFTimeInterval = 0
		reset()
		
		let move = Motion.to(square, duration: duration, options: [.Shift(100, 100), .Width(200)])
		move.ease(Easing.inOutQuart).delay(delay).play()
//		move.spring(tension: 70, friction: 10).play()
//
		var timer: CFTimeInterval = 0
		var startTimer: CFTimeInterval = 0
		let resize = Motion.to(square, duration: duration, options: [.Scale(0.5), .Rotate(CGFloat(M_PI_4))])
		resize.ease(Easing.inOutQuart).delay(delay + duration).onStart { () -> Void in
			print("started")
			startTimer = CACurrentMediaTime()
			timer = CACurrentMediaTime()
		}.onUpdate({ () -> Void in
			timer = CACurrentMediaTime()
		}).onComplete { () -> Void in
			print("completed: diff=\(timer - startTimer)")
		}.yoyo().repeatCount(4).play()
		print("TWEEN: start=\(resize.startTime), end=\(resize.endTime), total=\(resize.totalDuration)")
		
		
		
		let testObject = TestObject()
		testObject.value = 50
		label.text = "\(round(testObject.value))"
		
		let increment = Motion.to(testObject, duration: duration, options: [.KeyPath("value", 100)])
		increment.ease(Easing.outQuart).onUpdate { () -> Void in
			self.label.text = "\(round(testObject.value))"
		}.onComplete({ () -> Void in
			self.label.text = "\(round(testObject.value))"
		}).play()
		
//		let move = Motion.itemsTo([square, square2], duration: duration, options: [.Shift(100, 100)])
//		move.ease(Easing.inOutQuart).delay(delay).stagger(0.1).play()
	}
	
	func animateTimeline(gestureRecognizer: UITapGestureRecognizer) {
		let duration: CFTimeInterval = 1
		let delay: CFTimeInterval = 0
		reset()
		
		let move = Motion.to(square, duration: duration, options: [.Shift(100, 100), .Width(200), .Alpha(0.3)])
		move.ease(Easing.inOutQuart).delay(delay).onStart({ () -> Void in
			print("move started")
		}).onUpdate({ () -> Void in
//			print("move time: \(move.totalTime)")
		}).onComplete { () -> Void in
			print("move done")
		}
		
		let move2 = Motion.to(square2, duration: duration, options: [.Shift(-100, 0)])
		move2.ease(Easing.inOutQuart).delay(delay).onStart({ () -> Void in
			print("move2 started")
		}).onComplete { () -> Void in
			print("move2 done")
		}
		
		let timeline = Timeline()
		timeline.add(move, position: 1)
		timeline.add(move2, position: 1.5)
		timeline.addLabel("testPosition", position: 1.5)
		
		var timer: CFTimeInterval = 0
		var started: CFTimeInterval = 0
		timeline.onStart { () -> Void in
			print("timeline started")
			started = CACurrentMediaTime()
			timer = CACurrentMediaTime()
		}.onComplete { () -> Void in
			timer = CACurrentMediaTime()
			print("timeline done, diff=\(timer - started)")
		}
		timeline.repeatCount(2).yoyo()
		
//		timeline.seekToLabel("testPosition", pause: false)
		timeline.play()
		
		print("timeline.endTime: \(timeline.endTime), totalDuration: \(timeline.totalDuration)")
	}
	
	func reset() {
		square.alpha = 1
		square.layer.transform = CATransform3DIdentity
		square.frame = originalSquareFrame
		
		square2.alpha = 1
		square2.layer.transform = CATransform3DIdentity
		square2.frame = originalSquare2Frame
		
		Motion.killAll()
	}
}

extension ViewController: UITableViewDataSource {
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Row", forIndexPath: indexPath)
		let controller = rows[indexPath.row]
		
		cell.textLabel?.text = controller.title
		
		return cell
	}
}

extension ViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let controller = rows[indexPath.row]
		navigationController?.pushViewController(controller, animated: true)
	}
}

