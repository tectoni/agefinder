/* DiagramView */

#import <Cocoa/Cocoa.h>
@class SelData;
@class Analysis;

@interface DiagramView : NSView
{
    
	IBOutlet NSWindow *window;
	IBOutlet NSMenu *zoomMenu;
	IBOutlet NSArrayController *analysisController;
	IBOutlet NSArrayController *selectionController;
	NSMutableDictionary *attributes;
	NSMutableArray *age;
	NSMutableArray *sigma;
	NSArray *intervallCounts;
	float xMax, yMax, xMin;
	
	NSMutableArray *selArray;
    
	NSMutableDictionary *bindingInfo;
	NSMutableArray *allDataArray;
    NSArray *selectedData;
	NSArray *oldAnalysis;

//	float sigma;
}

-(IBAction)zoomLevel:(id)sender;
-(IBAction)savePDF:(id)sender;


- (void)startObservingAnalysis:(NSArray *)analysis;
- (void)stopObservingAnalysis:(NSArray *)analysis;

- (NSArray *)oldAnalysis;
- (void)setOldAnalysis:(NSArray *)anOldAnalysis;

- (NSArray *)selectedData;
- (void)setSelectedData:(NSArray *)theData;


-(void)prepareAttributes;

-(void)setXMin:(float)x;
-(void)setXMax:(float)x;
-(void)setYMax:(float)x;

-(void)setAge:(NSMutableArray*)array;
-(NSMutableArray *)age;

-(void)setSigma:(NSMutableArray*)array;
-(NSMutableArray *)sigma;

-(void)setSelArray:(NSMutableArray*)array;

- (NSDictionary *)infoForBinding:(NSString *)bindingName;
- (id)analysisContainer;
- (NSString *)analysisKeyPath; 
- (id)selectionIndexesContainer;
- (NSString *)selectionIndexesKeyPath; 
- (NSArray *)analysis;
- (NSIndexSet *)selectionIndexes;

-(NSArray *)allDataArray;



@end
