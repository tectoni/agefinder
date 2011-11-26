//
//  MyDocument.m
//  DataLister
//
//  Created by Peter Appel on 14/05/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "MyDocument.h"
#import "IsochroneView.h"
#import "DiagramView.h"
#import "Analysis.h"
#import "York.h"
#import "SelData.h"
#import "PreferenceController.h"
#import "Headers.h"
#import "WTFormatter.h"
#import "PPMFormatter.h"
#import "ERRFormatter.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    containsData=NO;

	daten = [[NSMutableArray alloc]init];
    selArray = [[NSMutableArray alloc]init];
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
	[diagramView setXMin:[textFieldHistoMinX floatValue]];
	[diagramView setXMax:[textFieldHistoMaxX floatValue]];
	[diagramView setYMax:[textFieldHistoMaxY floatValue]];
	[isochroneView setXMin:[textFieldIsoMinX floatValue]];
	[isochroneView setXMax:[textFieldIsoMaxX floatValue]];
	[isochroneView setYMin:[textFieldIsoMinY floatValue]];
	[isochroneView setYMax:[textFieldIsoMaxY floatValue]];
	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
			selector:@selector(handleTableChange:)
			name:@"MOGUnitsChanged"
			object:nil];
    }
 return self;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
//	NSLog(@"windowWillClose:");
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
//	NSLog(@"Unregistered with notification center: %@", [self fileName]);
}


-(void)handleTableChange:(NSNotification *)note
{
	PreferenceController *sender = [note object];
	[self updateTableHeaders:[sender ppmUnits]];
	
	
	[largeDateTable setNeedsDisplay:YES];

if ( [[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey] )
			{
			[textFieldIsoMaxX setFloatValue: 22000.];
			[textFieldIsoMaxY setFloatValue: 1100.];
			}
			else {
				[textFieldIsoMaxX setFloatValue: 20.];
				[textFieldIsoMaxY setFloatValue: 10.];
				}


[isochroneView setXMax:[textFieldIsoMaxX floatValue]];
[isochroneView setYMax:[textFieldIsoMaxY floatValue]];
[isochroneView setPPMMode:[[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey]];
[self updateDiagram:self];

}


-(void)updateTableHeaders:(BOOL)isppm
{
NSLog(@"Reveiving from  notification center");
NSTableHeaderCell *headerACell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerBCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerCCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerDCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerAerrCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerBerrCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerCerrCell = [[NSTableHeaderCell alloc] init];
NSTableHeaderCell *headerDerrCell = [[NSTableHeaderCell alloc] init];

if (isppm) {
	[headerACell setTitle:@"Th ppm"];
	[headerACell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Th"] setHeaderCell:headerACell];
	[[[largeDateTable tableColumnWithIdentifier:@"Th"] dataCell] setFormatter:ppmFormatter];
	[headerACell release];

	[headerBCell setTitle:@"U ppm"];
	[headerBCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"U"] setHeaderCell:headerBCell];
	[[[largeDateTable tableColumnWithIdentifier:@"U"] dataCell] setFormatter:ppmFormatter];
	[headerBCell release];

	[headerCCell setTitle:@"Pb ppm"];
	[headerCCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Pb"] setHeaderCell:headerCCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Pb"] dataCell] setFormatter:ppmFormatter];
	[headerCCell release];

	[headerDCell setTitle:@"Th* ppm"];
	[headerDCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"ThSt"] setHeaderCell:headerDCell];
	[[[largeDateTable tableColumnWithIdentifier:@"ThSt"] dataCell] setFormatter:ppmFormatter];
	[headerDCell release];

	[headerAerrCell setTitle:@"Th err"];
	[headerAerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Therr"] setHeaderCell:headerAerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Therr"] dataCell] setFormatter:errFormatter];
	[headerAerrCell release];

	[headerBerrCell setTitle:@"U err"];
	[headerBerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Uerr"] setHeaderCell:headerBerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Uerr"] dataCell] setFormatter:errFormatter];
	[headerBerrCell release];

	[headerCerrCell setTitle:@"Pb err"];
	[headerCerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Pberr"] setHeaderCell:headerCerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Pberr"] dataCell] setFormatter:errFormatter];
	[headerCerrCell release];

	[headerDerrCell setTitle:@"Th* err"];
	[headerDerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"ThSterr"] setHeaderCell:headerDerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"ThSterr"] dataCell] setFormatter:errFormatter];
	[headerDerrCell release];

//	[textFieldIsoMaxX setFloatValue: 22000.];
//	[textFieldIsoMaxY setFloatValue: 1100.];
//	imaxx = imaxx * 0.878809 * 1000.;
//	imaxy = imaxy * 0.928318 * 1000.;
	//[textFieldIsoMaxX setFloatValue: imaxx]; // collidiert noch mit aus Archiv gelesenen Werten 
	//[textFieldIsoMaxY setFloatValue: imaxy];
}

