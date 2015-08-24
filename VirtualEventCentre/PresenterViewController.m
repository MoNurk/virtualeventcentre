//
//  PresenterViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/09/2012.
//
//

#import "PresenterViewController.h"
#import "EventDetailViewController.h"
#import "PresenterCell.h"
#import "Presenter.h"
#import "ConnectionToServer.h"

@interface PresenterViewController ()

@end

@implementation PresenterViewController

@synthesize presenters, presenterTable, presenterIdToSend, presenter, json;

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
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
	// Do any additional setup after loading the view.
    [self populatePresenters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender
{
    [self populatePresenters];
}

-(void) populatePresenters
{
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
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
            [self loadImages];
            [activityIndicator stopAnimating];
        });
    });
}

- (void) loadImages
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * images = [[NSMutableArray alloc] init];
        for (NSDictionary* item in json)
        {
            NSString* imageUrl = (NSString*)[[item objectForKey:@"presenter"] objectForKey:@"profileImage"];
            
            if(imageUrl == nil) {
                [images addObject:[UIImage imageNamed:@"man.png"]];
            } else {
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageUrl]];
                UIImage* image = [UIImage imageWithData:imageData];
            
                [images addObject:image];
            }
        }
        
        int i = 0;
        for (Presenter * pres in presenters) {
            pres.profileImage = [images objectAtIndex:i];
            [presenterTable reloadData];
            i++;  
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            [presenterTable reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [presenters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PresenterCell *cell = (PresenterCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"PresenterCell"];
	Presenter *pre = [self.presenters objectAtIndex:indexPath.row];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [pre firstName], [pre surname]];
	cell.jobTitleLabel.text = [pre jobTitle];
	cell.profileImageView.image = [pre profileImage];
    if (cell.profileImageView.image == nil) {
        [[cell activityView] setHidden:NO];
        [[cell activityView] startAnimating];
    } else {
        [[cell activityView] stopAnimating];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Presenter* selectedPresenter = [self.presenters objectAtIndex:indexPath.row];
    
    self.presenterIdToSend = [selectedPresenter presenterId];
    
    [self performSegueWithIdentifier:@"PresenterToSessionSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PresenterToSessionSegue"])
    {
        EventDetailViewController* edvc = [segue destinationViewController];
        [edvc setId:presenterIdToSend withUrlToLoad:[NSString stringWithFormat:@"%@resteasy/sessions/presenterid/%i", IP_ADDRESS_AMAZON_AWS, presenterIdToSend]];
    }
}

@end
