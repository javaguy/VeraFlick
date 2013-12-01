//
//  flickViewRoomDetailController.h
//  veraflick
//
//  Created by Punit on 11/23/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VeraController.h"
#import "VeraRoom.h"

@interface flickViewRoomDetailController : UITableViewController
@property (atomic, strong) VeraRoom *room;
@property (atomic, strong) NSString *roomImageString;
@end
