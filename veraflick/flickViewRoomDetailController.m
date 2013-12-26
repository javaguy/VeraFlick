//
//  flickViewRoomDetailController.m
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "flickViewRoomDetailController.h"
#import "VeraSceneTrigger.h"
#import "ZwaveNode.h"
#import "ZwaveSwitch.h"
#import "ZwaveDimmerSwitch.h"
#import "FlickRoomSwitchCell.h"
#import "FlickRoomSceneCell.h"
#import "FlickRoomDimmerCell.h"
#import "FlickRoomDetailCellProtocol.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+TPAdditions.h"
#import "flickUserInfo.h"


@interface flickViewRoomDetailController () <FlickRoomDetailCellProtocol, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation flickViewRoomDetailController {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(veraNotificationReceived:)
                                                 name:VERA_DEVICES_DID_REFRESH_NOTIFICATION
                                               object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    commandInProgress = false;
    
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.image = [[[flickUserInfo sharedUserInfo] getImageForRoomId:self.room.identifier] applyLightDarkEffect];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = bgView;
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
            ZwaveDimmerSwitch *dimmerSwitch = (ZwaveDimmerSwitch*)node;
            
            if (dimmerSwitch.on) {
                [cell.lightSlider setValue:(float)([(ZwaveDimmerSwitch*)node brightness]/100.0) animated:YES];
            }
            else {
                [cell.lightSlider setValue:0.0 animated:YES];
            }
            NSLog(@"RoomViewDetailController:: Light switch %@ State %@ Brightness %d", node.name, ([(ZwaveDimmerSwitch*)node on]?@"ON":@"OFF"), (int)[(ZwaveDimmerSwitch*)node brightness]);
            
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

#pragma mark - Vera Control

- (void) veraNotificationReceived:(NSNotification *) notification {
    if ([[notification name] isEqualToString:VERA_DEVICES_DID_REFRESH_NOTIFICATION]) {
        //Refresh the state if no commands are in progress.
        //TODO: should check to see if the room is still valid and dismiss otherwise
        if (!commandInProgress) {
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:false];
        }
    }
}

-(void)sceneTriggered:(id)sender {
    VeraSceneTrigger *scene = [(FlickRoomSceneCell*)sender sceneObject];
    NSLog (@"VeraRoomDetailContter_sceneTriggered:: %@", scene.name);
    [scene runSceneCompletion:^(){
        NSLog(@"Scene triggered\n");
    }];
}

-(void)switchTriggered:(id)sender withState:(BOOL)on {
    ZwaveSwitch *mySwitch = [(FlickRoomSwitchCell*)sender object];
    NSLog (@"VeraRoomDetailContter_switchTriggered:: %@, %@", mySwitch.name, (on?@"ON":@"OFF"));
    commandInProgress = true;
    [mySwitch setOn:on completion:^() {
        NSLog(@"Light toggled");
        commandInProgress = false;
    }];
}

-(void)dimmerSwitchTriggered:(id)sender withBrightness:(int)brightness {
    ZwaveDimmerSwitch *mySwitch = (ZwaveDimmerSwitch*)[(FlickRoomDimmerCell*)sender object];
    NSLog (@"VeraRoomDetailController_dimmerSwitchTriggered:: %@, %@, %d", mySwitch.name, (mySwitch.on?@"ON":@"OFF"), brightness);
    commandInProgress = true;
    [mySwitch setBrightness:brightness completion:^() {
        NSLog(@"Light brightness set");
        commandInProgress = false;
    }];
}

#pragma mark - Action Sheet Commands

-(IBAction)addButtonPress:(id)sender {
    NSString *actionSheetTitle = @"Select Action"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    //NSString *other1 = @"Add Scene";
    NSString *other2 = @"Set Room's Image";
    NSString *other3 = @"Clear Room's Image";
    NSString *cancelTitle = @"Cancel";
    
    flickUserInfo *userInfo = [flickUserInfo sharedUserInfo];

    if ([userInfo isCustomImageSetForRoomId:self.room.identifier]) {
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other2, other3, nil];
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:actionSheetTitle
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:other2, nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Destructive Button"]) {
        NSLog(@"Destructive pressed --> Delete Something");
    }
    if ([buttonTitle isEqualToString:@"Add Scene"]) {
        NSLog(@"Other 1 pressed");
    }
    if ([buttonTitle isEqualToString:@"Set Room's Image"]) {
        NSLog(@"Other 2 pressed");
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    if ([buttonTitle isEqualToString:@"Clear Room's Image"]) {
        NSLog(@"Other 3 pressed");
        
        flickUserInfo *userInfo = [flickUserInfo sharedUserInfo];
        [userInfo setImage:nil ForRoomId:self.room.identifier];
        
        UIImageView *bgView = (UIImageView*)self.tableView.backgroundView;
        bgView.image = [userInfo getImageForRoomId:self.room.identifier];
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        [self performSelector:@selector(swapBackgroundImageWithTransition) withObject:nil afterDelay:1];
    }
    if ([buttonTitle isEqualToString:@"Cancel Button"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)swapBackgroundImageWithTransition
{
    flickUserInfo *userInfo = [flickUserInfo sharedUserInfo];
    
    UIImageView *bgView = (UIImageView*)self.tableView.backgroundView;
    bgView.image = [[userInfo getImageForRoomId:self.room.identifier] applyLightDarkEffect];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [bgView.layer addAnimation:transition forKey:nil];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *smallImage = [image imageScaledToSize:CGSizeMake(640.0f, (image.size.height/image.size.width)*640.0f)];
    
    flickUserInfo *userInfo = [flickUserInfo sharedUserInfo];
    
    [userInfo setImage:smallImage ForRoomId:self.room.identifier];
    
    UIImageView *bgView = (UIImageView*)self.tableView.backgroundView;
    bgView.image = image;
    bgView.contentMode = UIViewContentModeScaleAspectFill;

    [self dismissViewControllerAnimated:YES completion:^() {
        [self swapBackgroundImageWithTransition];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
