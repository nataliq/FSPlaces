//
//  FSConnectionManager.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSUser;

@interface FSConnectionManager : NSObject

+ (NSURLRequest *)tokenRequest;
+ (BOOL)extractTockenFromResponseURL:(NSURL *)url;
+ (BOOL)isActive;
+ (NSArray*) findVenuesNearby:(CLLocation *)location limit:(int) limit searchterm:(NSString*) searchterm;
+ (FSUser *)getUserInfo;

@end
