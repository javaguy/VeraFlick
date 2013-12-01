//
//  flickAppDelegate.m
//  veraflick
//
//  Created by Punit on 10/14/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "flickAppDelegate.h"
#import "flickViewRoomController.h"
#import "VeraRoom.h"
#import "VeraController.h"
#import "ZwaveNode.h"
#import "ZwaveSwitch.h"

#define MY_MIOS_USERNAME  @"javaguy01"
#define MY_MIOS_PASSWD @"Xunit12";

@implementation flickAppDelegate {
    VeraController *myVeraController;
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
    
    myVeraController = [VeraController sharedController];
    myVeraController.miosUsername = MY_MIOS_USERNAME;
    myVeraController.miosPassword = MY_MIOS_PASSWD;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
        //Check to see if the splashscreen is displayed (by checking if the navigation controller is not loaded.
        //TODO: hacky
        
        //Push the Room Detail View
        if (!loadedMainView) {
            //[self performSelectorOnMainThread:@selector(launchMainViewController) withObject:nil waitUntilDone:false];
            
            //Set up the heartbeat
            //[myVeraController startHeartbeat];
            loadedMainView = true;
        }
        
    }
    else if ([[notification name] isEqualToString:VERA_LOCATE_CONTROLLER_NOTIFICATION])
    {
        NSLog (@"flickAppDelegate_veraNotificationReceived::Locate Controller notification is successfully received!");
        [myVeraController refreshDevices];
    }
}

- (void) launchMainViewController {
    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
    
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
     */
    
    [self.window.rootViewController performSegueWithIdentifier:@"MainNavigationSegue" sender:self];
}

@end
