#import "GameLayer.h"
#import "MenuLayer.h"
#import "AppDelegate.h"
 
@implementation MenuLayer
 
+(id) scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
 
	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
 
	// add layer as a child to scene
	[scene addChild: layer];
 
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
        sharedSingleton = [Singleton sharedInstance];
        [sharedSingleton retain];
        [self menuMusic];
        [self addBackgroundImage];
        [self setUpMenus];
	}
	return self;
}
-(void) menuMusic{
    [[sharedSingleton sae] playBackgroundMusic:@"menuMusic.mp3"];
}
-(void) addBackgroundImage{
    CGSize winSize;
    winSize = [[CCDirector sharedDirector] winSize];
    CCSprite* background = [CCSprite spriteWithFile:@"assets/mainBackground.png"];
    [self addChild:background];
    background.position = ccp(winSize.width/2, winSize.height/2);
}

// set up the Menu
-(void) setUpMenus{
	// Create some menu items
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/mainMenu.plist"];
    CCSpriteBatchNode* mainSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/mainMenu.png"];
    [self addChild:mainSpriteSheet];

	CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"p.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"p.png"]
                                    target:self
                                    selector:@selector(play:)];
    menuItem1.scale = 0.6;
    menuItem1.position = CGPointMake(-120,-58);
    
    CCMenuItemImage * menuItem2 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                    target:self
                                    selector:@selector(leaderboard:)];
    menuItem2.scale = 0.34;
    menuItem2.position = CGPointMake(50,-102);
    
    CCMenuItemImage * menuItem3 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                    target:self
                                    selector:@selector(options:)];
    menuItem3.scale = 0.34;
    menuItem3.position = CGPointMake(149,-19);
    
    CCMenuItemImage * menuItem4 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                    target:self
                                    selector:@selector(howToPlay:)];
    menuItem4.scale = 0.34;
    menuItem4.position = CGPointMake(50,-19);
    
	// Create a menu and add your menu items to it
	myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
	// add the menu to your scene
	[self addChild:myMenu];
}
 
// on "dealloc" you need to release all your retained objects
- (void) dealloc{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
 
	// don't forget to call "super dealloc"
    [[sharedSingleton sae] pauseBackgroundMusic];
	[super dealloc];
}

- (void) play: (CCMenuItem*) menuItem{
    myMenu.enabled = NO;
    [[CCDirector sharedDirector] replaceScene:
        [CCTransitionFade transitionWithDuration:0.0f scene:[GameLayer scene]]];
}
- (void) leaderboard:(CCMenuItem*) menuItem{
	NSLog(@"ldb");
}
- (void) options:(CCMenuItem*) menuItem{
	NSLog(@"options");
}
- (void) howToPlay:(CCMenuItem*) menuItem{
	NSLog(@"htp");
}
 
@end