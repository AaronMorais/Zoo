//
//  GameLayer.m
//  Zoo
//
//  Created by Aaron Morais on 12-06-17.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GameLayer.h"
#import "MenuLayer.h"
#import "ABGameKitHelper.h"
#import "Utility.h"

#pragma mark - GameLayer

@interface GameLayer()
    @property (nonatomic, assign) int currentRound;
@end

@implementation GameLayer
@synthesize pBoxAction = _pBoxAction;
@synthesize eBoxAction = _eBoxAction;
@synthesize hBoxAction = _hBoxAction;
@synthesize lBoxAction = _lBoxAction;
@synthesize pFlailAction, lFlailAction, eFlailAction, hFlailAction, pBlinkAction, lBlinkAction, eBlinkAction, hBlinkAction, boxes,currentScore, gameHasStarted;

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
    //load sprite sheets
    [self loadSpriteSheets];
    [self layoutLayer];
    //add animation frames and create actions
    [self loadAnimationFrames];
    //init box array
    boxes = [[NSMutableArray alloc]init];
    //init singleton
    gameManager = [GameManager sharedInstance];
    [gameManager resetGameVariables];
    [self addBoxes];
}

- (void) layoutLayer {
    [self addBackgroundImage];
    [self addScoreLabel];
    [self addPauseLayer];
    [self addPauseButton];
    [self addLivesSprite];
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
    gameHasStarted = true;
    [self startSounds];
    [beltSprite runAction:beltAction];
    [self schedule:@selector(addSprite) interval:1];
}

- (void)countDown{
    countDownCounter--;
    [[[CCDirector sharedDirector] touchDispatcher] setDispatchEvents:NO];
    if(countDownCounter == 4){
        fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,0) fadeIn:NO speed:2 large:YES];
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

//create all boxes
- (void)addBoxes{
    [self generateOrder];
    for(NSNumber *box in boxOrder) {
        [self createBoxOfType:[box intValue]];
    }
}

//create a box of given type
- (void)createBoxOfType:(SpriteType)type{
    //init box based on type
    BoxSprite* newBox;
    CCLabelTTF* currentNumber;
        
    if(type == SpriteTypePenguin){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"penguinbox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccWHITE];
    }
    if(type == SpriteTypeElephant){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"elephantbox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccc3(129,137,137)];
    }
    if(type == SpriteTypeHippo){
        newBox = [BoxSprite spriteWithSpriteFrameName:@"hippobox1.png"];
        currentNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",newBox.currentCapacity] fontName:@"Aharoni" fontSize:80];
        [currentNumber setColor:ccc3(225,105,180)];
    }
    if(type == SpriteTypeLion){
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
        NSNumber* randomNum = [NSNumber numberWithInt:count];
        [boxOrder addObject:randomNum];
        count++;
    }
}


//provide the box with the correct animation and run it
//animations are not stored in the boxes, they're assigned when needed
- (void)animateBox:(BoxSprite*)box AtIndex:(NSNumber*)index{

    //get the box type from the boxOrder index and grab the correct animation
    NSNumber* value = [boxOrder objectAtIndex:[index integerValue]];
    if(value ==[NSNumber numberWithInt:SpriteTypePenguin]){
        [box runAction:_pBoxAction];
    }
    if(value ==[NSNumber numberWithInt:SpriteTypeElephant]){
        [box runAction:_eBoxAction];
    }
    if(value ==[NSNumber numberWithInt:SpriteTypeHippo]){
        [box runAction:_hBoxAction];
    }
    if(value ==[NSNumber numberWithInt:SpriteTypeLion]){
        [box runAction:_lBoxAction];
    }
}

