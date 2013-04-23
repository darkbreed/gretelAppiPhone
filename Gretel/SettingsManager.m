//
//  SettingsManager.m
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//


float const SMMileMultiplier = 0.000621371192;
float const SMKmMultiplier = 1000.0;
float const SMMilesSpeedMultiplier = 2.23693629;
float const SMFeetToMetersMultiplier = 0.3048;
float const SMMetersToFeetMultiplier = 3.2808399;
float const SMKmSpeedMultiplier = 3.6;
float const SMDistanceFilterValue = 34.0;

NSString *const SMUnitLabelSpeed = @"unitLabelSpeed";
NSString *const SMUnitLabelDistance = @"unitLabelDistance";
NSString *const SMUnitLabelHeight = @"unitLabelHeight";
NSString *const SMDistanceMultiplier = @"distanceMultiplier";
NSString *const SMSpeedMultiplier = @"speedMultiplier";
NSString *const SMSettingsUpdated = @"settingsUpdated";
NSString *const SMDistanceFilter = @"distanceFilter";
NSString *const SMHeightMultiplier = @"heightMultiplier";

NSString *const GTApplicationUsageTypeKey = @"applicationUsageType";
NSString *const GTApplicationDidUpdateUsageType = @"didUpdateUsageType";
NSString *const GTApplicationDidUpdateDistanceFilter = @"didUpdateDistanceFilter";

#import "SettingsManager.h"

NSString * const GTAppSettingsCurrentUnitType = @"currentUnitType";

@implementation SettingsManager {
    NSUserDefaults *appDefaults;
}

#pragma mark - Singleton methods
+(SettingsManager*)sharedManager {
    
    static SettingsManager *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    
    self = [super init];
    
    appDefaults = [NSUserDefaults standardUserDefaults];
    
    if(self){
        
        if([appDefaults integerForKey:GTAppSettingsCurrentUnitType]){
            self.unitType = [appDefaults integerForKey:GTAppSettingsCurrentUnitType];
            self.unitLabelSpeed = [appDefaults valueForKey:SMUnitLabelSpeed];
            self.unitLabelDistance = [appDefaults valueForKey:SMUnitLabelDistance];
            self.distanceMultiplier = [appDefaults floatForKey:SMDistanceMultiplier];
            self.speedMultiplier = [appDefaults floatForKey:SMSpeedMultiplier];
            self.distanceFilter = [appDefaults floatForKey:SMDistanceFilter];
            self.unitLabelHeight = [appDefaults valueForKey:SMUnitLabelHeight];
            self.heightMultiplier = [appDefaults floatForKey:SMHeightMultiplier];
            
        }else{
            self.unitLabelSpeed = @"MPH";
            self.unitLabelDistance = @"M";
            self.unitLabelHeight = @"FT";
            self.heightMultiplier = SMFeetToMetersMultiplier;
            self.distanceMultiplier = SMMileMultiplier;
            self.speedMultiplier = SMMilesSpeedMultiplier;
            self.distanceFilter = SMDistanceFilterValue;
        }
    }
    
    return self;
}

-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType {
    
    if(unitType == GTAppSettingsUnitTypeMPH){
        self.unitLabelSpeed = @"MPH";
        self.unitLabelDistance = @"M";
        self.unitLabelHeight = @"FT";
        self.distanceMultiplier = SMMileMultiplier;
        self.speedMultiplier = SMMilesSpeedMultiplier;
        self.heightMultiplier = SMMetersToFeetMultiplier;
    }else{
        self.unitLabelSpeed = @"KPH";
        self.unitLabelDistance = @"KM";
        self.unitLabelHeight = @"M";
        self.distanceMultiplier = SMKmMultiplier;
        self.speedMultiplier = SMKmSpeedMultiplier;
    }
    
    self.unitType = unitType;
    [appDefaults setInteger:unitType forKey:GTAppSettingsCurrentUnitType];
    [appDefaults setValue:self.unitLabelSpeed forKey:@"unitLabelSpeed"];
    [appDefaults setFloat:self.distanceMultiplier forKey:@"distanceMultiplier"];
    [appDefaults setFloat:self.speedMultiplier forKey:@"speedMultiplier"];
    [appDefaults setValue:self.unitLabelDistance forKey:@"unitLabelDistance"];
    [appDefaults setFloat:self.distanceFilter forKey:@"distanceFilter"];
    [appDefaults setValue:self.unitLabelHeight forKey:@"unitLabelHeight"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SMSettingsUpdated object:self];
    
}

-(void)setApplicationUsageType:(GTAppSettingsUsageType)usageType {

    [appDefaults setInteger:usageType forKey:GTApplicationUsageTypeKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GTApplicationDidUpdateUsageType object:nil];
    
}

-(void)setApplicationDistanceFilter:(float)distanceFilter {
    
    [appDefaults setFloat:distanceFilter forKey:SMDistanceFilter];
    [[NSNotificationCenter defaultCenter] postNotificationName:GTApplicationDidUpdateDistanceFilter object:nil];
}

-(GTAppSettingsUnitType)getApplicationUnitType {
    return [appDefaults integerForKey:GTAppSettingsCurrentUnitType];
}

-(GTAppSettingsUsageType)getApplicationUsageType {
    return [appDefaults integerForKey:GTApplicationUsageTypeKey];
}

@end
