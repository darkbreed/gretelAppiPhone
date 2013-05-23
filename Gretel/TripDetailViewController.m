//
//  CompletedTripViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "TripDetailViewController.h"
#import "ShareManager.h"

NSString * const GTTripIsResuming = @"tripIsResuming";

@interface TripDetailViewController ()

@end

@implementation TripDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripDeletionHandler:) name:GTTripDeletedSuccess object:nil];    
    
    self.title = [[tripManager currentTrip] tripName];
    tripManager = [TripManager sharedManager];
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:self.view];
    
    [self.navigationItem.leftBarButtonItem setImage:[GTThemeManager listIcon]];
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:[tripManager.tripForDetailView.tripDuration floatValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.durationLabel.text = timeString;
    
    float distance = [tripManager.tripForDetailView.totalDistance floatValue];
    
    if([[SettingsManager sharedManager] unitType] == GTAppSettingsUnitTypeMPH){
        distance = distance * [[SettingsManager sharedManager] distanceMultiplier];
    }else{
        distance = distance / [[SettingsManager sharedManager] distanceMultiplier];
    }
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f %@",distance,[[SettingsManager sharedManager] unitLabelDistance]];
    self.pointsRecordedLabel.text = [NSString stringWithFormat:@"%i",[tripManager.tripForDetailView.points count]];
    
    NSMutableArray *scrollViewContentViews = [[NSMutableArray alloc] init];
    
    [scrollViewContentViews addObject:[self createHUDView]];
    //[scrollViewContentViews addObject:[self createGraphView]];
    [scrollViewContentViews addObject:[self createEditView]];
    
    for (UIView *view  in scrollViewContentViews) {
        [self.horizontalScrollView addSubview:view];
    }
    
    self.horizontalScrollView.contentSize = CGSizeMake(self.horizontalScrollView.frame.size.width * scrollViewContentViews.count + 1, self.horizontalScrollView.frame.size.height);
    
    self.pageControl.numberOfPages = scrollViewContentViews.count;
    
}

-(UIView *)createEditView {
    
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(self.horizontalScrollView.frame.size.width, 0.0, self.horizontalScrollView.frame.size.width, 200.0)];
    
    UILabel *titleLabel = [UILabel new];
    [titleLabel setFrame:CGRectMake(0,0,180.0, 25.0)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:[@"Trip Name" uppercaseString]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setCenter:CGPointMake(editView.frame.size.width/2, 30.0)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    UITextField *tripNameField = [UITextField new];
    [tripNameField setFrame:CGRectMake(0,0,180.0, 25.0)];
    [tripNameField setCenter:CGPointMake(editView.frame.size.width/2, 60.0)];
    [tripNameField setDelegate:self];
    [tripNameField setReturnKeyType:UIReturnKeyDone];
    [tripNameField setText:tripManager.tripForDetailView.tripName];
    [tripNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [tripNameField setBorderStyle:UITextBorderStyleLine];
    [tripNameField setTextAlignment:NSTextAlignmentCenter];
    [tripNameField setBackgroundColor:[UIColor whiteColor]];
    
    [editView addSubview:titleLabel];
    [editView addSubview:tripNameField];
    
    return editView;
}


-(UIView *)createGraphView {
    UIView *graphView = [[UIView alloc] initWithFrame:CGRectMake(self.horizontalScrollView.frame.size.width, 0.0, self.horizontalScrollView.frame.size.width, 200.0)];
    [graphView setBackgroundColor:[UIColor lightGrayColor]];
    
    return graphView;
}

-(UIView *)createHUDView {
    
    UIView *hudView = [UIView new];
    [hudView addSubview:self.distanceLabel];
    [hudView addSubview:self.durationLabel];
    [hudView addSubview:self.pointsRecordedLabel];
    [hudView addSubview:self.distanceTitle];
    [hudView addSubview:self.durationTitle];
    [hudView addSubview:self.pointsRecordedTitle];
    
    return hudView;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.horizontalScrollView.frame.size.width;
    int page = floor((self.horizontalScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.notificationView setTextLabel:@"Drawing route"];
    [self.notificationView setShowActivity:YES animated:YES];
    [self.notificationView show:YES];
    [self.trip setRead:[NSNumber numberWithBool:YES]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *points = [tripManager fectchPointsForDrawing:YES];
        
        self.title = tripManager.tripForDetailView.tripName;
        
        [self drawRoute:points onMapView:self.mapView willRefreh:NO];
        [self addAnnotationsToMapView:self.mapView fromArray:points];
        [self zoomToFitMapView:self.mapView toFitRoute:points animated:NO];
        
        [self.notificationView hideAnimated];
        
    });
}

#pragma mark UIActionSheet delegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == TripDetailActionSheetTypeDelete) {
        
        switch (buttonIndex) {
            case 0:
                [[TripManager sharedManager] deleteTrip:tripManager.tripForDetailView];
                break;
                
            default:
                break;
        }
        
    }else if(actionSheet.tag == TripDetailActionSheetTypeMain){
        
        switch (buttonIndex) {
            case TripDetailActionSheetOptionDelete:
                [self confirmDeleteTrip];
                break;
                
            case TripDetailActionSheetOptionResume:
                [self confirmResume];
                break;
                
            case TripDetailActionSheetOptionShare:
                [self displayShareOptions];
                break;
            default:
                break;
        }
    
    }else if(actionSheet.tag == TripDetailActionSheetTypeShare){
        
        switch (buttonIndex) {
            case 0:
                [self shareByEmail];
                break;
                
            default:
                break;
        }
        
    }
}

