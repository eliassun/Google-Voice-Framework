//
//  GVMissedCall.m
//  GVFramework
//
//  Created by Stuart Moore on 4/15/14.
//  Copyright (c) 2014 Stuart J. Moore. All rights reserved.
//

#import "GVMissedCall.h"

@implementation GVMissedCall

- (GVMessageType)type {
    return GVMessageTypeMissedCall;
}

- (NSString*)text {
    return nil;
}

@end
