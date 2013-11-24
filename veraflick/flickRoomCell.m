//
//  flickRoomCell.m
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "flickRoomCell.h"

@implementation flickRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toggleSwitch:(id)sender {
    //Send the action to the delegate
    
    if (self.delegate != nil)
    {
        [self.delegate roomSwitchToggled:self value:self.roomSwitch.on];
        //[self.delegate performSelector:@selector(roomSwitchToggled:) withObject:self];
    }
}

@end
