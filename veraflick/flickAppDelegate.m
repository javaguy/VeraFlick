//
//  flickAppDelegate.m
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

#import "flickAppDelegate.h"
#import "flickViewRoomController.h"
#import "FlickLoadingScreenViewController.h"
#import "VeraRoom.h"
#import "VeraController.h"
#import "ZwaveNode.h"
#import "ZwaveSwitch.h"

//#define MY_MIOS_USERNAME  @"javaguy01"
//#define MY_MIOS_PASSWD @"Xunit12";

@implementation flickAppDelegate {
    VeraController *myVeraController;
    BOOL isLoginDialogDisplayed;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_LOCATE_CONTROLLER_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_DEVICES_DID_REFRESH_NOTIFICATION
                                               object:nil];
    isLoginDialogDisplayed = false;
    
    self.userInfo = [flickUserInfo sharedUserInfo];
    [self.userInfo getUserInfo];
    
    myVeraController = [VeraController sharedController];
    myVeraController.miosUsername = self.userInfo.userName;
    myVeraController.miosPassword = self.userInfo.password;
    myVeraController.useMiosRemoteService = true;
    [myVeraController findVeraController];

    // Override point for customization after application launch.
    return YES;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //start the refresh timer
    [myVeraController stopHeartbeat];
    
    [self.userInfo saveUserInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //Start the heartbeat timer again
    [myVeraController startHeartbeat];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) veraNotificationReceived:(NSNotification *) notification
{
    static BOOL loadedMainView = false;
    
    if ([[notification name] isEqualToString:VERA_DEVICES_DID_REFRESH_NOTIFICATION])
    {
        if ([notification.object isKindOfClass:[NSError class]]) {
            NSLog (@"flickAppDelegate_veraNotificationReceived::Refresh notification received with error!");
            //There was an error, assuming credentials issue.
            //Ask user for credetials and then lets try again
            [self performSelectorOnMainThread:@selector(showLoginDialog) withObject:nil waitUntilDone:false];
        }
        else {
            //Check to see if the splashscreen is displayed (by checking if the navigation controller is not loaded.
            if (!loadedMainView) {
                //Check to see if the Login dialog was displayed (this means we prompted the user)
                if (isLoginDialogDisplayed) {
                    
                }
                
                [self performSelectorOnMainThread:@selector(launchMainViewController) withObject:nil waitUntilDone:false];
                
                //Set up the heartbeat
                [myVeraController startHeartbeat];
                loadedMainView = true;
            }
            
            if (isLoginDialogDisplayed) {
                //We prompted the user for credentials and looks like it was successful so save it
                self.userInfo.userName = myVeraController.miosUsername;
                self.userInfo.password = myVeraController.miosPassword;
                [self.userInfo saveUserInfo];
            }
        }
        
    }
    else if ([[notification name] isEqualToString:VERA_LOCATE_CONTROLLER_NOTIFICATION])
    {
        if ([notification.object isKindOfClass:[NSError class]]) {
            NSLog (@"flickAppDelegate_veraNotificationReceived::Locate Controller notification received with error!");
            //There was an error, assuming credentials issue.
            //Ask user for credetials and then lets try again
            [self performSelectorOnMainThread:@selector(showLoginDialog) withObject:nil waitUntilDone:false];
        }
        else {
            NSLog (@"flickAppDelegate_veraNotificationReceived::Locate Controller notification is successfully received!");
            [myVeraController refreshDevices];
        }
    }
}

-(void) showLoginDialog {
    FlickLoadingScreenViewController *controller = (FlickLoadingScreenViewController*)self.window.rootViewController;
    controller.delegate = self;
    [controller showLoginView];
    isLoginDialogDisplayed = true;
}

-(void)loginButtonPressed:(FlickLoadingScreenViewController*)sender {
    //User submitted login information
    myVeraController.miosUsername = sender.loginField.text;
    myVeraController.miosPassword = sender.passwordField.text;
    [myVeraController findVeraController];
    
    sender.loginButton.enabled = false;
    [sender.activityIndicator startAnimating];
}

- (void) launchMainViewController {
    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
    
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
     */
    
    [self.window.rootViewController performSegueWithIdentifier:@"MainNavigationSegue" sender:self];
}

@end