else {
	[headerACell setTitle:@"ThO2 wt%"];
	[headerACell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Th"] setHeaderCell:headerACell];
	[[[largeDateTable tableColumnWithIdentifier:@"Th"] dataCell] setFormatter:wtFormatter];
	[headerACell release];

	[headerBCell setTitle:@"UO2 wt%"];
	[headerBCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"U"] setHeaderCell:headerBCell];
	[[[largeDateTable tableColumnWithIdentifier:@"U"] dataCell] setFormatter:wtFormatter];
	[headerBCell release];

	[headerCCell setTitle:@"PbO wt%"];
	[headerCCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Pb"] setHeaderCell:headerCCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Pb"] dataCell] setFormatter:wtFormatter];
	[headerCCell release];

	[headerDCell setTitle:@"ThO2* wt%"];
	[headerDCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"ThSt"] setHeaderCell:headerDCell];
	[[[largeDateTable tableColumnWithIdentifier:@"ThSt"] dataCell] setFormatter:wtFormatter];
	[headerDCell release];
	
	
	[headerAerrCell setTitle:@"ThO2 err"];
	[headerAerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Therr"] setHeaderCell:headerAerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Therr"] dataCell] setFormatter:errFormatter];
	[headerAerrCell release];

	[headerBerrCell setTitle:@"UO2 err"];
	[headerBerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Uerr"] setHeaderCell:headerBerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Uerr"] dataCell] setFormatter:errFormatter];
	[headerBerrCell release];

	[headerCerrCell setTitle:@"PbO err"];
	[headerCerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"Pberr"] setHeaderCell:headerCerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"Pberr"] dataCell] setFormatter:errFormatter];
	[headerCerrCell release];

	[headerDerrCell setTitle:@"ThO2* err"];
	[headerDerrCell setAlignment:NSCenterTextAlignment];
	[[largeDateTable tableColumnWithIdentifier:@"ThSterr"] setHeaderCell:headerDerrCell];
	[[[largeDateTable tableColumnWithIdentifier:@"ThSterr"] dataCell] setFormatter:errFormatter];
	[headerDerrCell release];

	//imaxx = imaxx / 0.878809 / 1000.;
	//imaxy = imaxy / 0.928318 / 1000.;

//	[textFieldIsoMaxX setFloatValue: 20.];
//	[textFieldIsoMaxY setFloatValue: 1.];

	//[textFieldIsoMaxX setFloatValue: imaxx]; // collidiert noch mit aus Archiv gelesenen Werten 
	//[textFieldIsoMaxY setFloatValue: imaxy];
	}
}





/***************************************************************************
daten
***************************************************************************/




- (void)startObservingAnalysis:(Analysis *)analysis
{
	[analysis addObserver:self
			forKeyPath:@"age"
			options:NSKeyValueObservingOptionOld
			context:NULL];
			
	[analysis addObserver:self
			forKeyPath:@"ageErr"
			options:NSKeyValueObservingOptionOld
			context:NULL];
}

- (void)stopObservingAnalysis:(Analysis *)analysis
{
	[analysis removeObserver:self forKeyPath:@"age"];
	[analysis removeObserver:self forKeyPath:@"ageErr"];
}

- (void)insertObject:(Analysis *)a inDatenAtIndex:(int)index
{
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromDatenAtIndex:index];
	if (![undo isUndoing]) {
		[undo setActionName:@"Insert Analysis"];
		}
	[self startObservingAnalysis:a];
	[daten insertObject:a atIndex:index];
}

-(void)remove:(id)sender
{
	if ([selArray count] > 0) {
		NSArray *selection = [analysisController selectedObjects];
		int choice = NSRunAlertPanel(@"Delete",@"If you delete % d data, all selections will also be removed. Do you relly want to do this?",@"Delete",@"Cancel", nil, [selection count]);
		if (choice == NSAlertDefaultReturn) {
			[analysisController remove:sender];
			}
		}
	else
	{		[analysisController remove:sender]; }
	
}

- (void)removeObjectFromDatenAtIndex:(int)index
{
	Analysis *a = [daten objectAtIndex:index];
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:a inDatenAtIndex:index];
	if (![undo isUndoing]) {
		[undo setActionName:@"Delete Daten"];
	}
	[self stopObservingAnalysis:a];
	[daten removeObjectAtIndex:index];
//	[self removeSelectionContainingIndex:index];
	
	
	
	
		[selArray removeAllObjects];

		[self updateDiagram:self];
		[selTable reloadData];
//[self updateDiagram:self];


}

