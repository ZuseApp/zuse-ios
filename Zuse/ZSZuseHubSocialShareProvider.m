//
//  ZSZuseHubSocialShareProvider.m
//  Zuse
//
//  Created by Sarah Hong on 4/12/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ZSZuseHubSocialShareProvider.h"

@implementation ZSZuseHubSocialShareProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    // Log out the activity type that we are sharing with
    NSLog(@"%@", activityType);
    
    // Create the default sharing string
    NSString *shareString = @"Check out the awesome game I made with Zuse!";
    
    // customize the sharing string for facebook, twitter, weibo, and google+
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareString = [NSString stringWithFormat:@"Attention Facebook: %@", shareString];
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        shareString = [NSString stringWithFormat:@"Attention Twitter: %@", shareString];
    } else if ([activityType isEqualToString:UIActivityTypePostToWeibo]) {
        shareString = [NSString stringWithFormat:@"Attention Weibo: %@", shareString];
    } else if ([activityType isEqualToString:@"com.captech.googlePlusSharing"]) {
        shareString = [NSString stringWithFormat:@"Attention Google+: %@", shareString];
    }
    
    return shareString;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

@end
