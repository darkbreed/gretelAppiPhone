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
    [self.accuracyLabel setText:[NSString stringWithFormat:@"%.0f M",settingsManager.distanceFilter]];
    [self.accuracySlider setValue:settingsManager.distanceFilter];
}

#pragma mark Button Handlers
-(IBAction)feedbackButtonHandler:(id)sender {
    [TestFlight openFeedbackView];
}

-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(IBAction)unitsControlDidChange:(UISegmentedControl *)control {
    [settingsManager setApplicationUnitType:control.selectedSegmentIndex];
}

-(IBAction)usageTypeControlDidChange:(UISegmentedControl *)control {
    [settingsManager setApplicationUsageType:control.selectedSegmentIndex];
}

-(IBAction)doneButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)dropboxButtonHandler:(id)sender {
    [[DBAccountManager sharedManager] linkFromController:self];
}

-(IBAction)accuracySliderDidChange:(UISlider *)slider {
    
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.0f M",slider.value];
    [settingsManager setApplicationDistanceFilter:slider.value];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
