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
        bluetoothManager = [[BRBluetoothManager alloc] init];
    }
    
    return self;
}

-(void)displayShareOptionsInViewController:(UIViewController *)viewController withTripData:(Trip *)data {
    
    tripData = data;
    parentViewController = viewController;
    
    UIActionSheet *shareOptions = [[UIActionSheet alloc] initWithTitle:@"Share via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Bluetooth",@"Debug",nil];
    
    [shareOptions showInView:parentViewController.view];
}

#pragma mark UIActionSheetDelegateMethods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        
        case kShareManagerShareByEmail:
            
            [self shareTripDataByEmail:tripData fromViewController:parentViewController];
            
            break;
        
        case kShareManagerShareWithDevice:
            
            [self shareTripDataWithLocalDevice];
            
            break;
            
        case kShareManagerDebug:
            

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

-(void)shareTripDataWithLocalDevice {
    
    [bluetoothManager displayPeerPicker];
    
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

#pragma BRBluetoothManagerDelegate methods
-(void)bluetoothManager:(BRBluetoothManager *)manager didConnectToPeer:(NSString *)peer {
    [bluetoothManager sendData:[tripData toData] toReceivers:nil];
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didDisconnectFromPeer:(NSString *)peer {
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didReceiveDataOfLength:(int)length fromTotal:(int)totalLength withRemaining:(int)remaining {
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didCompleteTransferOfData:(NSData *)data {
    
}

@end