-(void)displayShareOptions {
    
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share via:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
    [shareSheet setTag:TripDetailActionSheetOptionShare];
    [shareSheet showInView:self.view];
    
}

-(void)confirmDeleteTrip {
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@? This cannot be undone.", tripManager.tripForDetailView.tripName];
    
    UIActionSheet *confirmSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
    [confirmSheet setTag:TripDetailActionSheetTypeDelete];
    [confirmSheet showInView:self.view];
}

-(void)confirmResume {
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resume trip?" message:@"Would you like to resume this trip? If you have trips in progress these will be stopped and saved. If you are resuming a trip imported from an external source, it will appear in the recordings section from now on." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resume", nil];
    
    [alertView show];
    
}

#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1){
        
        [tripManager.tripForDetailView setReceivedFromRemote:[NSNumber numberWithBool:NO]];
        [[TripManager sharedManager] saveTripAndStop];
        [[TripManager sharedManager] setCurrentTrip:tripManager.tripForDetailView];
        [[TripManager sharedManager] setTripForDetailView:nil];
        [[TripManager sharedManager] setTripState:GTTripStateRecording];
        [[TripManager sharedManager] setIsResuming:YES];
        [[TripManager sharedManager] setPointsForDrawing:[[tripManager.currentTrip.points allObjects] mutableCopy]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GTTripIsResuming object:nil];
    }
}

-(void)shareByEmail {
    
    if(!shareManager){
        shareManager = [[ShareManager alloc] initWithShareType:ShareManagerShareTypeEmail fromViewController:self];
    }
    
    [shareManager shareTripDataByEmail:[NSArray arrayWithObject:tripManager.tripForDetailView]];
    
}

-(IBAction)actionButtonHandler:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Resume",@"Share", nil];
    [actionSheet setTag:TripDetailActionSheetTypeMain];
    [actionSheet showInView:self.view];
}


#pragma mark TripDeletion handlers
-(void)tripDeletionHandler:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextfieldDelegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        
        [self.view setCenter:CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2 -100.0))];
        
    } completion:nil];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [[tripManager tripForDetailView] setTripName:textField.text];
    [tripManager saveTrip];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    self.title = textField.text;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        
        [self.view setCenter:CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2))];
        
    } completion:nil];
    
    return YES;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
