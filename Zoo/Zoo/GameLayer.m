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
#import "ActionManager.h"

#pragma mark - GameLayer

@interface GameLayer() {
    CCSprite *_beltSprite;
    CCAction *_beltAction;
    int _countDownCounter;
    CCSprite *_countDownSprite;
    RadialGradientLayer *_fadeLayer;
    GameOverlayLayer *_pauseLayer;
    CGSize _winSize;
    CCSprite* _lifeSprite;
    CCSprite* _pause;
    CCLabelTTF* _score;
    NSInteger _lifeCount;
    CCSequence *_soundSequence;
    SimpleAudioEngine *_sae;
    GameManager *_gameManager;
}

@property (nonatomic, assign) NSInteger currentScore;
@property (nonatomic, assign) int currentRound;
@property (nonatomic, assign) BOOL roundStarted;
@property (nonatomic, strong) NSMutableArray *boxes;
@property (nonatomic, assign) BOOL doublePointPowerupEnabled;

@end

@implementation GameLayer

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
        _countDownCounter = 5;
        [self countDown];
	}
	return self;
}

- (void) loadAssets{
    _winSize = [[CCDirector sharedDirector] winSize];
    //load sprite sheets
    [self loadSpriteSheets];
    [self layoutLayer];
    //add animation frames and create actions
    [self loadBelt];
    //init box array
    [self createBoxes];
    //init singleton
    _gameManager = [GameManager sharedInstance];
    [_gameManager resetGameVariables];
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
    background.position = ccp(_winSize.width/2, _winSize.height/2);
}

- (void) addScoreLabel{
    _score = [CCLabelTTF labelWithString:@"0" fontName:@"Aharoni" fontSize:50];
    [_score setColor:ccc3(0,0,0)];
    [_score setHorizontalAlignment:kCCTextAlignmentRight];
    [self addChild: _score];
    _score.anchorPoint = ccp(0,0.5);
    _score.position =  ccp((.1 * _winSize.width),_winSize.height-(.065 * _winSize.height));
}

- (void) addPauseLayer {
    _pauseLayer = [[GameOverlayLayer alloc] initAsPauseMenu];
    [self addChild:_pauseLayer z:6];
    [_pauseLayer showLayer:NO];
}

- (void) addPauseButton{
    _pause = [CCSprite spriteWithSpriteFrameName:@"pausebutton.png"];
    [self addChild:_pause];
    _pause.position =  ccp((.046 * _winSize.width),_winSize.height-(.065 * _winSize.height));
}

- (void) addLivesSprite{
    _lifeSprite = [CCSprite spriteWithSpriteFrameName:@"3lives.png"];
    [self addChild:_lifeSprite];
    _lifeSprite.position =  ccp(_winSize.width - (.125 * _winSize.width) ,_winSize.height-(.065 * _winSize.height));
    _lifeCount = 3;
}

- (void) loadSpriteSheets{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/four.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/four2.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/conbelt.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/HUD.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"assets/countdown.plist"];
}

//add animation frames and create actions
- (void) loadBelt{
    _beltAction = [[ActionManager sharedInstance] beltAction];
    _beltSprite = [CCSprite spriteWithSpriteFrameName:@"conbelt01.png"];
    _beltSprite.position = ccp(_winSize.width/2, _winSize.height/2 - (.06 * _winSize.height));
    [self addChild:_beltSprite];
    _beltSprite.scale = CC_CONTENT_SCALE_FACTOR();
}

#pragma mark Game State Methods
//start the game
- (void)startGame{
    self.gameHasStarted = true;
    [self startSounds];
    [_beltSprite runAction:_beltAction];
    self.currentRound = 0;
    [self startNextRound];
}

