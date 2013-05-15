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
    SpriteTypePlusLife,
    SpriteTypeFreeze
} SpriteType;

@protocol DragSpriteProtocol
- (void)dragSpriteRemoved;
@end

//touch delegate used to identify touches on sprite
@interface DragSprite : CCSprite <CCTargetedTouchDelegate> 

-(id) initWithType:(SpriteType)type;
-(BOOL) isPointOnSprite:(CGPoint)touch;
-(void) removeMe;
-(void) rememberPosition;
-(void) resumeMoveSprite;
-(CGFloat) powerupFunction;
-(void) updateSpeed;
-(void) moveSpriteIsResuming:(BOOL)resume;

@property (nonatomic, strong) id <DragSpriteProtocol> delegate;
@property (nonatomic,assign) SpriteType type;

@end
