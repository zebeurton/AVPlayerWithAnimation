//
//  TTSprite.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 16/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTImageLayer.h"

@interface TTImageLayer ()
@property (strong, nonatomic) UIImage *image;
@end

@implementation TTImageLayer
@synthesize image = _image;

// initWithImageName
//
// Init method for the object
- (id) initWithImageName:(NSString *)name
{
    if (self = [super init])
    {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.image = [UIImage imageNamed:name];
        self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        self.contents = (id) self.image.CGImage;
    }
    
    return self;
}

- (void) dealloc
{
    _image = nil;
}


@end
