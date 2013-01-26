#import "cocos2d.h"

@protocol CommonPauseLayerDelegate<NSObject>
@end

@interface CommonPauseLayer : CCLayerColor {

    id<CommonPauseLayerDelegate> delegate;
}

-(id)initWithColor:(ccColor4B)aColor
        withTarget:(id<CommonPauseLayerDelegate>)aDelegate;
        

@property (nonatomic, retain) id<CommonPauseLayerDelegate> delegate;

@end
