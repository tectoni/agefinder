//
//  SelData.m
//  DynamicSelections
//
//  Created by Peter Appel on 03/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SelData.h"


@implementation SelData


- (id)init
{
	
    if (self = [super init])
	{
		[self setNoOfPoints:0];
		[self setCountOfSel:2];
		[self setSel:[NSArray array]];
		[self setMswd: 0.0];
	}
	return self;
}


- (int)countOfSel
{
	return countOfSel;
}

- (void)setCountOfSel:(int)aCountOfSel
{
	countOfSel = aCountOfSel;
}

- (int)noOfPoints
{
	return noOfPoints;
}

- (void)setNoOfPoints:(int)aNoOfPoints
{
	noOfPoints = aNoOfPoints;
}


- (NSArray *)sel {return sel;}


-(void)setSel:(NSArray *)aSel
{
	if (sel != aSel)
    {
        [sel autorelease];
		sel = [[NSArray alloc] initWithArray: aSel];
	}
}

- (float)mswd {return mswd;}

- (void)setMswd:(float)x
{
	mswd = x;
}

- (float)isoage { return isoage; }

- (void)setIsoage:(float)x 
{
	isoage = x;
}



- (float)isoageerr { return isoageerr; }

- (void)setIsoageerr:(float)x 
{
	isoageerr = x;
}



- (float)intersect { return intersect; }

- (void)setIntersect:(float)x 
{
	intersect = x;
}


- (float)intererr { return intererr; }

- (void)setIntererr:(float)x 
{
	intererr = x;
}


- (float)inclination { return inclination; }

- (void)setInclination:(float)x 
{
	inclination = x;
}



- (float)inclerr { return inclerr; }

- (void)setInclerr:(float)x 
{
	inclerr = x;
}

- (float)bestimate { return bestimate; }

- (void)setBestimate:(float)x 
{
	bestimate = x;
}


- (float)errbestimate { return errbestimate; }

- (void)setErrbestimate:(float)x 
{
	errbestimate = x;
}


- (float)chi2 { return chi2; }

- (void)setChi2:(float)x 
{
	chi2 = x;
}



- (void) dealloc
{
 //   [name release];
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self=[super init];
//	NSData *idData = [coder decodeObjectForKey:@"sel"];
//	NSArray *newSel = [NSKeyedUnarchiver unarchiveObjectWithData:idData];

//	[self coder decodeObjectForKey:@"sel"];	
	[self setSel:[coder decodeObjectForKey:@"sel"]];
	[self setCountOfSel:[coder decodeIntForKey:@"countOfSel"]];
	[self setNoOfPoints:[coder decodeIntForKey:@"noOfPoints"]];
	[self setMswd:[coder decodeFloatForKey:@"mswd"]];
	[self setIntersect:[coder decodeFloatForKey:@"intersect"]];
	[self setIntererr:[coder decodeFloatForKey:@"intererr"]];
	[self setInclination:[coder decodeFloatForKey:@"inclination"]];
	[self setInclerr:[coder decodeFloatForKey:@"inclerr"]];
	[self setIsoage:[coder decodeFloatForKey:@"isoage"]];
	[self setIsoageerr:[coder decodeFloatForKey:@"isoageerr"]];
	[self setBestimate:[coder decodeFloatForKey:@"bestimate"]];
	[self setErrbestimate:[coder decodeFloatForKey:@"errbestimate"]];
	[self setChi2:[coder decodeFloatForKey:@"chi2"]];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
//	NSData *idData = [NSKeyedArchiver archivedDataWithRootObject:sel];
//	[encoder encodeObject:idData forKey:@"sel"];
	[encoder encodeObject:[self sel] forKey:@"sel"];
	[encoder encodeInt:[self countOfSel] forKey:@"countOfSel"];
	[encoder encodeInt:[self noOfPoints] forKey:@"noOfPoints"];
	[encoder encodeFloat:[self mswd] forKey:@"mswd"];
	[encoder encodeFloat:[self intersect] forKey:@"intersect"];
	[encoder encodeFloat:[self intererr] forKey:@"intererr"];
	[encoder encodeFloat:[self inclination] forKey:@"inclination"];
	[encoder encodeFloat:[self inclerr] forKey:@"inclerr"];
	[encoder encodeFloat:[self isoage] forKey:@"isoage"];
	[encoder encodeFloat:[self isoageerr] forKey:@"isoageerr"];
	[encoder encodeFloat:[self bestimate] forKey:@"bestimate"];
	[encoder encodeFloat:[self errbestimate] forKey:@"errbestimate"];
	[encoder encodeFloat:[self chi2] forKey:@"chi2"];

}
	
@end
