//
//  AppDelegate.h
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 14/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    NSString *token;
    
    NSString* base64UserPass;
    
    BOOL isAdmin;
    BOOL isLoggedIn;
    
    int userId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *token;

@property (nonatomic, retain) NSString* base64UserPass;

@property BOOL isAdmin;
@property BOOL isLoggedIn;

@property int userId;

@end
