//
//  flickRoomCell.h
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
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




