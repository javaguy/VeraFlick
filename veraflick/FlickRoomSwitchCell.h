//
//  FlickRoomSwitchCell.h
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickRoomDetailCellProtocol.h"

@interface FlickRoomSwitchCell : UITableViewCell

@property (atomic, strong) IBOutlet UILabel *lightLabel;
@property (atomic, strong) ZwaveSwitch  *object;
@property (atomic, strong) IBOutlet UISwitch *lightSwitch;
@property (atomic, strong) IBOutlet id<FlickRoomDetailCellProtocol> delegate;

-(IBAction)toggleSwitch:(id)sender;

@end
