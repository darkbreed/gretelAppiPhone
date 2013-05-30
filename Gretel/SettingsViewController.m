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
    [self locationCheckIndexFromInterval:settingsManager.locationCheckInterval];
    [self updateAccuracySettingsControl];
    [self updateDistanceFilterSettingsControl];
    
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

-(IBAction)intervalSettingsDidChange:(UISegmentedControl *)control {
    
    [settingsManager setApplicationLocationCheckInterval:control.selectedSegmentIndex];
    
    switch (control.selectedSegmentIndex) {
        case 0:
            [settingsManager setApplicationLocationCheckInterval:1];
            break;
        case 1:
            [settingsManager setApplicationLocationCheckInterval:10];
            break;
        case 2:
            [settingsManager setApplicationLocationCheckInterval:30];
            break;
        case 3:
            [settingsManager setApplicationLocationCheckInterval:60];
            break;
        default:
            break;
    }
}

-(void)locationCheckIndexFromInterval:(int)interval {
    
    switch (interval) {
        case 1:
            [self.locationCheckInterval setSelectedSegmentIndex:0];
            break;
            
        case 10:
            [self.locationCheckInterval setSelectedSegmentIndex:1];
            break;
            
        case 30:
            [self.locationCheckInterval setSelectedSegmentIndex:2];
            break;
            
        case 60:
            [self.locationCheckInterval setSelectedSegmentIndex:3];
            break;
    }
    
}

-(void)updateAccuracySettingsControl {
   
    int selectedIndex = 0;
    
    double accuracy = settingsManager.desiredAccuracy;
    
    if (accuracy == kCLLocationAccuracyNearestTenMeters) {
        selectedIndex = 0;
    }else if (accuracy == kCLLocationAccuracyHundredMeters) {
        selectedIndex = 1;
    }else if (accuracy == kCLLocationAccuracyKilometer){
        selectedIndex = 2;
    }else if (accuracy == kCLLocationAccuracyThreeKilometers){
        selectedIndex = 3;
    }
    
    [self.accuracySettings setSelectedSegmentIndex:selectedIndex];
}


-(void)updateDistanceFilterSettingsControl {
    
    int selectedIndex = 0;
    
    float distance = settingsManager.distanceFilter;
    
    if (distance == 5.0) {
        selectedIndex = 0;
    }else if (distance == 10.0) {
        selectedIndex = 1;
    }else if (distance == 15.0){
        selectedIndex = 2;
    }else if (distance == 50.0){
        selectedIndex = 3;
    }
    
    [self.distanceFilterSettings setSelectedSegmentIndex:selectedIndex];
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

-(IBAction)distanceFilterSettingsDidChange:(UISegmentedControl *)control {
    
    switch (control.selectedSegmentIndex) {
        case 0:
            [settingsManager setDistanceFilter:1.0f];
            break;
        case 1:
            [settingsManager setDistanceFilter:5.0f];
            break;
        case 2:
            [settingsManager setDistanceFilter:10.0f];
            break;
        case 3:
            [settingsManager setDistanceFilter:50.0f];
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
