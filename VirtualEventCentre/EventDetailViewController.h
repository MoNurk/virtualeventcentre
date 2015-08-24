//
//  EventDetailViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/09/2012.
//
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "TitleDetail.h"

@interface EventDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    Session* sessionToSend;
    
    NSString* url; 
    
    NSMutableArray *tempSessionsArray;
    NSMutableArray *sessions;
    NSMutableArray *finalSessions;
    
    UITableView* myTableView;
    UITableViewCell* myTableViewCell;
    
    int thisEventId;
    
    UIActivityIndicatorView* busyIndicator;
}

@property int thisEventId;

@property (nonatomic, retain) Session* sessionToSend;

@property (nonatomic, retain) NSString* url; 

@property (nonatomic, retain) NSMutableArray* tempSessionsArray;
@property (nonatomic, retain) NSMutableArray* sessions;
@property (nonatomic, retain) NSMutableArray* finalSessions;

@property (nonatomic, retain) IBOutlet UITableView* myTableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* myTableViewCell;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busyIndicator; 

- (void) setId:(int) Id withUrlToLoad:(NSString*) urlToLoad;
//- (void) addButtonsToTable;
- (NSString*) checkIfStringIsNil:(NSString*)stringToCheck;

@end
