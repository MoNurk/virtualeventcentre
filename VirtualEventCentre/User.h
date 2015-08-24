//
//  User.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface User : NSObject {
    
    int userId;
    NSString* username;
    NSString* password;
}

@property int userId;

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

- (User *) initWithUserId:(int) Id username:(NSString*) uname password:(NSString*) pw;

@end