/*
-(void)removeSelectionContainingIndex:(unsigned int)index
{
	int i;
	NSLog(@"name %i",  index  );
	
	for (i = 0; i < [selArray count]; i++) {
		NSIndexSet *selection = [[selArray objectAtIndex:i]sel];
		NSLog(@"name %i %i  %@  %i",  i, index, selection, [selection lastIndex]  );
//		if ([selection lastIndex] > index-1)
		if ([selection containsIndex: index])
			[selArray removeObjectAtIndex:i];
	}
	[self updateDiagram:self];
//	[diagramView setNeedsDisplay:YES];
	[selTable reloadData];
	
} 
*/


-(NSMutableArray *)daten {return daten;}

- (void)setDaten:(NSMutableArray *)array	
{
	NSLog(@"setDaten");
	if (array == daten) 
		return;
	NSEnumerator *e = [daten objectEnumerator];
	Analysis *analysis;
	while (analysis = [e nextObject]) {
		[self stopObservingAnalysis:analysis];
	}
	
	[daten release];
	[array retain];
	daten = array;
	
	e = [daten objectEnumerator];
	while (analysis = [e nextObject]) {
		[self startObservingAnalysis:analysis];
		}
			NSLog(@"setDaten update");

		[self updateSel];
}

-(void)setLocs
{
float xAxisLength = 500;
float yAxisLength = 350;	// diese beiden Variablen müssten besser vom isochroneView geholt werden.
float xStep, yStep;
int index;
 xStep = xAxisLength/([textFieldIsoMaxX floatValue]-[textFieldIsoMinX floatValue]);
 yStep = yAxisLength/([textFieldIsoMaxY floatValue]-[textFieldIsoMinY floatValue]);
// Calculate the locs of the data points
	float x_, y_;


	for(index = 0; index < [daten count]; index++) {
		id dat =	[daten objectAtIndex: index] ;
		y_	=	([[dat valueForKey:@"pbContent"] floatValue] - [textFieldIsoMinY floatValue]) * yStep;
		x_	=	([[dat valueForKey:@"thStar"] floatValue] - [textFieldIsoMinX floatValue]) * xStep;
//		NSLog(@"x y %f  %f   %i", x_, y_, index);
		[dat setXLoc: x_];
		[dat setYLoc: y_];
		}
}

/***************************************************************************
selectionArray
***************************************************************************/



- (NSMutableArray *)selArray {return selArray;}

- (void)startObservingSelArray:(SelData *)aSel
{
	[aSel addObserver:self
			forKeyPath:@"countOfSel"
			options:NSKeyValueObservingOptionOld
			context:NULL];
			
	[aSel addObserver:self
			forKeyPath:@"noOfSel"
			options:NSKeyValueObservingOptionOld
			context:NULL];
			
						
	[aSel addObserver:self
			forKeyPath:@"selectedAnalyses"
			options:NSKeyValueObservingOptionOld
			context:NULL];
}

- (void)stopObservingSelArray:(SelData *)aSel
{
	[aSel removeObserver:self forKeyPath:@"countOfSel"];
	[aSel removeObserver:self forKeyPath:@"noOfSel"];
	[aSel removeObserver:self forKeyPath:@"selectedAnalyses"];

}


//Anstelle der Methode add: des NSArrayControllers wird hier das neue Objekt 
// mit definierten Daten initialisiert und dann mit addObject zugefügt

-(IBAction)createSel:(id)sender
{
Fitdata fit; 
float wixi, wi, tmp1, tmp2, X2;
float suwixi = 0;
float suwi = 0;
	[self broadcastSelAdd];
	SelData *newSel = [selectionController newObject]; 
	[newSel setCountOfSel:[selArray count]+1];
	[newSel setNoOfPoints:[[analysisController selectionIndexes] count]];
	[newSel setSel:[analysisController selectedObjects]];
	
//	NSLog(@"name %i",  [newSel countOfSel] );
// NSLog(@"indexes %@", [analysisController selectionIndexes]);

int N = [newSel noOfPoints];
float *xVal = malloc (sizeof (float) * N);
float *yVal = malloc (sizeof (float) * N);
float *errx = malloc (sizeof (float) * N);
float *erry = malloc (sizeof (float) * N);
int index = 0;
//	int	k = [[newSel sel] firstIndex];
	NSEnumerator *enumerator = [[newSel sel] objectEnumerator];
//	id anObject;
	id dat;
		while (dat = [enumerator nextObject])
				{
//				id dat = [daten objectAtIndex: k] ;
				xVal[index] = [[dat valueForKey:@"thStar"] floatValue];
				yVal[index] = [[dat valueForKey:@"pbContent"] floatValue];
				errx[index] = [[dat valueForKey:@"thStarErr"] floatValue] * xVal[index] / 100.0;
				erry[index] = [[dat valueForKey:@"pbErr"] floatValue] * yVal[index] / 100.0;
//				NSLog(@"x  %f y  %f  errx  %f  erry   %f no of data %i", xVal[index], yVal[index], errx[index], erry[index], N);

				tmp1 = sqrt(pow([[dat valueForKey:@"thStarErr"] floatValue], 2) + pow([[dat valueForKey:@"pbErr"] floatValue], 2));
				tmp2 = tmp1 * [[dat valueForKey:@"age"] floatValue] / 100.0;
				wi = 1 / pow(tmp2, 2);
				wixi = wi * [[dat valueForKey:@"age"] floatValue];
				suwixi = suwixi + wixi;
				suwi = suwi + wi;

//				k = [[newSel sel] indexGreaterThanIndex:k];
				index++;
				}
	X2 = [self chi2: newSel];	
	fit = DoYorkRegression( xVal,  yVal,  errx,   erry, N);	
	[newSel setBestimate:(suwixi/suwi)];
	[newSel setErrbestimate:(1/sqrt(suwi))];
	[newSel setIntersect: fit.intersect];
	[newSel setIntererr: fit.interErr];
	[newSel setInclination: fit.inclination];
	[newSel setInclerr: fit.inclErr];
	[newSel setMswd: fit.mswd];
	[newSel setIsoage: fit.age];
	[newSel setIsoageerr: fit.ageErr];
	[newSel setChi2: X2];
	[selectionController addObject:newSel];

	[newSel release];
//	[self setNeedsDisplay:YES];
	[selTable reloadData];
}




