//
//  FlickRoomDimmerCell.m
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

#import "FlickRoomDimmerCell.h"

@implementation FlickRoomDimmerCell

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

-(IBAction)dimmerValueChanged:(id)sender {
    
    UISlider *slider = (UISlider*)sender;
    
    if (self.delegate) {
        int newValue = (int)(slider.value*100.0);
        [self.delegate dimmerSwitchTriggered:self withBrightness:newValue];
    }
}

-(IBAction)maxBrightnessSelected:(id)sender {
    if (self.delegate) {
        [self.delegate switchTriggered:self withState:true];
    }
    self.lightSlider.value = 100.0f;
}

-(IBAction)minBrightnessSelected:(id)sender {
    if (self.delegate) {
        [self.delegate switchTriggered:self withState:false];
    }
    self.lightSlider.value = 0.0f;
}
@end
