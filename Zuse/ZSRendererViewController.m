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

@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (strong, nonatomic) ZSRendererScene *scene;
@property (strong, nonatomic) SKView *SKView;

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
    
    [self loadSpriteKit];
    
    [_scene.interpreter triggerEvent:@"start"];
}

- (void)loadSpriteKit {
    // Configure the view.
    _SKView = (SKView *)self.view;
    _SKView.showsFPS = YES;
    _SKView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [[ZSRendererScene alloc] initWithSize:_SKView.bounds.size projectJSON:_projectJSON];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [_SKView presentScene:_scene];
}

- (void) runInterpreter {
    [_interpreter triggerEvent:@"start"];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
