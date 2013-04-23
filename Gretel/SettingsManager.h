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

typedef enum {
    GTAppSettingsUsageTypeCar,
    GTAppSettingsUsageTypeWalk,
    GTAppSettingsUsageTypeMix
}GTAppSettingsUsageType;

extern float const SMMileMultiplier;
extern float const SMKmMultiplier;
extern float const SMMilesSpeedMultiplier;
extern float const SMKmSpeedMultiplier;
extern float const SMFeetToMetersMultiplier;
extern float const SMMetersToFeetMultiplier;

extern NSString *const SMUnitLabelSpeed;
extern NSString *const SMUnitLabelDistance;
extern NSString *const SMUnitLabelHeight;
extern NSString *const SMDistanceMultiplier;
extern NSString *const SMSpeedMultiplier;
extern NSString *const SMSettingsUpdated;
extern NSString *const SMDistanceFilter;
extern NSString *const SMHeightMultiplier;

extern NSString * const GTAppSettingsCurrentUnitType;
extern NSString * const GTApplicationUsageTypeKey;
extern NSString * const GTApplicationDidUpdateUsageType;
extern NSString * const GTApplicationDidUpdateDistanceFilter;

@interface SettingsManager : NSObject

@property (nonatomic, readwrite) GTAppSettingsUnitType unitType;
@property (nonatomic, readwrite) GTAppSettingsUsageType usageType;
@property (nonatomic, readwrite) float distanceMultiplier;
@property (nonatomic, readwrite) float speedMultiplier;
@property (nonatomic, readwrite) float distanceFilter;
@property (nonatomic, readwrite) float heightMultiplier;
@property (nonatomic, strong) NSString *unitLabelSpeed;
@property (nonatomic, strong) NSString *unitLabelDistance;
@property (nonatomic, strong) NSString *unitLabelHeight;

+(SettingsManager*)sharedManager;
-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType;
-(void)setApplicationUsageType:(GTAppSettingsUsageType)usageType;
-(GTAppSettingsUnitType)getApplicationUnitType;
-(GTAppSettingsUsageType)getApplicationUsageType;
-(void)setApplicationDistanceFilter:(float)distanceFilter;


@end
