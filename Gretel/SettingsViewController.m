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
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setSize:18.0];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor whiteColor], nil]];
    [iconFactory setSquare:YES];
    [iconFactory setStrokeColor:[UIColor blackColor]];
    [iconFactory setStrokeWidth:0.2];
    
    [self.navigationItem.leftBarButtonItem setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconList]];
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

-(IBAction)accuracySliderDidChange:(UISlider *)slider {
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.0f M",slider.value];
    [settingsManager setApplicationDistanceFilter:slider.value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
