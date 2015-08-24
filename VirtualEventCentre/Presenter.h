//
//  Presenter.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Presenter : NSObject {
    long presenterId;
    NSString* firstName;
    NSString* surname;
    NSString* jobTitle;
    UIImage* profileImage;
}

@property (nonatomic) long presenterId; 
@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* surname;
@property (nonatomic, retain) NSString* jobTitle;
@property (nonatomic, retain) UIImage* profileImage;

- (Presenter *) initWithPresenterId:(long) Id firstName:(NSString *) presenterFirstName surname:(NSString *) presenterSurname jobTitle:(NSString *) presenterJobTitle profileImage: (UIImage *) presenterImage;

@end
