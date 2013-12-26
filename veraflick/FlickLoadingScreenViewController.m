//
//  FlickLoadingScreenViewController.m
//  veraflick
//
//  Copyright (C) 2013  Punit Java
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
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
