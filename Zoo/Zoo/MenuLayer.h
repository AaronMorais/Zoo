// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "LoadingLayer.h"

@interface MenuLayer : CCLayer {
    CCSprite* background;
    CCMenu * myMenu;
    LoadingLayer *loading;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
