//
//  ViewController.h
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoManager.h"
#import "Trip.h"
#import "BRBaseMapViewController.h"

typedef enum {
    kTripStateRecording,
    kTripStatePaused,
    kTripStateNew
} kTripState;

typedef enum {
    kTripActionSheetStop,
    kTripActionSheetOptions
} kTripActionSheetType;

@interface RecordNewTripViewController : BRBaseMapViewController <MKMapViewDelegate> {
    int currentPointId;
    NSMutableArray *recordedPoints;
}

@property (nonatomic, strong) Trip *currentTrip;
@property (nonatomic, strong) IBOutlet UILabel *latLabel;
@property (nonatomic, strong) IBOutlet UILabel *lonLabel;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, readwrite) kTripState tripState;

-(IBAction)startTrackingButtonHandler:(id)sender;
-(IBAction)stopTrackingButtonHandler:(id)sender;
-(IBAction)addButtonHandler:(id)sender;
-(void)setCurrentTripState:(kTripState)tripState;

@end
