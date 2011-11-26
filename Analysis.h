//
//  Analysis.h
//  DataLister
//
//  Created by Peter Appel on 14/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "c2a.h"

@interface Analysis : NSObject {
NSString *analysisID;
float thContent, thErr, uContent, uErr, pbContent, pbErr,  age, ageErr, thStar, thStarErr;
	float xLoc;
	float yLoc;

}

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected;
- (NSRect)drawingBounds;

// Getter & Setter Methods
- (float)xLoc;
- (void)setXLoc:(float)aXLoc;

- (float)yLoc;
- (void)setYLoc:(float)aYLoc;


- (void)setAnalysisID:(NSString *)anID;
- (NSString *)analysisID;
- (void)setThContent:(float)x;
- (float)thContent;
- (void)setThErr:(float)x;
- (float)thErr;
- (void)setUContent:(float)x;
- (float)uContent;
- (void)setUErr:(float)x;
- (float)uErr;
- (void)setPbContent:(float)x;
- (float)pbContent;
- (void)setPbErr:(float)x;
- (float)pbErr;
- (void)setAge;
- (float)age;
- (void)setAgeErr;
- (float)ageErr;
- (void)setThStar;
- (float)thStar;
- (void)setThStarErr;
- (float)thStarErr;

@end
