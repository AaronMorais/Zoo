#import "cocos2d.h"
#import "LoadingLayer.h"

@interface MenuLayer : CCLayer {
    CCSprite* background;
    CCMenu * myMenu;
    LoadingLayer *loading;
}

+(CCScene *) scene;
- (void) playGame;

@end
