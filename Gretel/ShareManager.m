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
NSString * const SMMailSendingCancelled = @"mailSendingCancelled";
NSString * const SMMailSendingFailed = @"mailSendingFailed";
NSString * const SMMailSendingSuccess = @"mailSendingSuccess";
NSString * const SMMailSaved = @"mailSaved";

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
-(void)shareTripDataByEmail:(NSMutableArray *)trips {
        
    //Set up the mail composer
    MFMailComposeViewController *composeMailViewController = [[MFMailComposeViewController alloc] init];
    
    [composeMailViewController setSubject:@"Gretel GPX Files"];
    [composeMailViewController setMessageBody:@"Files created with Gretel" isHTML:NO];
    
    for (Trip *trip in trips) {
        
        GPXDocument *document = [[GPXDocument alloc] initWithFileURL:[NSURL fileURLWithPath:trip.gpxFilePath]];
        
        NSError *error = nil;
        [document readFromURL:[NSURL URLWithString:trip.gpxFilePath] error:&error];
        
        [composeMailViewController addAttachmentData:[document.gpxString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"application/xml" fileName:[NSString stringWithFormat:@"%@.%@",trip.tripName, ShareManagerGPXExtension]];
        
    }

    [composeMailViewController setMailComposeDelegate:self];
    
    //Display the composer
    [parentViewController presentViewController:composeMailViewController animated:YES completion:nil];
    
}

#pragma MFMailComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultSent:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMailSendingSuccess object:nil];
            break;
            
        case MFMailComposeResultSaved:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMailSaved object:nil];
            break;
        case MFMailComposeResultCancelled:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMailSendingCancelled object:nil];
            break;
            
        case MFMailComposeResultFailed:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMailSendingFailed object:nil];
            
        default:
            break;
    }
    
    [parentViewController dismissViewControllerAnimated:YES completion:nil];
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
    
}

-(void)bluetoothManager:(BRBluetoothManager *)manager didCompleteTransferOfData:(NSData *)data {

}

@end
