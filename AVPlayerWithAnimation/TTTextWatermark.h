//
//  TTTextWatermark.h
//  AVPlayerWithAnimation
//
//  Created by Drugeon-Hamon David on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTWatermark.h"

@interface TTTextWatermark : TTWatermark
@property (copy, nonatomic) NSString *text;

- (id) initWithText: (NSString *) text;
@end
