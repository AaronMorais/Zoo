//
//  PauseLayer.h
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "cocos2d.h"
#import "CCLayer.h"

@interface GameOverlayLayer : CCLayer

- (id)initAsPauseMenu;
- (id)initAsGameOver:(int)score;
- (void) showLayer:(BOOL)show;

@end
