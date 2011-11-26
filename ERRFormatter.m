//
//  ERRFormatter.m
//  AgeFinder
//
//  Created by Peter Appel on 06/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ERRFormatter.h"

@implementation ERRFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%.1f", [anObject  floatValue]];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error
{
    float floatResult;
    NSScanner *scanner;
    BOOL returnValue = NO;
	
    scanner = [NSScanner scannerWithString: string];
//    [scanner scanString: @"$" intoString: NULL];    //ignore  return value
    if ([scanner scanFloat:&floatResult] && ([scanner isAtEnd])) {
        returnValue = YES;
        if (obj)
            *obj = [NSNumber numberWithFloat:floatResult];
    } else {
        if (error)
            *error = NSLocalizedString(@"Couldn’t convert  to float", @"Error converting");
    }
    return returnValue;
}

@end
