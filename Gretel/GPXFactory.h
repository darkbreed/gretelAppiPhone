//
//  GPXFactory.h
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPSPoint.h"

extern NSString * const kGPXVersion;
extern NSString * const kGPXCreator;
extern NSString * const kGPXxmlsxsi;
extern NSString * const kGPXxmlns;
extern NSString * const kGPXSchemaLocation;

@interface GPXFactory : NSObject

-(NSString *)createGPXFileFromGPSPoints:(NSSet *)points;
-(NSString *)createWaypointNodeFromGPSPoint:(GPSPoint *)point;
-(NSArray *)createArrayOfPointsFromSet:(NSSet *)dataSet;

@end
