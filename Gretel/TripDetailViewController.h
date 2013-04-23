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

typedef enum {
    CompletedTripOptionTypeDelete
}CompletedTripOptionType;

typedef enum {
    CancelButtonTypeEdit,
    CancelButtonTypeShare
}CancelButtonType;

typedef enum {
    AnimationDirectionTypeShow,
    AnimationDirectionTypeHide
}AnimationDirectionType;

typedef enum {
    TripDetailAlertViewTypeDelete,
    
}TripDetailAlertViewType;

typedef enum {
    TripActionSheetTypeDelete,
    TripActionSheetTypeMapStyle
}TripActionSheetType;

extern NSString * const GTTripIsResuming;

@interface TripDetailViewController : BRBaseMapViewController <ShareManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate> {
    
    ///The trip points as an array to feed the map view
    NSArray *route;

    ShareManager *shareManager;
    TripManager *tripManager;
    
}

/** @section UI Properties */
@property (nonatomic, strong) IBOutlet UIView *tripEditForm;
@property (nonatomic, strong) IBOutlet UIView *tripShareForm;
@property (nonatomic, strong) IBOutlet UIView *deleteButton;
@property (nonatomic, strong) IBOutlet UIView *shareButton;
@property (nonatomic, strong) IBOutlet UIView *editButton;
@property (nonatomic, strong) IBOutlet UITextField *tripNameField;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointsRecordedLabel;
@property (nonatomic, strong) IBOutlet GCDiscreetNotificationView *notificationView;

/** @section Non UI Properties */
@property (nonatomic, strong) Trip *trip;

/** @section Button Handlers */
-(IBAction)editButtonHandler:(id)sender;
-(IBAction)shareButtonHandler:(id)sender;
-(IBAction)cancelButtonHandler:(UIButton *)sender;

@end
