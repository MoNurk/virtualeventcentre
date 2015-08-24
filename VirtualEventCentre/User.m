//
//  User.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import "User.h"

@implementation User

@synthesize userId, username, password;

- (User *) initWithUserId:(int)Id username:(NSString *)uname password:(NSString *)pw
{
    self.userId = Id;
    self.username = uname;
    self.password = pw;
    
    return self;
}

@end
