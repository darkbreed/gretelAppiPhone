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

/**
 * Creates a full GPX XML file from a set of points.
 * 
 * @param NSSet - set of GPS points
 * @return NSString - the XML output.
 */
-(NSString *)createGPXFileFromGPSPoints:(NSSet *)points;

/**
 * Creates a single waypoint XML node, called as pare of parent method that creates XML document
 * @param GPSPoint - Object that stores GPS properties
 * @return NSString - the XML output.
 */
-(NSString *)createWaypointNodeFromGPSPoint:(GPSPoint *)point;

/**
 * Creates an array of points from an NSSet.
 * @param NSSet - set of GPS points
 * @return NSArray - sorted array of GPS points.
 */
-(NSArray *)createArrayOfPointsFromSet:(NSSet *)dataSet;

@end
