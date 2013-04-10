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
#import <GPX/GPX.h>
#import "BRBluetoothManager.h"
#import "GPXDocument.h"

extern NSString * const SMMailSendingCancelled;
extern NSString * const SMMailSendingFailed;
extern NSString * const SMMailSendingSuccess;
extern NSString * const SMMailSaved;

@class ShareManager;

extern NSString * const ShareManagerGPXExtension;

@protocol ShareManagerDelegate

@optional
-(void)shareManagerDidFinishSharingSuccessfully:(ShareManager *)manager;
-(void)shareManagerDidCancelSharing;
-(void)shareManagerDidSaveMailForLater;
-(void)shareManagerDidFailWithError:(NSError *)error;

@end

/**
 * Enum of share types. Defines how the data should be shared. Currently data can be shared by:
 * - email: As a GPX file
 * - bluetooth: NSKeyedArchived that is broken into chunks and sent via GameKit APIs
 */
typedef enum {
    ShareManagerShareTypeEmail,
    ShareManagerShareTypeBluetooth,
    ShareManagerShareTypeDropbox,
    ShareManagerShareTypeBump
} ShareManagerShareType;

@interface ShareManager : NSObject <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, BRBluetoothManagerDelegate> {
    
    ///The view controller to display progess in
    UIViewController *parentViewController;
    
    ///The trip data to be shared
    Trip *tripData;
    
    ///An instance of BRBluetoothManager for sending the data via GameKit.
    BRBluetoothManager *bluetoothManager;
    
}

///GameKit session. Required for connecting to other devices.
@property (nonatomic, strong) GKSession *gameKitSession;

///Delegate
@property (nonatomic, strong) id <ShareManagerDelegate> delegate;

/**
 * Init method override
 * @param ShareManagerShareType - Initialise the share manager with a specific share type
 * @param UIViewController - the parent view controller. Used to display the mail composer view
 * @return id - self
 */
-(id)initWithShareType:(ShareManagerShareType)shareType fromViewController:(UIViewController *)viewController;


/**
 * Shares the trip via email. The trip data is passed into the GPX factory class and converted to GPX XML and attached to an email using the native email client.
 * @param Trip - the trip data to share
 * @return void
 */
-(void)shareTripDataByEmail:(NSMutableArray *)trips;

/**
 * Triggers the bluetooth sharing methods
 * @return void
 */
-(void)shareTripDataWithLocalDevice;

@end
