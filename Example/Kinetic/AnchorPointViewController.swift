//
//  AnchorPointViewController.swift
//  Kinetic_Example
//
//  Created by Nicholas Shipes on 2/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Kinetic

class AnchorPointViewController: ExampleViewController {
	var square: UIView!
	var squareContainer: UIView!
	
	fileprivate let pickerView = UIPickerView()
	fileprivate var pickerData: [String] = []
	fileprivate var tween: Tween?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = "Anchor Point"
		pickerData = [
			"Top-Left",
			"Top",
			"Top-Right",
			"Left",
			"Center",
			"Right",
			"Bottom-Left",
			"Bottom",
			"Bottom-Right"
		]
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		pickerView.translatesAutoresizingMaskIntoConstraints = false
		pickerView.dataSource = self
		pickerView.delegate = self
		view.addSubview(pickerView)
		
		square = UIView()
		square.translatesAutoresizingMaskIntoConstraints = false
		square.backgroundColor = .red
		
		/**
		 * `TransformContainerView` is a UIView subclass in Kinetic to be used when adjusting a view's anchorPoint.
		 *
		 * Need to place our animated view within a transparent container view since we will be adjusting the view's anchorPoint
		 * and applying a transform, which will prevent it from shifting the view's actual position within the view and allows
		 * us to still use AutoLayout for positioning the view
		 * re: https://stackoverflow.com/a/14105757
		 */
		squareContainer = TransformContainerView(view: square)
		view.addSubview(squareContainer)
		
		/*
		 * Since we're placing the animated square within a container view, we set position constraints on the container view
		 * and then width and height constraints on the actual square view, which will also size the container automatically
		 */
		NSLayoutConstraint.activate([squareContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
									 squareContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
									 square.widthAnchor.constraint(equalToConstant: 100),
									 square.heightAnchor.constraint(equalToConstant: 100),
									 pickerView.topAnchor.constraint(equalTo: squareContainer.bottomAnchor, constant: 100),
									 pickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
									 pickerView.rightAnchor.constraint(equalTo: view.rightAnchor),
									 pickerView.heightAnchor.constraint(equalToConstant: 250)])
		
		let tween = square.tween().to(Rotation(Float.pi * 2)).duration(1.0).ease(Cubic.easeInOut)
		animation = tween
		self.tween = tween
		
		pickerView.selectRow(4, inComponent: 0, animated: false)
	}
}

extension AnchorPointViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		var anchor = AnchorPoint.center
		
		switch row {
		case 0: anchor = .topLeft
		case 1: anchor = .top
		case 2: anchor = .topRight
		case 3: anchor = .left
		case 4: anchor = .center
		case 5: anchor = .right
		case 6: anchor = .bottomLeft
		case 7: anchor = .bottom
		case 8: anchor = .bottomRight
		default: anchor = .center
		}
		
		tween?.anchor(anchor)
	}
}
