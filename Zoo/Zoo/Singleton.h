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
    SimpleAudioEngine* sae;
}
 
@property(atomic,retain) NSMutableArray* bezierArray;
@property(atomic,retain) NSMutableArray* animals;
@property(atomic,retain) NSMutableArray* gameSpeed;
@property(atomic,retain) NSMutableArray* currentSpawnRate;
@property(atomic,retain) SimpleAudioEngine* sae;

+ (id)sharedInstance;
- (Boolean)checkHighScore:(int)newScore;
- (void) resetSingleton;
- (void) halfSpeed;
- (void) fullSpeed;

@end
