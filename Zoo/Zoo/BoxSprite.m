//
//  BoxSprite.m
//  Sprite for the boxes in game
//

#import "BoxSprite.h"
#import "ActionManager.h"
#import "GameLayer.h"

@interface BoxSprite()
@property (nonatomic,strong) CCLabelTTF *currentNumber; //label of current capacity
@property (nonatomic,strong) CCRenderTexture *currentStroke; //black outline of label
@property (nonatomic,assign) SpriteType type;
@end

@implementation BoxSprite

+(NSString *) initialSpriteNameForType:(SpriteType)type {
    switch(type){
        case SpriteTypePenguin:
            return @"penguinbox1.png";
        case SpriteTypeElephant:
            return @"elephantbox1.png";
        case SpriteTypeHippo:
            return @"hippobox1.png";
        case SpriteTypeLion:
            return @"lionbox1.png";
        default:
            return @"";
    }
}

-(id) initWithType:(SpriteType)type {
    NSString *fileName = [BoxSprite initialSpriteNameForType:type];
    self = [BoxSprite spriteWithSpriteFrameName:fileName];
    if(self) {
        self.type = type;
        [self newNumber];
        self.currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",self.currentCapacity] fontName:@"Aharoni" fontSize:80];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        if(type == SpriteTypePenguin) {
            [self.currentNumber setColor:ccWHITE];
            self.position = ccp(winSize.width/2 - (.1 * winSize.width), winSize.height/2 - (.075 * winSize.height));
        } else if(type == SpriteTypeElephant) {
            [self.currentNumber setColor:ccc3(129,137,137)];
            self.position = ccp(winSize.width/2 + (.1 * winSize.width), winSize.height/2 - (.075 * winSize.height));
        } else if(type == SpriteTypeHippo) {
            [self.currentNumber setColor:ccc3(225,105,180)];
            self.position = ccp(winSize.width/2 - (.1 * winSize.width), winSize.height/2 - (.34 * winSize.height));
        } else if(type == SpriteTypeLion) {
            [self.currentNumber setColor:ccYELLOW];
            self.position = ccp(winSize.width/2 + (.1 * winSize.width), winSize.height/2 - (.34 * winSize.height));
        }
        //position the number with offset
        self.currentNumber.position = ccp(self.position.x - (.02 * winSize.width),self.position.y);
    }
    return self;
}

//provide the box with the correct animation and run it
//animations are not stored in the boxes, they're assigned when needed
- (void)animate {
    if(self.type == SpriteTypePenguin){
        [self runAction:[[ActionManager sharedInstance] boxActions][0]];
    } else if(self.type == SpriteTypeElephant){
        [self runAction:[[ActionManager sharedInstance] boxActions][1]];
    } else if(self.type == SpriteTypeHippo){
        [self runAction:[[ActionManager sharedInstance] boxActions][2]];
    } else if(self.type == SpriteTypeLion){
        [self runAction:[[ActionManager sharedInstance] boxActions][3]];
    }
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
    [self updateStrokes];
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
}

-(void) boxTapped {
    [self newNumber];
    [self updateStrokes];
}

//remove current stroke and refresh strokes
- (void) updateStrokes{
    self.currentNumber.string = [NSString stringWithFormat:@"%d",self.currentCapacity];
    //remove current number and stroke
    //removing and adding number ensures no stroke overlap!
    [self.parent removeChild:self.currentNumber cleanup:YES];
    [self.parent removeChild:self.currentStroke cleanup:YES];
    
    //generate new stroke for number
    CCRenderTexture* stroke = [self createStrokeOnLabel:self.currentNumber WithSize:2];
    self.currentStroke = stroke;
    
    //add stroke and number back
    [self.parent addChild:self.currentStroke z:ElementLevelBoxNumber];
    [self.parent addChild:self.currentNumber z:ElementLevelBoxNumber];
}

//create the outline around the number, returns a texture
-(CCRenderTexture*)createStrokeOnLabel:(CCLabelTTF*)label WithSize:(float) size{
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
