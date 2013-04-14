//
//  PauseLayer.m
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "GameOverlayLayer.h"
#import "MenuLayer.h"
#import "GameManager.h"
#import "GameLayer.h"

@implementation GameOverlayLayer {
    CGSize winSize;
    CCLayerColor *fadeLayer;
    CCLabelTTF *highScoreHeader;
    CCLabelTTF *highScoreFooter;
    CCLabelTTF *yourScoreHeader;
    CCLabelTTF *yourScoreFooter;
    GameManager *gameManager;
    CCMenu * menu;
}

- (id)init {
    self = [super init];
    if (self) {
        gameManager = [GameManager sharedInstance];
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
        
        highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[gameManager getHighScore]] fontName:@"Aharoni" fontSize:70.0f];
        highScoreFooter.ignoreAnchorPointForPosition = YES;
        CGSize hsfSize = [highScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:70.0f]];
        highScoreFooter.position = ccp(winSize.width * 0.88 - hsfSize.width, winSize.height * 0.55);
        [self addChild:highScoreFooter];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/mainMenu.plist"];
        CCSpriteBatchNode* mainSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/mainMenu.png"];
        [self addChild:mainSpriteSheet];

        CCMenuItemImage * resumeMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/rsme.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/rsme.png"]
                                        target:self
                                        selector:@selector(resumeGame)];
                
        CCMenuItemImage * restartMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/rstrt.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/rstrt.png"]
                                        target:self
                                        selector:@selector(restartGame)];
        
        CCMenuItemImage * optionsMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/optns.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/optns.png"]
                                        target:self
                                        selector:@selector(openOptions)];
        
        CCMenuItemImage * quitMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/quit.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/quit.png"]
                                        target:self
                                        selector:@selector(quitToMain)];
        
        // Create a menu and add your menu items to it
        menu = [CCMenu menuWithItems:resumeMenuItem, restartMenuItem, optionsMenuItem, quitMenuItem, nil];
        [menu alignItemsHorizontallyWithPadding:0.0f];
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
        yourScoreHeader = [[CCLabelTTF alloc] initWithString:@"your score:" fontName:@"Aharoni" fontSize:40.0f];
        yourScoreHeader.ignoreAnchorPointForPosition = YES;
        yourScoreHeader.position = ccp(winSize.width * 0.125, winSize.height * 0.63);
        [self addChild:yourScoreHeader];
        
        yourScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Aharoni" fontSize:55.0f];
        yourScoreFooter.ignoreAnchorPointForPosition = YES;
        [yourScoreFooter setHorizontalAlignment:kCCTextAlignmentRight];
        yourScoreFooter.anchorPoint = ccp(0,0.5);
        CGSize ysfSize = [yourScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:55.0f]];
        yourScoreFooter.position = ccp(winSize.width * 0.88 - ysfSize.width, winSize.height * 0.51);
        [self addChild:yourScoreFooter];
    
        highScoreHeader = [[CCLabelTTF alloc] initWithString:@"highscore:" fontName:@"Aharoni" fontSize:40.0f];
        highScoreHeader.ignoreAnchorPointForPosition = YES;
        highScoreHeader.position = ccp(winSize.width * 0.125, winSize.height * 0.42);
        [self addChild:highScoreHeader];
        
        highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[gameManager getHighScore]] fontName:@"Aharoni" fontSize:55.0f];
        highScoreFooter.ignoreAnchorPointForPosition = YES;
        CGSize hsfSize = [highScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:55.0f]];
        highScoreFooter.position = ccp(winSize.width * 0.88 - hsfSize.width, winSize.height * 0.30);
        [self addChild:highScoreFooter];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/mainMenu.plist"];
        CCSpriteBatchNode* mainSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/mainMenu.png"];
        [self addChild:mainSpriteSheet];

        
        CCMenuItemImage * restartMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/pa.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/pa.png"]
                                        target:self
                                        selector:@selector(restartGame)];
        
        CCMenuItemImage * optionsMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/optns.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/optns.png"]
                                        target:self
                                        selector:@selector(openOptions)];
        
        CCMenuItemImage * quitMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithFile:@"assets/buttons/quit.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"assets/buttons/quit.png"]
                                        target:self
                                        selector:@selector(quitToMain)];
        
        
        // Create a menu and add your menu items to it
        menu = [CCMenu menuWithItems:restartMenuItem, optionsMenuItem, quitMenuItem, nil];
        [menu alignItemsHorizontallyWithPadding:0.0f];
        menu.position = ccp(winSize.width/2, 55);
        
        // add the menu to your scene
        [self addChild:menu];
        menu.enabled = NO;
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
    [self showLayer:NO];
    [(GameLayer *)self.parent pauseGame:NO];
}

- (void) restartGame {
    [self showLayer:NO];
    [(GameLayer *)self.parent restartGame];
}

- (void) openOptions {
    NSLog(@"options");
}

- (void) quitToMain {
    [self showLayer:NO];
    [(GameLayer *)self.parent quitToMain];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

@end
