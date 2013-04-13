//
//  GameLayer.h
//  Zoo
//
//  Created by Aaron Morais on 12-06-17.
//  Copyright TapA Studios 2012. All rights reserved.
//


#import <GameKit/GameKit.h> //gamecenter libraries  *****figure this out later!!
//@interface GameLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "DragSprite.h"
#import "BoxSprite.h"
#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "RadialGradientLayer.h"
#import "GameOverlayLayer.h"

@class DragSprite;
@interface GameLayer : CCLayerColor{
        int countDownCounter;
        CCSprite* countDownSprite;
        RadialGradientLayer* fadeLayer;
        RadialGradientLayer* powerupLayer;
        GameOverlayLayer* pauseLayer;
        CGSize winSize;
        CCSprite* lifeSprite;
        CCSprite* pause;
        CCSprite* beltSprite;
        CCLabelTTF* score;
        NSMutableArray* boxOrder;
        NSMutableArray* boxes;
        NSInteger currentScore;
        NSInteger lifeCount;
        NSInteger animalCount;
        CCSequence* soundSequence;
        SimpleAudioEngine *sae;
        CCAnimation* pbAnim;
        CCAnimation* pfAnim;
        CCAnimation* ebAnim;
        CCAnimation* efAnim;
        CCAnimation* hbAnim;
        CCAnimation* hfAnim;
        CCAnimation* lbAnim;
        CCAnimation* lfAnim;
        CCAnimation* pigbAnim;
        CCAnimation* pigfAnim;
        CCAction* beltAction;
        CCAction* _pBoxAction;
        CCAction* _eBoxAction;
        CCAction* _hBoxAction;
        CCAction* _lBoxAction;
        CCAction* pFlailAction;
        CCAction* eFlailAction;
        CCAction* hFlailAction;
        CCAction* lFlailAction;
        CCAction* pigFlailAction;
        CCAction* pBlinkAction;
        CCAction* eBlinkAction;
        CCAction* hBlinkAction;
        CCAction* lBlinkAction;
        CCAction* pigBlinkAction;
        GameManager* sharedSingleton;
}

@property (nonatomic,strong) CCAction *pBoxAction;
@property (nonatomic,strong) CCAction *eBoxAction;
@property (nonatomic,strong) CCAction *hBoxAction;
@property (nonatomic,strong) CCAction *lBoxAction;
@property (nonatomic,strong) CCAction *pFlailAction,* eFlailAction,* hFlailAction,* lFlailAction;
@property (nonatomic,strong) CCAction *pBlinkAction,* eBlinkAction,* hBlinkAction,* lBlinkAction;
@property (nonatomic) NSMutableArray *animals,* boxes;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic,assign) BOOL pigsNotAllowed;
@property (nonatomic,assign) BOOL gameState;
@property (nonatomic,assign) BOOL doublePointPowerupActivated;

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;
- (void) checkIntersect;
- (void) gainLife;
- (void) loseLife;
- (void) setPigsAllowed;
- (void) setNoDoublePoints;
- (void) startMovingBelt;
- (void) stopMovingBelt;
- (void) pauseGame:(BOOL)paused;
- (void) restartGame;
- (void) quitToMain;

@end
