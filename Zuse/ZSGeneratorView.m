#import "ZSGeneratorView.h"
#import "ZSGeneratorController.h"

@interface ZSGeneratorView ()

@property (nonatomic, strong) ZSGeneratorController *controller;

@end

@implementation ZSGeneratorView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _controller = [[ZSGeneratorController alloc] init];
        self.delegate = _controller;
        self.dataSource = _controller;
    }
    return self;
}

@end
