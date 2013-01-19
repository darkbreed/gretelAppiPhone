//
//  ShareManager.m
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "ShareManager.h"
#import <MessageUI/MessageUI.h>

NSString * const kGPXExtension = @"gpx";

@implementation ShareManager

#pragma mark - Singleton methods
+(ShareManager*)sharedManager {
    
    static ShareManager *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    
    self = [super init];
    
    if(self != nil){

    }
    
    return self;
}

/***
 
 Generic methods
 
 ***/
-(void)displayShareOptionsInViewController:(UIViewController *)viewController withTripData:(Trip *)data {
    
    tripData = data;
    parentViewController = viewController;
    
    UIActionSheet *shareOptions = [[UIActionSheet alloc] initWithTitle:@"Share vua" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Bluetooth", nil];
    
    [shareOptions showInView:parentViewController.view];
}

#pragma mark UIActionSheetDelegateMethods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        
        case kShareManagerShareByEmail:
            
            [self shareTripDataByEmail:tripData fromViewController:parentViewController];
            
            break;
        
        case kShareManagerShareWithDevice:
            
            [self connectToLocalDevice:YES];
            
            break;
            
        default:
            break;
    }
}

-(NSString *)getGPXStringFromTrip:(Trip *)trip {
    
    GPXFactory *factory = [[GPXFactory alloc] init];
    NSString *gpx = [factory createGPXFileFromGPSPoints:trip.points];
    
    return gpx;
}

-(void)connectToLocalDevice:(BOOL)local {
    
    //create peer picker and show picker of connections available...
    GKPeerPickerController *peerPicker = [[GKPeerPickerController alloc] init];
    peerPicker.delegate = self;
    
    if (self.gameKitSession == nil) {
        
        //...over bluetooth
        peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        
    }
    
    [peerPicker show];
    
}

/***
 
 Mail Sharing methods
 
 ***/
#pragma mark Share By Mail
-(void)shareTripDataByEmail:(Trip *)trip fromViewController:(UIViewController *)viewController {
    
    parentViewController = viewController;
    
    NSString *gpx = [self getGPXStringFromTrip:trip];
    NSString *fileName = [trip.tripName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    MFMailComposeViewController *composeMailViewController = [[MFMailComposeViewController alloc] init];
    [composeMailViewController addAttachmentData:[gpx dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"application/xml" fileName:[NSString stringWithFormat:@"%@.%@",fileName, kGPXExtension]];
    [composeMailViewController setMailComposeDelegate:self];
    
    [parentViewController presentViewController:composeMailViewController animated:YES completion:nil];
    
}

#pragma MFMailComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultSent:
        case MFMailComposeResultSaved:
        case MFMailComposeResultCancelled:
            [parentViewController dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

/***
 
 Bluetooth sharing methods
 http://mobile.tutsplus.com/tutorials/iphone/bluetooth-connectivity-with-gamekit/
 
 ***/

-(void)resetSession {
    
    [self.gameKitSession disconnectFromAllPeers];
    self.gameKitSession.delegate = nil;
    self.gameKitSession = nil;
    
}

-(GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    
    //create ID for session
    NSString *sessionIDString = @"com.benreed.Gretel";
    //create GKSession object
    GKSession *session = [[GKSession alloc] initWithSessionID:sessionIDString displayName:nil sessionMode:GKSessionModePeer];
    return session;
    
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    //set session delegate and dismiss the picker
    session.delegate = self;
    self.gameKitSession = session;
    picker.delegate = nil;
    [picker dismiss];
    
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    switch (state) {
        case GKPeerStateAvailable:
            
            break;
        
        case GKPeerStateUnavailable:
            
            break;  
            
        case GKPeerStateConnected:
            
            hud = [MBProgressHUD showHUDAddedTo:parentViewController.view animated:YES];
            
            [hud setMode:MBProgressHUDModeIndeterminate];
            [hud setLabelText:@"Sending data to Hansel"];
            
            //send data to all connected devices
            [self.gameKitSession sendDataToAllPeers:[tripData toData] withDataMode:GKSendDataReliable error:nil];
            
            [hud setLabelText:@"Complete"];
            [hud hide:YES afterDelay:1.0];
            
            break;
            
        case GKPeerStateDisconnected:
            
            [self resetSession];
            break;
            
        case GKPeerStateConnecting:
            
            break;
        default:
            
            [self resetSession];
            
            break;
    }

}

@end
