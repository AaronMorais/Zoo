//
//  PauseLayer.m
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "GameOverlayLayer.h"
#import "MenuLayer.h"
#import "Singleton.h"
#import "GameLayer.h"

@implementation GameOverlayLayer {
    CGSize winSize;
    CCLayerColor *fadeLayer;
    CCLabelTTF *highScoreHeader;
    CCLabelTTF *highScoreFooter;
    CCLabelTTF *yourScoreHeader;
    CCLabelTTF *yourScoreFooter;
    Singleton *sharedSingleton;
    CCMenu * menu;
}

- (id)init {
    self = [super init];
    if (self) {
        sharedSingleton = [Singleton sharedInstance];
        [sharedSingleton retain];
        winSize = [[CCDirector sharedDirector] winSize];
        
        fadeLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [fadeLayer setOpacity:175];
        [self addChild:fadeLayer];
    }
    return self;
}

- (id)initAsPauseMenu {
    self = [self init];
    if (self) {        
        highScoreHeader = [[CCLabelTTF alloc] initWithString:@"score to beat:" fontName:@"Aharoni" fontSize:55.0f];
        highScoreHeader.ignoreAnchorPointForPosition = YES;
        highScoreHeader.position = ccp(winSize.width * 0.125, winSize.height * 0.72);
        [self addChild:highScoreHeader];
        
        highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[sharedSingleton getHighScore]] fontName:@"Aharoni" fontSize:70.0f];
        highScoreFooter.ignoreAnchorPointForPosition = YES;
        highScoreFooter.position = ccp(winSize.width * 0.45, winSize.height * 0.55);
        [self addChild:highScoreFooter];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/mainMenu.plist"];
        CCSpriteBatchNode* mainSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/mainMenu.png"];
        [self addChild:mainSpriteSheet];

        CCMenuItemImage * resumeMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"p.png"]
                                        selectedSprite:[CCSprite spriteWithSpriteFrameName:@"p.png"]
                                        target:self
                                        selector:@selector(resumeGame)];
        resumeMenuItem.scale = 0.42;
        
        CCMenuItemImage * restartMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                        selectedSprite:[CCSprite spriteWithSpriteFrameName:@"ldb.png"]
                                        target:self
                                        selector:@selector(restartGame)];
        restartMenuItem.scale = 0.42;
        
        CCMenuItemImage * optionsMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                        selectedSprite:[CCSprite spriteWithSpriteFrameName:@"htp.png"]
                                        target:self
                                        selector:@selector(openOptions)];
        optionsMenuItem.scale = 0.42;

        
        CCMenuItemImage * quitMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                        selectedSprite:[CCSprite spriteWithSpriteFrameName:@"optns.png"]
                                        target:self
                                        selector:@selector(quitToMain)];
        quitMenuItem.scale = 0.42;
        
        
        // Create a menu and add your menu items to it
        menu = [CCMenu menuWithItems:resumeMenuItem, restartMenuItem, optionsMenuItem, quitMenuItem, nil];
        [menu alignItemsHorizontallyWithPadding:-30.0f];
        menu.position = ccp(winSize.width/2, 95);
        
        // add the menu to your scene
        [self addChild:menu];
        menu.enabled = NO;
    }
    return self;
}

- (id)initAsGameOver:(int)score {
    self = [self init];
    if (self) {        
        highScoreHeader = [[CCLabelTTF alloc] initWithString:@"highscore:" fontName:@"Aharoni" fontSize:55.0f];
        highScoreHeader.ignoreAnchorPointForPosition = YES;
        highScoreHeader.position = ccp(winSize.width * 0.125, winSize.height * 0.72);
        [self addChild:highScoreHeader];
        
        highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[sharedSingleton getHighScore]] fontName:@"Aharoni" fontSize:70.0f];
        highScoreFooter.ignoreAnchorPointForPosition = YES;
        highScoreFooter.position = ccp(winSize.width * 0.45, winSize.height * 0.55);
        [self addChild:highScoreFooter];
        
        yourScoreHeader = [[CCLabelTTF alloc] initWithString:@"yourScore:" fontName:@"Aharoni" fontSize:55.0f];
        yourScoreHeader.ignoreAnchorPointForPosition = YES;
        yourScoreHeader.position = ccp(winSize.width * 0.125, winSize.height * 0.72);
        [self addChild:yourScoreHeader];
        
        yourScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Aharoni" fontSize:70.0f];
        yourScoreFooter.ignoreAnchorPointForPosition = YES;
        yourScoreFooter.position = ccp(winSize.width * 0.45, winSize.height * 0.55);
        [self addChild:yourScoreFooter];
    }
    return self;
}

- (void) showLayer:(BOOL)show {
    menu.enabled = show;
    self.visible = show;
    if(show) {
        [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
    } else {
        [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    }
}

- (void) resumeGame {
    [(GameLayer *)self.parent pauseGame:NO];
}

- (void) restartGame {
    [(GameLayer *)self.parent restartGame];
}

- (void) openOptions {
    NSLog(@"options");
}

- (void) quitToMain {
    [(GameLayer *)self.parent quitToMain];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

@end
