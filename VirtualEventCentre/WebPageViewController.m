//
//  WebPageViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 12/09/2012.
//
//

#import "WebPageViewController.h"

@interface WebPageViewController ()

@end

@implementation WebPageViewController

@synthesize myWebView, urlToLoad, activityIndicator, actionButton, interactionController, fileOnline;

- (void) setPageToLoadWithUrl:(NSURL *)url
{
    self.urlToLoad = url; 
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
    
    if ([[urlToLoad absoluteString] hasSuffix:@".MOV"] || [[urlToLoad absoluteString] hasSuffix:@".mov"] || [[urlToLoad absoluteString] hasSuffix:@".mp4"] || [[urlToLoad absoluteString] hasSuffix:@".MP4"]) {
        NSLog(@"Is movie file");
    } else {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Get file online
            fileOnline = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlToLoad absoluteString]]];
            dispatch_async( dispatch_get_main_queue(), ^{
                actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInAction)];
                [[self navigationItem] setRightBarButtonItem:actionButton];
            });
        });
    }
}

- (void) openInAction
{
    NSArray *parts = [[urlToLoad absoluteString] componentsSeparatedByString:@"/"];
    NSString *previewDocumentFileName = [parts lastObject];
    NSLog(@"The file name is %@", previewDocumentFileName);
    
    // Write file to the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (!documentsDirectory) {
        NSLog(@"Documents directory not found!");
    }
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:previewDocumentFileName];
    [fileOnline writeToFile:appFile atomically:YES];
    
    // Get file again from Documents directory
    NSURL *fileURL = [NSURL fileURLWithPath:appFile];
    interactionController = [UIDocumentInteractionController  interactionControllerWithURL:fileURL];
    interactionController.delegate = self;
    interactionController.UTI = @"public.data";
    CGRect rect = CGRectMake(0, 0, 300, 300);
    [interactionController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
{
    NSLog(@"Did Dismiss");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setHidden:YES];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    [myWebView setScalesPageToFit:YES];
    
    //URL Request Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[self urlToLoad]];
    
    //Load the request in the UIWebView.
    [myWebView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    } else {
        return NO;
    }
}

@end
