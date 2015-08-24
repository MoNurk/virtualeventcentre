//
//  EditPresenterViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 25/03/2013.
//
//

#import "EditPresenterViewController.h"
#import "UploadProfileImageViewController.h"
#import "ConnectionToServer.h"

@interface EditPresenterViewController ()

@end

@implementation EditPresenterViewController

@synthesize presenterTable, presenter, presenters, json;

- (void) myModalViewControllerDidFinishAddingPresenter:(AddPresenterViewController *)controller
{
    NSLog(@"Should dismiss");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self populatePresenters];
}

- (void) myModalViewControllerDidCancel:(AddPresenterViewController *)controller
{
    NSLog(@"Should dismiss");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) addButtonPressed:(id)sender
{
    [self.navigationController performSegueWithIdentifier:@"AddPresenterSegue" sender:sender];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddPresenterSegue"])
    {
        AddPresenterViewController * addPresenterVC = [segue destinationViewController];
        addPresenterVC.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"UploadProfileImage"])
    {
        UploadProfileImageViewController * uploadProfile = [segue destinationViewController];
        [uploadProfile initPresenterId:[presenter presenterId]];
    }
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
    [self populatePresenters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) populatePresenters
{
    
//    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [activityIndicator setHidesWhenStopped:YES];
//    [activityIndicator setHidden:NO];
//    [activityIndicator startAnimating];
//    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
//    [self navigationItem].rightBarButtonItem = barButton;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        presenters = [[NSMutableArray alloc] init];
        
        json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/presenter", IP_ADDRESS_AMAZON_AWS]]];
        
        for (NSDictionary* item in json) {
            int presenterId = [[[item objectForKey:@"presenter"] objectForKey:@"presenterId"] integerValue];
            NSString* firstName = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"firstName"];
            NSString* surname = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"surname"];
            NSString* jobTitle = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"jobTitle"];
            
            presenter = [[Presenter alloc] initWithPresenterId:presenterId firstName:firstName surname:surname jobTitle:jobTitle  profileImage:nil];
            [presenters addObject:presenter];
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            [presenterTable reloadData];
            //[activityIndicator stopAnimating];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [presenters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PresenterCell"];
    Presenter * thisPresenter = [self.presenters objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [thisPresenter firstName], [thisPresenter surname]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Presenter *thePresenter = [self.presenters objectAtIndex:indexPath.row];
    presenter = thePresenter;
    
    [self performSegueWithIdentifier:@"UploadProfileImage" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//TODO: User should not be able to delete an event unless they have logged in as an admin.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isAdmin = [(AppDelegate *)[[UIApplication sharedApplication] delegate] isAdmin];
    NSString* encoded = [(AppDelegate *)[[UIApplication sharedApplication] delegate] base64UserPass];
    if (isAdmin == YES) {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSMutableArray *copiedArray = [self.presenters mutableCopy];
            
            Presenter * thisPresenter = [self.presenters objectAtIndex:indexPath.row];
            [copiedArray removeObjectAtIndex:indexPath.row];
            self.presenters = copiedArray;
            
            NSString *urlDeleteString = [NSString stringWithFormat:@"%@resteasy/presenter/", IP_ADDRESS_AMAZON_AWS];
            long urlDeleteId = [thisPresenter presenterId];
            NSString *appendedId = [NSString stringWithFormat:@"%@%li", urlDeleteString, urlDeleteId];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appendedId]];
            [request setValue:encoded forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"DELETE"];
            [NSURLConnection connectionWithRequest:request delegate:self];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
