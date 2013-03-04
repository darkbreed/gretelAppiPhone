//
//  Trip.m
//  Gretel
//
//  Created by Ben Reed on 01/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "Trip.h"
#import "GPSPoint.h"


@implementation Trip

@dynamic finishDate;
@dynamic recordingState;
@dynamic startDate;
@dynamic tripName;
@dynamic points;

+(NSString *)recordingStateStringForRecordingState:(TripRecordingState)recordingState {
    
    switch (recordingState) {
        case TripRecordingStateRecording:
            return @"recording";
        case TripRecordingStatePaused:
            return @"paused";
        case TripRecordingStateStopped:
            return @"stopped";
    }
}

@end

