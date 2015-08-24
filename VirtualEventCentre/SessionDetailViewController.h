//
//  SessionDetailViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 09/09/2012.
//
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface SessionDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    
    Session* selectedSession;
    
    UITableView* myTableView;
    
    NSMutableArray* titlesAndText;
    
    NSString* documentTitle;
    NSString* documentDetailText;
}

@property (nonatomic, retain) Session* selectedSession;

@property (nonatomic, retain) IBOutlet UITableView* myTableView;

@property (nonatomic, retain) NSMutableArray* titlesAndText;

@property (nonatomic, retain) NSString* documentTitle;
@property (nonatomic, retain) NSString* documentDetailText;

- (void) setMySession:(Session *)session;
//- (void) addButtonsToTable;
- (void) createEvent;
- (void) showTweetSheet;

@end
