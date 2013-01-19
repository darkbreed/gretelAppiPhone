//
//  GPXFactory.m
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "GPXFactory.h"

NSString * const kGPXVersion = @"1.0";
NSString * const kGPXCreator = @"Gretel 1.0 - http://www.benreed.me";
NSString * const kGPXxmlsxsi = @"http://www.w3.org/2001/XMLSchema-instance";
NSString * const kGPXxmlns = @"http://www.topografix.com/GPX/1/0";
NSString * const kGPXSchemaLocation = @"http://www.topografix.com/GPX/1/0/gpx.xsd";

@implementation GPXFactory


-(NSString *)createGPXFileFromGPSPoints:(NSSet *)points {
    
    NSArray *pointsArray = [self createArrayOfPointsFromSet:points];
    
    NSString *gpxOpenTag = [NSString stringWithFormat:@"<gpx version=\"%@\" creator=\"%@\" xmlns:xsi=\"%@\" xmlns=\"%@\" xsi:schemaLocation=\"%@\">\r",kGPXVersion, kGPXCreator, kGPXxmlsxsi, kGPXxmlns, kGPXSchemaLocation];
    NSString *gpxCloseTag = [NSString stringWithFormat:@"</gpx>\r"];
    
    NSMutableString *waypoints = [NSMutableString string];
    
    for(GPSPoint *point in pointsArray){
        [waypoints appendString:[self createWaypointNodeFromGPSPoint:point]];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", gpxOpenTag, waypoints, gpxCloseTag];
}

-(NSString *)createWaypointNodeFromGPSPoint:(GPSPoint *)point {
    
    NSString *wayPointOpen = [NSString stringWithFormat:@"<wpt lat=\"%f\" lon=\"%f\">\r", [point.lat doubleValue], [point.lon doubleValue]];
    NSString *wayPointElevation = [NSString stringWithFormat:@"<ele>%f</ele>\r", [point.altitude doubleValue]];
    NSString *wayPointTime = [NSString stringWithFormat:@"<time>%@</time>\r", point.timestamp];
    NSString *wayPointClose = [NSString stringWithFormat:@"</wpt>\r"];
    
    return [NSString stringWithFormat:@"%@%@%@%@",wayPointOpen, wayPointElevation, wayPointTime, wayPointClose];
}

-(NSArray *)createArrayOfPointsFromSet:(NSSet *)dataSet {
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"pointID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
    
    return [[dataSet allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
}


@end
