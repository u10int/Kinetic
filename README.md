Kinetic
======
A flexible tweening library for iOS in Swift2 similar to GSAP and inspired by Cheetah.

**NOTE** This project is still a work in progress and may not by fully suitable for production usage. More extensive documentation will also be added along the way.

Requirements
----
- iOS 8.0+
- Swift 2.0+

Features
----
- Quickly setup animations in a syntax similar to TweenMax, TimelineMax and the awesome [GSAP](http://greensock.com/gsap)
- Start, stop, pause and resume any animation during runtime
- Easings and springs for more realistic and interesting animations
- Chaining methods for concise code
- Support for animating from, animating to, or animating from and to specific values (`to`, `from`, `fromTo`)
- Animate multiple objects sequentially, in parallel or staggered in a single animation group
- Advanced animations using timelines to insert gaps, callbacks and more during an animation
- Support for animating any NSObject property on your custom objects

Basic Examples
----
Animating multiple properties of an UIView or CALayer can be done in a single line of code:

	```swift
	let square = UIView()
	square.frame = CGRectMake(50, 50, 50, 50)
	square.backgroundColor = UIColor.redColor()
	view.addSubview(square)
	
	// move 250pt to the right and set the height to 100pt for 0.5 seconds
	Kinetic.to(square, duration: 0.5, options: [.X(250), .Height(100)]).ease(Easing.inOutQuart).play()

	```
	
{insert screenshot}
	
Animating the same properties on multiple objects is just as quick and easy:

	```swift
	let greenSquare = UIView()
	greenSquare.frame = CGRectMake(0, 50, 100, 100)
	greenSquare.backgroundColor = UIColor(red: 0.0557, green: 0.7144, blue: 0.0677, alpha: 1.0)
	view.addSubview(greenSquare)
		
	let blueSquare = UIView()
	blueSquare.frame = CGRectMake(0, 50, 100, 100)
	blueSquare.backgroundColor = UIColor(red: 0.0, green: 0.6126, blue: 0.9743, alpha: 1.0)
	view.addSubview(blueSquare)
	
	// rotate the views and repeat 3 times in a back and forth (yoyo) motion
	let timeline = Kinetic.itemsTo([greenSquare, blueSquare], duration: 1, options: [.RotateXY(0, CGFloat(M_PI_2))])
	timeline.ease(Easing.inOutSine).perspective(1 / -1000).yoyo().repeatCount(3)
	timeline.play()
	```
	
{insert screenshot}

If you want to remove a tween at any time, you can either call `kill()` on the Tween instance directly, or you can remove multiple tweens of a single object by using the convenience methods provided by the central Kinetic class:

	```swift			
	Kinetic.killTweensOf(greenSquare)
	```
	
To remove all tweens currently running from all objects, simply call `killAll()`:

	```swift			
	Kinetic.killAll(greenSquare)
	```
	
Killing and removing a tween is similar to `pause()` and will stop the animation at its current position without returning the associated object back to its original starting position.

Supported Properties
----
Kinetic has support for animating most visible properties on UIView and CALayer already built-in, but you can also animating any custom key-value property on NSObject:

- `.X(xVal)`, `.Y(yVal)`, `.Position(xVal, yVal)` - animates the frame's origin of the view or layer
- `.Center(xVal, yVal)` - animates the frame's center of the view or layer
- `.Shift(xOffset, yOffset)` - shifts the frame's current origin by the specified x and y distances (similar to translate but changes the object's origin value instead of using `transform`)
- `.Width(val)`, `.Height(val)`, `.Size(width, height)` - animates the frame's size of the view or layer
- `.Alpha(val)` - animates the object's opacity
- `.Translate(xOffset, yOffset)` - shifts the frame's position by the specified x and y distances using the layer's `transform` property
- `.Scale(val)` - animates the scale of the object equally for all axes (x, y and z)
- `.ScaleXY(scaleX, scaleY)` - animates the scale of the object in the x and y axes
- `.Rotate(val)` - animates the rotation of the object two-dimensionally in the z axes
- `.RotateXY(rotateX, rotateY)` - animates the rotation of the object in the x and y axes (for three-dimensional rotation)
- `.Transform(transform)` - animates the object to the specified CATransform3D value
- `.BackgroundColor(color)` - animates the background color of the view or layer
- `.KeyPath(key, val)` - animates a custom property on an NSObject instance for the specified key path

