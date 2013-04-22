//
//  HelpView.m
//  Gretel
//
//  Created by Ben Reed on 22/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0)];
        [titleLabel setText:@"title"];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
        NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
        
        UIImageView *screenShotImageView = [[UIImageView alloc] initWithImage:[iconFactory createImageForIcon:NIKFontAwesomeIconQuestionSign]];
        [screenShotImageView setFrame:CGRectMake(0, 25, self.frame.size.width, 300)];
    
        [self addSubview:screenShotImageView];
        
        UITextView *helpText = [[UITextView alloc] initWithFrame:CGRectMake(0, 205, self.frame.size.width, 150)];
        [self addSubview:helpText];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
