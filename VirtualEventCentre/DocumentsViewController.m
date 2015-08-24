//
//  DocumentsViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 11/09/2012.
//
//

#import "DocumentsViewController.h"
#import "Document.h"
#import "WebPageViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DocumentsViewController ()

@end

@implementation DocumentsViewController

@synthesize sessionId, documents, documentsTable, urlToSend;

- (void) populateDocuments:(int)sesId
{
    self.sessionId = sesId;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        documents = [[NSMutableArray alloc] init];
        
        NSString* encoded = [(AppDelegate *)[[UIApplication sharedApplication] delegate] base64UserPass];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/sessions/documents/%i", IP_ADDRESS_AMAZON_AWS, sessionId]]];
        [request setValue:encoded forHTTPHeaderField:@"Authorization"];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        __autoreleasing NSError* error = nil;
        if (data != nil && error == nil) {
            NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if ([json count] == 0) {
                Document* document = [[Document alloc] initWithDocumentId:1 documentName:@"No Documents" documentUrl:@"No Documents"];
                [documents addObject:document];
            }
            else {
                for (NSDictionary* item in json) {
                    int documentId = [[[item objectForKey:@"document"] objectForKey:@"documentId"] integerValue];
                    NSString* documentName = (NSString *)[[item objectForKey:@"document"] objectForKey:@"documentName"];
                    NSString* documentUrl = (NSString *)[[item objectForKey:@"document"] objectForKey:@"documentUrl"];
                    
                    documentUrl = [documentUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    
                    Document* document = [[Document alloc] initWithDocumentId:documentId documentName:documentName documentUrl:documentUrl];
                    [documents addObject:document];
                }
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            [documentsTable reloadData];
            [activityIndicator stopAnimating];
        });
    });

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [documents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DocumentCell"];
	Document *doc = [self.documents objectAtIndex:indexPath.row];
	cell.textLabel.text = doc.documentName;
    cell.detailTextLabel.text = doc.documentUrl; 
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Document *doc = [self.documents objectAtIndex:indexPath.row];
    urlToSend = [NSURL URLWithString:[doc documentUrl]];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[doc documentUrl]]];
    if (canOpen == YES) {
        if ([[doc documentUrl] hasSuffix:@".MOV"] || [[doc documentUrl] hasSuffix:@".mov"] || [[doc documentUrl] hasSuffix:@".mp4"] || [[doc documentUrl] hasSuffix:@".MP4"]) {
            NSLog(@"Is movie file");
            
            MPMoviePlayerViewController *playerv = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[doc documentUrl]]];
            
            [self presentMoviePlayerViewControllerAnimated:playerv];
        } else {
            [self performSegueWithIdentifier:@"WebViewSegue" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"WebViewSegue"])
    {
        WebPageViewController* wpvc = [segue destinationViewController];
        [wpvc setPageToLoadWithUrl:urlToSend];
    }
}

@end
