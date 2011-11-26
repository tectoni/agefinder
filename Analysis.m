//
//  Analysis.m
//  DataLister
//
//  Created by Peter Appel on 14/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Analysis.h"
#import "c2a.h"

@implementation Analysis

- (id)init
{
	self = [super init];
    if (self) {
		[self setThContent:13.7];
		[self setThErr:2];

		[self setUContent:0.3];
		[self setUErr:5];

		[self setPbContent:0.33];
		[self setPbErr:6];

	//	[self setAgeErr:22.4];
		[self setAnalysisID:@"Mnz2"];
    }
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (![coder allowsKeyedCoding])
	{
		NSLog(@"analysis only works with NSKeyedArchiver");
	}
	NSData *idData = [coder decodeObjectForKey:@"identificator"];
	NSString *newID = [NSKeyedUnarchiver unarchiveObjectWithData:idData];
	[self setAnalysisID:newID];
	[self setXLoc:[coder decodeFloatForKey:@"xLoc"]];
	[self setYLoc:[coder decodeFloatForKey:@"yLoc"]];
	[self setThContent:[coder decodeFloatForKey:@"th"]];
	[self setUContent:[coder decodeFloatForKey:@"u"]];
	[self setPbContent:[coder decodeFloatForKey:@"pb"]];
	[self setThErr:[coder decodeFloatForKey:@"therr"]];
	[self setUErr:[coder decodeFloatForKey:@"uerr"]];
	[self setPbErr:[coder decodeFloatForKey:@"pberr"]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if (![coder allowsKeyedCoding])
	{
		NSLog(@"analysis only works with NSKeyedArchiver");
	}
	
	NSLog(@"analysis allowsKeyedCoding");

	NSData *idData = [NSKeyedArchiver archivedDataWithRootObject:analysisID];
	[coder encodeObject:idData forKey:@"identificator"];
	
		[coder encodeFloat:[self xLoc] forKey:@"xLoc"];
		[coder encodeFloat:[self yLoc] forKey:@"yLoc"];
	[coder encodeFloat:[self thContent] forKey:@"th"];
	[coder encodeFloat:[self uContent] forKey:@"u"];
	[coder encodeFloat:[self pbContent] forKey:@"pb"];
	[coder encodeFloat:[self thErr] forKey:@"therr"];
	[coder encodeFloat:[self uErr] forKey:@"uerr"];
	[coder encodeFloat:[self pbErr] forKey:@"pberr"];
	[coder encodeFloat:[self thStar] forKey:@"thstar"];
	[coder encodeFloat:[self thStarErr] forKey:@"thstarerr"];
	[coder encodeFloat:[self age] forKey:@"age"];
	[coder encodeFloat:[self ageErr] forKey:@"ageerr"];

}


- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected
{
	// ignore isSelected here for simplicity...
	// don't count shadow for selection
	NSRect circleBounds = 
	NSMakeRect(xLoc-8, yLoc-8, 8*2, 8*2);
	NSBezierPath *circle;
	circle = [NSBezierPath bezierPathWithOvalInRect:circleBounds];
	return [circle containsPoint:point];
}


- (NSRect)drawingBounds
{
	
	NSRect circleBounds = NSMakeRect(xLoc-8, yLoc-8,
									 8*2, 8*2);
		
	return (circleBounds);
}



- (float)xLoc { return xLoc; }
- (void)setXLoc:(float)aXLoc
{
	xLoc = aXLoc;
}


- (float)yLoc { return yLoc; }
- (void)setYLoc:(float)aYLoc
{
	yLoc = aYLoc;
}


- (void)setAnalysisID:(NSString *)anID
{
	anID = [anID copy];
	[analysisID release];
	analysisID = anID;
}

- (NSString *)analysisID { return analysisID; }


- (void)setThContent:(float)x
{
	thContent = x;
	[self setAge];
}
- (float)thContent {return thContent;}

- (void)setThErr:(float)x 
{
	thErr = x;
	[self setThStarErr];

}

- (float)thErr { return thErr; }

- (void)setUContent:(float)x
{
	uContent = x;
	[self setAge];
}

- (float)uContent { return uContent;}

- (void)setUErr:(float)x 
{
	uErr = x;
	[self setThStarErr];
}

- (float)uErr { return uErr; }

- (void)setPbContent:(float)x
{
	pbContent = x;
	[self setAge];
}

- (float)pbContent { return pbContent; }

- (void)setPbErr:(float)x 
{
	pbErr = x;
	[self setAgeErr];
}

- (float)pbErr { return pbErr; }



- (void)setAge
{
age = ApaAge(thContent, uContent, pbContent);
if (age > 0.0)	{
	[self setThStar];
	[self setThStarErr];	
	[self setAgeErr];
}

}

- (float)age {return age;}

- (void)setAgeErr
{
	ageErr = age * sqrt( pow(pbErr,2) + pow(thStarErr,2) ) / 100;	// absoluter Wert mit 1 sigma
}

- (float)ageErr { return ageErr; }


- (void)setThStar
{
thStar = CalcThStar(thContent, uContent, age);
}

- (float)thStar {return thStar;}

- (void)setThStarErr
{
float u, th, ths;
if (thContent > 100.0) {
	th = thContent * 1.1370904e-4;	// Conversion factors from Th(ppm) to ThO2(wt%)
	u = uContent *   1.134432e-4;
	ths = thStar * 1.1370904e-4;
	}
	else {
		th = thContent;
		u = uContent;
		ths = thStar;
		}
	float C = 264/(270* (exp(4.9475e-11*age*1e+6)-1)) * ((exp(9.8485e-10*age*1e+6) + 138 * exp(1.55125e-10*age*1e+6))/139 - 1);
	thStarErr = sqrt(pow((th/100*thErr),2) + pow((C*u/100*uErr), 2))/ths*100;
//	thStarErr = sqrt(pow(thErr,2) + pow(uErr, 2));
}


- (float)thStarErr { return thStarErr; }




@end
