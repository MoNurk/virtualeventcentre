//
//  PresenterViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/09/2012.
//
//

#import <UIKit/UIKit.h>
#import "Presenter.h"

@interface PresenterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray* presenters;
    NSMutableArray * json;
    
    UITableView* presenterTable;
    
    Presenter * presenter;
    
    int presenterIdToSend;
}

@property (nonatomic, retain) NSMutableArray* presenters;
@property (nonatomic, retain) NSMutableArray* json;
@property (nonatomic, retain) IBOutlet UITableView* presenterTable;
@property (nonatomic, retain) Presenter * presenter; 

@property int presenterIdToSend;

- (void) populatePresenters;
- (IBAction)refresh:(id)sender;

@end
