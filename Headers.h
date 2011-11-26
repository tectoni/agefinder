//
//  Headers.h
//  Trinity
//
//  Created by Peter Appel on 20/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Headers : NSObject {

	NSString *thHeader;
	NSString *uHeader;
	NSString *pbHeader;
	NSString *thStHeader;


}

-(NSString *)thHeader;
-(void)setThHeader:(NSString *)aThHeader;

-(NSString *)uHeader;
-(void)setUHeader:(NSString *)aUHeader;

-(NSString *)pbHeader;
-(void)setPbHeader:(NSString *)aPbHeader;

-(NSString *)thStHeader;
-(void)setThStHeader:(NSString *)aThStHeader;

@end
