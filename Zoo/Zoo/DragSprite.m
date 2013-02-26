#import "DragSprite.h"
#import "GameLayer.h"

#define IS_IPHONE_5 ([UIScreen mainScreen].bounds.size.height == 568.0)

@implementation DragSprite
@synthesize type, side, blink, flail, currentPosition;

//initialization of sprite
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect{
   if((self=[super initWithTexture:texture rect:rect])){
            //make sure touches are handled by the sprite. swallows touch so only one animal per touchpoint!
            [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
       
            //initialize the singleton instance
            sharedSingleton = [Singleton sharedInstance];
       
            age = 1;
   }
   return self;
}

//check that the sprite is being touched
-(BOOL) isTouchOnSprite:(CGPoint)touch{
	if(CGRectContainsPoint(self.boundingBox, touch))
		return YES;
	else return NO;
}

//touch start handling function - called on every touch
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //grab current touchpoint and convert to gl format
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    //if sprite is being touched, save current location, make the sprite pop out and flail
	if([self isTouchOnSprite:touchPoint]){
		whereTouch=ccpSub(self.position, touchPoint);
        self.scale = 1.2;
        [self.parent reorderChild:self z:2];
        [self stopAllActions];
        [self flailCurrentSprite];
        [self showShadow:YES];
		return YES;
	}
    
	return NO;
}

//touch move handling function 
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{

    //grab current touchpoint and convert to gl format
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    //move the sprite to where the user is dragging it
	self.position = ccpAdd(touchPoint,whereTouch);
	
}

//touch end handling function
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if(![(GameLayer *)self.parent gameState]) { return;}

    //stop the sprite from flailing and stop sprite from popping
    [self stopAllActions];
    [self blinkCurrentSprite];
    self.scale = 1;
    [self.parent reorderChild:self z:1];
    [self showShadow:NO];
    
    //check intersection with boxes FIX THIS - IT CHECKS ALL OF THEM 
    [self.parent respondsToSelector:@selector(checkIntersect)];
    [self closest]; // find the closest point on the conveyor belt and save it to currentPosition
    
    //grab destination
    NSValue* point = currentPosition; // NSValue* point = [self performSelector:@selector(currentPosition)];
    //smoothly move to destination
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:0.2 position:[point CGPointValue]];
    //start moving the sprite again
    CCCallFunc* resumeMove = [CCCallFunc actionWithTarget:self selector:@selector(resumeMoveSprite)];
    //run action
    if([sharedSingleton frozenPowerupActivated]){
        [self runAction:[CCSequence actions:moveTo, nil]];
    } else {
        [self runAction:[CCSequence actions:moveTo, resumeMove, nil]];
    }
    //checkIntersect again
    [self.parent performSelector:@selector(checkIntersect)];
}

// find the closest point on the conveyor belt and save it to currentPosition
- (void) closest{
    double distance = DBL_MAX;
    NSValue* point;
    
    //all of the bezier points that the animals follow
    NSMutableArray *bezierArray = [sharedSingleton bezierArray];
    
    //iterate through every point to determine the optimal point
    for(NSValue* val in bezierArray){
        double distanceApart = ccpDistance([val CGPointValue], self.position);
        if(distance>distanceApart){
            distance = distanceApart;
            point = val;
        }
    }
    
    //save optimal point
    self.currentPosition = point;
}

- (void) resumeMoveSprite{
    [self moveSprite:YES];
}

