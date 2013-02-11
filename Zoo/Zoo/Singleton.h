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
 
@property(atomic,retain) NSMutableArray* bezierArray;
@property(atomic,retain) NSMutableArray* animals;
@property(atomic,retain) NSMutableArray* gameSpeed;
@property(atomic,retain) NSMutableArray* currentSpawnRate;
@property(atomic,retain) SimpleAudioEngine* sae;
@property(atomic,retain) NSNumber* saveSpeed;
@property(atomic) BOOL frozenPowerupActivated;
@property(atomic) BOOL slowdownPowerupActivated;

+ (id)sharedInstance;
- (Boolean)checkHighScore:(int)newScore;
- (void) resetSingleton;
- (void) halfSpeed;
- (void) fullSpeed;
- (int) getHighScore;

@end
