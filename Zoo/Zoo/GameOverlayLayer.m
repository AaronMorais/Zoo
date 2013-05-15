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
    CGSize _winSize;
    CCLayerColor *_fadeLayer;
    CCLabelTTF *_highScoreHeader;
    CCLabelTTF *_highScoreFooter;
    CCLabelTTF *_userScoreHeader;
    CCLabelTTF *_userScoreFooter;
    GameManager *_gameManager;
    CCMenu *_menu;
}

- (id)init {
    self = [super init];
    if (self) {
        _gameManager = [GameManager sharedInstance];
        _winSize = [[CCDirector sharedDirector] winSize];
        
        _fadeLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [_fadeLayer setOpacity:175];
        [self addChild:_fadeLayer];
    }
    return self;
}

- (id)initAsPauseMenu {
    self = [self init];
    if (self) {        
        _highScoreHeader = [[CCLabelTTF alloc] initWithString:@"score to beat:" fontName:@"Aharoni" fontSize:55.0f];
        _highScoreHeader.ignoreAnchorPointForPosition = YES;
        _highScoreHeader.position = ccp(_winSize.width * 0.125, _winSize.height * 0.72);
        [self addChild:_highScoreHeader];
        
        _highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[_gameManager getHighScore]] fontName:@"Aharoni" fontSize:70.0f];
        _highScoreFooter.ignoreAnchorPointForPosition = YES;
        CGSize hsfSize = [_highScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:70.0f]];
        _highScoreFooter.position = ccp(_winSize.width * 0.88 - hsfSize.width, _winSize.height * 0.55);
        [self addChild:_highScoreFooter];
        
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
        _menu = [CCMenu menuWithItems:resumeMenuItem, restartMenuItem, optionsMenuItem, quitMenuItem, nil];
        [_menu alignItemsHorizontallyWithPadding:0.0f];
        _menu.position = ccp(_winSize.width/2, 95);
        
        // add the menu to your scene
        [self addChild:_menu];
        _menu.enabled = NO;
    }
    return self;
}

- (id)initAsGameOver:(int)score {
    self = [self init];
    if (self) {
        _userScoreHeader = [[CCLabelTTF alloc] initWithString:@"your score:" fontName:@"Aharoni" fontSize:40.0f];
        _userScoreHeader.ignoreAnchorPointForPosition = YES;
        _userScoreHeader.position = ccp(_winSize.width * 0.125, _winSize.height * 0.63);
        [self addChild:_userScoreHeader];
        
        _userScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Aharoni" fontSize:55.0f];
        _userScoreFooter.ignoreAnchorPointForPosition = YES;
        [_userScoreFooter setHorizontalAlignment:kCCTextAlignmentRight];
        _userScoreFooter.anchorPoint = ccp(0,0.5);
        CGSize ysfSize = [_userScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:55.0f]];
        _userScoreFooter.position = ccp(_winSize.width * 0.88 - ysfSize.width, _winSize.height * 0.51);
        [self addChild:_userScoreFooter];
    
        _highScoreHeader = [[CCLabelTTF alloc] initWithString:@"highscore:" fontName:@"Aharoni" fontSize:40.0f];
        _highScoreHeader.ignoreAnchorPointForPosition = YES;
        _highScoreHeader.position = ccp(_winSize.width * 0.125, _winSize.height * 0.42);
        [self addChild:_highScoreHeader];
        
        _highScoreFooter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",[_gameManager getHighScore]] fontName:@"Aharoni" fontSize:55.0f];
        _highScoreFooter.ignoreAnchorPointForPosition = YES;
        CGSize hsfSize = [_highScoreFooter.string sizeWithFont:[UIFont fontWithName:@"Aharoni" size:55.0f]];
        _highScoreFooter.position = ccp(_winSize.width * 0.88 - hsfSize.width, _winSize.height * 0.30);
        [self addChild:_highScoreFooter];
        
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
        _menu = [CCMenu menuWithItems:restartMenuItem, optionsMenuItem, quitMenuItem, nil];
        [_menu alignItemsHorizontallyWithPadding:0.0f];
        _menu.position = ccp(_winSize.width/2, 55);
        
        // add the menu to your scene
        [self addChild:_menu];
        _menu.enabled = NO;
    }
    return self;
}

- (void) showLayer:(BOOL)show {
    _menu.enabled = show;
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
