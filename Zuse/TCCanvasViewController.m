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
#import "TCSpriteManager.h"

@interface TCCanvasViewController ()

@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *sprites;

@end

@implementation TCCanvasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _spriteManager = [TCSpriteManager sharedManager];
    _sprites = _spriteManager.sprites;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sprites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    TCSprite * sprite = (TCSprite *)[_sprites objectAtIndex:indexPath.row];
    cell.imageView.image = sprite.image;
    
    return cell;
}

@end
