//
//  RadialGradiantLayer.m
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "RadialGradientLayer.h"

@implementation RadialGradientLayer {
    CCLayerGradient *_gradientBottom;
    CCLayerGradient *_gradientTop;
    CCLayerGradient *_gradientLeft;
    CCLayerGradient *_gradientRight;
    int _fadeInCount;
    int _savedSpeed;
    ccColor3B _savedColor;
    BOOL _isLarge;
}
- (id)initWithColor:(ccColor3B)color fadeIn:(BOOL)fade speed:(int)speed large:(BOOL)large{
    self = [super init];
    if (self) {
        _savedColor = color;
        _savedSpeed = speed;
        _isLarge = large;
        if(fade) {
            [self fadeInScheduler];
            _fadeInCount = 0;
        } else {
            [self showRadialGradientWithOpacity:255 color:color];
            _fadeInCount = 255;
        }
    }
    return self;
}

- (void) fadeInScheduler {
    [self schedule:@selector(fadeIn) interval:0.0001 repeat:25/_savedSpeed delay:0.0001];
}

- (void) fadeIn {
    _fadeInCount +=10*_savedSpeed;
    if(_fadeInCount > 255) {
        _fadeInCount = 255;
    }
    [self showRadialGradientWithOpacity:_fadeInCount color:_savedColor];
}

- (void) fadeAwayScheduler {
    [self schedule:@selector(fadeAway) interval:0.0001 repeat:24/_savedSpeed delay:0.0001];
}

- (void) fadeAway {
    _fadeInCount -=10*_savedSpeed;
    if(_fadeInCount < 0) {
        _fadeInCount = 0;
    }
    [self showRadialGradientWithOpacity:_fadeInCount color:_savedColor];
}

- (void) showRadialGradientWithOpacity:(CGFloat)opacity color:(ccColor3B) color{
    CGFloat size;
    if(_isLarge) { size = 4; } else { size = 16; }
    [self removeAllChildrenWithCleanup:YES];
    
    ccColor4B initial = ccc4(color.r, color.g, color.b, 0);
    ccColor4B final = ccc4(color.r, color.g, color.b, opacity);
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _gradientBottom = [CCLayerGradient layerWithColor:initial fadingTo:final alongVector:ccp(0,-1)];
    [self addChild:_gradientBottom];
    [_gradientBottom changeHeight:winSize.height/size];
    
    _gradientTop = [CCLayerGradient layerWithColor:initial fadingTo:final alongVector:ccp(0,1)];
    [self addChild:_gradientTop];
    [_gradientTop changeHeight:winSize.height/size];
    _gradientTop.position = ccp(0, winSize.height - winSize.height/size);
    
    _gradientLeft = [CCLayerGradient layerWithColor:final fadingTo:initial alongVector:ccp(1,0)];
    [self addChild:_gradientLeft];
    [_gradientLeft changeWidth:winSize.width/size];
    
    _gradientRight = [CCLayerGradient layerWithColor:final fadingTo:initial alongVector:ccp(-1,0)];
    [self addChild:_gradientRight];
    [_gradientRight changeWidth:winSize.width/size];
    _gradientRight.position = ccp(winSize.width - winSize.width/size, 0);
}

- (void) removeAfterDelay:(CGFloat)delay{
    [self performSelector:@selector(removeFromParentAndCleanup:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
}
@end
