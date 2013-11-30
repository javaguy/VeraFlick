//
//  flickViewRoomDetailController.m
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "flickViewRoomDetailController.h"
#import "VeraSceneTrigger.h"
#import "ZwaveNode.h"
#import "ZwaveSwitch.h"
#import "ZwaveDimmerSwitch.h"
#import "FlickRoomSwitchCell.h"
#import "FlickRoomSceneCell.h"
#import "FlickRoomDimmerCell.h"
#import "FlickRoomDetailCellProtocol.h"


@interface flickViewRoomDetailController () <FlickRoomDetailCellProtocol>

@end

@implementation flickViewRoomDetailController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_DEVICES_DID_REFRESH_NOTIFICATION
                                               object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    if ([self.room.scenes count] == 0)
        return 1;
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.room.scenes count] != 0) {
        //Return the scene
        return @"Scenes";
    }
    else {
        return @"Devices";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0 && [self.room.scenes count] != 0) {
        //Return the scene
        return [self.room.scenes count];
    }
    else {
        return [self.room.devices count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier[] = {@"RoomDetailSceneCell", @"RoomDetailSwitchCell", @"RoomDetailDimmerCell", @"RoomDetailUnsupportedCell"};
    int cellToUse = -1;
    UITableViewCell *returnCell;
    
    //Figure out the cell type that we need
    // Configure the cell...
    if (indexPath.section == 0 && [self.room.scenes count] != 0) {
        //We are configuring a scene object
        
        VeraSceneTrigger *scene = [self.room.scenes objectAtIndex:indexPath.row];
        cellToUse = 0;
        
        FlickRoomSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier[cellToUse] forIndexPath:indexPath];
        
        if (cell == nil) {
            cell = [[FlickRoomSceneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(CellIdentifier[cellToUse])];
        }
        
        cell.delegate = self;
        cell.textLabel.text = scene.name;
        cell.sceneObject = scene;
        
        returnCell = cell;
    }
    else {
        //It is a device
        ZwaveNode *node = [self.room.devices objectAtIndex:indexPath.row];
        
        if ([node isKindOfClass:[ZwaveDimmerSwitch class]]) {
            cellToUse = 2;
            FlickRoomDimmerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier[cellToUse] forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[FlickRoomDimmerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(CellIdentifier[cellToUse])];
            }
            
            cell.delegate = self;
            cell.lightLabel.text = node.name;
            cell.object = (ZwaveSwitch*)node;

            [cell.lightSlider setValue:[(ZwaveDimmerSwitch*)node brightness] animated:YES];
            
            returnCell = cell;
        }
        else if ([node isKindOfClass:[ZwaveSwitch class]]) {
            cellToUse = 1;
            FlickRoomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier[cellToUse] forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[FlickRoomSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(CellIdentifier[cellToUse])];
            }
            
            cell.delegate = self;
            cell.lightLabel.text = node.name;
            cell.lightSwitch.on = [(ZwaveSwitch*)node on];
            cell.object = (ZwaveSwitch*)node;
            returnCell = cell;
        }
        else {
            //Unsupported device
            cellToUse = 3;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier[cellToUse] forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[FlickRoomSwitchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:(CellIdentifier[cellToUse])];
            }
            
            cell.textLabel.text = node.name;
            returnCell = cell;

        }
    }
    
    return returnCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [self.room.scenes count] != 0) {
        //Its a scene
        return tableView.rowHeight;
    }
    else if ([[self.room.devices objectAtIndex:indexPath.row] isKindOfClass:[ZwaveDimmerSwitch class]]) {
        
        //Use the custom height as defined in the storyboard (this is workaround for storyboard bug)
        return  82;
    }
    else {
        return tableView.rowHeight;
    }
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Figure out which scene or light
    if (indexPath.section == 0 && [self.room.scenes count] != 0) {
        //It is a scene, run it
        VeraSceneTrigger *scene = [self.room.scenes objectAtIndex:indexPath.row];
        
        NSLog (@"Triggering Scene - %@", scene.name);
        
        [scene runSceneCompletion:^(){
            NSLog(@"Scene triggered\n");
        }];
    }
    else {
        ZwaveNode *node = [self.room.devices objectAtIndex:indexPath.row];
        
        if ([node isKindOfClass:[ZwaveSwitch class]]) {
            NSLog (@"Turing Light off - %@", node.name);
            [(ZwaveSwitch*)node setOn:false completion:^() {
                NSLog(@"Light turned off");
            }];
        }
        
    }
}*/

- (void) veraNotificationReceived:(NSNotification *) notification {
    if ([[notification name] isEqualToString:VERA_DEVICES_DID_REFRESH_NOTIFICATION]) {
        //Refresh the state.
        //TODO: should check to see if the room is still valid
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:false];
    }

}

-(void)sceneTriggered:(id)sender {
    VeraSceneTrigger *scene = [(FlickRoomSceneCell*)sender sceneObject];
    
    NSLog (@"Triggering Scene - %@", scene.name);
    
    [scene runSceneCompletion:^(){
        NSLog(@"Scene triggered\n");
    }];
 
}

-(void)switchTriggered:(id)sender withState:(BOOL)on {
    ZwaveSwitch *mySwitch = [(FlickRoomSwitchCell*)sender object];
    
    NSLog (@"Toggling light %@ %@", mySwitch.name, (on?@"ON":@"OFF"));
    [mySwitch setOn:on completion:^() {
        NSLog(@"Light toggled");
    }];
}

-(void)dimmerSwitchTriggered:(id)sender withBrightness:(int)brightness {
    ZwaveDimmerSwitch *mySwitch = (ZwaveDimmerSwitch*)[(FlickRoomDimmerCell*)sender object];
    
    NSLog (@"Dimming light %@ %d", mySwitch.name, brightness);
    [mySwitch setBrightness:brightness completion:^() {
        NSLog(@"Light toggled");
    }];
}


/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

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



@end
