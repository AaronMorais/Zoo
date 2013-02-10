//
//  RadialGradiantLayer.m
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "RadialGradientLayer.h"

@implementation RadialGradientLayer {
    CCLayerGradient *gradient;
    CCLayerGradient *gradient2;
    CCLayerGradient *gradient3;
    CCLayerGradient *gradient4;
    int count;
    int savedSpeed;
    ccColor3B savedColor;
}
- (id)initWithColor:(ccColor3B)color fadeIn:(BOOL)fade speed:(int)speed{
    self = [super init];
    if (self) {
        savedColor = color;
        savedSpeed = speed;
        if(fade) {
            [self fadeInScheduler];
            count = 0;
        } else {
            [self showRadialGradientWithOpacity:255 color:color];
            count = 255;
        }
    }
    return self;
}

- (void) fadeInScheduler {
    [self schedule:@selector(fadeIn) interval:0.0001 repeat:25/savedSpeed delay:0.0001];
}

- (void) fadeIn {
    count +=10*savedSpeed;
    if(count > 255) {
        count = 255;
    }
    [self showRadialGradientWithOpacity:count color:savedColor];
}

- (void) fadeAwayScheduler {
    [self schedule:@selector(fadeAway) interval:0.0001 repeat:24/savedSpeed delay:0.0001];
}

- (void) fadeAway {
    count -=10*savedSpeed;
    if(count < 0) {
        count = 0;
    }
    [self showRadialGradientWithOpacity:count color:savedColor];
}

- (void) showRadialGradientWithOpacity:(CGFloat)opacity color:(ccColor3B) color{
    [self removeAllChildrenWithCleanup:YES];
    ccColor4B initial = ccc4(color.r, color.g, color.b, 0);
    ccColor4B final = ccc4(color.r, color.g, color.b, opacity);
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    gradient = [CCLayerGradient layerWithColor:initial fadingTo:final alongVector:ccp(0,-1)];
    [self addChild:gradient];
    [gradient changeHeight:winSize.height/4];
    gradient2 = [CCLayerGradient layerWithColor:initial fadingTo:final alongVector:ccp(0,1)];
    [self addChild:gradient2];
    [gradient2 changeHeight:winSize.height/4];
    gradient2.position = ccp(0, winSize.height - winSize.height/4);
    gradient3 = [CCLayerGradient layerWithColor:final fadingTo:initial alongVector:ccp(1,0)];
    [self addChild:gradient3];
    [gradient3 changeWidth:winSize.width/4];
    gradient4 = [CCLayerGradient layerWithColor:final fadingTo:initial alongVector:ccp(-1,0)];
    [self addChild:gradient4];
    [gradient4 changeWidth:winSize.width/4];
    gradient4.position = ccp(winSize.width - winSize.width/4, 0);
}

@end
