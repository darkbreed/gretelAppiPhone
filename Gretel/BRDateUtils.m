//
//  BRDateUtils.m
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "BRDateUtils.h"

@implementation BRDateUtils

+(int)getTimeInDenomination:(kTimeDenomination)timeDenomination BetweenStartTime:(NSDate *)startTime andFinishTime:(NSDate *)finishTime {
  
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:startTime
                                                  toDate:finishTime options:0];
    
    NSInteger time = 0;
    
    switch (timeDenomination) {
        case kTimeInHours:
            time = [components hour];
            break;
        
        case kTImeInMinutes:
            time = [components minute];
            break;
        
        case kTimeInSeconds:
            time = [components second];
            break;
        
        default:
            break;
    }
    
    return time;
    
}

@end
