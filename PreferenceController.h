//
//  PreferenceController.h
//  Mogeva
//
//  Created by Peter Appel on 06/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString *MOGUnitsKey;
extern NSString *MOGIsoXMax;
extern NSString *MOGIsoYMax;


@interface PreferenceController : NSWindowController {
IBOutlet NSMatrix *unitsSelectorButton;

}

-(float)isoXMax;
-(float)isoYMax;

-(IBAction)changeUnitsInInterface:(id)sender;
-(BOOL)ppmUnits;

@end
