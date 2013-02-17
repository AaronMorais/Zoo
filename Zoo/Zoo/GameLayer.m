//
//  GameLayer.m
//  Zoo
//
//  Created by Aaron Morais on 12-06-17.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

/*
Randomness stats!
Hippo 205/1000
Lion 205/1000
Elephant 205/1000
Penguin 205/1000
Pig 100/1000
HP 15/1000
LP 30/1000
EP 5/1000
PP 30/1000*/

// Import the interfaces
#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "MenuLayer.h"
#import "ABGameKitHelper.h"

#pragma mark - GameLayer

// GameLayer implementation
@implementation GameLayer
@synthesize pBoxAction = _pBoxAction;
@synthesize eBoxAction = _eBoxAction;
@synthesize hBoxAction = _hBoxAction;
@synthesize lBoxAction = _lBoxAction;
@synthesize pFlailAction, lFlailAction, eFlailAction, hFlailAction, pBlinkAction, lBlinkAction, eBlinkAction, hBlinkAction, boxes,currentScore, pigsNotAllowed, gameState;

// Helper class method that creates a Scene with the GameLayer as the only child.
+(CCScene*) scene{
	// 'scene' is an autorelease object.
	CCScene* scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer* layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// on "init" you need to initialize your instance
-(id) init{
	// always call "super" init
	if((self=[super initWithColor:ccc4(0,0,0,255)]) ){
        //initialize touch handling
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        //load assets
        [self loadAssets];
        //start game
        countDownCounter = 5;
        [self countDown];
	}
	return self;
}

- (void) loadAssets{
    winSize = [[CCDirector sharedDirector] winSize];
    //add background image
    [self addBackgroundImage];
    //add score label
    [self addScoreLabel];
    [self addPauseLayer];
    //load sprite sheets
    [self loadSpriteSheets];
    //add pause button
    [self addPauseButton];
    //add lives
    [self addLivesSprite];
    //add animation frames and create actions
    [self loadAnimationFrames];
    //init box array
    boxes = [[NSMutableArray alloc]init];
    //init singleton
    sharedSingleton = [Singleton sharedInstance];
    [sharedSingleton resetSingleton];
    [self addBoxes];
}

- (void) addBackgroundImage{
    CCSprite* background = [CCSprite spriteWithFile:@"assets/playbkgd.png"];
    [self addChild:background];
    background.position = ccp(winSize.width/2, winSize.height/2);
}

- (void) addScoreLabel{
    score = [CCLabelTTF labelWithString:@"0" fontName:@"Aharoni" fontSize:50];
    [score setColor:ccc3(0,0,0)];
    [score setHorizontalAlignment:kCCTextAlignmentRight];
    [self addChild: score];
    score.anchorPoint = ccp(0,0.5);
    score.position =  ccp((.1 * winSize.width),winSize.height-(.065 * winSize.height));
}

- (void) addPauseLayer {
    pauseLayer = [[GameOverlayLayer alloc] initAsPauseMenu];
    [self addChild:pauseLayer z:6];
    [pauseLayer showLayer:NO];
}

- (void) loadSpriteSheets{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/four.plist"];
    CCSpriteBatchNode *animalSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/four.png"];
    [self addChild:animalSpriteSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/four2.plist"];
    CCSpriteBatchNode *animal2SpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/four2.png"];
    [self addChild:animal2SpriteSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/conbelt.plist"];
    CCSpriteBatchNode *beltSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/conbelt.png"];
    [self addChild:beltSpriteSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/HUD.plist"];
    CCSpriteBatchNode *hudSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/HUD.png"];
    [self addChild:hudSpriteSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/countdown.plist"];
    CCSpriteBatchNode *countdownSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"assets/countdown.png"];
    [self addChild:countdownSpriteSheet];
}

- (void) addPauseButton{
    pause = [CCSprite spriteWithSpriteFrameName:@"pausebutton.png"];
    [self addChild:pause];
    //FIX MAKE agnostic
    pause.position =  ccp((.046 * winSize.width),winSize.height-(.065 * winSize.height));
}

- (void) addLivesSprite{
    lifeSprite = [CCSprite spriteWithSpriteFrameName:@"3lives.png"];
    [self addChild:lifeSprite];
    lifeSprite.position =  ccp(winSize.width - (.125 * winSize.width) ,winSize.height-(.065 * winSize.height));
    lifeCount = 3;
}

//add animation frames and create actions
- (void) loadAnimationFrames{
    NSMutableArray *pbAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [pbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"penguinblink0%d.png", i]]];
    }
    for(int i = 10; i <= 31; i++) {
        [pbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"penguinblink%d.png", i]]];
    }
    pbAnim = [CCAnimation animationWithSpriteFrames:pbAnimFrames delay:0.08f];
    
    NSMutableArray *pfAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [pfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"penguinflail0%d.png", i]]];
    }
    for(int i = 10; i <= 51; i++) {
        [pfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"penguinflail%d.png", i]]];
    }
    pfAnim = [CCAnimation animationWithSpriteFrames:pfAnimFrames delay:0.05f];
    
    NSMutableArray *pboxAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [pboxAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"penguinbox%d.png", i]]];
    }
    CCAnimation *pboxAnim = [CCAnimation animationWithSpriteFrames:pboxAnimFrames delay:0.05f];
    
    NSMutableArray *eboxAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [eboxAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elephantbox%d.png", i]]];
    }
    CCAnimation *eboxAnim = [CCAnimation animationWithSpriteFrames:eboxAnimFrames delay:0.05f];
    
    NSMutableArray *hboxAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [hboxAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hippobox%d.png", i]]];
    }
    CCAnimation *hboxAnim = [CCAnimation animationWithSpriteFrames:hboxAnimFrames delay:0.05f];
    
    NSMutableArray *lboxAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [lboxAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lionbox%d.png", i]]];
    }
    CCAnimation *lboxAnim = [CCAnimation animationWithSpriteFrames:lboxAnimFrames delay:0.05f];
    
    NSMutableArray *beltAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [beltAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"conbelt0%d.png", i]]];
    }
    for(int i = 10; i <= 26; i++) {
        [beltAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"conbelt%d.png", i]]];
    }
    CCAnimation *beltAnim = [CCAnimation animationWithSpriteFrames:beltAnimFrames delay:0.15f];
    
    NSMutableArray *ebAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [ebAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elephantblink0%d.png", i]]];
    }
    for(int i = 10; i <= 36; i++) {
        [ebAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elephantblink%d.png", i]]];
    }
    ebAnim = [CCAnimation animationWithSpriteFrames:ebAnimFrames delay:0.1f];
    
    NSMutableArray *efAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [efAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elephantflail0%d.png", i]]];
    }
    for(int i = 10; i <= 52; i++) {
        [efAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elephantflail%d.png", i]]];
    }
    efAnim = [CCAnimation animationWithSpriteFrames:efAnimFrames delay:0.1f];
    
    NSMutableArray *hbAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [hbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hippoblink0%d.png", i]]];
    }
    for(int i = 10; i <= 32; i++) {
        [hbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hippoblink%d.png", i]]];
    }
    hbAnim = [CCAnimation animationWithSpriteFrames:hbAnimFrames delay:0.1f];
    
    NSMutableArray *hfAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [hfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hippoflail0%d.png", i]]];
    }
    for(int i = 10; i <= 52; i++) {
        [hfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hippoflail%d.png", i]]];
    }
    hfAnim = [CCAnimation animationWithSpriteFrames:hfAnimFrames delay:0.1f];
    
    NSMutableArray *lbAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [lbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lionblinking0%d.png", i]]];
    }
    for(int i = 10; i <= 32; i++) {
        [lbAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lionblinking%d.png", i]]];
    }
    lbAnim = [CCAnimation animationWithSpriteFrames:lbAnimFrames delay:0.1f];
    
    NSMutableArray *lfAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 9; i++) {
        [lfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lionflail0%d.png", i]]];
    }
    for(int i = 10; i <= 51; i++) {
        [lfAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lionflail%d.png", i]]];
    }
    lfAnim = [CCAnimation animationWithSpriteFrames:lfAnimFrames delay:0.1f];
    
    beltAction = [CCRepeatForever actionWithAction:
                            [CCAnimate actionWithAnimation:beltAnim]];
    self.pBoxAction = [CCAnimate actionWithAnimation:pboxAnim];
    self.eBoxAction = [CCAnimate actionWithAnimation:eboxAnim];
    self.hBoxAction = [CCAnimate actionWithAnimation:hboxAnim];
    self.lBoxAction = [CCAnimate actionWithAnimation:lboxAnim];
    
    beltSprite = [CCSprite spriteWithSpriteFrameName:@"conbelt01.png"];
    beltSprite.position = ccp(winSize.width/2, winSize.height/2 - (.06 * winSize.height));
    [self addChild:beltSprite];
    beltSprite.scale = CC_CONTENT_SCALE_FACTOR();
    pBlinkAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:pbAnim]];
    pFlailAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:pfAnim]];
    eBlinkAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:ebAnim]];
    eFlailAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:efAnim]];
    hBlinkAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:hbAnim]];
    hFlailAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:hfAnim]];
    lBlinkAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:lbAnim]];
    lFlailAction = [CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:lfAnim]];
}

