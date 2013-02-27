//
//  SettingsManager.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GTSettingsUnitTypeMPH,
    GTSettingsUnitTypeKPH
}GTSettingsUnitType;


@interface SettingsManager : NSObject


+(SettingsManager*)sharedManager;

@end
