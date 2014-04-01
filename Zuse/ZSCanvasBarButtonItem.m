#import "ZSCanvasBarButtonItem.h"
#import <FontAwesomeKit/FAKIcon.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

CGFloat const DefaultSize = 33;

@interface ZSCanvasBarButtonItem ()

@property (copy, nonatomic) void(^handler)();
@property (strong, nonatomic) UIButton *button;

@end

@implementation ZSCanvasBarButtonItem

+ (ZSCanvasBarButtonItem *)buttonWithIcon:(FAKIcon *)icon
                               tapHandler:(void (^)())handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    button.frame = CGRectMake(0, 0, icon.iconFontSize, icon.iconFontSize);
    [button setAttributedTitle:icon.attributedString forState:UIControlStateNormal];
    
    ZSCanvasBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    buttonItem.button = button;
    
    [button addTarget:buttonItem
               action:@selector(buttonTapped)
     forControlEvents:UIControlEventTouchUpInside];
    
    buttonItem.handler = [handler copy];
    
    return buttonItem;
}

+ (UIBarButtonItem *)flexibleBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:nil
                                                         action:nil];
}

+ (FAKIcon *)styledIcon:(FAKIcon *)icon {
    icon.iconFontSize = DefaultSize;
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return icon;
}

+ (ZSCanvasBarButtonItem *)playButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons playIconWithSize:DefaultSize]];
    [icon addAttribute:NSForegroundColorAttributeName
                 value:[UIColor zuseGreen]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)generatorsButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons ios7BrowsersIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)editButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons editIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)groupsButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKFontAwesome usersIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)toolboxButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons settingsIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)shareButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons shareIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)backButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons replyIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)stopButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons stopIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)pauseButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons pauseIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)finishButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons checkmarkIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)cutButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKFontAwesome scissorsIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)copyButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons ios7CopyOutlineIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)deleteButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons ios7TrashOutlineIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)editTextButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKFontAwesome fontIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)gridButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons gridIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)doneButtonWithHandler:(void (^)())handler {
    ZSCanvasBarButtonItem *item = [[ZSCanvasBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil
                                                                                      action:nil];
    item.target = item;
    item.action = @selector(buttonTapped);
    item.tintColor = [UIColor zuseYellow];
    item.handler = [handler copy];
    return item;
}

+ (ZSCanvasBarButtonItem *)collisionsButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons flashIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

+ (ZSCanvasBarButtonItem *)selectGroupButtonWithHandler:(void (^)())handler {
    ZSCanvasBarButtonItem *item = [[ZSCanvasBarButtonItem alloc] initWithTitle:@"foo"
                                                                         style:UIBarButtonItemStyleBordered target:nil action:nil];
    item.target = item;
    item.action = @selector(buttonTapped);
    item.tintColor = [UIColor zuseYellow];
    item.handler = [handler copy];
    return item;
}

+ (ZSCanvasBarButtonItem *)addButtonWithHandler:(void (^)())handler {
    FAKIcon *icon = [self styledIcon:[FAKIonIcons ios7PlusIconWithSize:DefaultSize]];
    return [self buttonWithIcon:icon tapHandler:handler];
}

- (void)buttonTapped {
    if (self.handler) {
        self.handler();
    }
}


@end