- (void) pauseGame:(BOOL)paused {
    if (paused) {
        [_pauseLayer showLayer:YES];
        
        [self pauseSchedulerAndActions];
        CCArray *children = self.children;
        [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
    } else {
        [self resumeSchedulerAndActions];
        CCArray *children = self.children;
        [children makeObjectsPerformSelector:@selector(resumeSchedulerAndActions)];
        
        [_pauseLayer showLayer:NO];
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

- (void)countDown{
    _countDownCounter--;
    [[[CCDirector sharedDirector] touchDispatcher] setDispatchEvents:NO];
    if(_countDownCounter == 4){
        _fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,0) fadeIn:NO speed:2 large:YES];
        [self addChild:_fadeLayer z:1];
        [self schedule:@selector(countDown) interval:0.5];
    }else if(_countDownCounter > 0){
        [self removeChild:_countDownSprite cleanup:YES];
        NSString* path = [NSString stringWithFormat:@"%d.png",_countDownCounter];
        _countDownSprite = [CCSprite spriteWithSpriteFrameName:path];
        _countDownSprite.position = ccp(_winSize.width/2, _winSize.height/2);
        _countDownSprite.scale = 0.75;
        [self addChild:_countDownSprite z:2];
        [self schedule:@selector(countDown) interval:1];
        [self countdownSound];
    }else if(_countDownCounter == 0){
        [_fadeLayer fadeAwayScheduler];
        [self scheduleOnce:@selector(removeFadeLayer) delay:2.0f];
        
        [self removeChild:_countDownSprite cleanup:YES];
        _countDownSprite = [CCSprite spriteWithSpriteFrameName:@"go!.png"];
        _countDownSprite.position = ccp(_winSize.width/2, _winSize.height/2);
        _countDownSprite.scale = 0.65;
        [self addChild:_countDownSprite z:2];
        [self schedule:@selector(countDown) interval:0.5];
        [self countdownSound];
    }else if(_countDownCounter == -1){
        [self startGame];
        [self removeChild:_countDownSprite cleanup:YES];
        [self unschedule:@selector(countDown)];
        _countDownCounter = 5;
        [[[CCDirector sharedDirector] touchDispatcher] setDispatchEvents:YES];
    }
}


#pragma mark Round Methods
- (void) startNextRound {
    self.currentRound +=1;
    self.roundStarted = YES;

    CGFloat rate = [_gameManager currentSpawnRate];
    CGFloat speed = [_gameManager gameSpeed];
    CGFloat spawnCount = [_gameManager currentSpawnCount];
    
    //increase speed but decrease rate
    speed *= 1.1;
    rate *= 0.95;
    spawnCount *= 1.2;
    
    //cap speed
    if(speed > 1.6){
        speed = 1.6;
    }
    
    //cap rate
    if(rate < 0.6){
        rate = 0.6;
    }
    
    NSLog(@"Round: %d Count:%d Speed: %f, Rate: %f", self.currentRound, (int)spawnCount, speed, rate);
    
    [_gameManager setCurrentSpawnRate:rate];
    [_gameManager setGameSpeed:speed];
    [_gameManager setCurrentSpawnCount:spawnCount];
    
    NSMutableArray *roundArray = [[NSMutableArray alloc] init];
    for(int i=0;i<(int)spawnCount;i++){
        //determine delay by random number and rate
        NSNumber* randomNum = [Utility randomNumberFrom:7 To:15];
        CGFloat delay = [randomNum doubleValue];
        delay /=10;
        delay = delay * rate;
        id tDelay = [CCDelayTime actionWithDuration:delay];
        id addDragSprite = [CCCallFunc actionWithTarget:self selector:@selector(addDragSprite)];
        [roundArray addObjectsFromArray:@[tDelay, addDragSprite]];
    }
    id roundEnded = [CCCallFunc actionWithTarget:self selector:@selector(setRoundEnded)];
    [roundArray addObject:roundEnded];
    
    CCSequence* roundSeq = [CCSequence actionWithArray:roundArray];
    [self stopAllActions];
    [self runAction:roundSeq];
}

-(void) setRoundEnded {
    self.roundStarted = NO;
}

#pragma mark Box Methods
- (void)createBoxes {
    self.boxes = [NSMutableArray array];
    for(int i=1;i<=4;i++) {
        BoxSprite *box = [[BoxSprite alloc] initWithType:i];
        [self addChild:box];
        [box updateStrokes];
        [self.boxes addObject:box];
    }
}

#pragma mark Drag Sprite Methods
//add sprite to game
- (void)addDragSprite {
    NSNumber* nsType = [Utility randomNumberFrom:1 To:1000]; //randomly choose animal type
    int type = [nsType intValue];
    while(_lifeCount==5 && type < 970 && type > 964) {
        nsType = [Utility randomNumberFrom:1 To:1000];
        type = [nsType intValue];
    }
    
    DragSprite* sprite; //declare animal
    //assign the animal it's animations based on type
    if(type < 220){
        sprite = [[DragSprite alloc] initWithType:SpriteTypePenguin];
    }else if(type < 440){
        sprite = [[DragSprite alloc] initWithType:SpriteTypeElephant];
    }else if(type < 660){
        sprite = [[DragSprite alloc] initWithType:SpriteTypeHippo];
    }else if(type < 880){
        sprite = [[DragSprite alloc] initWithType:SpriteTypeLion];
    }else if(type < 985){
        sprite = [[DragSprite alloc] initWithType:SpriteTypePig];
    }else if(type < 990){
        sprite = [[DragSprite alloc] initWithType:SpriteTypeDoublePoints];
    }else if(type < 995){
        sprite = [[DragSprite alloc] initWithType:SpriteTypePlusLife];
    }else{
        sprite = [[DragSprite alloc] initWithType:SpriteTypeFreeze];
    }
    sprite.delegate = self;
    //add sprite to layer and assign correct z axis
    [self addChild:sprite z:1];
    [sprite moveSpriteIsResuming:NO];
}

//check intersections between box and animals
-(void)checkIntersect{
    [self pickupSound]; //play pickup sound
    
    //iterate through every animal in the singleton array
    for(DragSprite* dragSprite in [[_gameManager animals] copy]){
        if(dragSprite.scale == 1){
            //FIX for iPad
            CGRect smallSprite = CGRectInset(dragSprite.boundingBox, (.05 * _winSize.width),(.05 * _winSize.height));
            int intersections = 0;
            int location = -1;
            //iterate through each box and check for intersections
            for (BoxSprite* boxTemp in self.boxes){
                //FIX for iPad
                if(CGRectIntersectsRect(smallSprite, CGRectInset(boxTemp.boundingBox,(.065 * _winSize.width),(.035 * _winSize.height)))){
                    intersections++;
                    if(location == -1){
                        location = [self.boxes indexOfObject:boxTemp];
                    }
                }
            }
            //if only 1 intersection, put into that box
            if(intersections == 1){                
                //call box animation for swallow
                [[self.boxes objectAtIndex:location] stopAllActions];
                [[self.boxes objectAtIndex:location] animate];
                
                int check = dragSprite.type;

                //lose life or change box counter depending on animal type
                if(((location+1) == check) || check > 5){
                    if(check <= 4) {
                        [[self.boxes objectAtIndex:location] swallow];
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
            }
        }
    }
}

#pragma mark DragSpriteDelegate methods
- (void)dragSpriteRemoved {
    if([[_gameManager animals] count] != 0 || self.roundStarted) { return;}
    
    NSMutableArray *roundArray = [NSMutableArray array];
    id tDelay = [CCDelayTime actionWithDuration:1.0f];
    id startNextRound = [CCCallFunc actionWithTarget:self selector:@selector(startNextRound)];
    [roundArray addObjectsFromArray:@[tDelay, startNextRound]];
    
    CCSequence* roundSeq = [CCSequence actionWithArray:roundArray];
    [self runAction:roundSeq];
}

#pragma mark CCTouchDelegate methods
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
    for(BoxSprite* boxTemp in self.boxes){
        //FIX for iPad
        if(CGRectContainsPoint(CGRectInset(boxTemp.boundingBox,(.065 * _winSize.width),(.035 * _winSize.height)), touchPoint)){
            if(boxTemp.swallowed == boxTemp.originalCapacity){
                [self unitIncrement:boxTemp.swallowed*2];
            }else{
                [self unitIncrement:boxTemp.swallowed];
            }
            [boxTemp boxTapped];
        }
    }
    //check if pause button was touched
    if(CGRectContainsPoint(_pause.boundingBox, touchPoint) && self.gameHasStarted){
        [self pauseGame:YES];
    }
}

#pragma mark Gradient Overlay methods
- (void) showPowerupGradient:(CGFloat)delay {
    RadialGradientLayer *powerupLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(0,0,255) fadeIn:NO speed:20 large:NO];
    [self addChild:powerupLayer z:2];
    [powerupLayer removeAfterDelay:delay];
}

- (void) showLoseLifeGradient {
    _fadeLayer = [[RadialGradientLayer alloc] initWithColor:ccc3(255,0,0) fadeIn:NO speed:20 large:YES];
    [self addChild:_fadeLayer z:2];
    [self scheduleOnce:@selector(removeFadeLayer) delay:0.15f];
}

- (void) removeFadeLayer {
    [self removeChild:_fadeLayer cleanup:YES];
    _fadeLayer = nil;
}

#pragma mark Score Methods
//increment score function
- (void) unitIncrement:(NSInteger)num {
    if(self.doublePointPowerupEnabled){
        num *=2;
    }
    //incremenet score by 10*provided val and then display visually
    self.currentScore +=(10*num);
    [_score setString:[NSString stringWithFormat:@"%d",self.currentScore]];
}

//reset score function
- (void) resetScore {
    //reset counter and display visually
    self.currentScore = 0;
    [_score setString:[NSString stringWithFormat:@"%d",self.currentScore]];
}

#pragma mark Powerup Methods
-(void)setDoublePointPowerup:(NSNumber *)powerup {
    [self setDoublePointPowerupEnabled:[powerup boolValue]];
}

#pragma mark Converyor Belt Start/Stop
- (void) startMovingBelt {
    [self moveBelt:YES];
}

- (void) stopMovingBelt {
    [self moveBelt:NO];
}

-(void) moveBelt:(BOOL)move {
    [_gameManager setFrozenPowerupActivated:!move];
    if(!move) {
        [_beltSprite stopAllActions];
        [self pauseSchedulerAndActions];
    } else {
        [_beltSprite stopAllActions];
        [_beltSprite runAction:_beltAction];
        [self resumeSchedulerAndActions];
    }
    for(DragSprite* dragSprite in [_gameManager animals]){
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
    _lifeCount--;
    if(_lifeCount >= 0){
        [_lifeSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%dlives.png",_lifeCount]]];
    }
    if(_lifeCount == 0){
        [self scheduleOnce:@selector(gameOver) delay:0.25];
    }
}

- (void) gainLife{
    //increment counter, display visually
    if(_lifeCount !=5){
        _lifeCount++;
        [_lifeSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%dlives.png",_lifeCount]]];
    }
}


#pragma mark Game Over Methods
- (void) gameOver{
    [_gameManager checkHighScore:self.currentScore]; //send the singleton the current game score, a high score may be recorded
     [[ABGameKitHelper sharedClass] reportScore:self.currentScore forLeaderboard:@"ZooBoxLeaderboard"];
    
    [self endGameSound]; //play endgame sounds
    self.gameHasStarted = NO;
    
    [self pauseSchedulerAndActions];
    CCArray *children = self.children;
    [children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
    GameOverlayLayer *gameOver = [[GameOverlayLayer alloc] initAsGameOver:self.currentScore];
    [self addChild:gameOver z:6];
    [gameOver showLayer:YES];
}

#pragma mark Sound methods
- (void) startSounds{
    [[_gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}

- (void) startGameSound{
    [[_gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}
- (void) killBG{
    [[_gameManager sae] pauseBackgroundMusic];
}

- (void) startBG{
    [[_gameManager sae] playBackgroundMusic:@"gameLoop.mp3"];
}

- (void) pickupSound{
    [[_gameManager sae] playEffect:@"pickup.mp3"]; //play pickup sound
}

- (void) countdownSound{
    [[_gameManager sae] playEffect:@"countdown.mp3"]; //play pickup sound
}

- (void) endGameSound{
    [[_gameManager sae] pauseBackgroundMusic]; //stop background music
    [[_gameManager sae] playEffect:@"gameStop.mp3"]; //play end game effect
}
@end
