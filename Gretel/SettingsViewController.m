//
//  SettingsViewController.m
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "SettingsViewController.h"
#import <Dropbox/Dropbox.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    settingsManager = [SettingsManager sharedManager];
    [self.unitOptions setSelectedSegmentIndex:[settingsManager getApplicationUnitType]];
    [self.applicationUsageSettings setSelectedSegmentIndex:[settingsManager getApplicationUsageType]];
    [self.accuracyLabel setText:[NSString stringWithFormat:@"%.0f seconds",settingsManager.locationCheckInterval]];
    [self.locationCheckInterval setValue:settingsManager.locationCheckInterval];
    
    [self.navigationItem.leftBarButtonItem setImage:[GTThemeManager listIcon]];
}

#pragma mark Button Handlers
-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(IBAction)unitsControlDidChange:(UISegmentedControl *)control {
    [settingsManager setApplicationUnitType:control.selectedSegmentIndex];
}

-(IBAction)usageTypeControlDidChange:(UISegmentedControl *)control {
    [settingsManager setApplicationUsageType:control.selectedSegmentIndex];
}

-(IBAction)intervalSliderDidChange:(UISlider *)slider {
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.0f seconds",slider.value];
    [settingsManager setApplicationLocationCheckInterval:slider.value];
}

-(IBAction)accuracySettingsDidChange:(UISegmentedControl *)control {
    
    switch (control.selectedSegmentIndex) {
        case 0:
            [settingsManager setApplicationAccuracy:kCLLocationAccuracyNearestTenMeters];
            break;
        case 1:
            [settingsManager setApplicationAccuracy:kCLLocationAccuracyHundredMeters];
            break;
        case 2:
            [settingsManager setApplicationAccuracy:kCLLocationAccuracyKilometer];
            break;
        case 3:
            [settingsManager setApplicationAccuracy:kCLLocationAccuracyThreeKilometers];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
