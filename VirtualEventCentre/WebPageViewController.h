//
//  WebPageViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 12/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface WebPageViewController : UIViewController <UIWebViewDelegate, UIDocumentInteractionControllerDelegate> {
    
    UIActivityIndicatorView* activityIndicator;
    
    UIDocumentInteractionController *interactionController;
    
    UIBarButtonItem * actionButton;
    
    UIWebView *myWebView;
    
    NSURL* urlToLoad;
    
    NSData * fileOnline;
}

@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@property (nonatomic, retain) UIDocumentInteractionController * interactionController; 

@property (nonatomic, retain) IBOutlet UIBarButtonItem * actionButton;

@property (nonatomic, retain) IBOutlet UIWebView* myWebView;

@property (nonatomic, retain) NSURL* urlToLoad;

@property (nonatomic, retain) NSData * fileOnline; 

- (void) setPageToLoadWithUrl:(NSURL*) url;

@end
