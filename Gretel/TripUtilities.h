//
//  TripUtilities.h
//  Gretel
//
//  Created by Ben Reed on 09/05/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"
#import <CoreLocation/CoreLocation.h>
#import "GPSPoint.h"

@interface TripUtilities : NSObject

+(float)calculateDistanceForPointsInMetres:(Trip *)trip;

@end
