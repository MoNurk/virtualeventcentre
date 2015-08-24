//
//  EditSessionDetailsViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 20/03/2013.
//
//

#import "EditSessionDetailsViewController.h"
#import "ConnectionToServer.h"

@interface EditSessionDetailsViewController ()

@end

@implementation EditSessionDetailsViewController

@synthesize name, description, videoURL, session;

- (void) setSession:(Session *)theSession
{
    session = theSession;
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-gradient-2.png"]];
    
    [name setText:[session sessionName]];
    [description setText:[session sessionDescription]];
    [videoURL setText:[session videoUrl]];
    
    NSLog(@"Testing: %@", [session sessionName]);
}

- (IBAction)submitUpdate:(id)sender
{
    //NSHTTPURLResponse * urlResponse = [ConnectionToServer makePUTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/sessions/%li", IP_ADDRESS_AMAZON_AWS, [session sessionId]]]];
    
    NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    
    [data setObject:[name text] forKey:@"sessionName"];
    [data setObject:[description text] forKey:@"sessionDescription"];
    if ([videoURL text] == nil) {
        [videoURL setText:@""];
    }
    [data setObject:[videoURL text] forKey:@"videoUrl"];
    [outer setObject:data forKey:@"session"];
    
    NSHTTPURLResponse * urlResponse = [ConnectionToServer makePUTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/sessions/%li", IP_ADDRESS_AMAZON_AWS, [session sessionId]]] jsonData:outer];
    
    if ([urlResponse statusCode] == 202) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Updated" message:@"Session has been updated successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Session update has failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
