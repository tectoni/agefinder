#import "DiagramView.h"
#import "SelData.h"
#import "Analysis.h"

static void *PropertyObservationContext = (void *)1091;

static void *GraphicsObservationContext = (void *)1092;
static void *SelectionIndexesObservationContext = (void *)1093;


static NSString *const GRAPHICS_BINDING_NAME = @"analysis";
static NSString * const SELECTIONINDEXES_BINDING_NAME = @"selectionIndexes";


@implementation DiagramView


+ (void)initialize
{
	[self exposeBinding:GRAPHICS_BINDING_NAME];
	[self exposeBinding:SELECTIONINDEXES_BINDING_NAME];
}


-(void)awakeFromNib
{
		[self setBoundsOrigin:NSMakePoint(-48.0,-30.0)];
		[self prepareAttributes];
        bindingInfo = [[NSMutableDictionary alloc] init];
        selArray = [[NSMutableArray alloc] init];


}

/*
nicht bei Objekten aus dem Nibfile  28/Jan/09

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		
		[self setBoundsOrigin:NSMakePoint(-50.0,-30.0)];
//		selArray = [[NSMutableArray alloc] init];
		[self prepareAttributes];

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

-(void)setXMin:(float)x
{
	xMin = x;
}

-(void)setXMax:(float)x
{
	xMax = x;
}

-(void)setYMax:(float)x
{
	yMax = x;
}



-(void)setSelectedData:(NSArray *)theData
{
	if (theData == selectedData)
		return;
		[selectedData release];
	[theData retain];
	selectedData = theData;
}


-(NSArray *)selectedData {return selectedData;}


- (void)setSelArray:(NSMutableArray *)aSelArray
{
    if (selArray != aSelArray) {
        [selArray release];
        selArray = [aSelArray mutableCopy];
// [selTable reloadData];
    }
}

/*
-(void)setSelArray:(NSMutableArray*)array
{
	if (array == selArray)
		return;
	
	[selArray release];
	[array retain];
	selArray = array;
}

*/
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



