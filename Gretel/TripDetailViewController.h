//
//  CompletedTripViewController.h
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BRBaseMapViewController.h"
#import "Trip.h"
#import "ShareManager.h"
#import "TripManager.h"
#import <GCDiscreetNotificationView/GCDiscreetNotificationView.h>
#import "GTThemeManager.h"

typedef enum {
    TripDetailActionSheetOptionDelete,
    TripDetailActionSheetOptionResume,
    TripDetailActionSheetOptionShare
}TripDetailActionSheetOption;

typedef enum {
    TripDetailActionSheetTypeDelete,
    TripDetailActionSheetTypeMain,
    TripDetailActionSheetTypeShare
}TripDetailActionSheetType;

extern NSString * const GTTripIsResuming;

@interface TripDetailViewController : BRBaseMapViewController <ShareManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
    
    ///The trip points as an array to feed the map view
    NSArray *route;

    ShareManager *shareManager;
    TripManager *tripManager;
    
}

/** @section UI Properties */
@property (nonatomic, weak) IBOutlet UITextField *tripNameField;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *pointsRecordedLabel;
@property (nonatomic, weak) UILabel *distanceTitle;
@property (nonatomic, weak) UILabel *durationTitle;
@property (nonatomic, weak) UILabel *pointsRecordedTitle;
@property (nonatomic, weak) IBOutlet UIScrollView *horizontalScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) GCDiscreetNotificationView *notificationView;

/** @section Non UI Properties */
@property (nonatomic, strong) Trip *trip;

/** @section Button Handlers */
-(IBAction)actionButtonHandler:(id)sender;

@end
