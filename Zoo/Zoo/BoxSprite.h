//
//  BoxSprite.h
//  

#import "cocos2d.h" //cocos2d library for sprite class

//Extends the base sprite class
@interface BoxSprite : CCSprite {
    NSInteger originalCapacity; //how many animals can fit in box
    NSInteger currentCapacity; //how many more animals can go in box
    NSInteger swallowed; //amount of animals inside of box
    CCLabelTTF* currentNumber; //label of current capacity
    CCRenderTexture* currentStroke; //black outline of label
}

-(void) swallow;
-(void) newNumber;
-(void) firstStroke;

@property NSInteger currentCapacity, originalCapacity, swallowed;
@property(strong) CCLabelTTF* currentNumber;
@property(strong) CCRenderTexture* currentStroke;

@end
