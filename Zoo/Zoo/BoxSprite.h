//
//  BoxSprite.h
//  

#import "cocos2d.h" //cocos2d library for sprite class
#import "DragSprite.h"

//Extends the base sprite class
@interface BoxSprite : CCSprite

- (id) initWithType:(SpriteType)type;
- (void) swallow;
- (void) boxTapped;
- (void) updateStrokes;
- (void) animate;

@property NSInteger currentCapacity, originalCapacity, swallowed;

@end
