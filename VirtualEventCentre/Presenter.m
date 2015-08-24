//
//  Presenter.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/09/2012.
//
//

#import "Presenter.h"

@implementation Presenter

@synthesize presenterId, firstName, surname, jobTitle, profileImage;

- (Presenter *) initWithPresenterId:(long)Id firstName:(NSString *)presenterFirstName surname:(NSString *)presenterSurname jobTitle:(NSString *)presenterJobTitle profileImage:(UIImage *)presenterImage
{
    self.presenterId = Id;
    self.firstName = presenterFirstName;
    self.surname = presenterSurname;
    self.jobTitle = presenterJobTitle;
    self.profileImage = presenterImage;
    
    return self; 
}

@end
