//
//  ZSInterpreterViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "BlocksKit.h"
#import <SpriteKit/SpriteKit.h>

#import "ZSRendererViewController.h"
#import "ZSInterpreter.h"
#import "ZSCompiler.h"
#import "ZSRendererScene.h"

@interface ZSRendererViewController ()

@property (strong, nonatomic) ZSRendererScene *scene;

@end

@implementation ZSRendererViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // This makes it so you can still do the swipe-to-get-back
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    // Configure the view.
    self.SKView.showsFPS = YES;
    self.SKView.showsNodeCount = YES;
//    [self loadSpriteKit];
    
//    [_scene.interpreter triggerEvent:@"start"];
}

- (void)loadSpriteKit {
    
    // Create and configure the scene.
    _scene = [[ZSRendererScene alloc] initWithSize:self.SKView.bounds.size projectJSON:_projectJSON];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [self.SKView presentScene:_scene];
}

- (void) runInterpreter {
    [_scene.interpreter triggerEvent:@"start"];
}

- (void)play {
    self.SKView.paused = NO;
    [self runInterpreter];
}

- (void)resume {
    self.SKView.paused = NO;
}

- (void)stop {
    self.SKView.paused = YES;
}

- (SKView *)SKView {
    return (SKView *)self.view;
}

- (void)setProjectJSON:(NSDictionary *)projectJSON {
    _projectJSON = projectJSON;
    [self loadSpriteKit];
}

- (void)viewWillAppear:(BOOL)animated {
}

@end
