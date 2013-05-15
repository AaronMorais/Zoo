//
//  ActionManager.m
//  Zoo
//
//  Created by Aaron Morais on 2013-05-14.
//
//

#import "ActionManager.h"

@implementation ActionManager

typedef enum {
    ActionTypeFlail = 1,
    ActionTypeBlink,
    ActionTypeBox,
    ActionTypeBelt
} ActionType;

+ (id)sharedInstance {
    static ActionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.animalBlinkActions = [NSMutableArray array];
        self.animalFlailActions = [NSMutableArray array];
        self.boxActions = [NSMutableArray array];
        [self createSpriteActions];
    }
    return self;
}

- (void)createSpriteActions{
    [self createActionNamed:@"lionblinking" WithSize:32 WithDelay:0.05f WithType:ActionTypeBlink];
    [self createActionNamed:@"lionflail" WithSize:51 WithDelay:0.05f WithType:ActionTypeFlail];
    
    [self createActionNamed:@"elephantblink" WithSize:36 WithDelay:0.05f WithType:ActionTypeBlink];
    [self createActionNamed:@"elephantflail" WithSize:52 WithDelay:0.05f WithType:ActionTypeFlail];
    
    [self createActionNamed:@"hippoblink" WithSize:32 WithDelay:0.05f WithType:ActionTypeBlink];
    [self createActionNamed:@"hippoflail" WithSize:52 WithDelay:0.05f WithType:ActionTypeFlail];
    
    [self createActionNamed:@"penguinblink" WithSize:31 WithDelay:0.05f WithType:ActionTypeBlink];
    [self createActionNamed:@"penguinflail" WithSize:51 WithDelay:0.05f WithType:ActionTypeFlail];
    
    [self createActionNamed:@"penguinbox" WithSize:9 WithDelay:0.05f WithType:ActionTypeBox];
    [self createActionNamed:@"elephantbox" WithSize:9 WithDelay:0.05f WithType:ActionTypeBox];
    [self createActionNamed:@"hippobox" WithSize:9 WithDelay:0.05f WithType:ActionTypeBox];
    [self createActionNamed:@"lionbox" WithSize:9 WithDelay:0.05f WithType:ActionTypeBox];
    
    [self createActionNamed:@"conbelt" WithSize:26 WithDelay:0.15f WithType:ActionTypeBelt];
}

- (void)createActionNamed:(NSString *)name WithSize:(int)size WithDelay:(CGFloat)delay WithType:(ActionType)type{
    NSMutableArray *animationFrames = [NSMutableArray array];
    for(int i=1; i<=size; i++) {
        if(i<10 && type != ActionTypeBox) {
            [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@0%d.png", name, i]]];
        } else {
            [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", name, i]]];
        }
    }
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:delay];
    CCAction *action;
    if(type == ActionTypeBox) {
        action = [CCAnimate actionWithAnimation:animation];
    } else {
        action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    }
    if(type == ActionTypeBlink) {
        [self.animalBlinkActions addObject:action];
    } else if(type == ActionTypeFlail){
        [self.animalFlailActions addObject:action];
    } else if(type == ActionTypeBelt) {
        self.beltAction = action;
    } else if(type == ActionTypeBox) {
        [self.boxActions addObject:action];
    }
}


@end
