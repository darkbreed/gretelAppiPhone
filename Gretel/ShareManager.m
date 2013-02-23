//
//  ShareManager.m
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "ShareManager.h"
#import <MessageUI/MessageUI.h>

NSString * const ShareManagerGPXExtension = @"gpx";

@implementation ShareManager

-(id)initWithShareType:(ShareManagerShareType)shareType fromViewController:(UIViewController *)viewController {
    
    self = [super init];
    parentViewController = viewController;
    
    if(self){
        
        switch (shareType) {
            case ShareManagerShareTypeEmail:
                //Set up email sharing
                break;
            
            case ShareManagerShareTypeBluetooth:
                //Set up bluetooth sharing
                
                bluetoothManager = [[BRBluetoothManager alloc] init];
                [bluetoothManager setDelegate:self];
                
                break;
                
            case ShareManagerShareTypeDropbox:
                //Set up Dropbox sharing
                
            case ShareManagerShareTypeBump:
                //Set up Bump sharing
                
            default:
                break;
        }
        
    }
    
    return self;
}


/***
 
 Mail Sharing methods
 
 ***/
#pragma mark Share By Mail
-(void)shareTripDataByEmail:(Trip *)trip {
    
    //Convert the trip into the GPX file format
    GPXFactory *factory = [[GPXFactory alloc] init];
    NSString *gpx = [factory createGPXFileFromGPSPoints:trip.points];
    NSString *fileName = [trip.tripName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    //Set up the mail composer
    MFMailComposeViewController *composeMailViewController = [[MFMailComposeViewController alloc] init];
    [composeMailViewController addAttachmentData:[gpx dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"application/xml" fileName:[NSString stringWithFormat:@"%@.%@",fileName, ShareManagerGPXExtension]];
    [composeMailViewController setMailComposeDelegate:self];
    
    //Display the composer
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

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    //Here for completeness
}

#pragma BRBluetoothManagerDelegate methods

-(void)shareTripDataWithLocalDevice {
    
    [bluetoothManager displayPeerPicker];
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didConnectToPeer:(NSString *)peer {
    
    NSData *dataToSend = [tripData toData];
    [bluetoothManager sendData:dataToSend toReceivers:nil];
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didBeginToSendData:(NSData *)data {
        
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didDisconnectFromPeer:(NSString *)peer {
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didSendDataOfLength:(int)length fromTotal:(int)totalLength withRemaining:(int)remaining {
    float fRemaining = remaining;
    float fTotalLength = totalLength;
    
    float percent = fRemaining/fTotalLength;
    
    NSLog(@"Sending is %f%% complete",percent);
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didCompleteTransferOfData:(NSData *)data {

}

@end
