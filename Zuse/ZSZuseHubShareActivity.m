//
//  ZSZuseHubShareActivity.m
//  Zuse
//
//  Created by Sarah Hong on 4/12/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ZSZuseHubShareActivity.h"

@interface ZSZuseHubShareActivity ()

@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSURL *url;

@end


@implementation ZSZuseHubShareActivity


- (NSString *)activityTitle {
    return @"ZuseHub";
}

- (NSString *)activityType {
    return @"com.zuse.zuseHubSharing";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"alphaIcon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.text = (NSString *)item;
        } else if ([item isKindOfClass:[NSURL class]]) {
            self.url = (NSURL *)item;
        }
    }
}

- (void)performActivity {
    self.wasChosen();
}


@end
