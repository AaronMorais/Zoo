#import "DragSprite.h"
#import "GameLayer.h"

@implementation DragSprite
@synthesize type, side, blink, flail, currentPosition;

//initialization of sprite
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect{
   if((self=[super initWithTexture:texture rect:rect])){
            //make sure touches are handled by the sprite. swallows touch so only one animal per touchpoint!
            [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
       
            //initialize the singleton instance
            sharedSingleton = [Singleton sharedInstance];
       
            //make sure the singleton does not get removed
            [sharedSingleton retain];
       
            //sprite moves as soon as it is initializes
//            [self moveSprite]; removed because .type is not set on init
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
        [self stopAllActions];
        [self flailCurrentSprite];
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
    //stop the sprite from flailing and stop sprite from popping
    [self stopAllActions];
    [self blinkCurrentSprite];
    self.scale = 1;
    
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
    NSMutableArray *moveArray = [NSMutableArray array];
    NSMutableArray *bezierArray = [sharedSingleton bezierArray];
    int flag = 0;
    CGPoint savedPoint = [self.currentPosition CGPointValue];
    
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
        }
        if([val isEqual:self.currentPosition]){
            flag = 1;
        }
    }
    if([self.type intValue] != 5){
        CCCallFunc* loseLife = [CCCallFunc actionWithTarget:self selector:@selector(loseLife)];
        [moveArray addObject:loseLife];
    }
    
    CCCallFunc* removeSprite = [CCCallFunc actionWithTarget:self selector:@selector(removeMe)];
    [moveArray addObject:removeSprite];
    
    CCSequence* moveSeq = [CCSequence actionWithArray:moveArray];
    [self runAction:moveSeq];
}

- (void) moveSprite{
    //set initial position and declare arrays
    self.position = ccp(6, 83);
    NSMutableArray* moveArray = [NSMutableArray array];
    NSMutableArray* bezierArray = [sharedSingleton bezierArray];
    CGPoint savedPoint = ccp(6,83);
    
    //move animal to each point smoothly
    for(NSValue* val in bezierArray){
        CGPoint p = [val CGPointValue];
        float speed = [[[sharedSingleton gameSpeed] objectAtIndex:0] floatValue];
        float distanceApart = ccpDistance(savedPoint,p);
        float duration = distanceApart/(200*speed);
        CCMoveTo* moveTo = [CCMoveTo actionWithDuration:duration position:p];
        [moveArray addObject:moveTo];
        CCCallFunc* rememberPosition = [CCCallFunc actionWithTarget:self selector:@selector(rememberPosition)];
        [moveArray addObject:rememberPosition];
        savedPoint = p;
    }
    if([self.type intValue] != 5){
        //lose life if animal is dead
        CCCallFunc* loseLife = [CCCallFunc actionWithTarget:self selector:@selector(loseLife)];
        [moveArray addObject:loseLife];
    }
    
    //animal dies at end of belt
    CCCallFunc* removeSprite = [CCCallFunc actionWithTarget:self selector:@selector(removeMe)];
    [moveArray addObject:removeSprite];
    
    //execute sequence
    CCSequence* moveSeq = [CCSequence actionWithArray:moveArray];
    [self runAction:moveSeq];
    
}

//save current sprite position in currentPosition variable
-(void) rememberPosition{
    [self setCurrentPosition:[NSValue valueWithCGPoint:self.position]];
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

-(void) powerupFunction{
//hippo powerup: slow movement speed and spawn rate for 8 secs
    if([self.type intValue] == 6){
        if(![sharedSingleton slowdownPowerupActivated]) {
            [self.parent performSelector:@selector(halfSpeed)];
        }
        [self unschedule:@selector(fullSpeed)];
        [self.parent scheduleOnce:@selector(fullSpeed) delay:8.0f];
    }
//lion powerup: no pigs for 10 seconds
    if([self.type intValue] == 7){
        [self.parent performSelector:@selector(setPigsNotAllowed:) withObject:(id)YES];
        [self unschedule:@selector(setPigsAllowed)];
        [self scheduleOnce:@selector(setPigsAllowed) delay:10.0f];
    }
//elephant powerup: plus life
    if([self.type intValue] == 8){
        [self gainLife];
    }
//penguin powerup: freeze belt for 5 secs
    if([self.type intValue] == 9){
        [self.parent performSelector:@selector(stopMovingBelt) withObject:self];
        [self.parent unschedule:@selector(startMovingBelt)];
        [self.parent scheduleOnce:@selector(startMovingBelt) delay:5.0f];
    }
}

- (void) setPigsAllowed {
    [self.parent performSelector:@selector(setPigsNotAllowed:) withObject:(id)NO];
}

- (void) updateSpeed {
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

@end
