//
//  Singleton.h
//  Zoo
//
//  Created by Aaron Morais on 2012-08-25.
//
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "SimpleAudioEngine.h"

@interface Singleton : NSObject {
}
 
@property(atomic,strong) NSMutableArray* bezierArray;
@property(atomic,strong) NSMutableArray* animals;
@property(atomic,strong) NSMutableArray* gameSpeed;
@property(atomic,strong) NSMutableArray* currentSpawnRate;
@property(atomic,strong) SimpleAudioEngine* sae;
@property(atomic,strong) NSNumber* saveSpeed;
@property(atomic) BOOL frozenPowerupActivated;
@property(atomic) BOOL slowdownPowerupActivated;

+ (id)sharedInstance;
- (Boolean)checkHighScore:(int)newScore;
- (void) resetSingleton;
- (void) halfSpeed;
- (void) fullSpeed;
- (int) getHighScore;

@end