#pragma mark Start Game
//start the game
- (void)startGame{
    gameState = true;
    [self startSounds];
    [beltSprite runAction:beltAction];
    [self schedule:@selector(addSprite) interval:1];
}

- (void)countDown{
    countDownCounter--;
    [[[CCDirector sharedDirector] touchDispatcher] setDispatchEvents:NO];
    if(countDownCounter == 4){
        fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,0) fadeIn:NO speed:2];
        [self addChild:fadeLayer z:1];
        [self schedule:@selector(countDown) interval:0.5];
    }else if(countDownCounter > 0){
        [self removeChild:countDownSprite cleanup:YES];
        NSString* path = [NSString stringWithFormat:@"%d.png",countDownCounter];
        countDownSprite = [CCSprite spriteWithSpriteFrameName:path];
        countDownSprite.position = ccp(winSize.width/2, winSize.height/2);
        countDownSprite.scale = 0.75;
        [self addChild:countDownSprite z:2];
        [self schedule:@selector(countDown) interval:1];
        [self countdownSound];
    }else if(countDownCounter == 0){
        [fadeLayer fadeAwayScheduler];
        [self scheduleOnce:@selector(removeFadeLayer) delay:2.0f];
        
        [self removeChild:countDownSprite cleanup:YES];
        countDownSprite = [CCSprite spriteWithSpriteFrameName:@"go!.png"];
        countDownSprite.position = ccp(winSize.width/2, winSize.height/2);
        countDownSprite.scale = 0.65;
        [self addChild:countDownSprite z:2];
        [self schedule:@selector(countDown) interval:0.5];
        [self countdownSound];
    }else if(countDownCounter == -1){
        [self startGame];
        [self removeChild:countDownSprite cleanup:YES];
        [self unschedule:@selector(countDown)];
        countDownCounter = 5;
        [[[CCDirector sharedDirector] touchDispatcher] setDispatchEvents:YES];
    }
}

