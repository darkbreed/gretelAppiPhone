//
//  SettingsManager.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GTAppSettingsUnitTypeMPH,
    GTAppSettingsUnitTypeKPH
}GTAppSettingsUnitType;

extern NSString * const GTAppSettingsCurrentUnitType;

@interface SettingsManager : NSObject

@property (nonatomic, readwrite) GTAppSettingsUnitType unitType;
@property (nonatomic, strong) NSString *unitLabel;

+(SettingsManager*)sharedManager;
-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType;
-(GTAppSettingsUnitType)getApplicationUnitType;


@end
