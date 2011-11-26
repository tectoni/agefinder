//
//  SelData.h
//  DynamicSelections
//
//  Created by Peter Appel on 03/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SelData : NSObject <NSCoding>
{
	NSArray *sel;
	int countOfSel;
	int noOfPoints;
	float mswd;
	float isoage;
	float isoageerr;
	float intersect;
	float intererr;
	float inclination;
	float inclerr;
	float bestimate;
	float errbestimate;
	float chi2;
}

- (int)noOfPoints;
- (void)setNoOfPoints:(int)aNoOfPoints;

- (int)countOfSel;
- (void)setCountOfSel:(int)aCountOfSel;

- (NSArray *)sel;
-(void)setSel:(NSArray *)aSel;

- (float)mswd;
- (void)setMswd:(float)x;

- (float)isoage;
- (void)setIsoage:(float)x;

- (float)isoageerr;
- (void)setIsoageerr:(float)x;

- (float)intersect;
- (void)setIntersect:(float)x;

- (float)intererr;
- (void)setIntererr:(float)x;


- (float)inclination;
- (void)setInclination:(float)x;

- (float)inclerr;
- (void)setInclerr:(float)x;

- (float)bestimate;
- (void)setBestimate:(float)x;

- (float)errbestimate;
- (void)setErrbestimate:(float)x;

- (float)chi2;
- (void)setChi2:(float)x;


@end
