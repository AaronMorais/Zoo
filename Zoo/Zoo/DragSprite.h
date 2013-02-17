//
//  DragSprite.h
//  Sprite class for all the animals in game
//

#import "cocos2d.h" //cocos2d library for sprite class
#import "Singleton.h" //game singleton

//touch delegate used to identify touches on sprite
@interface DragSprite : CCSprite <CCTargetedTouchDelegate> {

	CGPoint whereTouch; //initial pick up location
    NSNumber* type; //numeric type of animal; currently 1-4
    NSNumber* side; //numeric side which the animal will spawn; currently 1-2; UNUSED!
    CCAction* blink; //store the blink action for the sprite
    CCAction* flail; //store the flail action for the sprite
    CCSprite* shadow;
    Singleton* sharedSingleton; //access to singleton

}

-(BOOL) isTouchOnSprite:(CGPoint)touch;
-(void) removeMe;
-(void) rememberPosition;
-(void) resumeMoveSprite;
-(BOOL) powerupFunction;
-(void) updateSpeed;
-(void) moveSprite;
@property(strong) NSNumber* type, * side;
@property(strong) NSValue* currentPosition;
@property(strong) CCAction* blink, *flail;

@end
