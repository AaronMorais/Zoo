//
//  BoxSprite.m
//  Sprite for the boxes in game
//

#import "BoxSprite.h"

@implementation BoxSprite
@synthesize originalCapacity, currentCapacity, swallowed, currentNumber, currentStroke;

//initialization of sprite
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect{
   if((self=[super initWithTexture:texture rect:rect])){
        //initialize the box number
        [self newNumber];
   }
   return self;
}

//whenever the box takes an animal it swallows
- (void)swallow{
    //increment swallowed and decrement current capacity
    self.swallowed++;
    self.currentCapacity--;
    //if less than 0, lose life, auto reset box
    if(self.currentCapacity == -1){
        //call lose life
        [self.parent performSelector:@selector(loseLife)];
        [self newNumber];
    }
    
    //update count on box
    [self stroke];
}

//init/reset the box with a new number
- (void)newNumber{
    //reset swallowed
    self.swallowed = 0;
    
    if(self.currentCapacity && self.currentCapacity >0) {
        self.currentCapacity +=1;
        self.originalCapacity +=1;
        if(self.currentCapacity > 5){
            self.currentCapacity = 5;
            self.originalCapacity = 5;
        }
    } else {
        //reset box at 0 to 5 rather than incrementing by 1
        NSNumber* new = [NSNumber numberWithInt:5];
        //set new number
        self.currentCapacity = [new integerValue];
        self.originalCapacity = [new integerValue];
    }
    
    //if the box had a number, reset its values
    if(self.currentNumber){
        [self stroke];
    }
}

//random number function
-(NSNumber*)randFunction:(int)numOne:(int)numTwo {
    int randomNumber = (arc4random() % ((numTwo+1)-numOne))+numOne;
    return [NSNumber numberWithInt:randomNumber];
}

//create initial strokes for number outline
-(void) firstStroke{
    CCRenderTexture* stroke = [self createStroke:currentNumber:2];
    self.currentStroke = stroke;
    [self.parent addChild:self.currentStroke];
}

//remove current stroke and refresh strokes
- (void) stroke{
    self.currentNumber.string = [NSString stringWithFormat:@"%d",self.currentCapacity];
    //remove current number and stroke
    //removing and adding number ensures no stroke overlap!
    [self.parent removeChild:currentNumber cleanup:YES];
    [self.parent removeChild:self.currentStroke cleanup:YES];
    
    //generate new stroke for number
    CCRenderTexture* stroke = [self createStroke:currentNumber:2];
    self.currentStroke = stroke;
    
    //add stroke and number back
    [self.parent addChild:self.currentStroke];
    [self.parent addChild:currentNumber];
}

//create the outline around the number, returns a texture
-(CCRenderTexture*)createStroke:(CCLabelTTF*)label:(float) size{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
	[label setColor:ccBLACK];
	[label setVisible:YES];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y + size);
	CGPoint positionOffset = ccp(label.texture.contentSize.width * label.anchorPoint.x - label.texture.contentSize.width/2,label.texture.contentSize.height * label.anchorPoint.y - label.texture.contentSize.height/2);
	CGPoint position = ccpSub(originalPos, positionOffset);

	[rt begin];
	for (int i=0; i<360; i+=30)
	{
		[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:position];
	return rt;
}

@end
