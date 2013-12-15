//
//  FlickRoomDimmerCell.m
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
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