The animation properties you provide with your tweens use a very Swift-like syntax where you specify the starting or ending values as parameters to the property you wish to animate. For example, to animate a view's origin.x from its current position to 100pt you would use `.X(100)`. However, if you just wanted to shift the view from its current location 100pt to the right, you would use `.Shift(100,0)` instead, which specifies the distance to move the view in both x and y coordinates.

Classes
----
The following are the primary classes used within the library along with their purpose.

| Class         | Description                                                                                                                                               |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Kinetic       | Central class providing convenience static methods for creating tweens, timelines and removing them.                                                      |
| Tween         | Primary class used for animating individual objects and multiple properties.                                                                              |
| Timeline      | Used for combining multiple tweens into a single group with support for playing animations at specific times and inserting gaps along the timeline.       |
| Animation     | Internal base class for Tween and Timeline that provides common properties and methods.                                                                   |
| TweenProperty | Internal classes that represent a single animatable property for an object and performs the necessary calculations and updates during animation playback. |
| Easing        | Common easing properties for animations.                                                                                                                  |
| Spring        | Basic spring for physics-based animations.                                                                                                                |

Timelines
----
A Kinetic Timeline is similar to GSAP's TimelineMax in that it allows you to group multiple Tween instances into a single, easy to control sequence with precise timing management. Without using a Timeline instance, you would have to create multiple Tween instances and manually calculate their delay values to create the exact sequence you want.

For instance, if you want to move a view to the right, then down, and then scale it up by 2 for a duration of 3 seconds, you could do so by creating three Tween instances and offset their delay values by 1 second: 

	```swift
	Kinetic.to(square, duration: 1, options: [ .X(110) ]).ease(Easing.inOutCubic).play()
	Kinetic.to(square, duration: 1, options: [ .Y(250) ]).ease(Easing.inOutCubic).delay(1).play()
	Kinetic.to(square, duration: 1, options: [ .Scale(2) ]).ease(Easing.inOutCubic).delay(2).play()
	```		

Note that if you change the duration of any of the individual tweens, you also have to be sure to adjust the delay values for the sequence. And trying to pause, restart or reverse the sequence is even more of a challenge. However, by using a Timeline instance you can perform all of these functions easily:

	```swift
	let timeline = Timeline()
	timeline.add(Kinetic.to(square, duration: 1, options: [ .X(110) ]).ease(Easing.inOutCubic))
	timeline.add(Kinetic.to(square, duration: 1, options: [ .Y(250) ]).ease(Easing.inOutCubic))
	timeline.add(Kinetic.to(square, duration: 1, options: [ .Scale(2) ]).ease(Easing.inOutCubic))
	timeline.play())
	```
	
{insert screenshot}

Using `Kinetic.itemsTo`, `Kinetic.itemsFrom` and `Kinetic.itemsFromTo` you can animate the same properties on multiple objects using a single line of code. For example, you may want to move an array of views down by 50 points:

	```swift
	let timeline = Kinetic.itemsTo([views], duration: 0.5, options: [ .Shift(0, 50) ]).play()
	```

###Sequencing###



###Staggered Animations###

Using a Timeline also provides you with the ability to stagger multiple animations for more interesting effects. For instance, you may have a column of horizontal bars whose widths you want to animate to their final state. You could do this with a basic Timeline instance and increasingly offset their positions relative to the start time, but there's an easier way using `Kinetic.staggerTo`, `Kinetic.staggerFrom` and `Kinetic.staggerFromTo`:

	```swift
	// squares is an array of UIViews
	let timeline = Kinetic.staggerTo(squares, duration: 1, options: [ .Width(200) ], stagger: 0.08).spring(tension: 100, friction: 12).play()
	```
	
In a single line, you can animate each item in `squares` from their starting width to a width of 200 using a spring, each offset by 0.08 seconds. The methods `staggerTo`, `staggerFrom`, and `staggerToFrom` will return an instance of Timeline.

{insert screenshot}
	
You can also add labels to your timeline to be used for referencing when adding additional tweens or for playback. For example, you may want to include a color change animation for a view in your timeline and want other tweens to take place relative to that position. First create a label at the time you want to reference and then add your tweens relative to or offset from that label:

	```swift
	let resize = Kinetic.to(square, duration: 1, options: [ .Size(150,100) ]).ease(Easing.inOutCubic)
	let color = Kinetic.to(square, duration: 0.75, options: [ .BackgroundColor(UIColor.blueColor()) ])
		
	timeline.addLabel("colorChange", position: 1.3)
	timeline.add(color, relativeToLabel: "colorChange", offset: 0)
	timeline.add(resize, relativeToLabel: "colorChange", offset: 0.5)
	```

Refer to the example project for more detailed examples of using a Timeline.

