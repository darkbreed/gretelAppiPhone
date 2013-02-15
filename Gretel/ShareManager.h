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

typedef enum {
    kShareManagerShareByEmail,
    kShareManagerShareWithDevice,
    kShareManagerDebug
} kShareManagerShareType;

@interface ShareManager : NSObject <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, BRBluetoothManagerDelegate> {
    
    //Email sharing
    UIViewController *parentViewController;
    Trip *tripData;
    MBProgressHUD *hud;
    BRBluetoothManager *bluetoothManager;
}

@property (nonatomic, strong) GKSession *gameKitSession;

+(ShareManager*)sharedManager;

-(void)displayShareOptionsInViewController:(UIViewController *)viewController withTripData:(Trip *)data;
-(void)shareTripDataByEmail:(Trip *)trip fromViewController:(UIViewController *)viewController;
-(void)shareTripDataWithLocalDevice;

@end
