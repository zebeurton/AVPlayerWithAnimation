//
//  TTPlayerViewController.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>
#import "TTViewController.h"
#import "TTImageLayer.h"
#import "TTImageWatermark.h"
#import "TTWatermark.h"
#import "TTTextWatermark.h"

static void *MoviePlayerStatusObservationContext = &MoviePlayerStatusObservationContext;
static void *MoviePlayerReadyToDisplayObservationContext = &MoviePlayerReadyToDisplayObservationContext;

@interface TTViewController ()
@property (strong, nonatomic) AVPlayer* moviePlayer;
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
    //self.watermark = [[TTTextWatermark alloc] initWithText:@"CoreAnimation rocks!"];
    self.watermark.fromPosition = CGPointMake (0, self.view.frame.size.width / 2);
    self.watermark.toPosition = CGPointMake(self.view.frame.size.height, self.view.frame.size.width / 2);
    
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
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:item];
    [self.moviePlayer addObserver:self forKeyPath:@"status" options:0 context:MoviePlayerStatusObservationContext];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
        
    [_moviePlayer removeObserver:self forKeyPath:@"status" context:MoviePlayerStatusObservationContext];
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
    if (context == MoviePlayerStatusObservationContext) {
        if (self.moviePlayer.status == AVPlayerStatusReadyToPlay) {
            // MoviePlayer is initialized, we can add the MoviePlayerLayer and launch the video
            CGRect outbounds = self.view.frame;
            self.moviePlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
            self.moviePlayerLayer.frame = outbounds;
            self.moviePlayerLayer.position = CGPointMake(outbounds.size.height / 2, outbounds.size.width / 2);
            self.moviePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.view.layer addSublayer:self.moviePlayerLayer];
            [self.moviePlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:MoviePlayerReadyToDisplayObservationContext];

            self.watermarkLayer = [[TTImageLayer alloc] initWithImageName:((TTImageWatermark*)self.watermark).imageName];  
            self.watermarkLayer.anchorPoint = CGPointMake(0, 0.5);
            self.watermarkLayer.hidden = YES;
            //CATextLayer *textLayer = [CATextLayer layer];
            //textLayer.bounds = CGRectMake(0.0f, 0.0f, 300.0f, 30.0f);
            //textLayer.string = ((TTTextWatermark*)self.watermark).text;
            //textLayer.position = CGPointMake(self.watermark.fromX, self.watermark.fromY);
            //textLayer.font = CTFontCreateWithName( (CFStringRef)@"Courier", 0.0, NULL);
            //textLayer.fontSize = 20;
            //textLayer.wrapped = YES;
            //textLayer.alignmentMode = kCAAlignmentCenter;
            //textLayer.anchorPoint = CGPointMake(0, 0);
            //self.watermarkLayer = textLayer;
            [self.view.layer insertSublayer:self.watermarkLayer above:self.moviePlayerLayer];
        
            AVPlayerItem *item = self.moviePlayer.currentItem;
            CABasicAnimation *animation = [CABasicAnimation animation];
            animation.fromValue = [NSValue valueWithCGPoint:self.watermark.fromPosition];
            animation.toValue = [NSValue valueWithCGPoint:self.watermark.toPosition];
            animation.removedOnCompletion = NO;
            animation.beginTime = AVCoreAnimationBeginTimeAtZero;
            animation.duration = CMTimeGetSeconds(item.duration) / 4;
            animation.fillMode = kCAFillModeForwards;
            animation.repeatCount = 2;
            [self.watermarkLayer addAnimation:animation forKey:@"position"];
        }
    }
    else if (context == MoviePlayerReadyToDisplayObservationContext) {
        [self.moviePlayerLayer removeObserver:self forKeyPath:@"readyForDisplay" context:MoviePlayerReadyToDisplayObservationContext];

        self.watermarkLayer.hidden = NO;

        AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:self.moviePlayer.currentItem];
        [syncLayer addSublayer:self.watermarkLayer];
        [self.view.layer addSublayer:syncLayer];
        
        [self.moviePlayer play];
    }
}
@end