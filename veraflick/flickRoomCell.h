//
//  flickRoomCell.h
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

#import <UIKit/UIKit.h>

@protocol FlickRoomCellProtocol <NSObject>

- (IBAction)roomSwitchToggled:(id)sender value:(BOOL)value;

@end

@interface flickRoomCell : UITableViewCell

@property (atomic, strong) IBOutlet UILabel *roomLabel;
@property (atomic, strong) IBOutlet UIImageView *roomImageView;
@property (atomic, strong) IBOutlet UILabel *statusLabel;
@property (atomic, strong) IBOutlet UISwitch *roomSwitch;
@property (atomic) NSInteger roomID;
@property (atomic, strong) IBOutlet id<FlickRoomCellProtocol> delegate;

-(IBAction)toggleSwitch:(id)sender;
@end




