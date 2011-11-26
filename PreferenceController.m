//
//  PreferenceController.m
//  Mogeva - aka AgeFinder
//
//  Created by Peter Appel on 06/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

NSString *MOGUnitsKey = @"PPMFlag";
NSString *MOGIsoXMax = @"XMax";
NSString *MOGIsoYMax = @"YMax";



@implementation PreferenceController


-(id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}


- (void)windowDidLoad
{
	[unitsSelectorButton selectCellWithTag:[self ppmUnits]];

}

-(BOOL)ppmUnits
{
	NSLog(@"Preference controller ppmUnits ");

	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:MOGUnitsKey];
}

-(float)isoXMax
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults floatForKey:MOGIsoXMax];
}

-(float)isoYMax
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults floatForKey:MOGIsoYMax];
}



-(IBAction)changeUnitsInInterface:(id)sender
{

	[[NSUserDefaults standardUserDefaults] setBool:[[sender selectedCell] tag] forKey:MOGUnitsKey];
	NSLog(@"begin Sending notification MOGUnitsKey changed ");


	switch ([[sender selectedCell] tag])
	{
		case 0: 
			{
				[[NSUserDefaults standardUserDefaults] setFloat:20.0 forKey:MOGIsoXMax];
				[[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:MOGIsoYMax];

				NSLog(@"Sending notification MOGUnitsKey changed 0");
				break;

			}
		case 1:
			{
				[[NSUserDefaults standardUserDefaults] setFloat:20000. forKey:MOGIsoXMax];
				[[NSUserDefaults standardUserDefaults] setFloat:1000. forKey:MOGIsoYMax];

				NSLog(@"Sending notification MOGUnitsKey changed 1 %i", [self ppmUnits]);
				break;

			}
}
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	NSLog(@"End Sending notification MOGUnitsKey changed");
	[nc postNotificationName:@"MOGUnitsChanged" object:self];

}

@end
