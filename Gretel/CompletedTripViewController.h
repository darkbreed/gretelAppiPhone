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

@interface CompletedTripViewController : BRBaseMapViewController <ShareManagerDelegate> {
    
    ///The trip points as an array to feed the map view
    NSArray *route;

    ShareManager *shareManager;
    
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

/** @section Button Handlers */
-(IBAction)editButtonHandler:(id)sender;
-(IBAction)shareButtonHandler:(id)sender;
-(IBAction)cancelButtonHandler:(UIButton *)sender;

@end
