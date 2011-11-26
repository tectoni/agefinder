//
//  MyDocument_Pasteboard.m
//  TetLab
//
//  Created by Peter Appel on 12/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MyDocument_Pasteboard.h"


@implementation MyDocument(Pasteboard)


/* Methods for writing to the pasteboard */



- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type 
{
	BOOL result = NO;
    NSArray *transactions = [analysisController selectedObjects];
	NSMutableString *csvString = [NSMutableString string];
    NSEnumerator *pointEnum = [transactions objectEnumerator];
    id dat;
    while ( dat = [pointEnum nextObject] ) {
       NSNumber *ident = [dat valueForKey:@"analysisID"];
        NSNumber *th = [dat valueForKey:@"thContent"];
		NSNumber *therr = [dat valueForKey:@"thErr"];
		NSNumber *u = [dat valueForKey:@"uContent"];
        NSNumber *uerr = [dat valueForKey:@"uErr"];
		NSNumber *pb = [dat valueForKey:@"pbContent"];
        NSNumber *pberr = [dat valueForKey:@"pbErr"];
        NSNumber *age = [dat valueForKey:@"age"];
		NSNumber *ageerr = [dat valueForKey:@"ageErr"];
		NSNumber *thstar = [dat valueForKey:@"thStar"];
		NSNumber *thstarerr = [dat valueForKey:@"thStarErr"];
        [csvString appendString:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\n", ident, th, therr, u, uerr, pb, pberr, age, ageerr, thstar, thstarerr ]]; // Tab delimited data
    }

// add the string representation
if ( [type isEqualToString:NSStringPboardType] ) 
	{
	result = [pboard setString:(NSString *)csvString forType:type];
	NSLog(@"pboard %@  %@", csvString, type);
	NSLog(@"pboard %@",[pboard stringForType:NSStringPboardType]);
	}
return result;
 
}


-(void)copy:(id)sender
{
NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
NSPasteboard *pb = [NSPasteboard generalPasteboard];
[pb declareTypes:types owner:self];
[self writeSelectionToPasteboard:pb type:NSStringPboardType];
}





/* Methods for reading from the pasteboard */


-(void)paste:(id)sender
{
NSPasteboard *pb = [NSPasteboard generalPasteboard];
if (![self canTakeValueFromPasteboard:pb])
	{ NSBeep();}
}



-(BOOL)canTakeValueFromPasteboard:(NSPasteboard *)pb
{
	NSString *value;
	NSString *type;
	type =[pb availableTypeFromArray:[NSArray arrayWithObject: NSStringPboardType]];
	if (type) {
		value = [pb stringForType:NSStringPboardType];
		NSLog(@"pasteboard %@", value);
		[self createRecordsFromPasteboard:value];
		return YES;
		}
return NO;
}


-(void)cut:(id)sender
{
}


@end
