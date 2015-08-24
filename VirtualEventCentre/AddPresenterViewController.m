//
//  AddPresenterViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 25/03/2013.
//
//

#import "AddPresenterViewController.h"
#import "ConnectionToServer.h"

@interface AddPresenterViewController ()

@end

@implementation AddPresenterViewController

@synthesize delegate=_delegate, firstName, surname, jobTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)done:(id)sender
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setObject:[firstName text] forKey:@"firstName"];
        [data setObject:[surname text] forKey:@"surname"];
        [data setObject:[jobTitle text] forKey:@"jobTitle"];
        [outer setObject:data forKey:@"presenter"];
        
        NSHTTPURLResponse * urlResponse = [ConnectionToServer makePOSTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/presenter", IP_ADDRESS_AMAZON_AWS]] jsonData:outer];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([urlResponse statusCode] == 201
                ) {
                [self.delegate myModalViewControllerDidFinishAddingPresenter:self];
            }
            else {
                UIAlertView *failedAdd = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"There was an error adding the Presenter. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [failedAdd show];
            }
        });
    });

    
    //[self.delegate myModalViewControllerDidFinishAddingPresenter:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate myModalViewControllerDidCancel:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
