//
//  FlickLoadingScreenViewController.h
//  veraflick
//
//  Created by Punit on 12/22/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickLoadingScreenViewController : UIViewController

@property (atomic, strong) IBOutlet UITextField *loginField;
@property (atomic, strong) IBOutlet UITextField *passwordField;
@property (atomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) IBOutlet UIView *loginView;
@property (atomic, strong) IBOutlet UIButton *loginButton;

@property (atomic) id delegate;

-(IBAction)loginButtonPressed:(id)sender;
-(void)showLoginView;
-(void)hideLoginView;

@end
