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
#import "GTThemeManager.h"

extern NSString * const GTViewControllerRecordTrip;
extern NSString * const GTViewControllerTripHistory;
extern NSString * const GTViewControllerSettings;
extern NSString * const GTViewControllerAbout;
extern NSString * const GTViewControllerHelp;

typedef enum {
    MenuSectionTypeMap,
    MenuSectionTypeHistory,
    MenuSectionTypeOther
}MenuSectionType;

@interface SettingsMenuViewController : UITableViewController

@property (nonatomic, strong) RecordNewTripViewController *recordNewTripViewController;

@end
