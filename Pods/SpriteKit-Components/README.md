SpriteKit-Components [![Build Status](https://travis-ci.org/xr1337/SpriteKit-Components.png?branch=master)](https://travis-ci.org/xr1337/SpriteKit-Components)
====================

A component model for iOS 7+ SpriteKit Framework. Add components that perform specific behaviors to your nodes. Benefits to using the component based model include:

 - Lets you write reusable behaviors that you can apply to any node and reuse across projects
 - Adds an update method with delta time called for every SKComponentNode and behavior
 - Adds onEnter and onExit methods akin to Cocos2d's model for every SKComponentNode which lets you perform set up and tear down when your nodes are added to and removed from the scene.
 - Simplifies basic touch interaction to automatically support select, tap, drag, drop, and long presses

Project Setup
-------
 1. Start with a SpriteKit Game project
 2. Drag and drop in SpriteKit-Components.xcodeproj into your project workspace
 3. Add SpriteKit-Components to your target dependencies
 4. Add libSpriteKit-Components.a to your Link Binary With Libraries build phase
 5. Add SKComponents.h to your project and include it in your prefix.pch header if you never want to have to include it again

Component Model Usage
-------
Your base scene must inherit from SKComponentScene. SKComponentScene is the component model host that ensures all SKComponentNodes are found and registered.

Your scene graph should be based on SKComponentNodes, which should have your graphical/rendering nodes as their children. SKComponentNodes can be added anywhere in the scene.

Add behaviors to your SKComponentNodes with `[node addComponent:[MyComponent new]];`

SKComponent Protocol
-------
Your components must implement the following protocol. All methods are optional, however the enabled property is required.
```Objective-C
@protocol SKComponent <NSObject>

@property (nonatomic, readwrite) BOOL enabled;

@optional
@property (nonatomic, weak) SKNode *node;

@optional
// triggered when the component is added to a component node
- (void)awake;

// when the node is added to the scene
- (void)onEnter;

// when the node is removed from the scene
- (void)onExit;

// called every frame. dt = time since last frame
- (void)update:(CFTimeInterval)dt;

// SpriteKit - forwarded from SKScene
- (void)onSceneSizeChanged:(CGSize)oldSize;

// SpriteKit - forwarded from SKScene
- (void)didEvaluateActions;

#pragma mark -- Physics Handlers --

// SpriteKit - forwarded from SKScene
- (void)didSimulatePhysics;

// SpriteKit - forwarded from SKScene when this node is one of the nodes in contact
- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)didEndContact:(SKPhysicsContact *)contact;


#pragma mark -- Touch Handlers --
// all touch handlers are only triggered if the tough down is inside the node content area

// called once a touch moves beyond the SKComponentNode dragThreshold (defaults to 4 units)
- (void)dragStart:(SKCTouchState*)touchState;

// called every time a touch moves after dragging has started
- (void)dragMoved:(SKCTouchState*)touchState;

// called on touch up after dragging has started
- (void)dragDropped:(SKCTouchState*)touchState;

// called if the touch is canceled after dragging has started
- (void)dragCancelled:(SKCTouchState*)touchState;
- 

// called on Touch Up if UITouch tap count >= 1 and touch is not classified as dragging or a long touch
- (void)onTap:(SKCTouchState*)touchState;

// called if touch is held for SKComponentNode longPressTime (defaults to 1 second)
// AND touch has not moved beyond dragThreshold
- (void)onLongPress:(SKCTouchState*)touchState;

// equivalent to iOS Touch Up Inside. Typically used for menu items rather than tap
- (void)onSelect:(SKCTouchState*)touchState;


// standard touchesBegan event, called prior to touchState based events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

// standard touchesMoved event, called prior to touchState based events
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

// standard touchesEnded event, called prior to touchState based events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

// standard touchesCancelled event, called prior to touchState based events
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end
```



Example Component - ApplyAlpha to all children
-------

SKComponentNodes automatically apply their alpha value to their direct children, but lets say you want to apply that alpha to your node's children's children's children, and so on.

SKCDeepAlpha.h

```Objective-C
@interface SKCDeepAlpha : NSObject<SKComponent> {
    float previousAlpha;
}
@end
```

SKCDeepAlpha.m

```Objective-C
#import "SKCDeepAlpha.h"
    
@implementation SKCDeepAlpha
@synthesize node,enabled;

- (void)onEnter {
	recursivelyApplyAlpha(node, node.alpha);
}
    
- (void)didEvaluateActions {
	if (previousAlpha != node.alpha) {
		recursivelyApplyAlpha(node, node.alpha);
		previousAlpha = node.alpha;
	}
}

void recursivelyApplyAlpha(SKNode* node, float alpha) {
	for (SKNode *child in node.children) {
		child.alpha = alpha;
		if (child.children.count > 0)
			recursivelyApplyAlpha(child, alpha);
	}
}
@end
```

onEnter and didEvaluateActions will automatically be called when you add this component to a node in the scene. Add this component to one of your SKComponentNodes and any time you change the alpha on your component node, it will set the alpha on every descendent. 

To use this component, just add it to any SKComponentNode like this:

```Objective-C
SKNode* node = [SKComponentNode node];
[node addComponent:[SKCDeepAlpha new]];
// add sprites or shapes as children of your node, then add it to the scene
[scene addChild:node];
```

Example Component - Adding Touch Interaction
---------------------------------------

First off, don't forget to turn on user interaction on your SKComponentNode with `node.userInteractionEnabled = YES;`. A good place to do it would be in the component's awake method.

Every app has buttons. Let's make a component that responds to a touch-up-inside type gesture.

```Objective-C
@implementation SKCSelectTest
@synthesize node, enabled;

- (void)awake {
	node.userInteractionEnabled = YES;
}

- (void)onSelect:(SKCTouchState*)touchState {
	// do something
}
@end
```

OMG that was too easy. Let's make a component that will let you drag a node around the screen instead:

```Objective-C
@implementation SKCDraggable
@synthesize node, enabled;
@synthesize startPosition;

- (void)awake {
	node.userInteractionEnabled = YES;
}

- (void)dragStart:(SKCTouchState*)touchState {
	// we could do something here to clue the user in on the fact that we started dragging
	startPosition = node.position;
}

- (void)dragMoved:(SKCTouchState*)touchState {
	// check out the skHelper.m for a couple shorthand functions/methods for vector` math
	node.position = skpAdd(node.position, touchState.touchLocation);
}

- (void)dragDropped:(SKCTouchState*)touchState {
	// we could show the user we dropped successfully here
}

- (void)dragCancelled:(SKCTouchState*)touchState {
	node.position = startPosition;
}
@end
```

Naming and Accessing Components
--------------------
Let's say you added a few components to your node, and now you need to change the properties of one of those components. You could keep a reference to every component, but that would be annoying. Instead, just ask the component node for it:

```Objective-C
// Disable the component of type MyComponent (callbacks will immediately stop)
[node getComponent:[MyComponent class]].enabled = NO;
    
// or better yet, get the component casted to the proper type
SKGetComponent(node, MyComponent).customProperty = 42;
```
 
Most of the time each component on a node will be of a different type, but if you wanted to add two components of the same type, you will need to name them instead of relying on the class name.

```Objective-C
[node addComponent:[SpeedDoubler new] withName:@"2xSpeed"];
[node addComponent:[SpeedDoubler new] withName:@"4xSpeed"];
[node getComponentWithName:@"4xSpeed"].enabled = NO;
```

SKComponentNodes can be a component too
----------------------------
If you sublcass an SKComponentNode and you want to make use of the component callbacks without creating an extra component, just implement the `SKComponent` protocol.  Now your node gets all the component callbacks too. Just make sure you call `[super onEnter/onExit/update:]` so the component node can do it's behind the scenes magic.

Testing
---------
Check out our CI on https://travis-ci.org/xr1337/SpriteKit-Components

License
-------
This software is licensed under the MIT License (MIT). See LICENSE file for details.
