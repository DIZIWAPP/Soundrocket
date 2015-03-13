//
//  UIViewController+ShakeGesture.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "UIViewController+ShakeGesture.h"

@implementation UIViewController (ShakeGesture)
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    #ifdef DEBUG
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        NSLog(@"SHAKE IT LIKE A POLAROID PICTURE, SHAKE IT SHAKE IT ...");
    }
    #endif
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}
@end
