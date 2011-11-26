//
//  Composition2AgeTransformer.m
//  DataLister
//
//  Created by Peter Appel on 16/09/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Composition2AgeTransformer.h"


@implementation Composition2AgeTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}


- (id)transformedValue:(id)value
{
    float th, u, pb;
    float ageOutputValue;

    if (value == nil) return nil;

    // Attempt to get a reasonable value from the
    // value object.


}


@end