- (void) removeFadeLayer {
    [self removeChild:fadeLayer cleanup:YES];
}

//create all boxes
- (void)addBoxes{
    [self generateOrder];
    [self assignBoxType:[boxOrder objectAtIndex:0]];
    [self assignBoxType:[boxOrder objectAtIndex:1]];
    [self assignBoxType:[boxOrder objectAtIndex:2]];
    [self assignBoxType:[boxOrder objectAtIndex:3]];
}

//create a box of given type
- (void)assignBoxType:(NSNumber*)type{
    //init box based on type
    BoxSprite* newBox;
    CCLabelTTF* currentNumber;
    if(type ==[NSNumber numberWithInt:1]){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"penguinbox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccWHITE];
    }
    if(type ==[NSNumber numberWithInt:2]){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"elephantbox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccc3(129,137,137)];
    }
    if(type ==[NSNumber numberWithInt:3]){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"hippobox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccc3(225,105,180)];
    }
    if(type ==[NSNumber numberWithInt:4]){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"lionbox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccYELLOW];
    }
    //depending on box, position it on screen
    //FIX THIS make it screen size agnostic
    if([boxes count] == 0){
        newBox.position = ccp(winSize.width/2 - (.1 * winSize.width), winSize.height/2 - (.075 * winSize.height));
    }
    if([boxes count] == 1){
        newBox.position = ccp(winSize.width/2 + (.1 * winSize.width), winSize.height/2 - (.075 * winSize.height));
    }
    if([boxes count] == 2){
        newBox.position = ccp(winSize.width/2 - (.1 * winSize.width), winSize.height/2 - (.34 * winSize.height));
    }
    if([boxes count] == 3){
        newBox.position = ccp(winSize.width/2 + (.1 * winSize.width), winSize.height/2 - (.34 * winSize.height));
    }
    //position the number with offset
    currentNumber.position = ccp(newBox.position.x - (.02 * winSize.width),newBox.position.y);
    //assign the object the label
    [newBox setCurrentNumber:currentNumber];
    //add box to layer
    [self addChild:newBox];
    //draw box stoke, add number
    [newBox firstStroke];
    [self addChild:currentNumber];
    //add boxes to box array
    [boxes addObject:newBox];
}

