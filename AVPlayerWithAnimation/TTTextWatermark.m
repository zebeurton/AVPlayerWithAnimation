//
//  TTTextWatermark.m
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTextWatermark.h"

@implementation TTTextWatermark
@synthesize text = _text;

- (id) initWithText:(NSString *)text
{
    if (self = [super init]) {
        self.text = text;
    }
    
    return self;
}
@end
