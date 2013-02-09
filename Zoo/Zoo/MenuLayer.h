// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Singleton.h"

@interface MenuLayer : CCLayer {
    Singleton* sharedSingleton;
    CCMenu * myMenu;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
