//
//  BaseNavigationControllerViewController.h
//  Gretel
//
//  Created by Ben Reed on 18/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCDiscreetNotificationView/GCDiscreetNotificationView.h>

@interface BaseNavigationControllerViewController : UINavigationController

@property (nonatomic,strong) GCDiscreetNotificationView *notificationView;

@end