//add sprite to game
- (void)addSprite {
    NSNumber* nsType = [Utility randomNumberFrom:1 To:1000]; //randomly choose animal type
    int type = [nsType intValue];
    while((self.noPigsPowerupEnabled && type > 819 && type < 920) || (lifeCount==5 && type < 970 && type > 964)) {
        nsType = [Utility randomNumberFrom:1 To:1000];
        type = [nsType intValue];
    }
    DragSprite* sprite; //init animal
    
    //assign the animal it's animations based on type
    if(type < 205){
        sprite = [DragSprite spriteWithSpriteFrameName:@"penguinblink01.png"];
        [sprite runAction:[pBlinkAction copy]];
        sprite.blink = [pBlinkAction copy];
        sprite.flail = [pFlailAction copy];
        sprite.type = SpriteTypePenguin;
    }else if(type < 410){
        sprite = [DragSprite spriteWithSpriteFrameName:@"elephantblink01.png"];
        [sprite runAction:[eBlinkAction copy]];
        sprite.blink = [eBlinkAction copy];
        sprite.flail = [eFlailAction copy];
        sprite.type = SpriteTypeElephant;
    }else if(type < 615){
        sprite = [DragSprite spriteWithSpriteFrameName:@"hippoblink01.png"];
        [sprite runAction:[hBlinkAction copy]];
        sprite.blink = [hBlinkAction copy];
        sprite.flail = [hFlailAction copy];
        sprite.type = SpriteTypeHippo;
    }else if(type < 820){
        sprite = [DragSprite spriteWithSpriteFrameName:@"lionblinking01.png"];
        [sprite runAction:[lBlinkAction copy]];
        sprite.blink = [lBlinkAction copy];
        sprite.flail = [lFlailAction copy];
        sprite.type = SpriteTypeLion;
    }else if(type < 920){
        sprite = [DragSprite spriteWithFile:@"assets/animals/pig.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = SpriteTypePig;
    }else if(type < 935){
        sprite = [DragSprite spriteWithFile:@"assets/animals/hippogold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = SpriteTypeDoublePoints;
    }else if(type < 965){
        sprite = [DragSprite spriteWithFile:@"assets/animals/liongold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = SpriteTypeNoPigs;
    }else if(type < 970){
        sprite = [DragSprite spriteWithFile:@"assets/animals/elephantgold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = SpriteTypePlusLife;
    }else{
        sprite = [DragSprite spriteWithFile:@"assets/animals/penguingold.png"];
        sprite.blink = NULL;
        sprite.flail = NULL;
        sprite.type = SpriteTypeFreeze;
    }
    [sprite moveSprite:NO];
    //add sprite to layer and assign correct z axis
    [self addChild:sprite z:1];
    //add sprite to singleton list
    [[gameManager animals] addObject:sprite];
    //increment number of animal counter
    animalCount++;
    [self animalLoop]; //get the next animal
}

//determine the amount of time until next animal 
- (void) animalLoop {
    CGFloat rate = [gameManager currentSpawnRate];    
    CGFloat speed = [gameManager gameSpeed];
    
    //increase speed but decrease rate
    if(currentScore < 1000) {
        speed *= 1.020;
        rate *= 0.990;
    } else {
        speed *= 1.015;
        rate *= 0.995;
    }
    
    //cap speed at 1.7
    if(speed > 1.6){
        speed = 1.6;
    }
    
    //cap rate at 0.3
    if(rate < 0.6){
        rate = 0.6;
    }
    NSLog(@"speed: %f, rate: %f", speed, rate);
    
    [gameManager setCurrentSpawnRate:rate];
    [gameManager setGameSpeed:speed];

    //determine delay by random number and rate
    NSNumber* randomNum = [Utility randomNumberFrom:7 To:15];
    CGFloat delay = [randomNum doubleValue];
    delay /=10;
    delay = delay * rate;
    //schedule next sprite
    [self schedule:@selector(addSprite) interval:delay];
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
    if(CGRectContainsPoint(pause.boundingBox, touchPoint) && gameHasStarted){
        [self pauseGame:YES];
    }
}

- (void) pauseGame:(BOOL)paused {
    if (paused) {
        [pauseLayer showLayer:YES];
        
        [self pauseSchedulerAndActions];
        CCArray *children = self.children;
        [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
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
    
    //iterate through every animal in the singleton array
    for(DragSprite* dragSprite in [[gameManager animals] copy]){
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
                //call box animation for swallow
                [[boxes objectAtIndex:location] stopAllActions];
                [self animateBox:[boxes objectAtIndex:location]AtIndex:[NSNumber numberWithInt:location]];
                
                int check = dragSprite.type;

                //lose life or change box counter depending on animal type
                if([boxOrder objectAtIndex:location] == [NSNumber numberWithInt:check] || check > 5){
                    if(check <= 4) {
                        [[boxes objectAtIndex:location] swallow];
                    }
                    CGFloat gradientLength = [dragSprite powerupFunction];
                    if(gradientLength > 0.0f) {
                        [self showPowerupGradient:gradientLength];
                    }
                }else{
                    [self loseLife];
                    [self showLoseLifeGradient];
                }
                
                //remove animal
                [self removeChild:dragSprite cleanup:YES];
                [[gameManager animals] removeObject:dragSprite];
            }
        }
    }
}

#pragma mark Gradient Overlay methods
- (void) showPowerupGradient:(CGFloat)delay {
    RadialGradientLayer *powerupLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,255) fadeIn:NO speed:20 large:NO];
    [self addChild:powerupLayer z:2];
    [powerupLayer removeAfterDelay:delay];
}

- (void) showLoseLifeGradient {
    fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(255,0,0) fadeIn:NO speed:20 large:YES];
    [self addChild:fadeLayer z:2];
    [self scheduleOnce:@selector(removeFadeLayer) delay:0.15f];
}

- (void) removeFadeLayer {
    [self removeChild:fadeLayer cleanup:YES];
    fadeLayer = nil;
}

#pragma mark Score Methods
//increment score function
- (void) unitIncrement:(NSInteger)num {
    if(self.doublePointPowerupEnabled){
        num *=2;
    }
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

#pragma mark Powerup Methods
-(void)setDoublePointPowerup:(NSNumber *)powerup {
    [self setDoublePointPowerupEnabled:[powerup boolValue]];
}

-(void)setNoPigsPowerup:(NSNumber *)powerup {
    [self setNoPigsPowerupEnabled:[powerup boolValue]];
}

#pragma mark Converyor Belt Start/Stop
- (void) startMovingBelt {
    [self moveBelt:YES];
}

- (void) stopMovingBelt {
    [self moveBelt:NO];
}

-(void) moveBelt:(BOOL)move {
    [gameManager setFrozenPowerupActivated:!move];
    if(!move) {
        [beltSprite stopAllActions];
        [self unschedule:@selector(addSprite)];
    } else {
        [beltSprite stopAllActions];
        [beltSprite runAction:beltAction];
        [self schedule:@selector(addSprite) interval:2.0f];
    }
    for(DragSprite* dragSprite in [gameManager animals]){
        if(move) {
            [dragSprite updateSpeed];
        } else {
            [dragSprite stopAllActions];
        }
    }
}

#pragma mark Life Methods
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
    if(lifeCount !=5){
        lifeCount++;
        [lifeSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%dlives.png",lifeCount]]];
    }
}


#pragma mark Game Over Methods
- (void) gameOver{
    [gameManager checkHighScore:currentScore]; //send the singleton the current game score, a high score may be recorded
     [[ABGameKitHelper sharedClass] reportScore:currentScore forLeaderboard:@"ZooBoxLeaderboard"];
    
    [self endGameSound]; //play endgame sounds
    gameHasStarted = NO;
    
    [self pauseSchedulerAndActions];
    CCArray *children = self.children;
    [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
    GameOverlayLayer *gameOver = [[GameOverlayLayer alloc] initAsGameOver:currentScore];
    [self addChild:gameOver z:6];
    [gameOver showLayer:YES];
}

#pragma mark Sound methods
- (void) startSounds{
    [[gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}

- (void) startGameSound{
    [[gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}
- (void) killBG{
    [[gameManager sae] pauseBackgroundMusic];
}

- (void) startBG{
    [[gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}

- (void) pickupSound{
    [[gameManager sae] playEffect:@"pickup.mp3"]; //play pickup sound
}

- (void) countdownSound{
    [[gameManager sae] playEffect:@"countdown.mp3"]; //play pickup sound
}

- (void) endGameSound{
    [[gameManager sae] pauseBackgroundMusic]; //stop background music
    [[gameManager sae] playEffect:@"gameStop.mp3"]; //play end game effect
}
@end
