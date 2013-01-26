
#import "CommonPauseLayer.h"

@implementation CommonPauseLayer
@synthesize delegate;

-(id)initWithColor:(ccColor4B)aColor
        withTarget:(id<CommonPauseLayerDelegate>)aDelegate
{  
if ((self = [super initWithColor:aColor])) {
		
		self.delegate = aDelegate;
    }
	
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN + 1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)dealloc
{
	self.delegate = nil;
	[super dealloc];
}

@end