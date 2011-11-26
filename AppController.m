//
//  AppController.m
//  Mogeva
//
//  Created by Peter Appel on 26/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "PreferenceController.h"


@implementation AppController


+ (void)initialize {
	
	 // Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	// Put defaults in the dictionary
	[defaultValues setObject:[NSNumber numberWithBool:YES]
					  forKey:MOGUnitsKey];
	
	// Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	NSLog(@"registered defaults: %@", defaultValues);
}

- (IBAction)showPreferencePanel:(id)sender
{
	// Is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}


- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}


@end
