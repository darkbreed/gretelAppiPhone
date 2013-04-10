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

@interface TripDetailViewController : BRBaseMapViewController <ShareManagerDelegate, UIAlertViewDelegate> {
    
    ///The trip points as an array to feed the map view
    NSArray *route;

    ShareManager *shareManager;
    TripManager *tripManager;
    
}

///The trip to be viewed
@property (nonatomic, strong) Trip *trip;
///UIView for edit form
@property (nonatomic, strong) IBOutlet UIView *tripEditForm;
///UIView for share form
@property (nonatomic, strong) IBOutlet UIView *tripShareForm;
///Delete button
@property (nonatomic, strong) IBOutlet UIView *deleteButton;
///Share button
@property (nonatomic, strong) IBOutlet UIView *shareButton;
///Edit button
@property (nonatomic, strong) IBOutlet UIView *editButton;
///Trip name text field
@property (nonatomic, strong) IBOutlet UITextField *tripNameField;

@property (nonatomic, strong) IBOutlet GCDiscreetNotificationView *notificationView;

/** @section Button Handlers */
-(IBAction)editButtonHandler:(id)sender;
-(IBAction)shareButtonHandler:(id)sender;
-(IBAction)cancelButtonHandler:(UIButton *)sender;

@end
