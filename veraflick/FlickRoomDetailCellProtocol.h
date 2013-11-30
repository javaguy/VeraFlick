//
//  FlickRoomDetailCellProtocol.h
//  veraflick
//
//  Created by Punit on 11/29/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraSceneTrigger.h"
#import "ZwaveSwitch.h"
#import "ZwaveDimmerSwitch.h"

@protocol FlickRoomDetailCellProtocol <NSObject>

-(IBAction)sceneTriggered:(id)sender;
-(IBAction)switchTriggered:(id)sender withState:(BOOL)on;
-(IBAction)dimmerSwitchTriggered:(id)sender withBrightness:(int)brightness;

@end
