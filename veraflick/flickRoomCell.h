//
//  flickRoomCell.h
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flickRoomCell : UITableViewCell

@property (atomic, strong) IBOutlet UILabel *roomLabel;
@property (atomic, strong) IBOutlet UIImageView *roomImageView;
@property (atomic, strong) IBOutlet UILabel *statusLabel;

-(IBAction)toggleSwitch:(id)sender;


@end
