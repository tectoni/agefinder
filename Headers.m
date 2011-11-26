//
//  Headers.m
//  Trinity
//
//  Created by Peter Appel on 20/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Headers.h"


@implementation Headers


-(id)init
{
if (self = [super init])
{
		[self setThHeader:@"links"];
		[self setUHeader:@"rechts"];
		[self setPbHeader:@"op"];
		[self setThStHeader:@"op"];

}
return self;
}


-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:thHeader forKey:@"thHeader"];
	[coder encodeObject:uHeader forKey:@"uHeader"];
	[coder encodeObject:pbHeader forKey:@"pbHeader"];
	[coder encodeObject:thStHeader forKey:@"thStHeader"];

}

-(id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		[self setThHeader:[coder decodeObjectForKey:@"thHeader"]];
		[self setUHeader:[coder decodeObjectForKey:@"uHeader"]];
		[self setPbHeader:[coder decodeObjectForKey:@"pbHeader"]];
		[self setThStHeader:[coder decodeObjectForKey:@"thStHeader"]];

	}
	return self;
}

- (void)setThHeader:(NSString *)x
{
	x = [x copy];
	[thHeader release];
	thHeader = x;
}

- (void)setUHeader:(NSString *)x
{
	x = [x copy];
	[uHeader release];
	uHeader = x;
}

- (void)setPbHeader:(NSString *)x
{
	x = [x copy];
	[pbHeader release];
	pbHeader = x;
}

- (void)setThStHeader:(NSString *)x
{
	x = [x copy];
	[thStHeader release];
	thStHeader = x;
}


- (NSString *)thHeader
{
	return thHeader;
}

- (NSString *)uHeader
{
	return uHeader;
}


- (NSString *)pbHeader
{
	return pbHeader;
}


- (NSString *)thStHeader
{
	return thStHeader;
}


-(void)dealloc
{
[thHeader release];
[uHeader release];
[pbHeader release];
[thStHeader release];
[super dealloc];
}

@end
