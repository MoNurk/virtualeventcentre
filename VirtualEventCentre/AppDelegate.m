//
//  AppDelegate.m
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 14/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window, token, base64UserPass, isAdmin, isLoggedIn, userId;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [application setApplicationIconBadgeNumber:0];
    
    //[[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    
    if (token == NULL) {
        //do nothing
    }
    else {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            
            NSNumber *badge = [NSNumber numberWithInt:0];
            NSString *strWithoutSpaces  = [NSString stringWithFormat:@"%@", token];
            strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];    
            strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
            NSString *strDeviceToken = [strWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            [data setObject:strDeviceToken  forKey:@"deviceToken"];
            [data setObject:badge forKey:@"deviceBadge"];
            [outer setObject:data forKey:@"device"];
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outer options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", jsonString);
            
            NSHTTPURLResponse* urlResponse = nil;  
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://23.21.180.33:8080/resteasy/general/addDevice"]];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            [request setHTTPBody:jsonData];
            [request setHTTPMethod:@"POST"];
            [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error]; 
            
            dispatch_async( dispatch_get_main_queue(), ^{
                
            });
        });
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
     NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"My token is: %@", deviceToken);
        NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        NSNumber *badge = [NSNumber numberWithInt:0];
        NSString *strWithoutSpaces  = [NSString stringWithFormat:@"%@",deviceToken];
        strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];    
        strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
        NSString *strDeviceToken = [strWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        token = strDeviceToken;
        
        [data setObject:strDeviceToken  forKey:@"deviceToken"];
        [data setObject:badge forKey:@"deviceBadge"];
        [outer setObject:data forKey:@"device"];
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outer options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        
        NSHTTPURLResponse* urlResponse = nil;  
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://23.21.180.33:8080/resteasy/general/addDevice"]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setHTTPBody:jsonData];
        [request setHTTPMethod:@"POST"];
        [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error]; 
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
        });
    });
	

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	 NSLog(@"Failed to get token, error: %@", error);
}

@end
