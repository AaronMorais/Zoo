//
//  Singleton.h
//  Zoo
//
//  Created by Aaron Morais on 2012-08-25.
//
//

#import "cocos2d.h"
#import "FMDatabase.h"
#import "SimpleAudioEngine.h"

@interface GameManager : NSObject {
}
 
@property(nonatomic,strong) NSMutableArray* bezierArray;
@property(nonatomic,strong) NSMutableArray* animals;
@property(nonatomic,assign) CGFloat gameSpeed;
@property(nonatomic,assign) CGFloat currentSpawnRate;
@property(nonatomic,strong) SimpleAudioEngine* sae;
@property(nonatomic, assign) BOOL frozenPowerupActivated;

+ (id)sharedInstance;
+ (BOOL)shouldShowHowToPlay;
+ (void)saveShouldShowHowToPlay:(BOOL)shouldShowHowToPlay;
- (void)checkHighScore:(int)newScore;
- (void) resetGameVariables;
- (int) getHighScore;

@end
