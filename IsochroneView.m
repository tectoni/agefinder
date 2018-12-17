//
//  IsochroneView.m
//  DataLister
//
//  Created by Peter Appel on 30/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IsochroneView.h"
#import "SelData.h"
#import "York.h"
#import "Analysis.h"

static void *PropertyObservationContext = (void *)1091;

static void *GraphicsObservationContext = (void *)1092;
static void *SelectionIndexesObservationContext = (void *)1093;


static NSString *const GRAPHICS_BINDING_NAME = @"analysis";
static NSString *const SELECTIONINDEXES_BINDING_NAME = @"selectionIndexes";


@implementation IsochroneView


+ (void)initialize
{
	[self exposeBinding:GRAPHICS_BINDING_NAME];
	[self exposeBinding:SELECTIONINDEXES_BINDING_NAME];
}

- (NSArray *)exposedBindings
{
	return [NSArray arrayWithObjects:GRAPHICS_BINDING_NAME, @"selectedObjects", nil];
}

-(void)awakeFromNib
{
		[self setBoundsOrigin:NSMakePoint(-48.0,-30.0)];
		selArray = [[NSMutableArray alloc] init];
		[self prepareAttributes];
		bindingInfo = [[NSMutableDictionary alloc] init];

}

/* 
initWithFrame wird nicht bei instantierten Objekten aus dem Nib File ausgeführt

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		
		[self setBoundsOrigin:NSMakePoint(-50.0,-30.0)];
		selArray = [[NSMutableArray alloc] init];
		[self prepareAttributes];
		bindingInfo = [[NSMutableDictionary alloc] init];

	}
	return self;
}
*/


- (void)prepareAttributes
{
    attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:11]
                   forKey:NSFontAttributeName];
    
    [attributes setObject:[NSColor blackColor]
                   forKey:NSForegroundColorAttributeName];
}

- (NSMutableArray *)selArray {return selArray;}


- (void)setSelArray:(NSMutableArray *)aSelArray
{
    if (selArray != aSelArray) {
        [selArray release];
        selArray = [aSelArray mutableCopy];
[selTable reloadData];
    }
}

-(BOOL)setPPMMode:(BOOL)ppm
{
	if (ppm) {
	ppmMode = YES; 
	}
	else 
		ppmMode = NO;
		
}

- (void)mouseDown:(NSEvent *)event
{
	/*
	 Fairly simple just to illustrate the point
	 */
//		NSLog(@" mouseDown");

	// find out if we hit anything
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	NSEnumerator *gEnum = [[self analysis] reverseObjectEnumerator];
	id anAnalysis;
	while (anAnalysis = [gEnum nextObject])
    {
		if ([anAnalysis hitTest:p isSelected:NO])
		{
			break;
		}
	}
	
	/*
	 if no graphic hit, then if extending selection do nothing else set selection to nil
	 */
	if (anAnalysis == nil)
	{
		if (!([event modifierFlags] & NSShiftKeyMask))
		{
			[[self selectionIndexesContainer] setValue:nil forKeyPath:[self selectionIndexesKeyPath]];
		}
		return;
	}
	
	/*
	 graphic hit
	 if not extending selection (Shift key down) then set selection to this graphic
	 if extending selection, then:
	 - if graphic in selection remove it
	 - if not in selection add it
	 */
	NSIndexSet *selection = nil;
	unsigned int analysisIndex = [[self analysis] indexOfObject:anAnalysis];
	
	if (!([event modifierFlags] & NSShiftKeyMask))
	{
		selection = [NSIndexSet indexSetWithIndex:analysisIndex];
	}
	else
	{
		if ([[self selectionIndexes] containsIndex:analysisIndex])
		{
			selection = [[[self selectionIndexes] mutableCopy] autorelease];
			[(NSMutableIndexSet *)selection removeIndex:analysisIndex];
		}
		else
		{
			selection = [[[self selectionIndexes] mutableCopy] autorelease];
			[(NSMutableIndexSet *)selection addIndex:analysisIndex];
		}
	}
	[[self selectionIndexesContainer] setValue:selection forKeyPath:[self selectionIndexesKeyPath]];
}

