//
//  SettingsViewController.m
//  Gretel
//
//  Created by Ben Reed on 27/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        settingsManager = [SettingsManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.unitOptions setSelectedSegmentIndex:[settingsManager getApplicationUnitType]];

}

#pragma mark Button Handlers
-(IBAction)dismissButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(IBAction)unitsControlDidChange:(UISegmentedControl *)control {

    [settingsManager setApplicationUnitType:control.selectedSegmentIndex];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
