//
//  HowToPlayViewController.m
//  Zoo
//
//  Created by Aaron Morais on 2013-04-13.
//
//

#import "HowToPlayViewController.h"
#define K_NUMBER_OF_IMAGES 20

@interface HowToPlayViewController ()
    @property (nonatomic, strong) UIImageView *htpImageView;
    @property (nonatomic, strong) UIButton *nextButton;
    @property (nonatomic, strong) UIButton *prevButton;
    @property (nonatomic, strong) UIButton *dismissButton;
    @property (nonatomic, strong) UIButton *playButton;
    @property (nonatomic, assign) int currentImageIndex;
@end

@implementation HowToPlayViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat viewWidth = self.view.frame.size.height;
    CGFloat viewHeight = self.view.frame.size.width;
    
    self.htpImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.htpImageView];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.nextButton.frame = CGRectMake(viewWidth - 60, viewHeight - 60, 50, 50);
    [self.nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(displayNextImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.prevButton setTitle:@"PREV" forState:UIControlStateNormal];
    self.prevButton.frame = CGRectMake(10, viewHeight - 60, 50, 50);
    [self.prevButton addTarget:self action:@selector(displayPreviousImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.prevButton];
    
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.dismissButton.frame = CGRectMake(viewWidth - 60, 10, 50, 50);
    [self.dismissButton setTitle:@"Main Menu" forState:UIControlStateNormal];
    self.dismissButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.dismissButton addTarget:self action:@selector(dismissViewModalViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playButton.frame = CGRectMake(floorf(viewWidth/2) - 25, viewHeight - 100, 50, 50);
    [self.playButton setTitle:@"PLAY" forState:UIControlStateNormal];
    self.playButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    [self displayImageWithIndex:1 WithAnimation:NO];
}

- (void) displayNextImage {
    int nextImageIndex = [self getNextImageIndex];
    [self displayImageWithIndex:nextImageIndex WithAnimation:YES];
}

- (void) displayPreviousImage {
    int nextImageIndex = [self getPreviousImageIndex];
    [self displayImageWithIndex:nextImageIndex WithAnimation:YES];
}

- (int)getNextImageIndex {
    int number = self.currentImageIndex + 1;
    if(number > K_NUMBER_OF_IMAGES) {
        number = K_NUMBER_OF_IMAGES;
    }
    return number;
}

- (int)getPreviousImageIndex {
    int number = self.currentImageIndex - 1;
    if(number < 0) {
        number = 0;
    }
    return number;
}

- (void) displayImageWithIndex:(int)nextTipIndex WithAnimation:(BOOL)animated {
    self.currentImageIndex = nextTipIndex;
    NSString *imageString = [NSString stringWithFormat:@"htp/%d", nextTipIndex];
    [UIView transitionWithView:self.view
                      duration:animated ? 0.5f : 0.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        UIImage *image = [UIImage imageNamed:imageString];
                        self.htpImageView.image = image;
                        [self.htpImageView sizeToFit];
                    } completion:nil];    
    if(self.currentImageIndex <= 1) {
        [self.prevButton setHidden:YES];
    } else {
        [self.prevButton setHidden:NO];
    }
    if(self.currentImageIndex >= K_NUMBER_OF_IMAGES) {
        [self.nextButton setHidden:YES];
        [self.playButton setHidden:NO];
    } else {
        [self.nextButton setHidden:NO];
        [self.playButton setHidden:YES];
    }
}

- (void) playButtonPressed {
    [self dismissViewModalViewController];
    [self.delegate playGame];
}

- (void) dismissViewModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    [self.dismissButton sizeToFit];
//    [self.dismissButton setFrame:CGRectIntegral(CGRectMake(self.containerView.frame.size.width - self.dismissButton.frame.size.width - 15, 20, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height))];
//    
//    [self.tipImageView sizeToFit];
//    [self.tipImageView setFrame:CGRectIntegral(CGRectMake((self.containerView.frame.size.width - self.tipImageView.frame.size.width) /2, 50, self.tipImageView.frame.size.width, self.tipImageView.frame.size.height))];
//    
//    [self.separator setFrame:CGRectIntegral(CGRectMake(20, self.tipImageView.frame.size.height + self.tipImageView.frame.origin.y + 10, self.containerView.frame.size.width - 40, 5))];
//    
//    //center the next tip button between the separator and the border
//    [self.nextTipButton sizeToFit];
//    [self.nextTipButton setCenter: CGPointMake(floorf(self.separator.center.x), floorf(self.separator.frame.origin.y + ((self.containerView.frame.size.height - self.separator.frame.origin.y)/2)) )];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
