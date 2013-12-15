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
#import "flickUserInfo.h"

@interface flickViewRoomController () <FlickRoomCellProtocol>

@end

@implementation flickViewRoomController {
    VeraController *myVeraController;
    NSArray *rooms;
    flickUserInfo *userInfo;
    BOOL commandInProgress;
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
    //[self hideTabBar:self.tabBarController];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_DEVICES_DID_REFRESH_NOTIFICATION
                                               object:nil];
    
    //roomImages = [[NSDictionary alloc] initWithObjectsAndKeys: @"GenericRoom", @"Unassigned",  @"BedroomRoom", @"Master Bedroom", @"LivingRoom", @"Living Room", @"DiningRoom", @"Dining Room", @"KitchenRoom", @"Kitchen", nil];
    
    myVeraController = [VeraController sharedController];
    
    userInfo = [flickUserInfo sharedUserInfo];
    
    NSArray *orderedRoomsIds = userInfo.roomOrder;
    
    if (orderedRoomsIds == nil) {
        //First time usecase
        NSArray *veraRooms = [myVeraController.rooms allValues];
        orderedRoomsIds = [[NSArray alloc] initWithArray:[veraRooms valueForKeyPath:@"identifier"]];
    }
    
    //Order the rooms according to user preference, adding any new rooms at the end
    NSMutableDictionary *tempRooms = [[NSMutableDictionary alloc]
                                        initWithDictionary:myVeraController.rooms];
    NSMutableArray *orderedRooms = [[NSMutableArray alloc]
                                        initWithCapacity:tempRooms.count];

    for (NSString *roomId in orderedRoomsIds) {
        VeraRoom *r = [tempRooms objectForKey:roomId];
        
        if (r != nil) {
            [orderedRooms addObject:r];
            [tempRooms removeObjectForKey:roomId];
        }
    }
    [orderedRooms addObjectsFromArray:[tempRooms allValues]];
    
    //Save the new order back
    orderedRoomsIds = [orderedRooms valueForKeyPath:@"identifier"];

    ((flickUserInfo*)[flickUserInfo sharedUserInfo]).roomOrder = orderedRoomsIds;
    
    rooms = orderedRooms;
    
    commandInProgress = false;
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
    cell.roomImageView.image = [userInfo getImageForRoomId:room.identifier];
    
    bool switchOn = false;
    bool hasLight = false;
    for (NSObject *device in room.devices) {
        if ([device isKindOfClass:[ZwaveSwitch class]]) {
            if ([(ZwaveSwitch*)device on]) {
                switchOn = true;
            }
            hasLight = true;
        }
    }
    
    if (hasLight) {
        cell.roomSwitch.hidden = false;
        [cell.roomSwitch setOn:switchOn animated:false];
    }
    else {
        cell.roomSwitch.hidden = true;
    }
  
    return cell;
}

-(IBAction)roomSwitchToggled:(flickRoomCell*)sender value:(BOOL)value {
    VeraRoom *room = (VeraRoom*)[rooms objectAtIndex:sender.roomID];
    NSLog (@"VeraRoomController_RoomSwitchToggled:: %@, %@\n", room.name, (value?@"ON":@"OFF"));
    [self setLightsForRoom:room setOn:value];
}

int numLights;
- (void)setLightsForRoom:(VeraRoom*)room setOn:(BOOL)setOn {
    
    numLights = 0;
    commandInProgress = true;
    
    for (NSObject *node in room.devices)
    {
        if ([node isKindOfClass:[ZwaveSwitch class]]) {
            ZwaveSwitch *zwSwitch = (ZwaveSwitch*)node;
            
            
            numLights++;
            NSLog (@"Toggling Light - %@\n", zwSwitch.name);
            [zwSwitch setOn:setOn completion:^(){
                NSLog(@"Light toggled\n");
                if (--numLights == 0) {
                    commandInProgress = false;
                }
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
        
        //TODO: Refresh the rooms, the app won't reflect new rooms until restarted
        //rooms = [myVeraController.rooms allValues];
        
        if (!commandInProgress) {
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:false];
        }
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
