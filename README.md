[![Version](https://img.shields.io/cocoapods/v/Kinetic.svg?style=flat)](http://cocoapods.org/pods/Kinetic)
[![License](https://img.shields.io/cocoapods/l/Kinetic.svg?style=flat)](http://cocoapods.org/pods/Kinetic)
[![Platform](https://img.shields.io/cocoapods/p/Kinetic.svg?style=flat)](http://cocoapods.org/pods/Kinetic)
[![Total Downloads](https://img.shields.io/cocoapods/dt/Kinetic.svg)](http://cocoapods.org/pods/Kinetic)
![CI Status](https://img.shields.io/travis/u10int/Kinetic/master.svg?style=flat)

Kinetic
======
A super-flexible tweening library for iOS in Swift inspired by [GSAP](http://greensock.com/gsap).

Requirements
----
- iOS 9.0+
- Swift 3.0+
- Xcode 8+

## Usage
The following docs are meant to give a general overview of interacting with the library and the various functionality currently supported. For a better, more in-depth demonstration on working with this library, make sure to review the code provided in the example project. To run the example project, clone the repo, open the `Kinetic.xcworkspace` and run the **Kinetic-Example** project.

## Installation
- **CocoaPods**: add `pod "Kinetic"` to your `Podfile`
- **Carthage**: add `github "u10int/Kinetic" "master"` to your `Cartfile`

### Features
- Quickly setup animations in a syntax inspired by TweenMax, TimelineMax and the awesome [GSAP](http://greensock.com/gsap)
- Start, stop, pause and resume any animation during runtime
- Easings and springs for more realistic and interesting animations
- Chaining methods for concise code
- Support for animating from, animating to, or animating from and to specific values (`to:`, `from:`)
- Animate multiple objects sequentially, in parallel or staggered in a single animation group
- Advanced animations using timelines to insert gaps, callbacks and more during an animation
- Support for animating any NSObject property on your custom objects or any tweenable value

### Roadmap
- <del>Improve and cleanup API</del>
- <del>Support for animating elements along a UIBezierPath</del>
- Support for animating SVG drawings
- Support for animating text and characters

### Author
* [Nicholas Shipes](https://github.com/u10int) ([@u10int](https://twitter.com/u10int))

### License
Kinetic is available under the MIT license. See the LICENSE file for more info.


## Basic Examples
Animating multiple properties of an UIView or CALayer can be done in a single line of code:

```swift
let square = UIView()
square.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
square.backgroundColor = UIColor.redColor()
view.addSubview(square)

// move 250pt to the right and set the height to 100pt for 0.5 seconds
Kinetic.animate(square).to(X(250), Size(height: 100)).duration(0.5).ease(.inOutQuart).play()
```

Alternatively, you can setup a tween on a UIView or CALayer instance by using the `tween()` properly, which is an extension provided by Kinetic:

```swift
square.tween().to(X(250), Size(height: 100)).duration(0.5).ease(.inOutQuart).play()
```

![Basic Tween](Example/screenshots/kinetic-tween-basic.gif)

Animating the same properties on multiple objects is just as quick and easy:

```swift
let greenSquare = UIView()
greenSquare.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
greenSquare.backgroundColor = UIColor (red: 0.0557, green: 0.7144, blue: 0.0677, alpha: 1.0)
view.addSubview(greenSquare)
	
let blueSquare = UIView()
blueSquare.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
blueSquare.backgroundColor = UIColor (red: 0.0, green: 0.6126, blue: 0.9743, alpha: 1.0)
view.addSubview(blueSquare)
	
let orangeSquare = UIView()
orangeSquare.frame = CGRect(x: 0, y: 160, width: 100, height: 100)
orangeSquare.backgroundColor = .orange
view.addSubview(orangeSquare)
	
let timeline = Kinetic.animateAll([greenSquare, blueSquare, orangeSquare]).to(Rotation(y: CGFloat(Double.pi / 2))).duration(1)
timeline.ease(.sineInOut).perspective(1 / -1000).yoyo().repeatCount(3)
timeline.anchor(.center)
timeline.play()
```

And similar to individual tween targets above, you can use the `tween()` method on an array of `Tweenable` objects which will setup a tween but instead return an instance of `Timeline`:

```swift
let timeline = [greenSquare, blueSquare, orangeSquare].to(Rotation(y: CGFloat(Double.pi / 2))).duration(1)
```

![Grouped Tween](Example/screenshots/kinetic-tween-basic-group.gif)

Review the example project for more in-depth and complex animation examples using Kinetic.

## Animatable Properties
Kinetic has support for animating most visible properties on UIView and CALayer already built-in, but you can also animating any custom key-value property on NSObject:

### Position
| Property | Description |
|---|---|
| `Position(_ position: CGPoint)` | Animates the target's origin/position using the specified `CGPoint` value |
| `Position(_ x: CGFloat, _ y: CGFloat)` | Animates the target's origin/position using the specified `x` and `y` values |
| `X(x: CGFloat)` | Animates the target's `origin.x` or `position.x` value |
| `Y(y: CGFloat)` | Animates the target's `origin.y` or `position.y` value |
| `Center(_ center: CGPoint)` | Animates the target's center position using the specified `CGPoint` value |
| `Center(_ x:CGFloat, _ y: CGFloat)` | Animates the target's center position using the specified `x` and `y` values |
| `Center(x: CGFloat)` | Animates the target's `center.x` value |
| `Center(y: CGFloat)` | Animates the target's `center.y` value |
| `Shift(_ offset: CGPoint)` | Shifts the frame's current origin by the specified point's x and y values as distances (similar to translate but changes the object's origin value instead of using `transform`). |
| `Shift(_ x: CGFloat, _ y: CGFloat)` | Shifts the frame's current origin by the specified x and y distances (similar to translate but changes the object's origin value instead of using `transform`). |
| `Shift(x: CGFloat)` | Shifts the target's `origin.x` position by the specified distance relative to its current position. Negative values will move the target to the left. |
| `Shift(y: CGFloat)` | Shifts the target's `origin.y` position by the specified distance relative to its current position. Negative values will move the target up. |

### Size
| Property | Description |
|---|---|
| `Size(_ size: CGSize)` | Animates the target's size using the specified `CGSize` value |
| `Size(_ width: CGFloat, _ height: CGFloat)` | Animates the target's size using the specified `width` and `height` values |
| `Size(width: CGFloat)` | Animates the target's `size.width` value |
| `Size(height: CGFloat)` | Animates the target's `size.height` value |

### Transforms
| Property | Description |
|---|---|
| `Translation(_ offset: CGPoint)` | Shifts the frame's position by the specified point's x and y values as distances using the layer's `transform` property |
| `Translation(_ x: CGFloat, _ y: CGFloat)` | Shifts the frame's position by the specified x and y distances using the layer's `transform` property |
| `Scale(_ value: CGFloat)` | Animates the target's scale by applying the specified scale value to all 3 axes |
| `Scale(x: CGFloat, y: CGFloat, z: CGFloat)` | Animates the target's scale using specific scale values for each axis |
| `Rotation(_ value: CGFloat)` | Animates the rotation of the object two-dimensionally in the z axes to the specified angle |
| `Rotation(x: CGFloat)` | Animates the rotation of the object in the x axes (for three-dimensional rotation) to the specified angle |
| `Rotation(y: CGFloat)` | Animates the rotation of the object in the y axes (for three-dimensional rotation) to the specified angle |

### Color
| Property | Description |
|---|---|
| `BackgroundColor(_ color: UIColor)` | Animates the background color of the view or layer to the specified color value
| `BorderColor(_ color: UIColor)` | Animates the border color of the view or layer to the specified color value |
| `FillColor(_ color: UIColor)` | Animates the fill color of the view or layer to the specified color value, typically used on `CAShapeLayer` instances |
| `StrokeColor(_ color: UIColor)` | Animates the stroke color of the view or layer to the specified color value, typically used on `CAShapeLayer` instances |

### Paths
| Property | Description |
|---|---|
| `Path(_ path: Path)` | Animates the target's progress along the specified path |
| `StrokeStart(_ value: CGFloat)` | Animates the path's start position |
| `StrokeEnd(_ value: CGFloat)` | Animates the path's end position |

### Other
| Property | Description |
|---|---|
| `Frame(_ value)` | |
| `Alpha(_ value: CGFloat)` | Animates the object's opacity to the specified value (from `0` to `1.0`) |
| `CornerRadius(_ value: CGFloat)` | Animates the corner radius of the view or layer to the specified value |
| `KeyPath(_ key: String, _ value: Interpolatable)` | Animates a custom property on an NSObject instance for the specified key path. The `value` must be a valid `Interpolatable` type. |

The animation properties you provide with your tweens use a very Swift-like syntax where you specify the starting or ending values as parameters to the property you wish to animate. For example, to animate a view's `origin.x` from its current position to `100.0` you would use `X(100)`. However, if you just wanted to shift the view from its current location 100pt to the right, you would use `Shift(x: 100)` instead, which specifies the distance to move the view in just the x axis.

## Classes
The following are the primary classes used within the library along with their role:

| Class | Description |                                                                                                                                       
|---|---|
| Kinetic | Central class providing convenience static methods for creating tweens, timelines and removing them from their targets. |
| Tween | Primary class used for performing animations on a single `Tweenable` target for one or more animatable properties. |
| Timeline | Used for combining multiple tweens into a single group with support for controlling a single tween's position relative to the overall animation's duration. |
| Animation | Base class for Tween and Timeline that provides core animation functionality. Is not tied to a specific or series of `Tweenable` targets like `Tween` and `Timeline` are and thus does not perform any value updates automatically during the animation's duration. |                                  
| Easing | Common easing properties for animations. |
| Spring | Basic spring for physics-based animations. |

### Interpolatable Values
Underlying each tween instance is a series of values conforming to the `Interpolatable` protocol, which most common value-types used throughout UIKit already adopt (e.g. `CGFloat`, `CGPoint`, `UIColor`, etc). If you just need to perform a basic value-based interpolation on a property value, you can use an instance of `Interpolator` instead of the full-featured `Tween` and/or `Timeline` classes. This if useful if you have a custom object that is not a subclass of `UIView` or `CALayer` and that cannot use the `KeyPath()` property since it isn't a subclass of `NSObject`. 

For instance, if you just want to interpolate a value of `100.0` to `500.0` with a specific timing function offered by Kinetic, just use the `interpolator(to:duration:function:apply:)` method on your starting value:                                  

```swift
(100.0.interpolator(to: 500.0, duration: 1.0, function: Easing.type(.quadInOut)) { (value) in
	print("\(value)")
}).run()
```       

When using an interpolator directly, you are responsible for updating the values on the respective instances. Also, this method does not support any of the features available with `Tween` or `Timeline`.                                             

## Controlling Tweens
Once you have an instance of a Tween using `Kinetic.animate:` or Timeline using `Kinetic.animateAll:`, controlling your animation during playback is extremely simple.

You can configure your tween before playback to define its delay, easing or spring, repeat count, or repeat forever:

```swift
// sets the initial state of the animation before playback, where `...` is a series of `Property` instances
tween.from(...)

// sets the final state of the animation when playback completes, where `...` is a series of `Property` instances
tween.to(...)

// total duration of the animation, in seconds, not including any delay value
tween.duration(0.5)

// wait 2 seconds before starting the animation
tween.delay(2)

// set the easing to use for the animation, which will be used for all properties in the tween
tween.ease(.inOutQuart)

// configure the tween to use a spring animation, which will be used instead of any easing previously set
tween.spring(tension: 100, friction: 12)

// tell the tween to repeat 4 additional times, meaning it will play a total of 5 times
tween.repeatCount(4)

// set a delay of 0.5 seconds between repeats
tween.repeatDelay(0.5)

// tell the tween to repeat forever until stopped using stop() or pause()
tween.forever()

// reverses the direction of playback each time the tween is repeated
// if the tween is configured to repeat 4 times, then the animation will play with the pattern: forward, reversed, forward, reversed, forward.
tween.yoyo()

// set the transform perspective for the tween's associated object
// this is only used for three-dimensional CALayer transformation
tween.perspective(1 / -1000)
```

Once you've configured your tween and started its playback using `play()`, you can stop, pause, resume, seek, reverse, or restart a tween at any time:

```swift
// plays the tween from the beginning
tween.play()

// stops the tween at the current position
tween.pause()

// resumes playback from the tween's current position
tween.resume()

// reverses playback direction toward the beginning
tween.reverse()

// returns playback direction to the normal direction
tween.forward()

// restarts the tween from the beginning
tween.restart()

// jump to 0.5 seconds into the tween
tween.seek(0.5)

// immediately stop and remove the tween from the object
tween.kill()

// get the current progress of the tween from 0 (start) to 1 (end); doesn't account for repeats (a single animation cycle)
tween.progress()

// move the animation's playhead progress from 0 (start) to 1 (end) excluding repeats and repeatDelays (a single animation cycle)
tween.setProgress(progress: Float)

// get the current progress of the tween from 0 (start) to 1 (end) including repeats and repeatDelays
tween.totalProgress()

// move the animation's playhead progress from 0 (start) to 1 (end) including repeats and repeatDelays
tween.setTotalProgress(progress: Float)

// get the total elapsed time of the tween including any repeats and delays
tween.time()
```

You can also remove multiple tweens of a single object by using the convenience methods provided by the central Kinetic module:

```swift
Kinetic.killTweensOf(square)
```

To remove all tweens currently running from all objects, simply call `killAll()`:

```swift
Kinetic.killAll(greenSquare)
```

Killing and removing a tween is similar to `pause()` and will stop the animation at its current position without returning the associated object back to its original starting position. The tween will also be disassociated from the object and removed from the tween cache.

### Callbacks
You can assign callback blocks for several events during a tween's playback, including when it starts, when it updates an object's properties, when it repeats and when it completes. The Tween instance that called the block will be provided as an argument to your block.

The following events are triggered by an `Animation` instance: 

```swift
// called when the tween starts animating
tween.on(.started) { (tween) -> Void in
	print("tween started")
}

// called when the tween's properties are updated during the animation
tween.on(.updated) { (tween) -> Void in
	print("tween updated: time=\(tween.elapsed)")
}

// called each time the tween repeats
// if the tween's playback is reversed, this will be called when the tween's position reaches the beginning
// of the tween, or 0, instead of the end
tween.on(.repeated) { (tween) -> Void in
	print("tween repeated")
}

// called when the animation is cancelled before it completes
tween.on(.cancelled) { (tween) -> Void in
	print("tween cancelled")
}

// called when all properties of the tween have finished animating to their final values
tween.on(.completed) { (tween) -> Void in
	print("tween completed")
}
```

## Custom Properties
Most of the time you'll be animating UIView and CALayer instances and their visual properties. However, you may also need to animate a different property not supported with Kinetic's standard property set or a property of a custom object in your project. You can accomplish this using the `KeyPath(_ key: String, _ value: Interpolatable)` property with a Tween and a custom NSObject subclass that conforms to the `KeyPathTweenable` protocol:

```swift
class CountingObject: NSObject, KeyPathTweenable {
	var value: Float = 0
}
```

A good use case for this is to setup a UILabel that animates a value change, such as from 50 to 250. With a Tween instance and the `KeyPath()` property, this is just as easy as any other animation:

```swift
let textLabel = UILabel()
textLabel.font = UIFont.systemFont(ofSize: 40)
textLabel.textColor = UIColor.black
textLabel.frame = CGRect(x: 50, y: 50, width: 200, height: 50)
view.addSubview(textLabel)
	
let testObject = CountingObject()
testObject.value = 50
textLabel.text = "\(testObject.value)"
		
let tween = testObject.tween()
    .to(KeyPath("value", 250.0))
    .duration(2)
    .ease(.expoOut)
	
tween.on(.updated) { (animation) in
	self.textLabel.text = "\(String(format:"%.1f", self.testObject.value))"
}.on(.completed) { (animation) in
	print("DONE")
}
```

![Counting Label](Example/screenshots/kinetic-timeline-countlabel.gif)

Any custom property can be used as long as it's a property of an NSObject subclass that conforms to `KeyPathTweenable` and the property has a numerical value. 

An alternative to using the `KeyPath()` property method for animating custom properties is using an interpolator directly as explained in the **Interpolatable Values** section above.

## Timelines
A Kinetic Timeline allows you to group multiple Tween instances into a single, easy to control sequence with precise timing management for more complex animations. Without using a Timeline instance, you would have to create multiple Tween instances and manually calculate their delay values to create the exact sequence you want.

### Serial Animations

In many cases, you'll want to perform a serial, or sequential, animation on a single or multiple objects where each tween is performed one after another. For instance, if you want to move a view to the right, then down, and then scale it up by 2 for a duration of 3 seconds, you could do so by creating three Tween instances and offset their delay values by 1 second:

```swift
square.tween()
    .to(X(110))
    .duration(1)
    .ease(.inOutCubic)
    .play()
	
square.tween()
    .to(Y(250))
    .duration(1)
    .ease(.inOutCubic)
    .delay(1)
    .play()
	
square.tween()
    .to(Scale(2))
    .duration(1)
    .ease(.inOutCubic)
    .delay(2)
    .play()
```

Note that if you change the duration of any of the individual tweens, you also have to be sure to adjust the delay values for the sequence. And trying to pause, restart or reverse the sequence is even more of a challenge. However, by using a Timeline instance you can perform all of these functions easily:

```swift
let timeline = Timeline()
timeline.add(square.tween().to(X(110)).duration(1).ease(.inOutCubic))
timeline.add(square.tween().to(Y(250)).duration(1).ease(.inOutCubic))
timeline.add(square.tween().to(Scale(2)).duration(1).ease(.inOutCubic))
timeline.play()
```

![Timeline Sequence](Example/screenshots/kinetic-timeline-sequence.gif)

The above timeline will perform each tween sequentially for a total duration of 3 seconds since each tween is 1 second in length.

Instead of having each tween play one after another, you can specify a position for one or all of the tweens in your sequence. For example, we want to play the second tween in the above sequence at 1.5 seconds into the timeline instead of immediately after the first one completes:

```swift
let timeline = Timeline()
timeline.add(square.tween().to(X(110)).duration(1).ease(.inOutCubic))
timeline.add(square.tween().to(Y(250)).duration(1).ease(.inOutCubic), position: 1.5)
timeline.add(square.tween().to(Scale(2)).duration(1).ease(.inOutCubic))
timeline.play()
```

This change will play the second tween at 1.5 seconds into the animation, and then the last one immediately after it completes at 2.5 seconds. Therefore, our timeline's new total duration will be 3.5 seconds instead of 3 seconds.

![Timeline Sequence](Example/screenshots/kinetic-timeline-sequence2.gif)

###Grouped + Staggered Animations###

Using `Kinetic.animateAll` you can animate the same properties on multiple objects using a single line of code. For example, you have 3 square views you want to scale up and rotate 45 degrees at the same time:

```swift
let squares = [greenSquare, blueSquare, redSquare]
let timeline = squares.tween()
                    .to(Scale(2), Rotation(CGFloat(Math.pi / 2.0)))
                    .duration(1)
                    .ease(.inOutSine)
timeline.play()
```

![Timeline Grouped](Example/screenshots/kinetic-timeline-grouped.gif)

Using a Timeline also provides you with the ability to stagger multiple animations for more interesting effects. For instance, you may have a column of horizontal bars whose widths you want to animate to their final state. You could do this with a basic Timeline instance and increasingly offset their positions relative to the start time, but there's an easier way using `stagger:` on your `Timeline` instance:

```swift
let squares = [greenSquare, blueSquare, redSquare]
let timeline = squares.tween()
                    .to(Size(width: 250))
                    .duration(1)
                    .stagger(0.08)
                    .spring(tension: 100, friction: 12)
timeline.play()
```

In a single line, you can animate each item in `squares` from their starting width to a width of 200 using a spring, each offset by 0.08 seconds.

![Timeline Staggered](Example/screenshots/kinetic-timeline-staggered.gif)

The method `Kinetic.animateAll:` will return an instance of Timeline.

You can also add labels to your timeline to be used for referencing when adding additional tweens or for playback. For example, you may want to include a color change animation for a view in your timeline and want other tweens to take place relative to that position. First create a label at the time you want to reference and then add your tweens relative to or offset from that label:

```swift
let resize = square.tween()
                .to(Size(150,100))
                .duration(1)
                .ease(Easing.inOutCubic)
					
let color = square.tween()
                .to(BackgroundColor(UIColor.blue))
                .duration(0.75)

timeline.addLabel("colorChange", position: 1.3)
timeline.add(color, relativeToLabel: "colorChange", offset: 0)
timeline.add(resize, relativeToLabel: "colorChange", offset: 0.5)
```

###Time Labels###

You can add any number of time labels to a timeline that can then be used as reference points for specific positions along the timeline. Once a label has been set, you can add tweens to the timeline relative to a specific label using an offset value. Negative offset values will insert the tween that number of seconds before the label:

```swift
// use a label to store a position reference when the color change still start animating
timeline.addLabel("colorChange", position: 1.3)

// add the color change tween to the timeline relative to our "colorChange" label
let color = square.tween().to(BackgroundColor(UIColor.blue)).duration(0.75)
timeline.add(color, relativeToLabel: "colorChange", offset: 0)

// resize the view 1 second after the color change starts
let resize = square.tween().to(Size(150,100)).duration(1).ease(.inOutCubic)
timeline.add(resize, relativeToLabel: "colorChange", offset: 0.5)

// move the view 0.25 seconds before the color change starts
let move = square.tween().to(Position(200,200)).duration(1).ease(.inOutCubic)
timeline.add(move, relativeToLabel: "colorChange", offset: -0.25)

timeline.play()
```

![Timeline Labels](Example/screenshots/kinetic-timeline-labels.gif)

###Time Callbacks##

With timelines you can also insert callback blocks at any time within a timeline's total duration, which is useful if you want to perform a certain action while the timeline is playing or perform another animation:

```swift
timeline.addCallback(Float(idx) * 0.15 + 1.5, block: {
	dot.tween().to(FillColor(UIColor.orange).duration(0.5).play()
})
```

![Timeline Callbacks](Example/screenshots/kinetic-preloader.gif)

###Controlling Timelines###

Timelines support the same methods as tweens for controlling their playback, such as `pause()`, `stop()`, `resume()`, `restart()`, and `seek()`. However, timelines also come with a few more since they support inserting labels at specific times. You can stop at or start playing from a specific label you have previously set on a timeline using `goToAndPlay()` and `goToAndStop()`:

```swift
timeline.addLabel("colorChange", 0.7)
timeline.play()
...
timeline.goToAndStop("colorChange")
```

If the specified label doesn't exist on the timeline, then the timeline will play from or start at the beginning of the timeline.

Timelines also support the same callback blocks as tweens, so you can use `onStart()`, `onUpdate()`, `onRepeat()` and `onComplete()` for timeline instances as well. You can also have callbacks for individual tween instances within a timeline in conjunction with callbacks on the parent timeline if you want to be notified when a particular tween has started or completed.

Refer to the example project for more detailed examples of using a Timeline.

