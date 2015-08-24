//
//  EditSessionViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import <UIKit/UIKit.h>
#import "AddSessionViewController.h"

@interface EditSessionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, AddSessionViewControllerDelegate> {
    
    Session * selectedSession;
    
    UITableView * myTableView;
    
    int sessionIdToSend;
    
    NSMutableArray *tempSessionsArray;
    NSMutableArray *sessions;
    NSMutableArray *finalSessions;
}
@property (nonatomic, retain) Session * selectedSession;

@property (nonatomic, retain) IBOutlet UITableView * myTableView;

@property int sessionIdToSend;

@property (nonatomic, retain) NSMutableArray* tempSessionsArray;
@property (nonatomic, retain) NSMutableArray* sessions;
@property (nonatomic, retain) NSMutableArray* finalSessions;

@end