// bindings-related -- infoForBinding and convenience methods
- (void)observeValueForKeyPath:(NSString *)keyPath
    ofObject:(id)object
    change:(NSDictionary *)change
    context:(void *)context
{
//		NSLog(@"observeValueForKeyPath" );

    if (context == GraphicsObservationContext)
	{
		/*
		 Should be able to use
		 NSArray *oldGraphics = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newAnalysis = [object valueForKeyPath:[self analysisKeyPath]];
		
		NSMutableArray *onlyNew = [newAnalysis mutableCopy];
		[onlyNew removeObjectsInArray:oldAnalysis];
		[self startObservingAnalysis:onlyNew];
		[onlyNew release];
		
		NSMutableArray *removed = [oldAnalysis mutableCopy];
		[removed removeObjectsInArray:newAnalysis];
		[self stopObservingAnalysis:removed];
		[removed release];
		
		[self setOldAnalysis:newAnalysis];
		
		// could check drawingBounds of old and new, but...
		[self setNeedsDisplay:YES];
		return;
    }
	
	if (context == PropertyObservationContext)
	{
		NSRect updateRect;
		
		if ([keyPath isEqualToString:@"drawingBounds"])
		{
			NSRect newBounds = [[change objectForKey:NSKeyValueChangeNewKey] rectValue];
			NSRect oldBounds = [[change objectForKey:NSKeyValueChangeOldKey] rectValue];
			updateRect = NSUnionRect(newBounds,oldBounds);
		}
		else
		{
			updateRect = [(Analysis *)object drawingBounds];
		}
		updateRect = NSMakeRect(updateRect.origin.x-1.0,
								updateRect.origin.y-1.0,
								updateRect.size.width+2.0,
								updateRect.size.height+2.0);
		[self setNeedsDisplayInRect:updateRect];
		return;
	}
	
	if (context == SelectionIndexesObservationContext)
	{
		[self setNeedsDisplay:YES];
		return;
	}
}



- (void)startObservingAnalysis:(NSArray *)analysis
{
	if ([analysis isEqual:[NSNull null]])
	{
		return;
	}
	
	/*
	 Register to observe each of the new graphics, and each of their observable properties -- we need old and new values for drawingBounds to figure out what our dirty rect
	 */
	NSEnumerator *analysisEnumerator = [analysis objectEnumerator];
	
	/*
	 Declare newGraphic as NSObject * to get key value observing methods
	 Add Graphic protocol for drawing
	 */
    Analysis *newAnalysis;
	/*
	 Register as observer for all the drawing-related properties
	 */
    while (newAnalysis = [analysisEnumerator nextObject])
	{
		[newAnalysis addObserver:self
					 forKeyPath:@"drawingBounds"
						options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
						context:PropertyObservationContext];
		
		[newAnalysis addObserver:self
					 forKeyPath:@"drawingBounds"
						options:0
						context:PropertyObservationContext];
	}
}


- (void)stopObservingAnalysis:(NSArray *)analysis
{
	if ([analysis isEqual:[NSNull null]])
	{
		return;
	}
	
	NSEnumerator *graphicsEnumerator = [analysis objectEnumerator];
	
    id oldGraphic;
    while (oldAnalysis = [graphicsEnumerator nextObject])
	{
		[oldAnalysis removeObserver:self forKeyPath:@"drawingBounds"];
		[oldAnalysis removeObserver:self forKeyPath:@"drawingContents"];
	}
}

- (NSArray *)oldAnalysis
{
	return oldAnalysis;
}

- (void)setOldAnalysis:(NSArray *)anOldAnalysis
{
    if (oldAnalysis != anOldAnalysis) {
        [oldAnalysis release];
        oldAnalysis = [anOldAnalysis mutableCopy];
    }
}


- (void)bind:(NSString *)bindingName
	   toObject:(id)observableObject
	withKeyPath:(NSString *)observableKeyPath
		   options:(NSDictionary *)options
{
	
    if ([bindingName isEqualToString:GRAPHICS_BINDING_NAME])
	{
		if ([bindingInfo objectForKey:GRAPHICS_BINDING_NAME] != nil)
		{
//			[self unbind:GRAPHICS_BINDING_NAME];	
		}
		/*
		 observe the controller for changes -- note, pass binding identifier as the context, so we get that back in observeValueForKeyPath:... -- that way we can determine what needs to be updated
		 */
		
		NSDictionary *bindingsData = [NSDictionary dictionaryWithObjectsAndKeys:
									  observableObject, NSObservedObjectKey,
									  [[observableKeyPath copy] autorelease], NSObservedKeyPathKey,
									  [[options copy] autorelease], NSOptionsKey, nil];
		[bindingInfo setObject:bindingsData forKey:GRAPHICS_BINDING_NAME];
		
		[observableObject addObserver:self
						   forKeyPath:observableKeyPath
							  options:(NSKeyValueObservingOptionNew |
									   NSKeyValueObservingOptionOld)
							  context:GraphicsObservationContext];
		[self startObservingAnalysis:[observableObject valueForKeyPath:observableKeyPath]];
		
    }
	else
		if ([bindingName isEqualToString:SELECTIONINDEXES_BINDING_NAME])
		{
			if ([bindingInfo objectForKey:SELECTIONINDEXES_BINDING_NAME] != nil)
			{
				[self unbind:SELECTIONINDEXES_BINDING_NAME];	
			}
			/*
			 observe the controller for changes -- note, pass binding identifier as the context, so we get that back in observeValueForKeyPath:... -- that way we can determine what needs to be updated
			 */
			
			NSDictionary *bindingsData = [NSDictionary dictionaryWithObjectsAndKeys:
										  observableObject, NSObservedObjectKey,
										  [[observableKeyPath copy] autorelease], NSObservedKeyPathKey,
										  [[options copy] autorelease], NSOptionsKey, nil];
			[bindingInfo setObject:bindingsData forKey:SELECTIONINDEXES_BINDING_NAME];
			
			
			[observableObject addObserver:self
							   forKeyPath:observableKeyPath
								  options:0
								  context:SelectionIndexesObservationContext];
		}
	else
	{
		/*
		 For every binding except "graphics" and "selectionIndexes" just use NSObject's default implementation. It will start observing the bound-to property. When a KVO notification is sent for the bound-to property, this object will be sent a [self setValue:theNewValue forKey:theBindingName] message, so this class just has to be KVC-compliant for a key that is the same as the binding name.  Also, NSView supports a few simple bindings of its own, and there's no reason to get in the way of those.
		 */
		[super bind:bindingName toObject:observableObject withKeyPath:observableKeyPath options:options];
	}
    [self setNeedsDisplay:YES];
}






- (NSDictionary *)infoForBinding:(NSString *)bindingName
{
	NSDictionary *info = [bindingInfo objectForKey:bindingName];
	if (info == nil) {
		info = [super infoForBinding:bindingName];
	}
	return info;
}

- (id)analysisContainer
{
	return [[self infoForBinding:GRAPHICS_BINDING_NAME] objectForKey:NSObservedObjectKey];
}

- (NSString *)analysisKeyPath {
	return [[self infoForBinding:GRAPHICS_BINDING_NAME] objectForKey:NSObservedKeyPathKey];
}

- (id)selectionIndexesContainer
{
	return [[self infoForBinding:SELECTIONINDEXES_BINDING_NAME] objectForKey:NSObservedObjectKey];
}

- (NSString *)selectionIndexesKeyPath {
	return [[self infoForBinding:SELECTIONINDEXES_BINDING_NAME] objectForKey:NSObservedKeyPathKey];
}

- (NSArray *)analysis
{	
    return [[self analysisContainer] valueForKeyPath:[self analysisKeyPath]];	
}

- (NSIndexSet *)selectionIndexes
{
	return [[self selectionIndexesContainer] valueForKeyPath:[self selectionIndexesKeyPath]];
}





// getter and setter


-(void)setAllDataArray:(NSMutableArray*)array
{
	if (array == allDataArray)
		return;
	
	[allDataArray release];
	[array retain];
	allDataArray = array;
}




-(void)setXMin:(float)aVal
{
	xMin = aVal;
}

-(void)setXMax:(float)aVal
{
	xMax = aVal;
}

-(void)setYMax:(float)aVal
{
	yMax = aVal;
}


-(void)setYMin:(float)aVal
{
	yMin = aVal;
}


// Getter & Setter for x (Th*) and y (Pb) and for their Errors

-(void)setX:(NSMutableArray*)array	// Th*
{
	if (array == x)
		return;
	
	[x release];
	[array retain];
	x = array;
}

-(NSMutableArray *)x {return x;}

-(void)setXerr:(NSMutableArray*)array
{
	if (array == xerr)
		return;
	
	[xerr release];
	[array retain];
	xerr = array;
}


-(NSMutableArray *)xerr {return xerr;}


-(void)setY:(NSMutableArray*)array	// pb
{
	if (array == y)
		return;
	
	[y release];
	[array retain];
	y = array;
}

-(NSMutableArray *)y {return y;}

-(void)setYerr:(NSMutableArray*)array
{
	if (array == yerr)
		return;
	
	[yerr release];
	[array retain];
	yerr = array;
}

		
	
-(NSMutableArray *)yerr {return yerr;}




- (void)drawRect:(NSRect)rect
{
	NSPoint a, b, c, p1, p2, p3, p4;	// p1..p4 points for errorbars
	float xStep, yStep;
	int index;
//	NSMutableIndexSet *commonSet = [[NSMutableIndexSet alloc] init];

	NSMutableArray *commonSet = [[NSMutableArray alloc] init];
	
	NSRect bounds = [self bounds];
	float tickLength;	
	float xAxisLength;
	float yAxisLength;
	NSString *xAxisLabel;
	NSString *yAxisLabel;
	NSString *xAxisFormatString;
	NSString *yAxisFormatString;

	tickLength = 3;
	xAxisLength = 500.0;	
	yAxisLength = 350.0;
	[[NSColor whiteColor] set];
	
	[NSBezierPath fillRect:bounds];
	if (ppmMode) {
	xAxisLabel = [NSString stringWithString:@"Th* [ppm]"];
	yAxisLabel = [NSString stringWithString:@"Pb [ppm]"];
	xAxisFormatString = [NSString stringWithString:@"%3.0f"];
	yAxisFormatString = [NSString stringWithString:@"%3.0f"];

	}
	else 
	{
		xAxisLabel = [NSString stringWithString:@"ThO2* [wt.%]"];
		yAxisLabel = [NSString stringWithString:@"PbO [wt.%]"];
		xAxisFormatString = [NSString stringWithString:@"%3.1f"];
		yAxisFormatString = [NSString stringWithString:@"%1.2f"];


	}
	[[NSColor blackColor] set];
	NSEraseRect(rect);
//	NSLog(@"histoView  %@", self);

// Draw x-y axis
	NSBezierPath *path;
	path = [[NSBezierPath alloc] init];
			[path setLineWidth: 1.0];
			a.x = 0.0;
			a.y = 0.0;
			b.x = a.x + xAxisLength;
			b.y = a.y;
			c.x = a.x;
			c.y = a.y + yAxisLength;
			[path moveToPoint: c];
			[path lineToPoint: a];
			[path lineToPoint: b];
	//		[path closePath];
	[path stroke];
    [path release];

	
float yaw = [yAxisLabel sizeWithAttributes:attributes].width/2;	
float yah = [yAxisLabel sizeWithAttributes:attributes].height/2;	

	
float xx = -40 - yaw, yy = yAxisLength/2-yah;
[[NSGraphicsContext currentContext] saveGraphicsState];
 NSRect rcWhereToDraw = NSMakeRect(xx, yy, [yAxisLabel sizeWithAttributes:attributes].width, [yAxisLabel sizeWithAttributes:attributes].height);
 
float dx = NSMidX(rcWhereToDraw), dy = NSMidY(rcWhereToDraw);


NSAffineTransform *tr = [NSAffineTransform transform];
[tr translateXBy:dx yBy:dy]; // center or rect will be the center of rotation
[tr rotateByDegrees:90]; // rotate it
[tr translateXBy:-dx yBy:-dy]; // move it back
[tr concat];

[yAxisLabel drawInRect:rcWhereToDraw withAttributes:attributes];
[[NSGraphicsContext currentContext] restoreGraphicsState];

[xAxisLabel drawAtPoint:NSMakePoint(xAxisLength/2 - [xAxisLabel sizeWithAttributes:attributes].width/2, -25.0) withAttributes:attributes]; 	


// Draw axis ticks
	

 xStep = xAxisLength/(xMax-xMin);
 yStep = yAxisLength/(yMax-yMin);
/*
[histoPath moveToPoint: a];
yMax = 1;
for (index=5; index < [intervallCounts count]; index++) {
		y = [[intervallCounts objectAtIndex:index] intValue];
		NSLog(@"counts at index  %i  %i", y, index );
		b.x = xStep * (index-5) * 20;
		b.y = yStep * y;
		[histoPath lineToPoint:b];
		if ([[intervallCounts objectAtIndex:index] intValue] > yMax) {
			yMax = [[intervallCounts objectAtIndex:index] intValue];
			}
		}
 */



//	Draw the isochrones
NSPoint anfangspunkt;
NSPoint endpunkt;
float A, B;		// y = Ax + B

if ([selArray count] > 0) {
	NSBezierPath *isopath = [[NSBezierPath alloc] init];

	for (index = 0; index < [selArray count]; index++) {
	SelData *aSel = [selArray objectAtIndex:index];

		[commonSet addObjectsFromArray: [[aSel sel] valueForKey:@"thStar"]];
	
// wofür habe ich das nochmal verwendet

// 1.7.: für die Separation zwischen Isodata und Restdata

// bringt das Programm zum Hängen
	
	
	A = [aSel inclination];
	B = [aSel intersect];
			//  zuerst obere und untere Limits bestimmen
			// dazu die selektierten Daten durchlaufen
	//		[aSel sel] gibt den NSSet mit indizes der Analysis 	
	
			
	if (B > yMin || xMin > (yMin - B)/A) {				// die 2. Bedingung ist die Behandlung des FAlls xMin > x(yMin)
	anfangspunkt.x = xMin;								// if ( xMin > (yMin - B)/A ) { }
	anfangspunkt.y = yStep * ((A * xMin + B) - yMin);	
	}														
	else {												
	anfangspunkt.x =  xStep * ((yMin - B) / A - xMin);
	anfangspunkt.y =  yMin;
	}

	endpunkt.x = xStep * (xMax - xMin);
	endpunkt.y = yStep * ((xMax * A + B) - yMin);
//	NSLog(@"isoView endpunkt y isochrone  %f", endpunkt.y);

	[isopath moveToPoint:anfangspunkt];
	[isopath lineToPoint:endpunkt];		
	[[NSColor blueColor] set];
	[isopath stroke];			
	} 	// for
	[isopath release];


}	// if	

// Draw the data points
	float x_, xerr_, y_, yerr_;
	Analysis *analysis;
/*		
		NSEnumerator *enumerator = [commonSet objectEnumerator];
		//	id anObject;
		id dat;
		while (dat = [enumerator nextObject])
		{
			NSLog(@"cs thStar    %f",[[dat valueForKey:@"thStar"] floatValue]);
		}

*/


//	NSLog(@"x count    %i", [x count]);
	NSArray *analysisArray = [self analysis];
	for(index = 0; index < [x count]; index++) {
		
		// hier ist ein Fehler, da sich das Objekt [analysisArray objectAtIndex:index] ändert, wenn die Sortier-
		// reihenfolge der Tabelle verändert wird.

		if ([commonSet containsObject:[x objectAtIndex:index]])
			[[NSColor blueColor] set];
			else
			[[NSColor grayColor] set];

// im commonSet sind die Objekte abgelegt, die in allen Selections ausgewählt sind.


	NSBezierPath *path = [[NSBezierPath alloc] init];
		x_ =	[[x objectAtIndex: index] floatValue] - xMin;
		y_	=	[[y objectAtIndex: index] floatValue] - yMin;
		xerr_ = [[xerr objectAtIndex: index] floatValue] * [[x objectAtIndex: index] floatValue] / 100.0;
		yerr_ = [[yerr objectAtIndex: index] floatValue] * [[y objectAtIndex: index] floatValue] / 100.0;
//		NSLog(@"x y %f  %f   %i", x_, y_, index);
		// points p1..p4: links rechts unten oben, error in % ??
		p1.x = xStep * (x_ -  xerr_);
		p2.x = xStep * (x_ +  xerr_);
		p1.y = p2.y = yStep * y_;
		p3.x = p4.x = xStep * x_;
		p3.y = yStep * (y_ - yerr_);
		p4.y = yStep * (y_ + yerr_); 
		[path moveToPoint:p1];
		[path lineToPoint:p2];
		[path moveToPoint:p3];
		[path lineToPoint:p4];

		[path stroke];
		[path release];
		
		}

// Draw ticks x axis

int numberOfXTicks = 5;
float delta = (xMax - xMin)/numberOfXTicks;
float xLabel;
NSString *stringXLabel;
NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 0; index < (numberOfXTicks+1); index++) {
	xLabel = xMin + delta * index;
//	stringXLabel = [NSString stringWithFormat:@"%3.1f", xLabel];
	stringXLabel = [NSString stringWithFormat:xAxisFormatString, xLabel];
	b.x = xStep * (xLabel-xMin);
	[stringXLabel drawAtPoint:NSMakePoint(b.x - [stringXLabel sizeWithAttributes:attributes].width/2, -15.0) withAttributes:attributes]; 	
	
	if (index > 0) {
	[tickPath moveToPoint:NSMakePoint( b.x, 0.0)];
	[tickPath lineToPoint:NSMakePoint( b.x, tickLength)];
	[tickPath stroke];
	}
}


// NSLog(@"ymax %i", yMax);


//	Draw ticks y axis
int numberOfYTicks = 5;
delta = (yMax - yMin)/numberOfYTicks;
float yLabel;
NSString *stringYLabel;
//NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 0; index < (numberOfYTicks+1); index++) {
	yLabel = yMin + delta * index;
	stringYLabel = [NSString stringWithFormat:yAxisFormatString, yLabel];
	b.y = yStep * (yLabel - yMin) ;
	[stringYLabel drawAtPoint:NSMakePoint(-5.0 - [stringYLabel sizeWithAttributes:attributes].width, b.y - [stringYLabel sizeWithAttributes:attributes].height/2) withAttributes:attributes]; 	

	if (index > 0) {
	[tickPath moveToPoint:NSMakePoint(0.0, b.y)];
	[tickPath lineToPoint:NSMakePoint(tickLength, b.y)];
	[tickPath stroke];
	}    

}
    [tickPath release];

	/*
	 Draw a red box around items in the current selection.
	 Selection should be handled by the graphic, but this is a shortcut simply for display.
	 */
