//
//  AppController.h
//  Mogeva
//
//  Created by Peter Appel on 26/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class PreferenceController;

@interface AppController : NSObject {
	PreferenceController *preferenceController;
}
- (IBAction)showPreferencePanel:(id)sender;

@end
