//
//  TTPlaybackView.h
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface TTPlaybackView : UIView
@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
