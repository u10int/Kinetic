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
	
	fileprivate var originalSquareFrame = CGRect.zero
	fileprivate var originalSquare2Frame = CGRect.zero
	
	var tableView: UITableView!
	var rows = [UIViewController]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Kinetic"
		view.backgroundColor = UIColor.white
		
		tableView = UITableView()
		tableView.frame = view.bounds
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Row")
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
		rows.append(PreloaderViewController())
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
}

extension ViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Row", for: indexPath)
		let controller = rows[indexPath.row]
		
		cell.textLabel?.text = controller.title
		
		return cell
	}
}

extension ViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let controller = rows[indexPath.row]
		navigationController?.pushViewController(controller, animated: true)
	}
}

