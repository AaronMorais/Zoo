#import "GameLayer.h"
#import "MenuLayer.h"
#import "AppDelegate.h"
#import "ABGameKitHelper.h"

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
        sharedSingleton = [GameManager sharedInstance];
        
        loading = [[LoadingLayer alloc] initWithColor:ccc4(0,0,0,255)];
        [self addChild:loading];
        
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
    background = [CCSprite spriteWithFile:@"assets/mainBackground.png"];
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
    menuItem1.scale = 0.42;
    
    CCMenuItemImage * menuItem2 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                    target:self
                                    selector:@selector(leaderboard:)];
    menuItem2.scale = 0.42;
    
    CCMenuItemImage * menuItem3 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                    target:self
                                    selector:@selector(howToPlay:)];
    menuItem3.scale = 0.42;

    
    CCMenuItemImage * menuItem4 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                    selectedSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                    target:self
                                    selector:@selector(options:)];
    menuItem4.scale = 0.42;
    
    
	// Create a menu and add your menu items to it
	myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
    [myMenu alignItemsHorizontallyWithPadding:-30.0f];
    myMenu.position = ccp([[CCDirector sharedDirector] winSize].width/2, 95);
    
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
}

- (void) play: (CCMenuItem*) menuItem{
    [self removeChild:background cleanup:YES];
    [self removeChild:myMenu cleanup:YES];
    [self scheduleOnce:@selector(loadGameScene) delay:0.0f];
}

- (void) loadGameScene {
    [[CCDirector sharedDirector] replaceScene:
        [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer scene]]];
}
- (void) leaderboard:(CCMenuItem*) menuItem{
    [[ABGameKitHelper sharedClass] showLeaderboard:@"ZooBoxLeaderboard"];
}
- (void) options:(CCMenuItem*) menuItem{
	NSLog(@"options");
}
- (void) howToPlay:(CCMenuItem*) menuItem{
	NSLog(@"htp");
}
 
@end