//
//  flickUserInfo.m
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

#import "flickUserInfo.h"

@implementation flickUserInfo

static flickUserInfo *sharedInstance;

NSDictionary *roomImageDefaults;

+(id)sharedUserInfo{
    @synchronized(self) {
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] init];
            
            //These are stock images hardcoded to a specific room id. Update these to fix images specific to your room.
            roomImageDefaults = [[NSDictionary alloc] initWithObjectsAndKeys: @"GenericRoom", @"0",  @"BedroomRoom", @"1", @"LivingRoom", @"2", @"DiningRoom", @"3", @"KitchenRoom", @"4", nil];
        }
    }
    return sharedInstance;
}

-(void)getUserInfo {
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.userName = [defaults objectForKey:@"userName"];
    self.password = [defaults objectForKey:@"password"];
    self.roomImages = [defaults objectForKey:@"roomImages"];
    self.roomOrder = [defaults objectForKey:@"roomOrder"];
    
    //This is to hardcode the values since no editing UI exists yet
    //self.roomOrder = [[NSArray alloc] initWithObjects:@"1", @"3", @"2", @"4", @"0", nil];
    
    if (self.roomImages == nil) {
        self.roomImages = [[NSMutableDictionary alloc] init];
    }
}

-(void)saveUserInfo {
    //Save the user data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.userName forKey:@"userName"];
    [defaults setObject:self.password forKey:@"password"];
    [defaults setObject:self.roomImages forKey:@"roomImages"];
    [defaults setObject:self.roomOrder forKey:@"roomOrder"];
    
    [defaults synchronize];
}

-(void)setImage:(UIImage*)image ForRoomId:(NSString*)roomId {
    
    if (image != nil) {
        NSData *imageData = UIImagePNGRepresentation(image);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.png", roomId, @"cached"]];
        
        NSLog((@"pre writing to file"));
        if (![imageData writeToFile:imagePath atomically:NO]) {
            NSLog((@"Failed to cache image data to disk"));
        }
        else {
            NSLog(@"the cachedImagedPath is %@",imagePath);
            
            //Save the image in the room Images dictionary
            [self.roomImages setObject:imagePath forKey:roomId];
        }
    }
    else {
        [self.roomImages removeObjectForKey:roomId];
    }
    
    [self saveUserInfo];
}

-(bool)isCustomImageSetForRoomId:(NSString*)roomId {
    NSString *pathToImage = [self.roomImages valueForKey:roomId];
    
    if (pathToImage == nil || [pathToImage isEqualToString:@""]) {
        return false;
    }
    
    return  true;
}

-(UIImage *)getImageForRoomId:(NSString*)roomId {
    UIImage *image;
    NSString *pathToImage = [self.roomImages valueForKey:roomId];
    
    if (pathToImage == nil || [pathToImage isEqualToString:@""]) {
        image = [UIImage imageNamed:[roomImageDefaults objectForKey:roomId]];
        
    }
    else {
        image = [UIImage imageWithContentsOfFile:pathToImage];
    }
    
    if (image == nil) {
        //Placeholder image
        image = [UIImage imageNamed:[roomImageDefaults objectForKey:@"0"]];
    }

    return image;
}

@end