-(float)chi2:(SelData *)aSel
{
	// use a C array of integer for basic calculations
	int classCounter[100];			// must be larger than  max. age/widthOfIntervalls
	int index, c;
	
	float ll, chi2, s,sum, mean, stdabw, p;
	float widthOfIntervalls;	// sigma												// 20 Ma
	int numberOfIntervalls = 6;							// 
	NSLog(@"Chi2\n");

float noP = [aSel noOfPoints];
// Berechnung des  Mittelwertes


	NSEnumerator *enumerator = [[aSel sel] objectEnumerator];
	id dat;
	sum = 0.0;
	while (dat = [enumerator nextObject]) {
			sum = sum + [[dat valueForKey:@"age"] floatValue];
			}
	mean = sum/noP;
	
// Berechnung der einfachen Standardabweichung
	sum = 0.0;
	enumerator = [[aSel sel] objectEnumerator];
	while (dat = [enumerator nextObject]) {
			s = s + pow([[dat valueForKey:@"age"] floatValue] - mean, 2);
			}			
	stdabw =  sqrt(s / ([aSel noOfPoints]-1));

// Berechung von Chi2 
	widthOfIntervalls = stdabw;
	for (index = 0; index < numberOfIntervalls; index++) { 
		classCounter[index]=0;
	}	
	ll = mean - 3 * stdabw;

	sum = 0.0;
	enumerator = [[aSel sel] objectEnumerator];
	while (dat = [enumerator nextObject]) {
			c = (int) ([[dat valueForKey:@"age"] floatValue]-ll) / widthOfIntervalls;
			classCounter[c]++; 
			NSLog(@"classCounter[%i] = %i", c, classCounter[c]);
			}			


for (index = 0; index < numberOfIntervalls; index++) { 
	if (index == 0 || index == 5) 
		p = 0.022;
		else 
		if (index == 1 || index == 4)
		p = 0.136;
		else 
		p = 0.341;
	chi2 = chi2 + pow(classCounter[index] - noP * p, 2) / noP / p;
	}
	NSLog(@"Chi2 stdabw %f  mean %f   chi2 %f", stdabw, mean, chi2);

return chi2;
}	





- (void)insertObject:(SelData *)newSel inSelArrayAtIndex:(int)index
{
//		[[self undoManager] registerUndoWithTarget:self selector:nil object:nil];

	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromDatenAtIndex:index];
	if (![undo isUndoing]) {
		[undo setActionName:@"Insert Selection"];
		}
		
	[self broadcastSelAdd];
	[newSel setCountOfSel:[selArray count]+1];
	[newSel setNoOfPoints:[[analysisController selectionIndexes] count]];
	[newSel setSel:[analysisController selectedObjects]];

		
		
	[selArray insertObject:newSel atIndex:index];
//		NSLog(@"selArray" );
	[selTable reloadData];

}

- (void)setSelArray:(NSMutableArray *)array
{
	if (array == selArray) 
		return;
	
	NSEnumerator *e = [selArray objectEnumerator];
	SelData *selData;
	while (selData = [e nextObject]) {
		[self stopObservingSelArray:selData];
	}
	
	[selArray release];
	[array retain];
	selArray = array;
	
	e = [selArray objectEnumerator];
	while (selData = [e nextObject]) {
		[self startObservingSelArray:selData];
		}
}



- (void)broadcastSelAdd
{
//	NSLog(@"broadcastSelAdd");

    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify postNotificationName:@"selectionAdded" object:nil];
}

- (void)broadcastSelRemoved
{
    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify postNotificationName:@"selectionRemoved" object:nil];
}

