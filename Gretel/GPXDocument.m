//
//  GPXDocument.m
//  Gretel
//
//  Created by Ben Reed on 08/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "GPXDocument.h"

@implementation GPXDocument

@synthesize gpxString;

-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [NSData dataWithBytes:[self.gpxString UTF8String] length:[self.gpxString length]];
}


-(BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if ([contents length] > 0) {
        self.gpxString = [[NSString alloc] initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
    } else {
        self.gpxString = @"";
    }
    return YES;
}

@end
