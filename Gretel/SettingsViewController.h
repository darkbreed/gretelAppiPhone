//
//  SettingsViewController.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsManager.h"

@interface SettingsViewController : UIViewController {
    SettingsManager *settingsManager;
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *unitOptions;
@property (nonatomic, strong) IBOutlet UISegmentedControl *accuracySettings;

@end
