//
//  SettingsViewController.h
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISegmentedControl *speedDisplayOptions;
@property (nonatomic, strong) IBOutlet UISegmentedControl *accuracySettings;

@end
