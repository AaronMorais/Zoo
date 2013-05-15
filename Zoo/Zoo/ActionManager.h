//
//  ActionManager.h
//  Zoo
//
//  Created by Aaron Morais on 2013-05-14.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ActionManager : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSMutableArray *animalBlinkActions;
@property (nonatomic, strong) NSMutableArray *animalFlailActions;
@property (nonatomic, strong) NSMutableArray *boxActions;
@property (nonatomic, strong) CCAction *beltAction;

@end
