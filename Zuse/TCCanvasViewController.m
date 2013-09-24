//
//  TCViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCCanvasViewController.h"
#import "TCSpriteTableView.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "TCSpriteManager.h"

@interface TCCanvasViewController ()

@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (weak, nonatomic) IBOutlet TCSpriteView *paddleOne;
@property (weak, nonatomic) IBOutlet TCSpriteView *paddleTwo;
@property (weak, nonatomic) IBOutlet TCSpriteView *ball;

@end

@implementation TCCanvasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _spriteManager = [TCSpriteManager sharedManager];
    
    _ball.touchesMoved = ^(UITouch *touch) {
        
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
