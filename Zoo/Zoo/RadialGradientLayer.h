//
//  RadialGradiantLayer.h
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "CCLayer.h"
#import "cocos2d.h"

@interface RadialGradientLayer : CCLayer

- (id)initWithColor:(ccColor3B)color fadeIn:(BOOL)fade speed:(int)speed;
- (void) fadeAwayScheduler;

@end
