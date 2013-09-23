//
//  TCSpriteTableView.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCSpriteTableView.h"
#import "TCSpriteManager.h"

@interface TCSpriteTableView ()

@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *sprites;

@end

@implementation TCSpriteTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _spriteManager = [TCSpriteManager sharedManager];
        _sprites = _spriteManager.sprites;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