//generate the box order
- (void)generateOrder{
    boxOrder = [[NSMutableArray alloc] init];
    int count = 1;
    while(count <=4){
        NSNumber* randomNum = [self randFunction:1:4];
        if(![self numInArray:randomNum]){
            [boxOrder addObject:randomNum];
            count++;
        }
    }
}

//check if num is in array
- (bool)numInArray:(NSNumber*)checkNum{
    for(NSNumber*num in boxOrder){
        if(num == checkNum){
            return true;
        }
    }
    return false;
}

//add sprite to game
- (void)addSprite{
    NSNumber* nsType = [self randFunction:820:1000]; //randomly choose animal type
    int type = [nsType intValue];
    while(pigsNotAllowed && type > 820 && type < 920) {
        nsType = [self randFunction:820:1000];
        type = [nsType intValue];
    }
    NSNumber* side = [self randFunction:1:2]; //randomly choose animal side
    DragSprite* sprite; //init animal
    
    //assign the animal it's animations based on type
    if(type < 205){
        sprite = [DragSprite spriteWithSpriteFrameName:@"penguinblink01.png"];
        [sprite runAction:[pBlinkAction copy]];
        sprite.blink = [pBlinkAction copy];
        sprite.flail = [pFlailAction copy];
        sprite.type = [NSNumber numberWithInt:1];
    }else if(type < 410){
        sprite = [DragSprite spriteWithSpriteFrameName:@"elephantblink01.png"];
        [sprite runAction:[eBlinkAction copy]];
        sprite.blink = [eBlinkAction copy];
        sprite.flail = [eFlailAction copy];
        sprite.type = [NSNumber numberWithInt:2];
    }else if(type < 615){
        sprite = [DragSprite spriteWithSpriteFrameName:@"hippoblink01.png"];
        [sprite runAction:[hBlinkAction copy]];
        sprite.blink = [hBlinkAction copy];
        sprite.flail = [hFlailAction copy];
        sprite.type = [NSNumber numberWithInt:3];
    }else if(type < 820){
        sprite = [DragSprite spriteWithSpriteFrameName:@"lionblinking01.png"];
        [sprite runAction:[lBlinkAction copy]];
        sprite.blink = [lBlinkAction copy];
        sprite.flail = [lFlailAction copy];
        sprite.type = [NSNumber numberWithInt:4];
    }else if(type < 920){
        sprite = [DragSprite spriteWithFile:@"assets/animals/pig.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = [NSNumber numberWithInt:5];
    }else if(type < 935){
        sprite = [DragSprite spriteWithFile:@"assets/animals/hippogold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = [NSNumber numberWithInt:6];
    }else if(type < 965){
        sprite = [DragSprite spriteWithFile:@"assets/animals/liongold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = [NSNumber numberWithInt:7];
    }else if(type < 970){
        sprite = [DragSprite spriteWithFile:@"assets/animals/elephantgold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = [NSNumber numberWithInt:8];
    }else{
        sprite = [DragSprite spriteWithFile:@"assets/animals/penguingold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = [NSNumber numberWithInt:9];
    }
    [sprite moveSprite];
    //assign side and type
    sprite.side = side;
    //add sprite to layer and assign correct z axis
    [self addChild:sprite z:1];
    //add sprite to singleton list
    [[sharedSingleton animals] addObject:sprite];
    //increment number of animal counter
    animalCount++;
    [self animalLoop]; //get the next animal
}

//determine the amount of time until next animal 
- (void) animalLoop {
    //get rate from singleton
    NSNumber* rateNum = [[sharedSingleton currentSpawnRate] objectAtIndex:0];
    double rate = [rateNum doubleValue];
    
    //every 5000 points increase speed
    if(currentScore%3 == 0 && currentScore>0){
        //get game speed from singleton
        NSNumber* speedNum = [[sharedSingleton gameSpeed] objectAtIndex:0];
        double speed= [speedNum doubleValue];
        
        //increase speed but decrease rate
        speed += 0.04;
        rate *= 0.95;

        //cap speed at 1.95
        if(speed > 1.95){
            speed = 1.95;
        }
        
        //cap rate at 0.3
        if(rate < 0.45){
            rate = 0.45;
        }
        
        //save values into singleton
        rateNum = [NSNumber numberWithDouble:rate];
        [[sharedSingleton currentSpawnRate] replaceObjectAtIndex:0 withObject:rateNum];
        speedNum = [NSNumber numberWithDouble:speed];
        [[sharedSingleton gameSpeed] replaceObjectAtIndex:0 withObject:speedNum];
    }
    //determine delay by random number and rate
    NSNumber* randomNum = [self randFunction:7:15];
    double delay = [randomNum doubleValue];
    delay /=10;
    delay = delay * rate;
    //schedule next sprite
    [self schedule:@selector(addSprite) interval:delay];
}

//random number generator
-(NSNumber*)randFunction:(int)numOne:(int)numTwo {
    int randomNumber = (arc4random() % ((numTwo+1)-numOne))+numOne;
    return [NSNumber numberWithInt:randomNumber];
}

//touch handlers for the pause button and boxes
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    //get touchpoint and convert to gl format
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    //iterate through each box to check touch
    for(BoxSprite* boxTemp in boxes){
        //FIX bounding box for agnostic screen
        if(CGRectContainsPoint(CGRectInset(boxTemp.boundingBox,(.065 * winSize.width),(.035 * winSize.height)), touchPoint)){
            if(boxTemp.swallowed == boxTemp.originalCapacity){
                [self unitIncrement:boxTemp.swallowed*2];
            }else{
                [self unitIncrement:boxTemp.swallowed];
            }
            [boxTemp newNumber];
        }
    }
    //check if pause button was touched
    if(CGRectContainsPoint(pause.boundingBox, touchPoint) && gameState){
        [self pauseGame:YES];
    }
}

- (void) pauseGame:(BOOL)paused {
    if (paused) {
        [self pauseSchedulerAndActions];
        CCArray *children = self.children;
        [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
        
        [pauseLayer showLayer:YES];

    } else {
        [self resumeSchedulerAndActions];
        CCArray *children = self.children;
        [children makeObjectsPerformSelector:@selector(resumeSchedulerAndActions)];
        
        [pauseLayer showLayer:NO];
    }
}

- (void) restartGame {
    [[CCDirector sharedDirector] replaceScene:
        [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer scene]]];
}

- (void) quitToMain {
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:[MenuLayer scene]]];
}

//check intersections between box and animals
//FIX THIS. We shouldn't be iterating through all animals
-(void)checkIntersect{
    [self pickupSound]; //play pickup sound
    NSMutableArray* discardedItems = [NSMutableArray array]; //initialize discard array
    
    //iterate through every animal in the singleton array
    for(DragSprite* dragSprite in [sharedSingleton animals]){
        if(dragSprite.scale == 1){
            //FIX SPRITE BOUNDING BOX for agnostic screen size
            CGRect smallSprite = CGRectInset(dragSprite.boundingBox, (.05 * winSize.width),(.05 * winSize.height));
            int intersections = 0;
            int location = -1;
            //iterate through each box and check for intersections
            for (BoxSprite* boxTemp in boxes){
                //FIX BOX BOUNDING BOX for agnostic screen size
                if(CGRectIntersectsRect(smallSprite, CGRectInset(boxTemp.boundingBox,(.065 * winSize.width),(.035 * winSize.height)))){
                    intersections++;
                    if(location == -1){
                        location = [boxes indexOfObject:boxTemp];
                    }
                }
            }
            //if only 1 intersection, put into that box
            if(intersections == 1){
                //mark for animal for immediate removal
                [discardedItems addObject:dragSprite];
                
                //call box animation for swallow
                [[boxes objectAtIndex:location] stopAllActions];
                [self animateBox:[boxes objectAtIndex:location]:[NSNumber numberWithInt:location]];
                
                int check = [dragSprite.type intValue];
                //p.e.h.l
                //hip.li.el.pen
                if(check == 6){
                    check = 3;
                }
                if(check == 7){
                    check = 4;
                }
                if(check == 8){
                    check = 2;
                }
                if(check == 9){
                    check = 1;
                }
                //lose life or change box counter depending on animal type
                if([boxOrder objectAtIndex:location] == [NSNumber numberWithInt:check]){
                    [[boxes objectAtIndex:location] swallow];
                    [dragSprite powerupFunction];
                    [self showPowerupGradient];
                }else{
                    [self loseLife];
                    [self showLoseLifeGradient];
                }
            }
        }
    }
    
    //iterate through flagged animals and remove them
    //remove animals from singleton
    for(DragSprite* remove in discardedItems){
        [self removeChild:remove cleanup:YES];
    }
    [[sharedSingleton animals] removeObjectsInArray:discardedItems];
}

//provide the box with the correct animation and run it
//animations are not stored in the boxes, they're assigned when needed
- (void)animateBox:(BoxSprite*)box:(NSNumber*)index{

    //get the box type from the boxOrder index and grab the correct animation
    NSNumber* value = [boxOrder objectAtIndex:[index integerValue]];
    if(value ==[NSNumber numberWithInt:1]){
        [box runAction:_pBoxAction];
    }
    if(value ==[NSNumber numberWithInt:2]){
        [box runAction:_eBoxAction];
    }
    if(value ==[NSNumber numberWithInt:3]){
        [box runAction:_hBoxAction];
    }
    if(value ==[NSNumber numberWithInt:4]){
        [box runAction:_lBoxAction];
    }
}

- (void) showPowerupGradient {
    fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,255) fadeIn:NO speed:20];
    [self addChild:fadeLayer z:1];
    [self scheduleOnce:@selector(removeFadeLayer) delay:0.15f];
}

