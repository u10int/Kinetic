//
//  Event.swift
//  Kinetic
//
//  Created by Nicholas Shipes on 11/19/17.
//

import Foundation

public enum EventState<T> {
	case active
	case closed(T)
}

public final class Event<T> {
	public typealias Observer = (T) -> Void
	
	private(set) internal var state = EventState<T>.active
	
	internal var closed: Bool {
		if case .active = state {
			return false
		} else {
			return true
		}
	}
	
	private var observers = [Observer]()
	private var keyedObservers = [String: Observer]()
	
	internal func trigger(_ payload: T) {
		guard closed == false else { return }
		deliver(payload)
	}
	
	internal func observe(_ observer: @escaping Observer) {
		guard closed == false else {
//			observer(T)
			return
		}
		observers.append(observer)
	}
	
	internal func observe(_ observer: @escaping Observer, key: String) {
		guard closed == false else {
//			observer(T)
			return
		}
		keyedObservers[key] = observer
	}
	
	internal func unobserve(key: String) {
		keyedObservers.removeValue(forKey: key)
	}
	
	internal func close(_ payload: T) {
		guard closed == false else { return }
		state = .closed(payload)
		deliver(payload)
	}
	
	private func deliver(_ payload: T) {
		observers.forEach { (observer) in
			observer(payload)
		}
		keyedObservers.forEach { (key, observer) in
			observer(payload)
		}
	}
}
