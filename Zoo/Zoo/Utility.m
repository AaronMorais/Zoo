//
//  Utility.m
//  Zoo
//
//  Created by Aaron Morais on 2013-04-13.
//
//

#import "Utility.h"

@implementation Utility

//random number generator
+(NSNumber*)randomNumberFrom:(int)numOne To:(int)numTwo {
    int randomNumber = (arc4random() % ((numTwo+1)-numOne))+numOne;
    return [NSNumber numberWithInt:randomNumber];
}


@end
