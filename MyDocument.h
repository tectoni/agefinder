//
//  MyDocument.h
//  datenLister
//
//  Created by Peter Appel on 14/05/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "York.h"
@class DiagramView;
@class IsochroneView;
@class Analysis;
@class SelData;
@class PreferenceController;
@class Headers;
@class WTFormatter;
@class PPMFormatter;
@class ERRFormatter;

	static const float THOX2THEL = 0.878809;
	static const float UOX2UEL = 0.881498;
	static const float PBOX2PBEL = 0.928318;

@interface MyDocument : NSDocument
{


	NSMutableDictionary *dict;
	BOOL containsData;
	IBOutlet ERRFormatter *errFormatter;
	IBOutlet WTFormatter *wtFormatter;
	IBOutlet PPMFormatter *ppmFormatter;
	IBOutlet PreferenceController *preferenceController;
	IBOutlet NSArrayController *analysisController;
	IBOutlet NSArrayController *selectionController;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *theTabView;
	IBOutlet DiagramView *diagramView;
	IBOutlet IsochroneView *isochroneView;
	IBOutlet NSButton *updateDiagramButton;
	IBOutlet NSButton *updateIsochroneButton;
	IBOutlet NSButton *saveIso2PDF;
	IBOutlet NSButton *saveHisto2PDF;

	IBOutlet NSTableView *dataTable;
	IBOutlet NSTableView *largeDateTable;
	NSMutableArray *daten;	

	IBOutlet NSTableView *selTable;
	IBOutlet NSTableView *selTable2;	// isochrone View
	
	IBOutlet NSTextField *textFieldHistoMaxX;
	IBOutlet NSTextField *textFieldHistoMinX;
	IBOutlet NSTextField *textFieldHistoMaxY;
	IBOutlet NSTextField *textFieldIsoMaxX;
	IBOutlet NSTextField *textFieldIsoMinX;
	IBOutlet NSTextField *textFieldIsoMaxY;
	IBOutlet NSTextField *textFieldIsoMinY;

	NSMutableArray *selArray;
	float hmaxx, hminx, hmaxy, imaxx, iminx, imaxy, iminy;
//	BOOL isppm;

}
-(void)handleTableChange:(NSNotification *)note;
-(void)updateTableHeaders:(BOOL)isppm;

- (void)insertObject:(Analysis *)a inDatenAtIndex:(int)index;
- (void)removeObjectFromDatenAtIndex:(int)index;
-(void)remove:(id)sender;

- (void)setDaten:(NSMutableArray *)array;
-(NSMutableArray *)daten;

-(float)chi2:(SelData *)aSel;

- (void)buildDiagram;
- (IBAction)updateDiagram:(id)sender;

- (void)insertObject:(SelData *)newSel inSelArrayAtIndex:(int)index;
-(IBAction)createSel:(id)sender;
-(IBAction)deleteSelectedSel:(id)sender;
-(IBAction)saveHisto2PDF:(id)sender;
-(IBAction)saveIso2PDF:(id)sender;

- (void)broadcastSelAdd;
- (void)broadcastSelRemoved;
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification;
-(void)updateSel;
-(void)setSelArray:(NSMutableArray *)array;
-(NSMutableArray *)selArray;

- (IBAction)importTextFile:(id)sender;

-(void)createRecordsFromPasteboard:(NSString *)path;

-(void)createRecordsFromTextFile:(NSString *)path;

-(void)setLocs;
- (IBAction)exportTextFile:(id)sender;
- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (void)writeRecordsToTextFile:(NSString *)path;
-(void)runDataFormatAlert;


@end
