//
//  SettingsViewController.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsManager.h"
#import "TestFlight.h"
#import "ECSlidingViewController.h"
#import "GTThemeManager.h"

@interface SettingsViewController : UIViewController {
    SettingsManager *settingsManager;
}

/** @section UI Properties */
@property (nonatomic, strong) IBOutlet UISegmentedControl *unitOptions;
@property (nonatomic, strong) IBOutlet UISegmentedControl *applicationUsageSettings;
@property (nonatomic, strong) IBOutlet UISegmentedControl *locationCheckInterval;
@property (nonatomic, weak) IBOutlet UISegmentedControl *accuracySettings;
@property (nonatomic, weak) IBOutlet UISegmentedControl *distanceFilterSettings;
@property (nonatomic, weak) IBOutlet UILabel *accuracyLabel;

@end
