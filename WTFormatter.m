#import "WTFormatter.h"

@implementation WTFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%.4f", [anObject  floatValue]];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error
{
    float floatResult;
    NSScanner *scanner;
    BOOL returnValue = NO;
	
    scanner = [NSScanner scannerWithString: string];
  //  [scanner scanString: @"$" intoString: NULL];    //ignore  return value
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
