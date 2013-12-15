//
//  flickUserInfo.h
//  veraflick
//
//  Created by Punit on 12/14/13.
//  Copyright (c) 2013 Punit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface flickUserInfo : NSObject

+(id)sharedUserInfo;

@property (atomic, strong) NSString *userName;
@property (atomic, strong) NSString *password;
@property (atomic, strong) NSMutableDictionary *roomImages;
@property (atomic, strong) NSArray *roomOrder;

-(void)saveUserInfo;
-(void)getUserInfo;
-(void)setImage:(UIImage*)image ForRoomId:(NSString*)roomId;
-(UIImage *)getImageForRoomId:(NSString*)roomId;

@end