- (void) moveSprite:(BOOL)resume{
    //set initial position and declare arrays
    CGPoint savedPoint;
    int flag = 0;
    if(!resume) {
        if(IS_IPHONE_5){
            self.position = ccp(-10,83);
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.position = ccp(-10, 83);
        } else {
            self.position = ccp(-10, 199.199997);
        }
        savedPoint = self.position;
        flag = 1;
    } else {
        savedPoint = [self.currentPosition CGPointValue];
    }
    NSMutableArray* moveArray = [NSMutableArray array];
    NSMutableArray* bezierArray = [sharedSingleton bezierArray];
    
    //move animal to each point smoothly
    //iterate through every point until getting to current spot then add to actions array
    for(NSValue* val in bezierArray){
        if(flag == 1){
            CGPoint p = [val CGPointValue];
            float speed = [[[sharedSingleton gameSpeed] objectAtIndex:0] floatValue];
            float distanceApart = ccpDistance(savedPoint,p);
            float duration = distanceApart/(200*speed);
            CCMoveTo* moveTo = [CCMoveTo actionWithDuration:duration position:p];
            [moveArray addObject:moveTo];
            CCCallFunc* rememberPosition = [CCCallFunc actionWithTarget:self selector:@selector(rememberPosition)];
            [moveArray addObject:rememberPosition];
            savedPoint = p;
        } else if([val isEqual:self.currentPosition]){
            flag = 1;
        }
    }

    if([self.type intValue] < 5){
        //lose life if animal is dead
        CCCallFunc* loseLife = [CCCallFunc actionWithTarget:self selector:@selector(loseLife)];
        [moveArray addObject:loseLife];
    }
    if([self.type intValue] > 5){
        //powerup gets reborn at end of belt
        CCCallFunc* resetPosition = [CCCallFunc actionWithTarget:self selector:@selector(resetPosition)];
        [moveArray addObject:resetPosition];
    } else {
        //animal dies at end of belt
        CCCallFunc* removeSprite = [CCCallFunc actionWithTarget:self selector:@selector(removeMe)];
        [moveArray addObject:removeSprite];
    }

    //execute sequence
    CCSequence* moveSeq = [CCSequence actionWithArray:moveArray];
    [self runAction:moveSeq];
    
}

//save current sprite position in currentPosition variable
-(void) rememberPosition{
    [self setCurrentPosition:[NSValue valueWithCGPoint:self.position]];
}

- (void) resetPosition {
    if (age > 3) {
        [self removeMe];
        return;
    }
    age++;
    if(IS_IPHONE_5){
        self.position = ccp(-10,83);
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.position = ccp(-10, 83);
    } else {
        self.position = ccp(-10, 199.199997);
    }
    [self updateSpeed];
}

//make sprite flail
-(void) flailCurrentSprite{
    if(self.flail){
        [self runAction:flail];
    }
}

//make sprite blink
-(void) blinkCurrentSprite{
    if(self.blink){
        [self runAction:blink];
    }
}

-(CGFloat) powerupFunction{
//hippo powerup: double points
    if([self.type intValue] == 6){
        [sharedSingleton setDoublePointPowerupActivated:YES];
        [self unschedule:@selector(setNoDoublePoints)];
        [self scheduleOnce:@selector(setNoDoublePoints) delay:5.0f];
        return 5.0f;
    }
//lion powerup: no pigs for 10 seconds
    if([self.type intValue] == 7){
        [self.parent performSelector:@selector(setPigsNotAllowed:) withObject:[NSNumber numberWithBool:YES]];
        [self unschedule:@selector(setPigsAllowed)];
        [self scheduleOnce:@selector(setPigsAllowed) delay:10.0f];
        return 10.0f;
    }
//elephant powerup: plus life
    if([self.type intValue] == 8){
        [self gainLife];
        return 0.15f;
    }
//penguin powerup: freeze belt for 5 secs
    if([self.type intValue] == 9){
        [self.parent performSelector:@selector(stopMovingBelt) withObject:self];
        [self.parent unschedule:@selector(startMovingBelt)];
        [self.parent scheduleOnce:@selector(startMovingBelt) delay:5.0f];
        return 5.0f;
    }
    return 0.0f;
}

- (void) setPigsAllowed {
    [self.parent performSelector:@selector(setPigsNotAllowed:) withObject:[NSNumber numberWithBool:NO]];
}

- (void) setNoDoublePoints {
    [sharedSingleton setDoublePointPowerupActivated:NO];
}

- (void) updateSpeed {
    if(self.scale != 1) { return;}
    [self stopAllActions];
    [self blinkCurrentSprite];
    [self closest];
    [self resumeMoveSprite];
}

//remove sprite's touch control
-(void) onExit{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

//cleanup sprite by removing from singleton list
-(void) removeMe{
    [[sharedSingleton animals] removeObject:self];
    [self.parent removeChild:self cleanup:YES];
}

//calls the parent lose life
-(void) loseLife{
    [self.parent performSelector:@selector(loseLife)];
}

//calls the parent lose life
-(void) gainLife{
    [self.parent performSelector:@selector(gainLife)];
}

- (void) showShadow:(BOOL)enabled {
    if (enabled) {
        shadow = [CCSprite spriteWithSpriteFrame:[self displayFrame]];
        [self addChild:shadow z:-1];
        shadow.ignoreAnchorPointForPosition = YES;
        shadow.color = ccBLACK;
        shadow.opacity = 100;
        shadow.position = ccp(-5,-5);
    } else {
        [self removeChild:shadow cleanup:YES];
    }
}

@end