-(IBAction)deleteSelectedSel:(id)sender
{
	[self broadcastSelRemoved];
	NSIndexSet *rows = [selTable selectedRowIndexes];
	
	if ([rows count] > 0) {
		unsigned int row = [rows lastIndex];
		
		while (row != NSNotFound) {
			[selArray removeObjectAtIndex:row];
			row = [rows indexLessThanIndex:row];
		}
		[diagramView setNeedsDisplay:YES];
		[isochroneView setNeedsDisplay:YES];
		[selTable reloadData];
	} else {
		NSBeep();
	}
}




-(IBAction)updateDiagram:(id)sender
{	
	[[self undoManager] registerUndoWithTarget:self selector:nil object:nil];
	[self buildDiagram];
	[self setLocs];
	[diagramView setNeedsDisplay:YES];
	[isochroneView setNeedsDisplay:YES];
}


- (void)buildDiagram
{
	id dat;
	NSMutableArray *ageArray = [[NSMutableArray alloc] init];
	NSMutableArray *sigmaArray = [[NSMutableArray alloc] init];
	NSMutableArray *yArray = [[NSMutableArray alloc] init];
	NSMutableArray *yerrArray = [[NSMutableArray alloc] init];
	NSMutableArray *xArray = [[NSMutableArray alloc] init];
	NSMutableArray *xerrArray = [[NSMutableArray alloc] init];

//			NSLog(@"daten count  %i", [daten count]);

	NSEnumerator *dataEnum = [daten objectEnumerator];

	while (dat = [dataEnum nextObject]) {
		NSNumber *ag = [dat valueForKey:@"age"];
        NSNumber *si = [dat valueForKey:@"ageErr"];
		NSNumber *y = [dat valueForKey:@"pbContent"];
		NSNumber *x = [dat valueForKey:@"thStar"];
		NSNumber *xerr = [dat valueForKey:@"thStarErr"];
		NSNumber *yerr = [dat valueForKey:@"pbErr"];
		[ageArray addObject:ag];
		[sigmaArray addObject:si];
		[xArray addObject:x];
		[yArray addObject:y];
		[xerrArray addObject:xerr];
		[yerrArray addObject:yerr];
	}

	[diagramView setXMin:[textFieldHistoMinX floatValue]];
	[diagramView setXMax:[textFieldHistoMaxX floatValue]];
	[diagramView setYMax:[textFieldHistoMaxY floatValue]];
	
	[isochroneView setXMin:[textFieldIsoMinX floatValue]];
	[isochroneView setXMax:[textFieldIsoMaxX floatValue]];
	[isochroneView setYMin:[textFieldIsoMinY floatValue]];
	[isochroneView setYMax:[textFieldIsoMaxY floatValue]];

	[diagramView setSelArray:selArray];
	[diagramView setSigma:sigmaArray];
	[diagramView setAge:ageArray];
    [diagramView setAllDataArray: daten];
    [diagramView setSelectedData: [analysisController selectedObjects]];

	[isochroneView setX: xArray];
	[isochroneView setXerr: xerrArray];
	[isochroneView setY: yArray];
	[isochroneView setYerr: yerrArray];
	[isochroneView setSelArray: selArray];
    [ageArray release];
    [sigmaArray release];
    [yArray release];
    [yerrArray release];
    [xArray release];
    [xerrArray release];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	NSLog(@"windowControllerDidLoadNib");

    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	// we can't do these in IB at the moment, as
	// we don't have palette items for them
	[isochroneView bind: @"analysis" toObject: analysisController
		   withKeyPath:@"arrangedObjects" options:nil];
	[isochroneView bind: @"selectionIndexes" toObject: analysisController
		   withKeyPath:@"selectionIndexes" options:nil];
    [diagramView bind: @"analysis" toObject: analysisController
            withKeyPath:@"arrangedObjects" options:nil];
	[diagramView bind: @"selectionIndexes" toObject: analysisController
            withKeyPath:@"selectionIndexes" options:nil];

		   	if (containsData)
			{
				[textFieldHistoMaxX setFloatValue:hmaxx];
				[textFieldHistoMinX setFloatValue:hminx];
				[textFieldHistoMaxY setFloatValue:hmaxy];

				[textFieldIsoMaxX setFloatValue:imaxx];
				[textFieldIsoMinX setFloatValue:iminx];
				[textFieldIsoMaxY setFloatValue:imaxy];
				[textFieldIsoMinY setFloatValue:iminy];

		[self buildDiagram];
		[self updateSel];
	}
	else { if ( [[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey] )
			{
			[textFieldIsoMaxX setFloatValue: 22000.];
			[textFieldIsoMaxY setFloatValue: 1100.];
			}
			else {
				[textFieldIsoMaxX setFloatValue: 20.];
				[textFieldIsoMaxY setFloatValue: 10.];
				}
			}
	

[self updateTableHeaders: [[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey]];		
	
[largeDateTable setNeedsDisplay:YES];

[isochroneView setXMax:[textFieldIsoMaxX floatValue]];
[isochroneView setYMax:[textFieldIsoMaxY floatValue]];
[isochroneView setPPMMode:[[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey]];
[self updateDiagram:self];

	
}



/***************************************************************************
TABLE METHODS
***************************************************************************/

// Delegate methods
- (int)numberOfRowsInTableView:(NSTableView *)table;
{
//	NSLog(@"numberOfRows...");

    return [daten count];
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
	NSLog(@"tableViewSelectionDidChange");
 if ([aNotification object] == selTable) {
//	NSLog(@"true");
	[self updateSel];
	}
	else {
//	NSLog(@"else");
	[selTable deselectAll:nil];
	}
}


/* 
tableViewSelectionDidChange und updateSel sind sehr provisorisch. Da über den SelectionController die Daten der 
Tabelle gebunden sind erfolgt eine Selection und eine tableViewSelectionDidChange Meldung. Da die Meldung in diesem Fall 
von der datenTabelle kommt wird selTable deselektiert. Das ließ sich nicht vermeiden. Daher unten die nochmalige 
aktivierung der Auswahl der selTable.
*/
-(void)updateSel
{

	unsigned selectedRow = [selTable selectedRow];
	NSLog(@"vgfr %i",  selectedRow );

	if (selectedRow == -1)
		{
		// fill code to handle null selection	-	remove selection from data table
			NSLog(@"numberofselerows %i",  [selTable numberOfSelectedRows] );

			[selTable deselectAll:nil];
		}
	else		
	{
		[analysisController setSelectedObjects:[[selArray objectAtIndex:selectedRow] sel] ];
		[selTable selectRow:selectedRow byExtendingSelection:NO];
		NSLog(@"selextion %i,  %i %@ %@", [[[selArray objectAtIndex:selectedRow] sel] count], selectedRow, [[selArray objectAtIndex:selectedRow] sel], [selArray description] );
	}
}	


// Delegate methods



- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
//	NSLog(@"trtrt");
if (aTableView == selTable) {
	NSString *columnKey = [aTableColumn identifier];
	SelData *aSel = [selArray objectAtIndex:rowIndex];
	return 	[aSel valueForKey:columnKey];
	}
}


- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
//	NSLog(@"llllll");
	if (aTableView == selTable) {

	NSString *columnKey = [aTableColumn identifier];
	SelData *aSel = [selArray objectAtIndex:rowIndex];
	[aSel setValue:anObject forKey:columnKey];
	}
}

// Methods for importing text file

- (IBAction)importTextFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSLog(@"importTextFile");
    [panel beginSheetForDirectory:nil 
							 file:nil 
							types:nil 
				   modalForWindow:mainWindow
					modalDelegate:self 
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
					  contextInfo:nil];
    [panel setCanChooseDirectories:NO];
    [panel setPrompt:@"Choose File"];
}


- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    NSString *textFilePath;
	NSLog(@"openPanelDidEnd");
    if (returnCode == NSOKButton) {
        textFilePath = [openPanel filename];
        [self createRecordsFromTextFile:textFilePath];
    }
}

-(void)createRecordsFromPasteboard:(NSString *)pbString
{
	float thV, uV, pbV, theV, ueV, pbeV;
	NSString *aString;
//    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];			
    NSScanner *scanner = [NSScanner scannerWithString:pbString];
	NSCharacterSet *skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\n, ()\t\r\""];
	[scanner setCharactersToBeSkipped:skippedCharacters];
	while ([scanner isAtEnd] == NO) {
		[scanner scanUpToCharactersFromSet:skippedCharacters intoString:&aString];
		[scanner scanFloat:&thV];
		[scanner scanFloat:&theV]; 
		[scanner scanFloat:&uV];
		[scanner scanFloat:&ueV];
		[scanner scanFloat:&pbV]; 
		[scanner scanFloat:&pbeV];
/*
		[newData addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				aString, @"identificator",
                [NSNumber numberWithFloat:thV], @"thContent",
                [NSNumber numberWithFloat:uV], @"uContent",
				[NSNumber numberWithFloat:pbV], @"pbContent",
				[NSNumber numberWithFloat:theV], @"thErr",
				[NSNumber numberWithFloat:ueV], @"uErr",
				[NSNumber numberWithFloat:pbeV], @"pbErr",
                nil]];
*/
				
		Analysis *anAnalysis = [[Analysis alloc]init];	
		[anAnalysis setAnalysisID:aString];
		[anAnalysis setThContent: thV];
		[anAnalysis setUContent: uV];
		[anAnalysis setPbContent: pbV];
		[anAnalysis setThErr: theV];
		[anAnalysis setUErr: ueV];
		[anAnalysis setPbErr: pbeV];
		[analysisController addObject:anAnalysis];
		[anAnalysis release];
	}		
	//    [self setGraphics:newGraphics];
	//	NSLog(@"points %@:", points);
	//		[insertObject: addObjectsFromArray:newGraphics];
