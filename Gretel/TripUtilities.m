//
//  TripUtilities.m
//  Gretel
//
//  Created by Ben Reed on 09/05/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripUtilities.h"

@implementation TripUtilities

+(float)calculateDistanceForPointsInMetres:(Trip *)trip {
    
    CLLocationDistance totalDistance = 0.0f;
    
    NSArray *points = [trip.points allObjects];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointID" ascending:YES];
    NSArray *sortedPoints = [points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];;
    
    if([sortedPoints count] > 0){
        
        GPSPoint *startPoint = [sortedPoints objectAtIndex:0];
        GPSPoint *nextPoint = nil;
        
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[startPoint.lat floatValue] longitude:[startPoint.lon floatValue]];
        CLLocation *nextLocation = nil;
        
        int count = [sortedPoints count];
        
        for (int i = 0; i < count; i++) {
            if(i > 0 && i < count){
                
                nextPoint = [sortedPoints objectAtIndex:i];
                nextLocation = [[CLLocation alloc] initWithLatitude:[nextPoint.lat floatValue] longitude:[nextPoint.lon floatValue]];
                totalDistance += [startLocation distanceFromLocation:nextLocation];
                startLocation = nextLocation;
                
            }
        }
        
        return totalDistance;
        
    }else{
        return 0.0;
    }
}

@end