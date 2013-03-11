//
//  SettingsManager.m
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

NSString *const SMUnitLabelSpeed = @"unitLabelSpeed";
NSString *const SMUnitLabelDistance = @"unitLabelDistance";
NSString *const SMDistanceMultiplier = @"distanceMultiplier";
NSString *const SMSpeedMultiplier = @"speedMultiplier";
NSString *const SMSettingsUpdated = @"settingsUpdated";

NSString *const GTApplicationUsageTypeKey = @"applicationUsageType";
NSString *const GTApplicationDidUpdateUsageType = @"didUpdateUsageType";

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
        }else{
            self.unitLabelSpeed = @"MPH";
            self.unitLabelDistance = @"M";
            self.distanceMultiplier = 0.000621371192;
            self.speedMultiplier = 2.23693629;
        }
    }
    
    return self;
}

-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType {
    
    self.unitType = unitType;
    
    if(unitType == GTAppSettingsUnitTypeMPH){
        self.unitLabelSpeed = @"MPH";
        self.unitLabelDistance = @"M";
        self.distanceMultiplier = 0.000621371192;
        self.speedMultiplier = 2.23693629;
    }else{
        self.unitLabelSpeed = @"KPH";
        self.unitLabelDistance = @"KM";
        self.distanceMultiplier = 1000.0;
        self.speedMultiplier = 3.6;
    }
    
    [appDefaults setInteger:unitType forKey:GTAppSettingsCurrentUnitType];
    [appDefaults setValue:self.unitLabelSpeed forKey:@"unitLabelSpeed"];
    [appDefaults setFloat:self.distanceMultiplier forKey:@"distanceMultiplier"];
    [appDefaults setFloat:self.speedMultiplier forKey:@"speedMultiplier"];
    [appDefaults setValue:self.unitLabelDistance forKey:@"unitLabelDistance"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SMSettingsUpdated object:self];
    
}

-(void)setApplicationUsageType:(GTAppSettingsUsageType)usageType {

    //Configure app for car
    [appDefaults setInteger:usageType forKey:GTApplicationUsageTypeKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GTApplicationDidUpdateUsageType object:nil];
}

-(GTAppSettingsUnitType)getApplicationUnitType {
    
    return [appDefaults integerForKey:GTAppSettingsCurrentUnitType];
    
}

-(GTAppSettingsUsageType)getApplicationUsageType {
    return [appDefaults integerForKey:GTApplicationUsageTypeKey];
}

@end
