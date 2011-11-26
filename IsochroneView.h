//
//  IsochroneView.h
//  DataLister
//
//  Created by Peter Appel on 30/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "York.h"
@class Analysis;
@class SelData;

@interface IsochroneView : NSView
{
	IBOutlet NSTableView *selTable;
	IBOutlet NSWindow *window;
	IBOutlet NSMenu *zoomMenu;
	IBOutlet NSArrayController *analysisController;
	NSMutableArray *selArray;

	NSMutableArray *x;
	NSMutableArray *y;
	NSMutableArray *xerr;
	NSMutableArray *yerr;
	NSMutableDictionary *attributes;
	NSArray *intervallCounts;
	float xMax, xMin, yMax, yMin;
//	float sigma;
	NSMutableDictionary *bindingInfo;
	NSMutableArray *allDataArray;
	NSArray *oldAnalysis;
	BOOL ppmMode;
    

    
}


-(void)setAllDataArray:(NSMutableArray*)array;


- (void)startObservingAnalysis:(NSArray *)analysis;
- (void)stopObservingAnalysis:(NSArray *)analysis;

- (NSArray *)oldAnalysis;
- (void)setOldAnalysis:(NSArray *)anOldAnalysis;


-(IBAction)zoomLevel:(id)sender;
-(IBAction)savePDF:(id)sender;

-(void)prepareAttributes;


-(void)setSelArray:(NSMutableArray *)aSelArray;
-(NSMutableArray *)selArray;

-(void)setXMin:(float)x;
-(void)setXMax:(float)x;
-(void)setYMax:(float)x;
-(void)setYMin:(float)x;
-(BOOL)setPPMMode:(BOOL)ppm;


-(void)setX:(NSMutableArray*)array;	// Th*
-(NSMutableArray *)x;
-(void)setY:(NSMutableArray*)array;	// pb
-(NSMutableArray *)y;

-(void)setXerr:(NSMutableArray*)array;
-(NSMutableArray *)xerr;
-(void)setYerr:(NSMutableArray*)array;
-(NSMutableArray *)yerr;


- (NSDictionary *)infoForBinding:(NSString *)bindingName;
- (id)analysisContainer;
- (NSString *)analysisKeyPath; 
- (id)selectionIndexesContainer;
- (NSString *)selectionIndexesKeyPath; 
- (NSArray *)analysis;
- (NSIndexSet *)selectionIndexes;

@end
