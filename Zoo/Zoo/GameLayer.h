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
#import "Singleton.h"
#import "RadialGradientLayer.h"

@class DragSprite;
@interface GameLayer : CCLayerColor{
        int countDownCounter;
        CCSprite* countDownSprite;
        RadialGradientLayer* fadeLayer;
        CGSize winSize;
        CCSprite* lifeSprite;
        CCSprite* pause;
        CCSprite* beltSprite;
        CCLabelTTF* score;
        bool gameState;
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
        Singleton* sharedSingleton;
}

@property (nonatomic,retain) CCAction *pBoxAction;
@property (nonatomic,retain) CCAction *eBoxAction;
@property (nonatomic,retain) CCAction *hBoxAction;
@property (nonatomic,retain) CCAction *lBoxAction;
@property (nonatomic,retain) CCAction *pFlailAction,* eFlailAction,* hFlailAction,* lFlailAction;
@property (nonatomic,retain) CCAction *pBlinkAction,* eBlinkAction,* hBlinkAction,* lBlinkAction;
@property (nonatomic,assign) NSMutableArray *animals,* boxes;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic,assign) BOOL pigsNotAllowed;

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;
-(void) checkIntersect;
-(void) gainLife;
-(void) loseLife;
-(void) halfSpeed;
-(void) fullSpeed;
-(void) startMovingBelt;
-(void) stopMovingBelt;

@end
