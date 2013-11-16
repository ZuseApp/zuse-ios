//
//  ZSInterpreterViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import <SpriteKit/SpriteKit.h>

#import "ZSRendererViewController.h"
#import "ZSInterpreter.h"
#import "ZSCompiler.h"
#import "ZSSarahTestScene.h"

@interface ZSRendererViewController ()

@property (strong, nonatomic) ZSInterpreter *interpreter;

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
	// TODO: Redundant loading of the json since the program object already does this.
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"pong" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:_projectJSON];
    
    _interpreter = [compiler compile];
    
    // compiler
//    for (NSDictionary *dict in json[@"objects"]) {
//        [_interpreter loadObject:dict];
//    }
    
    [NSThread detachNewThreadSelector:@selector(runInterpreter:) toTarget:self withObject:nil];
}

- (void)loadSpriteKit {
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [ZSSarahTestScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void) runInterpreter:(id)object {
    [_interpreter triggerEvent:@"start"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