- (void)drawRect:(NSRect)rect
{
	NSPoint a, b, c;
	float xStep, yStep;
	int index, i, j;

	NSRect bounds = [self bounds];
	float tickLength;	
	float xAxisLength;
	float yAxisLength;
	tickLength = 3;
	xAxisLength = 500.0;	
	yAxisLength = 350.0;
	NSString *xAxisLabel = [NSString stringWithString:@"age [Ma]"];
	NSString *yAxisLabel = [NSString stringWithString:@"relative Probability"];
	[[NSColor whiteColor] set];
	
	[NSBezierPath fillRect:bounds];
    Analysis *analysis;

    NSArray *analysisArray = [self analysis];

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
	
//mc = [self getMaxCount:intervallCounts];

 xStep = xAxisLength/(xMax-xMin);
 yStep = yAxisLength/yMax;
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

// Draw the gausscurves
float age_, err, gy, stepSize, lowerX, x;
    id dat;
//		NSLog(@"age count    %i", [age count]);
    
    NSIndexSet *currentSelectionIndexes = [self selectionIndexes];
 	NSEnumerator *dataEnum = [analysisArray objectEnumerator];
    index = 0;
  
    while (dat = [dataEnum nextObject]) 
    {
        index++;
		age_ = [[dat valueForKey:@"age"] floatValue];
        err = [[dat valueForKey:@"ageErr"] floatValue];
        
//	for(index = 0; index < [age count]; index++) {
	NSBezierPath *gaussPath = [[NSBezierPath alloc] init];


//	age_ =	[[age objectAtIndex: index] floatValue];
//	err	=	[[sigma objectAtIndex: index] floatValue];
//	NSLog(@"age err %f  %f   %i", age_, err, index);

	lowerX = (age_ - 3*err) > xMin ? (age_ - 3*err) : xMin;
	stepSize = err/10;		// *6 = 60 is the numberOfSteps (3 sigma * 2 sides)
	
	[gaussPath moveToPoint:NSMakePoint((lowerX-xMin)*xStep,0)];
	for ( i = 0; i < 60; i++) {
		x = lowerX + i*stepSize;
		gy = 1/(err * sqrt(2*3.14159265)) * exp(-pow((x-age_),2)/2/pow(err,2));
		[gaussPath lineToPoint:NSMakePoint((x-xMin) * xStep, gy * yStep)];
//		NSLog(@"gy x %f  %f   %i", gy, x, i);

		}
    [[NSColor grayColor] set];
	[gaussPath stroke];
  	[gaussPath release];
    }  
        
       
        
        //		NSLog(@"gy x %f  %f   %i", gy, x, i);
        //    NSLog(@"currentselinx %@", [self selectionIndexes]);
    //  if ( [selectedData containsObject:dat])
        if (currentSelectionIndexes != nil)
        {  
            NSUInteger indx = [currentSelectionIndexes firstIndex];
            while (indx != NSNotFound)
            {
                analysis = [analysisArray objectAtIndex:indx];

                indx = [currentSelectionIndexes indexGreaterThanIndex:indx];
                NSBezierPath *selPath = [[NSBezierPath alloc] init];
                age_ = [[analysis valueForKey:@"age"] floatValue];
                err = [[analysis valueForKey:@"ageErr"] floatValue];

                
                lowerX = (age_ - 3*err) > xMin ? (age_ - 3*err) : xMin;
                stepSize = err/10;		// *6 = 60 is the numberOfSteps (3 sigma * 2 sides)
                [selPath moveToPoint:NSMakePoint((lowerX-xMin)*xStep,0)];
                
                
                for ( i = 0; i < 60; i++) 
                {
                    x = lowerX + i*stepSize;
                    gy = 1/(err * sqrt(2*3.14159265)) * exp(-pow((x-age_),2)/2/pow(err,2));
                    [selPath lineToPoint:NSMakePoint((x-xMin) * xStep, gy * yStep)];
                    //		NSLog(@"gy x %f  %f   %i", gy, x, i);
                }
                [[NSColor greenColor] set];
                [selPath stroke];
                [selPath release];

            }             
                
	}


int numberOfXTicks = 5;
float delta = (xMax - xMin)/numberOfXTicks;
float xLabel;
NSString *stringXLabel;
NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 0; index < (numberOfXTicks+1); index++) {
xLabel = delta * index + xMin;
stringXLabel = [NSString stringWithFormat:@"%4.0f", xLabel];
b.x = xStep * (xLabel-xMin);
[stringXLabel drawAtPoint:NSMakePoint(b.x - [stringXLabel sizeWithAttributes:attributes].width/2, -15.0) withAttributes:attributes]; 	

	if (index > 0) {

	[tickPath moveToPoint:NSMakePoint( b.x, 0.0)];
	[tickPath lineToPoint:NSMakePoint( b.x, tickLength)];
	[tickPath stroke];
	}
}


// NSLog(@"ymax %i", yMax);
delta = yMax/5.0;
int numberOfYTicks = rint(yMax/delta);
float yLabel;
NSString *stringYLabel;
//NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 0; index < (numberOfYTicks+1); index++) {
yLabel = delta * index;
stringYLabel = [NSString stringWithFormat:@"%1.2f", yLabel];
b.y = yStep * yLabel;
[stringYLabel drawAtPoint:NSMakePoint(-5.0 - [stringYLabel sizeWithAttributes:attributes].width, b.y - [stringYLabel sizeWithAttributes:attributes].height/2) withAttributes:attributes]; 	
	if (index > 0) {
	[tickPath moveToPoint:NSMakePoint(0.0, b.y)];
	[tickPath lineToPoint:NSMakePoint(tickLength, b.y)];
	[tickPath stroke];
	}

}
    [tickPath release];

//	Draw Sum Curves ,jetztwirds schwierig

