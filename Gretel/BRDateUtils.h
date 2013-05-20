//
//  BRDateUtils.h
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTimeInSeconds,
    kTImeInMinutes,
    kTimeInHours
} kTimeDenomination;
    
@interface BRDateUtils : NSObject

/**
 * Returns the time in a given denomintation as an int.
 * @param kTimeDenomination
 * @param NSDate startTime
 * @param NSDate endTime
 * @return int time
 */
+(int)getTimeInDenomination:(kTimeDenomination)timeDenomination BetweenStartTime:(NSDate *)startTime andFinishTime:(NSDate *)finishTime;

@end
