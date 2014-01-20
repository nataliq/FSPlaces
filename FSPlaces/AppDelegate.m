//
//  AppDelegate.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "AppDelegate.h"
#import "FSConnectionManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Override point for customization after application launch.
    if ([self.window respondsToSelector:@selector(setTintColor:)]) {
        [self.window setTintColor:[UIColor colorWithRed:189.0f/255.0f green:70.0f/255.0f blue:220.0f/255.0f alpha:1.0]];
    }

    return YES;
    
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"fsplaces"]) {
        [[FSConnectionManager sharedManager] handleFSOAuthURL:url];
    }
    return YES;
}

@end
