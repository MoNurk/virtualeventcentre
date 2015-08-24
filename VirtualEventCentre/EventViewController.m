//
//  EventViewController.m
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 28/08/2012.
//
//

#import "EventViewController.h"
#import "LoginViewController.h"
#import "ConnectionToServer.h"

@interface EventViewController ()

@end

@implementation EventViewController

@synthesize event, eventToSend, eventTable, events, tempEventsArray, busyIndicator, eventIdToSend, loginShown, refreshControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if([[[viewController tabBarItem] title] isEqualToString:@"Admin"] && appDelegate.isAdmin == NO){
        UIAlertView * adminAlert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"This feature is only available to Event admins" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [adminAlert show];
        
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.delegate = self; 
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
    NSString *myPath = [self saveFilePath];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
		NSArray *values = [[NSArray alloc] initWithContentsOfFile:myPath];
        if (![[values objectAtIndex:0] isEqualToString:@""])
        {
            appDelegate.base64UserPass = [values objectAtIndex:0];
            appDelegate.isAdmin = [[values objectAtIndex:1] boolValue];
            appDelegate.userId = [[values objectAtIndex:2] integerValue];
            appDelegate.isLoggedIn = YES;
        }
	}
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    UIRefreshControl *refreshController = [[UIRefreshControl alloc] init];
    refreshController.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshController addTarget:self action:@selector(populateEventsTable) forControlEvents:UIControlEventValueChanged];
    [self.eventTable addSubview:refreshController];
    
    self.refreshControl = refreshController;
    
    [self populateEventsTable];
}

- (void) viewDidAppear:(BOOL)animated
{   
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isLoggedIn] == NO)
    {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isLoggedIn = YES;
    }
}

- (NSString *) saveFilePath
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [[path objectAtIndex:0] stringByAppendingPathComponent:@"savefile.plist"];
}

- (IBAction)logOut:(id)sender
{
    NSArray *values = [[NSArray alloc] initWithObjects:@"",nil];
    [values writeToFile:[self saveFilePath] atomically:YES];
    
    for (UINavigationController *navController in self.tabBarController.viewControllers) {
        [navController popToRootViewControllerAnimated:NO];
    }
    
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
}

- (IBAction)refreshTable:(id)sender
{
    [self populateEventsTable];
}

- (void)populateEventsTable
{
    int userId = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userId];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        
        NSMutableArray * json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events/%i", IP_ADDRESS_AMAZON_AWS, userId]]];
        
            for (NSDictionary* item in json) {
                int eventId = [[[item objectForKey:@"event"] objectForKey:@"eventId"] integerValue];
                NSString* eventName = (NSString *)[[item objectForKey:@"event"] objectForKey:@"eventName"];
                NSString* eventDescription = (NSString *)[[item objectForKey:@"event"] objectForKey:@"eventDescription"];
                
                event = [[Event alloc] initWithEventId:eventId eventName:eventName eventDescription:eventDescription];
                [tempArray addObject:event];
            }
        //}
        
        UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
        self.events = [NSMutableArray arrayWithCapacity:1];
        
        if (tempArray) {
            tempEventsArray = tempArray;
        } else  {
            return;
        }
        
        // (1)
        for (Event *theEvent in tempEventsArray) {
            NSInteger sect = [theCollation sectionForObject:theEvent collationStringSelector:@selector(eventName)];
            theEvent.sectionNumber = sect;
        }
        // (2)
        NSInteger highSection = [[theCollation sectionTitles] count];
        NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
        for (int i=0; i<=highSection; i++) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
            [sectionArrays addObject:sectionArray];
        }
        // (3)
        for (Event *theObject in tempEventsArray) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:theObject.sectionNumber] addObject:theObject];
        }
        // (4)
        for (NSMutableArray *sectionArray in sectionArrays) {
            NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                                collationStringSelector:@selector(eventName)];
            [self.events addObject:sortedSection];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [eventTable reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) myModalViewControllerDidFinishLogin:(LoginViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    [self populateEventsTable];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EventDetail"])
    {
        EventDetailViewController* edvc = [segue destinationViewController];
        [edvc setId:eventIdToSend withUrlToLoad:[NSString stringWithFormat:@"%@resteasy/sessions/eventid/%i", IP_ADDRESS_AMAZON_AWS, eventIdToSend]];
    }
    else if ([[segue identifier] isEqualToString:@"LoginSegue"])
    {
        LoginViewController * loginVC = [segue destinationViewController];
        loginVC.delegate = self;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.events objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.events objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *itemsInSection = [self.events objectAtIndex:indexPath.section];
    Event *thisEvent = [itemsInSection objectAtIndex:indexPath.row];
    
    self.eventIdToSend = thisEvent.eventId;
    
    [self performSegueWithIdentifier:@"EventDetail" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    Event *eventObj = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = eventObj.eventName;
    cell.detailTextLabel.text = eventObj.eventDescription;
    
    return cell;
}

@end