//	 NSArray *analysisArray = [self analysis];
	NSIndexSet *currentSelectionIndexes = [self selectionIndexes];
//    NSLog(@"currentselinx %@", [self selectionIndexes]);

	if (currentSelectionIndexes != nil)
	{
		NSBezierPath *path = [[NSBezierPath alloc] init];
		unsigned int index = [currentSelectionIndexes firstIndex];
		while (index != NSNotFound)
		{
			analysis = [analysisArray objectAtIndex:index];
//			NSLog(@"analysis Array %f", [analysis xLoc]);
			NSRect analysisDrawingBounds = [analysis drawingBounds];
			if (NSIntersectsRect(rect, analysisDrawingBounds))
			{
				[path appendBezierPathWithRect:analysisDrawingBounds];
			}
			index = [currentSelectionIndexes indexGreaterThanIndex:index];
		}
		[[NSColor redColor] set];
		[path setLineWidth:1.0];
		[path stroke];        
        [path release];

	}


[self retain];
	
}		// drawRect



//
// The action for saving to PDF file. Just do a save panel and
// use -didEnd to handle results.
//
-(IBAction) savePDF:(id)sender
{
	NSSavePanel * panel = [NSSavePanel savePanel];
//	NSLog(@"savePDF",self);
	[panel setRequiredFileType: @"pdf"];
	[panel beginSheetForDirectory: nil
							 file: nil
				   modalForWindow: [self window]
					modalDelegate: self
				   didEndSelector: @selector(didEnd:returnCode:contextInfo:)
					  contextInfo: nil];
}





//
// Do this after the PDF file target has been set.
//
-(void) didEnd: (NSSavePanel *)sheet returnCode:(int)code 
   contextInfo: (void *)contextInfo
{
	if(code == NSOKButton)
	{
	//	NSLog(@"didEnd called for %@", self);

		
		NSRect bounds = [self bounds];
		NSSize frameSize = [self frame].size;
		
/*		frameSize.width = bounds.size.width;
		frameSize.height = bounds.size.height;
		[self setFrameSize:frameSize];
		[self setBounds:bounds];
		
*/		
		
		NSRect r = NSMakeRect(bounds.origin.x, bounds.origin.y, frameSize.width, frameSize.height);
		

	//	NSRect r = [self bounds];
		NSData *data = [self dataWithPDFInsideRect:r];
		[data writeToFile: [sheet filename] atomically: YES];				

	}
}



@end