if ([selArray count] > 0) {	
	for (index = 0; index < [selArray count]; index++) {
    NSBezierPath *sumGaussPath = [[NSBezierPath alloc] init];

	SelData *aSel = [selArray objectAtIndex:index];
			//  zuerst obere und untere Limits bestimmen
			// dazu die selektierten Daten durchloopen
	//		[aSel sel] gibt den NSSet mit indizes der Analysis 		

	float upLimit = xMin;
	float lowLimit = xMax;

//  float lowLimit, upLimit;

// Erstmal den Bereich der x-Werte ermittlen, über den die Summenkurven gebildet werden 
// sollen. Dies sind upLimit und lowLimit.

 	NSEnumerator *enumerator = [[aSel sel] objectEnumerator];
	id obj;
	while (obj = [enumerator nextObject]) {
    /* code that acts on the set’s values */
		float compValue = [[obj valueForKey:@"age"] floatValue];
//		NSLog(@"age %f index %i", [[obj valueForKey:@"age"] floatValue], index); 
		float	compErr	= [[obj valueForKey:@"ageErr"] floatValue];
		 upLimit  = (((compValue + 3*compErr) > upLimit) && ((compValue + 3*compErr) < xMax)) ? (compValue + 3*compErr) : upLimit  ;
		 lowLimit = (((compValue - 3*compErr) < lowLimit) && ((compValue - 3*compErr) > xMin)) ? (compValue - 3*compErr) : lowLimit ;
		}
//		NSLog(@"lowLimit %f upLimit %f", lowLimit, upLimit); 

// Jetzt zum Startpunkt gehen und den Pfad beginnen	
	
	[sumGaussPath moveToPoint:NSMakePoint((lowLimit-xMin)*xStep,0)];
	
// Die Kurve soll in 60 Schritten aufgebaut werden. Bestimmung der Schrittweite:	
	stepSize = (upLimit - lowLimit)/100;

// Jetzt wird die eigentlichen Summenkurve bestimmt. Dazu wird für jeden der 60 Einzelschritte 
// für jedes Alter in der Auswahl (_age) der Wert y an der Stelle x berechnet und diese Einzelwerte
// werden aufsummiert.

// Äussere Schleife für jeden Einzelschritt			
 	for ( j = 0; j < 100; j++) {
		x = lowLimit + j*stepSize;
		gy = 0; 
	enumerator = [[aSel sel] objectEnumerator];
// Innere Schleife: Aufsummierung der y - Werte
	while (obj = [enumerator nextObject]) {
				age_ = [[obj valueForKey:@"age"] floatValue];
				err = [[obj valueForKey:@"ageErr"] floatValue];
				gy = gy + 1/(err * sqrt(2*3.14159265)) * exp(-pow((x-age_),2)/2/pow(err,2));
//				NSLog(@"gy x %f  %f   %i", gy, x, k);
				}				
				[sumGaussPath lineToPoint:NSMakePoint((x-xMin) * xStep, gy * yStep)];

		}

	[[NSColor blueColor] set];
	[sumGaussPath stroke];
    [sumGaussPath release];		
	//draw the bestimate-curve

	err = [aSel errbestimate];
	lowerX = [aSel bestimate] - 3*err;
	stepSize = err/10;		// *6 = 60 is the numberOfSteps (3 sigma * 2 sides)
	NSBezierPath *bestimatePath = [[NSBezierPath alloc] init];

	[bestimatePath moveToPoint:NSMakePoint((lowerX-xMin)*xStep,0)];
	for ( i = 0; i < 60; i++) {
		x = lowerX + i*stepSize;
		gy = 1/(err * sqrt(2*3.14159265)) * exp(-pow((x-[aSel bestimate]),2)/2/pow(err,2));
		[bestimatePath lineToPoint:NSMakePoint((x-xMin) * xStep, gy * yStep)];
//		NSLog(@"gy x %f  %f   %i", gy, x, i);
		}

	[[NSColor redColor] set];
	[bestimatePath stroke];
	[bestimatePath release];
	
} 	

}	// if	

[self retain];
}



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
