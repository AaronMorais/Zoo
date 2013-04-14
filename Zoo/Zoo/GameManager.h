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
 
@property(atomic,strong) NSMutableArray* bezierArray;
@property(atomic,strong) NSMutableArray* animals;
@property(atomic,strong) NSMutableArray* gameSpeed;
@property(atomic,strong) NSMutableArray* currentSpawnRate;
@property(atomic,strong) SimpleAudioEngine* sae;
@property(atomic,strong) NSNumber* saveSpeed;
@property(atomic) BOOL frozenPowerupActivated;

+ (id)sharedInstance;
+ (BOOL)shouldShowHowToPlay;
+ (void)saveShouldShowHowToPlay:(BOOL)shouldShowHowToPlay;
- (void)checkHighScore:(int)newScore;
- (void) resetGameVariables;
- (int) getHighScore;

@end
