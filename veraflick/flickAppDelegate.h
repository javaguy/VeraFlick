//
//  flickAppDelegate.h
//  veraflick
//
//  Created by Punit on 10/14/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "flickUserInfo.h"

@interface flickAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) flickUserInfo *userInfo;

@end
