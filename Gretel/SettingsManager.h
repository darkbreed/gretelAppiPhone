//
//  SettingsManager.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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
extern NSString *const SMLocationCheckInterval;
extern NSString *const SMHeightMultiplier;
extern NSString *const SMDesiredAccuracy;

extern NSString * const GTAppSettingsCurrentUnitType;
extern NSString * const GTApplicationUsageTypeKey;
extern NSString * const GTApplicationDidUpdateUsageType;
extern NSString * const GTApplicationDidUpdateDistanceFilter;
extern NSString * const GTApplicationDidUpdateAccuracy;

@interface SettingsManager : NSObject

@property (nonatomic, readwrite) GTAppSettingsUnitType unitType;
@property (nonatomic, readwrite) GTAppSettingsUsageType usageType;
@property (nonatomic, readwrite) float distanceMultiplier;
@property (nonatomic, readwrite) float speedMultiplier;
@property (nonatomic, readwrite) float locationCheckInterval;
@property (nonatomic, readwrite) float heightMultiplier;
@property (nonatomic, strong) NSString *unitLabelSpeed;
@property (nonatomic, strong) NSString *unitLabelDistance;
@property (nonatomic, strong) NSString *unitLabelHeight;
@property (nonatomic, readwrite) CLLocationAccuracy desiredAccuracy;

+(SettingsManager*)sharedManager;

/**
 * Set the application unit type to Miles or KM
 * @param GTAppSettingsUnitType unitType
 * @return void
 */
-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType;

/**
 * Set the application usage type
 * @param GTAppSettingsUsageType usageType
 * @return void
 */
-(void)setApplicationUsageType:(GTAppSettingsUsageType)usageType;

/**
 * Returns the application unit type
 * @return GTAppSettingsUnitType usageType
 */
-(GTAppSettingsUnitType)getApplicationUnitType;

/**
 * Returns the application usage type
 * @return GTAppSettingsUsageType usageType
 */
-(GTAppSettingsUsageType)getApplicationUsageType;

/**
 * Sets the value for the NSTimer that turns the GPS on or off
 * @param float interval
 * @return void
 */
-(void)setApplicationLocationCheckInterval:(float)interval;

/**
 * Sets the Accuracy type
 * @return void
 */
-(void)setApplicationAccuracy:(CLLocationAccuracy)accuracyType;

@end
