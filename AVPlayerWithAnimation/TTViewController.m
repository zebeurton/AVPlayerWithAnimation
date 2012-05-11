//
//  TTPlayerViewController.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreText/CoreText.h>
#import "TTViewController.h"
#import "TTImageLayer.h"
#import "TTImageWatermark.h"
#import "TTWatermark.h"
#import "TTTextWatermark.h"

static void *MoviePlayerStatusObservationContext = &MoviePlayerStatusObservationContext;
static void *MoviePlayerReadyToDisplayObservationContext = &MoviePlayerReadyToDisplayObservationContext;

@interface TTViewController () {
    id _observer;
}
@property (strong, nonatomic) AVPlayer* moviePlayer;
@property (strong, nonatomic) AVPlayerLayer* moviePlayerLayer;
@property (strong, nonatomic) NSMutableArray* watermarkLayers;
@property (strong, nonatomic) NSMutableArray* watermarks;
@property (strong, nonatomic) CATextLayer* timecodeLayer;

- (void) updateTimecode:(CMTime) time;
@end

@implementation TTViewController
@synthesize moviePlayer = _moviePlayer;
@synthesize moviePlayerLayer = _moviePlayerLayer;
@synthesize watermarkLayers = _watermarkLayer;
@synthesize watermarks = _watermark;
@synthesize timecodeLayer = _timecodeLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize the MoviePlayer and its layer
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"littleVid3" withExtension:@"mp4"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:item];
    [self.moviePlayer addObserver:self forKeyPath:@"status" options:0 context:MoviePlayerStatusObservationContext];
    
    _observer = [self.moviePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time){
        [self updateTimecode:time];
    }];
    
    // Initialize the watermarks to add above the video
    self.watermarkLayers = [[NSMutableArray alloc] init];
    self.watermarks = [[NSMutableArray alloc] init];
    TTWatermark *watermark = [[TTImageWatermark alloc] initWithImageName:@"CoreAnimation.png"];
    watermark.fromPosition = CGPointMake (0, self.view.frame.size.width / 2);
    watermark.toPosition = CGPointMake(self.view.frame.size.height, self.view.frame.size.width / 2);
    watermark.duration = CMTimeGetSeconds(item.duration) / 4;
    [self.watermarks addObject:watermark];

    watermark = [[TTTextWatermark alloc] initWithText:@"email@gmail.com"];
    watermark.fromPosition = CGPointMake (self.view.frame.size.height, 0);
    watermark.toPosition = CGPointMake(0, self.view.frame.size.width);
    watermark.duration = CMTimeGetSeconds(item.duration) / 4;
    [self.watermarks addObject:watermark];

    // Create gesture recognizer to handle zoom in / zoom out
    // with double taps with one finger
    UITapGestureRecognizer *oneFingerTwoTaps = 
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom)];
    
    // Set required taps and number of touches
    [oneFingerTwoTaps setNumberOfTapsRequired:2];
    [oneFingerTwoTaps setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [[self view] addGestureRecognizer:oneFingerTwoTaps];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
        
    [_moviePlayer removeObserver:self forKeyPath:@"status" context:MoviePlayerStatusObservationContext];
    [_moviePlayer removeTimeObserver:_observer];
    _observer = nil;
    _moviePlayer = nil;
    
    [_moviePlayerLayer removeFromSuperlayer];
    _moviePlayerLayer = nil;
    
    for (CALayer* watermark in _watermarkLayer) {
        [watermark removeFromSuperlayer];
        [_watermarkLayer removeObject:watermark];
    }
    
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

            // Create watermarks layer
            AVPlayerItem *item = self.moviePlayer.currentItem;
            for (TTWatermark* watermark in self.watermarks) {
                CALayer* watermarkLayer;
                
                if ([watermark isKindOfClass:[TTImageWatermark class]]) {
                    watermarkLayer = [[TTImageLayer alloc] initWithImageName:((TTImageWatermark*)watermark).imageName];  
                    watermarkLayer.anchorPoint = CGPointMake(0, 0.5);
                }
                else if ([watermark isKindOfClass:[TTTextWatermark class]]) {
                    watermarkLayer = [CATextLayer layer];
                    watermarkLayer.borderColor = [UIColor whiteColor].CGColor;
                    watermarkLayer.borderWidth = 1;
                    ((CATextLayer*)watermarkLayer).string = ((TTTextWatermark*) watermark).text;  
                    watermarkLayer.bounds = CGRectMake(0.0f, 0.0f, 200.0f, 15.0f);
                    ((CATextLayer*)watermarkLayer).font = CTFontCreateWithName( (CFStringRef)@"Courier", 0.0, NULL);
                    ((CATextLayer*)watermarkLayer).fontSize = 20;
                    ((CATextLayer*)watermarkLayer).wrapped = YES;
                    ((CATextLayer*)watermarkLayer).alignmentMode = kCAAlignmentLeft;
                    watermarkLayer.anchorPoint = CGPointMake(1, 1);

                }
                watermarkLayer.hidden = YES;
                [self.watermarkLayers addObject:watermarkLayer];
                [self.view.layer insertSublayer:watermarkLayer above:self.moviePlayerLayer];
                
                CABasicAnimation *animation = [CABasicAnimation animation];
                animation.fromValue = [NSValue valueWithCGPoint:watermark.fromPosition];
                animation.toValue = [NSValue valueWithCGPoint:watermark.toPosition];
                animation.removedOnCompletion = NO;
                animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                animation.duration = watermark.duration;
                animation.fillMode = kCAFillModeBoth;
                [watermarkLayer addAnimation:animation forKey:@"position"];
            }

            self.timecodeLayer = [CATextLayer layer];
            self.timecodeLayer.position = CGPointMake(self.view.frame.size.height / 2, 0);
            self.timecodeLayer.bounds = CGRectMake(0.0f, 0.0f, 100.0f, 15.0f);
            self.timecodeLayer.font = CTFontCreateWithName( (CFStringRef)@"Courier", 0.0, NULL);
            self.timecodeLayer.fontSize = 20;
            self.timecodeLayer.wrapped = YES;
            self.timecodeLayer.alignmentMode = kCAAlignmentLeft;
            self.timecodeLayer.anchorPoint = CGPointMake(0.5, 0);
            [self.view.layer insertSublayer:self.timecodeLayer above:self.moviePlayerLayer];
        }
    }
    else if (context == MoviePlayerReadyToDisplayObservationContext) {
        [self.moviePlayerLayer removeObserver:self forKeyPath:@"readyForDisplay" context:MoviePlayerReadyToDisplayObservationContext];
        
        AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:self.moviePlayer.currentItem];

        for (CALayer *layer in self.watermarkLayers) {
            layer.hidden = NO;
            [syncLayer addSublayer:layer];
        }

        [syncLayer addSublayer:self.timecodeLayer];
        [self.view.layer addSublayer:syncLayer];
        
        [self.moviePlayer play];
    }
}

static NSString *timeStringForSeconds(Float64 seconds) {
    NSUInteger hours = seconds / 3600;
    NSUInteger num_seconds = seconds - hours * 3600;
    NSUInteger minutes = num_seconds / 60;
    num_seconds = num_seconds - (minutes * 60);

    NSString *date =  [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, num_seconds];
    return date;
}

- (void) updateTimecode:(CMTime) time
{
    NSString *date = timeStringForSeconds(CMTimeGetSeconds(self.moviePlayer.currentTime));
    NSLog(@"%@", date);
    self.timecodeLayer.string = date;
}
@end