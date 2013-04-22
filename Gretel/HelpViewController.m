//
//  HelpViewController.m
//  Gretel
//
//  Created by Ben Reed on 22/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    
    for (int i = 0; i < colors.count; i++) {
        
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        HelpView *subview = [[HelpView alloc] initWithFrame:frame];
        subview.backgroundColor = [colors objectAtIndex:i];
        [self.scrollView addSubview:subview];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setSize:18.0];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor whiteColor], nil]];
    [iconFactory setSquare:YES];
    [iconFactory setStrokeColor:[UIColor blackColor]];
    [iconFactory setStrokeWidth:0.2];
    
    [self.navigationItem.leftBarButtonItem setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconList]];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
