//
//  SettingsMenuViewController.h
//  Gretel
//
//  Created by Ben Reed on 17/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "RecordNewTripViewController.h"

@interface SettingsMenuViewController : UITableViewController

@property (nonatomic, strong) RecordNewTripViewController *recordNewTripViewController;

@end
