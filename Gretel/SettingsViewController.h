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

@interface SettingsViewController : UIViewController {
    SettingsManager *settingsManager;
}

/** @section UI Properties */
@property (nonatomic, strong) IBOutlet UISegmentedControl *unitOptions;
@property (nonatomic, strong) IBOutlet UISegmentedControl *applicationUsageSettings;
@property (nonatomic, strong) IBOutlet UISlider *accuracySlider;
@property (nonatomic, strong) IBOutlet UILabel *accuracyLabel;

@end
