//
//  ShareManager.h
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <GameKit/GameKit.h>
#import "Trip.h"
#import "GPSPoint.h"
#import "GPXFactory.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "BRBluetoothManager.h"

extern NSString * const kGPXExtension;

/**
 * Enum of share types. Defines how the data should be shared. Currently data can be shared by:
 * - email: As a GPX file
 * - bluetooth: NSKeyedArchived that is broken into chunks and sent via GameKit APIs
 */
typedef enum {
    kShareManagerShareByEmail,
    kShareManagerShareWithDevice,
    kShareManagerDebug
} kShareManagerShareType;

@interface ShareManager : NSObject <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, BRBluetoothManagerDelegate> {
    
    ///The view controller to display progess in
    UIViewController *parentViewController;
    
    ///The trip data to be shared
    Trip *tripData;
    
    ///Progress meter to be shown in the parent view controller to update the user.
    MBProgressHUD *hud;
    
    ///An instance of BRBluetoothManager for sending the data via GameKit.
    BRBluetoothManager *bluetoothManager;
}

///GameKit session. Required for connecting to other devices.
@property (nonatomic, strong) GKSession *gameKitSession;

/**
 * Creates a singleton instance of the ShareManager.
 * @return ShareManager - singleton instance of the manager.
 */
+(ShareManager*)sharedManager;

/**
 * Creates a singleton instance of the ShareManager.
 * @param UIViewController - the view controller to display the share options dialogue in
 * @param Trip - the trip data to share
 * @return void
 */
-(void)displayShareOptionsInViewController:(UIViewController *)viewController withTripData:(Trip *)data;

/**
 * Shares the trip via email. The trip data is passed into the GPX factory class and converted to GPX XML and attached to an email using the native email client.
 * @param UIViewController - the view controller to display the mail composer in.
 * @param Trip - the trip data to share
 * @return void
 */
-(void)shareTripDataByEmail:(Trip *)trip fromViewController:(UIViewController *)viewController;

/**
 * Triggers the bluetooth sharing methods
 * @return void
 */
-(void)shareTripDataWithLocalDevice;

@end
