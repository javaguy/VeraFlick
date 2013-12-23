//
//  FlickLoadingScreenViewController.m
//  veraflick
//
//  Created by Punit on 12/22/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "FlickLoadingScreenViewController.h"

@interface FlickLoadingScreenViewController ()

@end

@implementation FlickLoadingScreenViewController

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
	// Do any additional setup after loading the view.
}

-(void)showLoginView {
    self.loginView.hidden = false;
    self.loginView.alpha = 0.0f;
    self.loginButton.enabled = true;
    [UIView animateWithDuration:1.0
                          delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.loginView.alpha = 1.0f;
                     }
                     completion:nil];
    [self.activityIndicator stopAnimating];
    
}

-(void)hideLoginView {
    [UIView animateWithDuration:1.0
                          delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.loginView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.loginView.hidden = true;
                     }];
    [self.activityIndicator startAnimating];
}

-(void)loginButtonPressed:(id)sender {
    [self.view endEditing:true];
    
    if (self.delegate != nil) {
        [self.delegate performSelectorOnMainThread:@selector(loginButtonPressed:) withObject:self waitUntilDone:false];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
