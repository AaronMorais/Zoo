//
//  LoadingLayer.m
//  Zoo
//
//  Created by Aaron Morais on 2013-02-10.
//
//

#import "LoadingLayer.h"

@implementation LoadingLayer

-  (id)initWithColor:(ccColor4B)color {
    self = [super initWithColor:color];
    if (self) {
//        CCLabelTTF *loading = [[CCLabelTTF alloc] initWithString:@"Loading..." fontName:@"Arial" fontSize:20.0f];
//        [self addChild:loading];
//        CGSize winSize = [[CCDirector sharedDirector] winSize];
//        [loading setPosition:ccp(winSize.width/2, winSize.height/2)];
        [self addBackgroundImage];
    }
    return self;
}

-(void) addBackgroundImage{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"assets/loadingScreen.jpg"];
    [self addChild:background];
    background.position = ccp(winSize.width/2, winSize.height/2);
}

@end