- (void) showLoseLifeGradient {
    fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(255,0,0) fadeIn:NO speed:20];
    [self addChild:fadeLayer z:1];
    [self scheduleOnce:@selector(removeFadeLayer) delay:0.15f];
}


//increment score function
- (void) unitIncrement:(NSInteger)num {
    //incremenet score by 100*provided val and then display visually
    currentScore +=(10*num);
    [score setString:[NSString stringWithFormat:@"%d",currentScore]];
}

//reset score function
- (void) resetScore {
    //reset counter and display visually
    currentScore = 0;
    [score setString:[NSString stringWithFormat:@"%d",currentScore]];
}

- (void) startMovingBelt {
    [self moveBelt:YES];
}

- (void) stopMovingBelt {
    [self moveBelt:NO];
}

-(void) moveBelt:(BOOL)move {
    [sharedSingleton setFrozenPowerupActivated:!move];
    if(!move) {
        [beltSprite stopAllActions];
        [self unschedule:@selector(addSprite)];
    } else {
        [beltSprite stopAllActions];
        [beltSprite runAction:beltAction];
        [self schedule:@selector(addSprite) interval:2.0f];
    }
    for(DragSprite* dragSprite in [sharedSingleton animals]){
        if(move) {
            [dragSprite updateSpeed];
        } else {
            [dragSprite stopAllActions];
        }
    }
}
- (void) halfSpeed {
    [sharedSingleton setSlowdownPowerupActivated:YES];
    
    [sharedSingleton halfSpeed];
    for(DragSprite* dragSprite in [sharedSingleton animals]){
        [dragSprite updateSpeed];
    }
}

