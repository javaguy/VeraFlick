//
//  FlickRoomSceneCell.m
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import "FlickRoomSceneCell.h"

@implementation FlickRoomSceneCell

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
    
    if (self.delegate && selected) {
        [self.delegate sceneTriggered:self];
        [super setSelected:false animated:YES];
    }
    
}

@end