//	[self updateUI];
	
}

-(void)createRecordsFromTextFile:(NSString *)path
{
	float thV, uV, pbV, theV, ueV, pbeV;
	NSString *aString;
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];			
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
	NSCharacterSet *skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\n, ()\t\""];
	[scanner setCharactersToBeSkipped:skippedCharacters];
	while ([scanner isAtEnd] == NO) {
		[scanner scanUpToCharactersFromSet:skippedCharacters intoString:&aString];
		[scanner scanFloat:&thV];
		[scanner scanFloat:&theV]; 
		[scanner scanFloat:&uV];
		[scanner scanFloat:&ueV];
		[scanner scanFloat:&pbV]; 
		[scanner scanFloat:&pbeV];
/*
		[newData addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				aString, @"identificator",
                [NSNumber numberWithFloat:thV], @"thContent",
                [NSNumber numberWithFloat:uV], @"uContent",
				[NSNumber numberWithFloat:pbV], @"pbContent",
				[NSNumber numberWithFloat:theV], @"thErr",
				[NSNumber numberWithFloat:ueV], @"uErr",
				[NSNumber numberWithFloat:pbeV], @"pbErr",
                nil]];
*/
				
		Analysis *anAnalysis = [[Analysis alloc]init];	
		[anAnalysis setAnalysisID:aString];
		[anAnalysis setThContent: thV];
		[anAnalysis setUContent: uV];
		[anAnalysis setPbContent: pbV];
		[anAnalysis setThErr: theV];
		[anAnalysis setUErr: ueV];
		[anAnalysis setPbErr: pbeV];
		[analysisController addObject:anAnalysis];
		[anAnalysis release];
	}		
	//    [self setGraphics:newGraphics];
	//	NSLog(@"points %@:", points);
	//		[insertObject: addObjectsFromArray:newGraphics];
//	[self updateUI];
	
}


//Methods for exporting data to text file

- (IBAction)exportTextFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
	NSLog(@"exportTextFile");	
	[panel setRequiredFileType:@"txt"];
    [panel beginSheetForDirectory:nil 
							 file:nil 
				   modalForWindow: mainWindow
					modalDelegate:self 
				   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
					  contextInfo:nil];
    [panel setCanCreateDirectories:NO];
    [panel setPrompt:@"Save Text File"];
}

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    NSString *textFilePath;
	NSLog(@"savePanelDidEnd");
    if (returnCode == NSOKButton) {
        textFilePath = [savePanel filename];
		[self writeRecordsToTextFile:textFilePath];
    }
}


- (void)writeRecordsToTextFile:(NSString *)path
{
    NSMutableString *csvString = [NSMutableString string];
	[csvString appendString:@"ID\tThO2\terr ThO2\tUO2\terr UO2\tPbO\terr PbO\tap. age [Ma]\terr ap. age\tThO2*\terr ThO2*\n"];

    NSEnumerator *pointEnum = [daten objectEnumerator];
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
	
	NSEnumerator *e = [selArray objectEnumerator];
	while ( dat = [e nextObject] ) {
		NSNumber *age = [dat valueForKey:@"isoage"];
		NSNumber *histo_age = [dat valueForKey:@"bestimate"];
		NSNumber *chi2 = [dat valueForKey:@"chi2"];
		NSNumber *isoerr = [dat valueForKey:@"isoageerr"];
		NSNumber *histoerr = [dat valueForKey:@"errbestimate"];

		NSNumber *mswd = [dat valueForKey:@"mswd"];
		NSArray *selections = [dat valueForKey:@"sel"];
		
		[csvString appendString:[NSString stringWithFormat:@"Isochrone Age [Ma]: %@\t error %@\t MSWD: %@\n", age, isoerr, mswd]];
		[csvString appendString:[NSString stringWithFormat:@"Histogram Age [Ma]: %@\t error %@\t CHI2: %@\n", histo_age, histoerr, chi2]];
		[csvString appendString:@"Used data: "];
	
		NSEnumerator *e = [selections objectEnumerator];
//		int index = 0;
		while (dat = [e nextObject]) {
	//		stringXLabel = [NSString stringWithFormat:@"%3.1f", xLabel];

				[csvString appendString:[NSString stringWithFormat:@"%@ ", [dat valueForKey:@"analysisID"] ] ];
				}				
				[csvString appendString:@"\n"];
		}
	
	 [csvString writeToFile:path atomically:YES];
}


-(IBAction)saveHisto2PDF:(id)sender
{
[diagramView savePDF:sender];
}

