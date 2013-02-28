//
//  SettingsManager.m
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

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
    
    if(self){
        if(![appDefaults valueForKey:GTAppSettingsCurrentUnitType]){
            [appDefaults setInteger:GTAppSettingsUnitTypeMPH forKey:GTAppSettingsCurrentUnitType];
            self.unitLabel = @"MPH";
        }
    }
    
    return self;
}

-(void)setApplicationUnitType:(GTAppSettingsUnitType)unitType {

    [appDefaults setInteger:unitType forKey:GTAppSettingsCurrentUnitType];
    if(unitType == GTAppSettingsUnitTypeMPH){
        self.unitLabel = @"MPH";
    }else{
        self.unitLabel = @"KPH";
    }
    
}

-(GTAppSettingsUnitType)getApplicationUnitType {
    
    return [appDefaults integerForKey:GTAppSettingsCurrentUnitType];
    
}

@end
