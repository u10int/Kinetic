//
//  ViewController.swift
//  Tween
//
//  Created by Nicholas Shipes on 10/22/15.
//  Copyright © 2015 Urban10 Interactive, LLC. All rights reserved.
//

import UIKit
import Kinetic

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
		
		title = "Kinetic Examples"
		view.backgroundColor = UIColor.whiteColor()
		
		tableView = UITableView()
		tableView.frame = view.bounds
		tableView.dataSource = self
		tableView.delegate = self
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Row")
		view.addSubview(tableView)
		
		rows.append(BasicTweenViewController())
		rows.append(BasicFromTweenViewController())
		rows.append(BasicFromToTweenViewController())
		rows.append(GroupTweenViewController())
		rows.append(SequenceViewController())
		rows.append(TransformViewController())
		rows.append(AdditiveViewController())
		rows.append(PhysicsViewController())
		rows.append(StaggerViewController())
		rows.append(TimelineViewController())
		rows.append(CountingLabelViewController())
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
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