-(IBAction)saveIso2PDF:(id)sender;
{
[isochroneView savePDF:sender];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	    // Insert code here to write your document from the given data.  
	// You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//	dict = [NSMutableDictionary dictionaryWithObject:daten forKey: @"daten"];


//	[archiver encodeObject:dict forKey:@"mainDict"];
//    NSLog(@"dataRepresentationOfType1");

	[archiver encodeObject:[self daten]  forKey:@"analysen"];
	[archiver encodeObject:[self selArray] forKey:@"auswahl"]; // Fehler liegt hier
//    NSLog(@"dataRepresentationOfType2");
	[archiver encodeFloat:[textFieldHistoMaxX floatValue] forKey:@"histomaxx"];
 	[archiver encodeFloat:[textFieldHistoMinX floatValue] forKey:@"histominx"];
	[archiver encodeFloat:[textFieldHistoMaxY floatValue] forKey:@"histomaxy"];

	[archiver encodeFloat:[textFieldIsoMaxX floatValue] forKey:@"isomaxx"];
 	[archiver encodeFloat:[textFieldIsoMinX floatValue] forKey:@"isominx"];
	[archiver encodeFloat:[textFieldIsoMaxY floatValue] forKey:@"isomaxy"];
	[archiver encodeFloat:[textFieldIsoMinY floatValue] forKey:@"isominy"];
	[archiver encodeBool:[preferenceController ppmUnits] forKey:MOGUnitsKey];
	[archiver finishEncoding];
	[archiver release];
	return data;

    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    NSLog(@"About to read data of type %@", aType);
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    dict = [[unarchiver decodeObjectForKey:@"mainDict"] retain];
	BOOL isPPMunit;
	daten = [unarchiver decodeObjectForKey:@"analysen"];
	selArray = [unarchiver decodeObjectForKey:@"auswahl"];
	hmaxx = [unarchiver decodeFloatForKey:@"histomaxx"];
	hminx = [unarchiver decodeFloatForKey:@"histominx"];
	hmaxy = [unarchiver decodeFloatForKey:@"histomaxy"];

	imaxx = [unarchiver decodeFloatForKey:@"isomaxx"];
	iminx = [unarchiver decodeFloatForKey:@"isominx"];
	imaxy = [unarchiver decodeFloatForKey:@"isomaxy"];
	iminy = [unarchiver decodeFloatForKey:@"isominy"];
 	isPPMunit = [unarchiver decodeBoolForKey:MOGUnitsKey];
//	NSLog(@"imaxx %f", imaxx);
	[unarchiver finishDecoding];
    [unarchiver release];

	if (daten == nil) { // dict
		return NO;
	} else {
	[self setSelArray:selArray];
//    [self setDaten:[dict objectForKey:@"daten"]];
	[self setDaten:daten];

	// For applications targeted for Tiger or later systems, you should use the new Tiger API 
	// readFromData:ofType:error:.  In this case you can also choose to override 
	// -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.

if ([[NSUserDefaults standardUserDefaults] boolForKey:MOGUnitsKey] != isPPMunit) {
	[self runDataFormatAlert];
	}
		containsData=YES;
		return YES;
	}
}

-(void)runDataFormatAlert
{
NSAlert* alert = [[NSAlert alloc] init] ;
[alert setMessageText: @"Attention"];
[alert setInformativeText: @"Data format appear to mismatch Data Units of the User Interface. Close Window, change Data Units in Preferences and reload data."];
[alert setAlertStyle:NSInformationalAlertStyle];
[alert runModal];
[alert release];
}

- (void)printShowingPrintPanel:(BOOL)flag 
{ 
NSView *theView;

switch ( [[[theTabView selectedTabViewItem] identifier] intValue]) {
case 1: {
			theView = diagramView;
			// NSLog(@"theView 1");
			break;
		}
case 2: {
			theView = [[theTabView selectedTabViewItem] view];
			// NSLog(@"theView 2");
			break;
		}
case 3: {
			theView = isochroneView;
			// NSLog(@"theView 3");
			break;
		}
default:	break; // this should not occur
}

     NSPrintOperation *printOp; 
	[[self printInfo] setHorizontalPagination:NSFitPagination];
    [[self printInfo] setHorizontallyCentered:YES];
    [[self printInfo] setVerticallyCentered:YES];
    
     printOp=[NSPrintOperation printOperationWithView: theView
                                            printInfo:[self printInfo]]; 
     [printOp setShowPanels:flag]; 
     [self runModalPrintOperation:printOp 
                         delegate:nil 
                   didRunSelector:NULL 
                      contextInfo:NULL]; 
} 

- (void)dealloc
// aus irgendeinem unbekanntem Grund wird dealloc nicht aufgerufen
// Die Abmeldung am NotificationCenter erfolgt in -windowWillClose:
{
NSLog(@"Destroying %@", self);

	[self setDaten:nil];
	[self setSelArray:nil];

	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	NSLog(@"Unregistered with notification center: %@", [self fileName]);
	[super dealloc];
}


@end
