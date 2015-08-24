//
//  EditSessionDetailsViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 20/03/2013.
//
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface EditSessionDetailsViewController : UIViewController {
    
    Session * session;
    
    UITextField * name;
    UITextField * description;
    UITextField * videoURL;
}

@property (nonatomic, retain) Session * session;

@property (nonatomic, retain) IBOutlet UITextField * name;
@property (nonatomic, retain) IBOutlet UITextField * description;
@property (nonatomic, retain) IBOutlet UITextField * videoURL;

- (void) setSession:(Session*)theSession;
- (IBAction)submitUpdate:(id)sender;

@end
