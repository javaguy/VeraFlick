//
//  FlickRoomSwitchCell.m
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "FlickRoomSwitchCell.h"

@implementation FlickRoomSwitchCell

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

-(IBAction)toggleSwitch:(id)sender {
    if (self.delegate) {
        [self.delegate switchTriggered:self withState:self.lightSwitch.isOn];
    }
}


@end
