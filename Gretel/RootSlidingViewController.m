//
//  RootSlidingViewController.m
//  Gretel
//
//  Created by Ben Reed on 17/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "RootSlidingViewController.h"
#import "SettingsMenuViewController.h"

@interface RootSlidingViewController ()

@end

@implementation RootSlidingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIStoryboard *storyboard;
    
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"recordTrip"];
    
    SettingsMenuViewController *settingsMenu = [[SettingsMenuViewController alloc] init];
    settingsMenu.recordNewTripViewController = self.topViewController;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
