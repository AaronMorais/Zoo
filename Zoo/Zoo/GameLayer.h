//
//  GameLayer.h
//  Zoo
//
//  Created by Aaron Morais on 12-06-17.
//  Copyright TapA Studios 2012. All rights reserved.
//


#import "cocos2d.h"
#import "DragSprite.h"
#import "BoxSprite.h"
#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "RadialGradientLayer.h"
#import "GameOverlayLayer.h"

@class DragSprite;
@interface GameLayer : CCLayerColor <DragSpriteProtocol>{
        int countDownCounter;
        CCSprite* countDownSprite;
        RadialGradientLayer* fadeLayer;
        GameOverlayLayer* pauseLayer;
        CGSize winSize;
        CCSprite* lifeSprite;
        CCSprite* pause;
        CCLabelTTF* score;
        NSInteger currentScore;
        NSInteger lifeCount;
        CCSequence* soundSequence;
        SimpleAudioEngine *sae;
        GameManager* gameManager;
}

@property (nonatomic) NSInteger  currentScore;
@property (nonatomic,assign) BOOL gameHasStarted;
@property (nonatomic,assign) BOOL doublePointPowerupEnabled;

+ (CCScene *) scene;
- (void) checkIntersect;
- (void) gainLife;
- (void) loseLife;
- (void) startMovingBelt;
- (void) stopMovingBelt;
- (void) pauseGame:(BOOL)paused;
- (void) restartGame;
- (void) quitToMain;

- (void)setDoublePointPowerup:(NSNumber *)powerup;

@end
