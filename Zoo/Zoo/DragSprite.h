//
//  DragSprite.h
//  Sprite class for all the animals in game
//

#import "cocos2d.h" //cocos2d library for sprite class
#import "GameManager.h" //game singleton

typedef enum {
    SpriteTypeLion = 1,
    SpriteTypeElephant,
    SpriteTypeHippo,
    SpriteTypePenguin,
    SpriteTypePig,
    SpriteTypeDoublePoints,
    SpriteTypeNoPigs,
    SpriteTypePlusLife,
    SpriteTypeFreeze
} SpriteType;

//touch delegate used to identify touches on sprite
@interface DragSprite : CCSprite <CCTargetedTouchDelegate> {

	CGPoint whereTouch; //initial pick up location
    CCAction *blink; //store the blink action for the sprite
    CCAction *flail; //store the flail action for the sprite
    CCSprite *shadow;
    GameManager *gameManager; //access to singleton
    NSInteger age;

}

/*
Sprite Spawn Frequency:
Hippo 220/1000
Lion 220/1000
Elephant 220/1000
Penguin 220/1000
Pig 105/1000
Double Points 5/1000
No Pigs 5/1000
Plus Life 0/1000
Freeze 5/1000
*/
-(BOOL) isPointOnSprite:(CGPoint)touch;
-(void) removeMe;
-(void) rememberPosition;
-(void) resumeMoveSprite;
-(CGFloat) powerupFunction;
-(void) updateSpeed;
-(void) moveSprite:(BOOL)resume;
@property(strong) NSNumber* side;
@property(strong) NSValue* currentPosition;
@property(strong) CCAction* blink, *flail;
@property (nonatomic,assign) SpriteType type;

@end
