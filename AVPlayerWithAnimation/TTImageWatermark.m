//
//  TTImageWatermark.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTImageWatermark.h"

@implementation TTImageWatermark
@synthesize imageName = _imageName;

-(id) initWithImageName:(id)name
{
    if (self = [super init]) {
        self.imageName = name;
    }
    
    return self;
}
@end
