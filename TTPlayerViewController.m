//
//  TTPlayerViewController.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TTPlayerViewController.h"
#import "TTPlaybackView.h"

@interface TTPlayerViewController ()

@end

@implementation TTPlayerViewController
@synthesize moviePlayer = _moviePlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:@"http://www.samkeeneinteractivedesign.com/videos/littleVid3.mp4"];
    self.moviePlayer = [AVPlayer playerWithURL:url];
    [_moviePlayer addObserver:self forKeyPath:@"status" options:0 context: nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _moviePlayer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (_moviePlayer.status == AVPlayerStatusReadyToPlay) {
        [(TTPlaybackView*)self.view setPlayer:self.moviePlayer];
        [self.moviePlayer play];
    }
}

@end
