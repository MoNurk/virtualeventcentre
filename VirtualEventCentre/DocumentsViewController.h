//
//  DocumentsViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 11/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface DocumentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    int sessionId;
    
    NSMutableArray* documents;
    
    UITableView* documentsTable;
    
    NSURL* urlToSend;
}

@property int sessionId;
@property (nonatomic, retain) NSMutableArray* documents;
@property (nonatomic, retain) IBOutlet UITableView* documentsTable;
@property (nonatomic, retain) NSURL* urlToSend;

- (void) populateDocuments:(int) sesId;

@end
