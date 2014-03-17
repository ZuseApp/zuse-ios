//
//  ZSZuseHubEnums.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSZuseHubEnums : NSObject

typedef NS_ENUM(NSInteger, ZSZuseHubDrawerSection){
    ZSZuseHubDrawerMyZuseHub,
    ZSZuseHubDrawerBrowseProjects,
    ZSZuseHubDrawerSettings,
    ZSZuseHubDrawerSectionCount,
};

typedef NS_ENUM(NSInteger, ZSZuseHubBrowseType)
{
    ZSZuseHubBrowseTypeNewest,
    ZSZuseHubBrowseTypeCount,
};

typedef NS_ENUM(NSInteger, ZSZuseHubMyHubType)
{
    ZSZuseHubMyHubTypeShareProject,
    ZSZuseHubMyHubTypeViewMySharedProjects,
};

typedef NS_ENUM(NSInteger, ZSZuseHubSettingsType)
{
    ZSZuseHubSettingsBackToMainMenu,
    ZSZuseHubSettingsLogout,
};

@end
