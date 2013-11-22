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
#import "ZSRendererScene.h"

@interface ZSRendererViewController ()

@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (strong, nonatomic) SKScene *scene;
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
	// TODO: Redundant loading of the json since the program object already does this.
//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"pong" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
//    _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:_projectJSON];
    _interpreter = [compiler interpreter];
    [self loadSpriteKit];
    
    // compiler
//    for (NSDictionary *dict in json[@"objects"]) {
//        [_interpreter loadObject:dict];
//    }
    
//    [NSThread detachNewThreadSelector:@selector(runInterpreter:) toTarget:self withObject:nil];
    [self runInterpreter];
}

- (void)loadSpriteKit {
    // Configure the view.
    _SKView = (SKView *)self.view;
    _SKView.showsFPS = YES;
    _SKView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [[ZSRendererScene alloc] initWithSize:_SKView.bounds.size interpreter:_interpreter];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [_SKView presentScene:_scene];
}

- (void) runInterpreter {
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
