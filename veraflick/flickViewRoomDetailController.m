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


@interface flickViewRoomDetailController ()

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
    static NSString *CellIdentifier = @"RoomDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0 && [self.room.scenes count] != 0) {
        VeraSceneTrigger *scene = [self.room.scenes objectAtIndex:indexPath.row];
        cell.textLabel.text = scene.name;
    }
    else {
        ZwaveNode *node = [self.room.devices objectAtIndex:indexPath.row];
        cell.textLabel.text = node.name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
