//
//  TTPlayerViewController.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TTViewController.h"
#import "TTImageLayer.h"
#import "TTImageWatermark.h"
#import "TTWatermark.h"

static void *TTViewControllerStatusObservationContext = &TTViewControllerStatusObservationContext;

@interface TTViewController ()
@property (strong, nonatomic) AVPlayerLayer* moviePlayerLayer;
@property (strong, nonatomic) CALayer* watermarkLayer;
@property (strong, nonatomic) TTWatermark *watermark;
@end

@implementation TTViewController
@synthesize moviePlayer = _moviePlayer;
@synthesize moviePlayerLayer = _moviePlayerLayer;
@synthesize watermarkLayer = _watermarkLayer;
@synthesize watermark = _watermark;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize the watermark to add above the video
    self.watermark = [[TTImageWatermark alloc] initWithImageName:@"CoreAnimation.png"];
    self.watermark.x = self.view.frame.size.height / 2;
    self.watermark.y = self.view.frame.size.width / 2;
    
    // Create gesture recognizer to handle zoom in / zoom out
    // with double taps with one finger
    UITapGestureRecognizer *oneFingerTwoTaps = 
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom)];
    
    // Set required taps and number of touches
    [oneFingerTwoTaps setNumberOfTapsRequired:2];
    [oneFingerTwoTaps setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [[self view] addGestureRecognizer:oneFingerTwoTaps];

    // Initialize the MoviePlayer and its layer
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"littleVid3" withExtension:@"mp4"];
    self.moviePlayer = [AVPlayer playerWithURL:url];
    [self.moviePlayer addObserver:self forKeyPath:@"status" options:0 context:TTViewControllerStatusObservationContext];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_moviePlayer removeObserver:self forKeyPath:@"status" context:TTViewControllerStatusObservationContext];
    _moviePlayer = nil;
    
    [_moviePlayerLayer removeFromSuperlayer];
    _moviePlayerLayer = nil;
    
    [_watermarkLayer removeFromSuperlayer];
    _watermarkLayer = nil;
}

- (void)handleZoom
{
    if (self.moviePlayerLayer.videoGravity == AVLayerVideoGravityResizeAspect) {
        self.moviePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    else {
        self.moviePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (self.moviePlayer.status == AVPlayerStatusReadyToPlay) {
        // MoviePlayer is initialized, we can add the MoviePlayerLayer and launch the video
        CGRect outbounds = self.view.frame;
        self.moviePlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        self.moviePlayerLayer.frame = outbounds;
        self.moviePlayerLayer.position = CGPointMake(outbounds.size.height / 2, outbounds.size.width / 2);
        self.moviePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:self.moviePlayerLayer];

        self.watermarkLayer = [[TTImageLayer alloc] initWithImageName:((TTImageWatermark*)self.watermark).imageName];
        self.watermarkLayer.position = CGPointMake(self.watermark.x, self.watermark.y);
        [self.view.layer insertSublayer:self.watermarkLayer above:self.moviePlayerLayer];
        
        [self.moviePlayer play];
        
    }
}
@end
