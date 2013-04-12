//
//  Instabug.h
//  Instabug
//

#import <Foundation/Foundation.h>

//The event to fire the feedback form
typedef enum{
    InstabugFeedbackEventShake,
    InstabugFeedbackEventThreeFingersSwipe,
    InstabugFeedbackEventNone
} InstabugFeedbackEvent;

//The screenshot capture source
typedef enum{
    InstabugCaptureSourceUIKit,
    InstabugCaptureSourceOpenGL
} InstabugCaptureSource;

@interface Instabug : NSObject

/*!
 
 @method		KickOffWithToken:CaptureSource:FeedbackEvent:IsTrackingLocation:
 @discussion	Starts the SDK
 
 */
+(void)KickOffWithToken:(NSString*)token
          CaptureSource:(InstabugCaptureSource)captureSource
          FeedbackEvent:(InstabugFeedbackEvent)feedbackEvent
     IsTrackingLocation:(BOOL)isTrackingLocation;

/*!
 
 @method		ShowFeedbackForm
 @discussion	Instantly shows the feedback form
 
 */
+(void)ShowFeedbackForm;

@end