//
//  flickViewRoomController.m
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "flickViewRoomController.h"
#import "flickViewRoomDetailController.h"
#import "flickRoomCell.h"
#import "VeraRoom.h"
#import "VeraController.h"
#import "ZwaveNode.h"
#import "ZwaveSwitch.h"

#define MY_MIOS_USERNAME  @"javaguy01"
#define MY_MIOS_PASSWD @"Xunit12";

@interface flickViewRoomController () <FlickRoomCellProtocol>

@end

@implementation flickViewRoomController {
    VeraController *myVeraController;
    NSArray *rooms;
    NSDictionary *roomImages;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Hide the tab bar controller since we don't use it right now
    [self hideTabBar:self.tabBarController];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_DEVICES_DID_REFRESH_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_LOCATE_CONTROLLER_NOTIFICATION
                                               object:nil];
    
    roomImages = [[NSDictionary alloc] initWithObjectsAndKeys: @"GenericRoom", @"Unassigned",  @"BedroomRoom", @"Master Bedroom", @"LivingRoom", @"Living Room", @"DiningRoom", @"Dining Room", @"KitchenRoom", @"Kitchen", nil];
    
    rooms = [[NSArray alloc] init];
    
    myVeraController = [VeraController sharedController];
    myVeraController.miosUsername = MY_MIOS_USERNAME;
    myVeraController.miosPassword = MY_MIOS_PASSWD;
    myVeraController.useMiosRemoteService = true;
    [myVeraController findVeraController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [rooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RoomCell";
    flickRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[flickRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }

    VeraRoom *room = (VeraRoom*)[rooms objectAtIndex:indexPath.row];
    
    cell.delegate = self;
    cell.roomID = indexPath.row;
    cell.roomLabel.text = room.name;
    cell.roomImageView.image = [UIImage imageNamed:[roomImages objectForKey:room.name]];
    
    bool switchOn = false;
    
    for (NSObject *device in room.devices) {
        if ([device isKindOfClass:[ZwaveSwitch class]]) {
            if ([(ZwaveSwitch*)device on]) {
                switchOn = true;
            }
        }
    }
    
    [cell.roomSwitch setOn:switchOn animated:false];
  
    return cell;
}

-(IBAction)roomSwitchToggled:(flickRoomCell*)sender value:(BOOL)value {
    VeraRoom *room = (VeraRoom*)[rooms objectAtIndex:sender.roomID];
    NSLog (@"VeraRoomController_RoomSwitchToggled:: %@, %@\n", room.name, (value?@"ON":@"OFF"));
    [self setLightsForRoom:room setOn:value];
}

- (void)setLightsForRoom:(VeraRoom*)room setOn:(BOOL)setOn {
    
    for (NSObject *node in room.devices)
    {
        if ([node isKindOfClass:[ZwaveSwitch class]]) {
            ZwaveSwitch *zwSwitch = (ZwaveSwitch*)node;
            
            NSLog (@"Toggling Light - %@\n", zwSwitch.name);
            [zwSwitch setOn:setOn completion:^(){
                NSLog(@"Light toggled\n");
            }];
        }
    }
}

NSIndexPath *segueHitIndex;
-(IBAction)segueButtonPressed:(id)sender
{
    
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    segueHitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
}

- (void) veraNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:VERA_DEVICES_DID_REFRESH_NOTIFICATION])
    {
        NSLog (@"Devices Refreshed notification is successfully received!");
        
        if (rooms.count != myVeraController.rooms.count) {
            //This is the first time we've gotten the state, or state has changed, refresh
            
            rooms = [[NSArray alloc] init];
            
            rooms = [myVeraController.rooms allValues];
            
            /*VeraRoom *firstRoom = nil;
            //We want to reorder the rooms by moving the unassigned room to the end
            for (VeraRoom *room in myVeraController.rooms) {
                
                if (!firstRoom) {
                    firstRoom = room;
                    continue;
                }
                rooms = [rooms arrayByAddingObject:room];
            }
            rooms = [rooms arrayByAddingObject:firstRoom];
             */
            
            //Set up the heartbeat
            [myVeraController startHeartbeat];
        }
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:false];
        

        
    }
    else if ([[notification name] isEqualToString:VERA_LOCATE_CONTROLLER_NOTIFICATION])
    {
        NSLog (@"Locate Controller notification is successfully received!");
        //self.titleLabel.text = @"Located Controller";
        //[self performSelectorOnMainThread:@selector(UpdateLabelText:) withObject:@"Located Controller" waitUntilDone:false];
        [myVeraController refreshDevices];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    flickViewRoomDetailController *newController = [segue destinationViewController];
    
    VeraRoom *room = [rooms objectAtIndex:segueHitIndex.row];
    
    newController.title = room.name;
    newController.room = room;
    newController.roomImageString = [roomImages objectForKey:room.name];
}



- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        //480px for pre-Iphone 5, 568px for Iphone 5+
        int newHeight = [[UIScreen mainScreen] bounds].size.height;
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, newHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, newHeight)];
        }
    }
    
    //[UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        //431px for pre-Iphone 5, 568-49px for Iphone 5+
        int newHeight = [[UIScreen mainScreen] bounds].size.height - 49;
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, newHeight, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, newHeight)];
        }
        
        
    }
    
    //[UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
@end
