//
//  FlickRoomDimmerCell.h
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickRoomDetailCellProtocol.h"
#import "FlickRoomSwitchCell.h"

@interface FlickRoomDimmerCell : FlickRoomSwitchCell

@property (atomic, strong) IBOutlet UISlider *lightSlider;

-(IBAction)dimmerValueChanged:(id)sender;

@end