- (void) fullSpeed {
    [sharedSingleton setSlowdownPowerupActivated:NO];

    [sharedSingleton fullSpeed];
    for(DragSprite* dragSprite in [sharedSingleton animals]){
        [dragSprite updateSpeed];
    }
}

//lose life function
- (void) loseLife {
    //decrement counter, display visually
    //if 0 lives, wait 0.25 seconds then call game-over function
    lifeCount--;
    if(lifeCount >= 0){
        [lifeSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%dlives.png",lifeCount]]];
    }
    if(lifeCount == 0){
        [self scheduleOnce:@selector(gameOver) delay:0.25];
    }
}

- (void) gainLife{
    //increment counter, display visually
    if(lifeCount !=3){
        lifeCount++;
        [lifeSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%dlives.png",lifeCount]]];
    }
}

//end the game
- (void) gameOver{
    Boolean highScoreFlag = [sharedSingleton checkHighScore:currentScore]; //send the singleton the current game score, a high score may be recorded
     [[ABGameKitHelper sharedClass] reportScore:currentScore forLeaderboard:@"ZooBoxLeaderboard"];
    
    [self endGameSound]; //play endgame sounds
    gameState = NO;
    
    [self pauseSchedulerAndActions];
    CCArray *children = self.children;
    [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
    GameOverlayLayer *gameOver = [[GameOverlayLayer alloc] initAsGameOver:currentScore];
    [self addChild:gameOver z:6];
    [gameOver showLayer:YES];
}

- (void) startSounds{
    [[sharedSingleton sae] playBackgroundMusic:@"gameLoop.mp3"];
/*    soundSequence = [CCSequence actionOne:[CCCallBlock actionWithBlock:^(void){[[sharedSingleton sae]playEffect:@"engineStart.mp3"];}] two:[CCCallBlock actionWithBlock:^(void){[[sharedSingleton sae]playBackgroundMusic:@"engineLoop.mp3"];}]];
    [self runAction:soundSequence];*/
}

- (void) startGameSound{
    [[sharedSingleton sae] playBackgroundMusic:@"gameLoop.mp3"];
}
- (void) killBG{
    [[sharedSingleton sae] pauseBackgroundMusic];
}

- (void) startBG{
    [[sharedSingleton sae] playBackgroundMusic:@"gameLoop.mp3"];
}

- (void) pickupSound{
    [[sharedSingleton sae] playEffect:@"pickup.mp3"]; //play pickup sound
}

- (void) countdownSound{
    [[sharedSingleton sae] playEffect:@"countdown.mp3"]; //play pickup sound
}

- (void) endGameSound{
    [[sharedSingleton sae] pauseBackgroundMusic]; //stop background music
    [[sharedSingleton sae] playEffect:@"gameStop.mp3"]; //play end game effect
}

// on "dealloc" you need to release all your retained objects
//FIX THIS - I DON"T THINK EVERYTHING IS DEALLOCED

/* SOME GAME CENTER STUFF
#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
} */
@end
