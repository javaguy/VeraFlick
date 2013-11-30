//
//  FlickRoomSceneCell.h
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickRoomDetailCellProtocol.h"

@interface FlickRoomSceneCell : UITableViewCell

@property (atomic, strong) VeraSceneTrigger *sceneObject;
@property (atomic, strong) IBOutlet id<FlickRoomDetailCellProtocol> delegate;


@end
