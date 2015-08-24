//
//  EditSessionViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import "EditSessionViewController.h"
#import "EditSessionDetailsViewController.h"
#import "UploadBannerViewController.h"
#import "Session.h"
#import "ConnectionToServer.h"
#import "UploadImageVideoViewController.h"

@interface EditSessionViewController ()

@end

@implementation EditSessionViewController

@synthesize myTableView, sessions, tempSessionsArray, finalSessions, sessionIdToSend, selectedSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)presentAddSessionView:(id)sender
{
    [self.navigationController performSegueWithIdentifier:@"AddSessionSegue" sender:sender];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddSessionSegue"])
    {
        AddSessionViewController * addSessionVC = [segue destinationViewController];
        addSessionVC.delegate = self; 
    }
    if ([[segue identifier] isEqualToString:@"AddBannerSegue"])
    {
        UploadBannerViewController * uploadBanner = [segue destinationViewController];
        [uploadBanner uploadBannerToEventId:[NSString stringWithFormat:@"%i", sessionIdToSend]];
    }
    else if ([[segue identifier] isEqualToString:@"EditSessionDetails"])
    {
        EditSessionDetailsViewController * editSession = [segue destinationViewController];
        [editSession setSession:selectedSession];
    }
    else if ([[segue identifier] isEqualToString:@"UploadImageSegue"])
    {
        UploadImageVideoViewController * uploadImageVideo = [segue destinationViewController];
        [uploadImageVideo setSessionId:[selectedSession sessionId]];
    }

}

- (void) populateSessions
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        
        NSMutableArray* json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/sessions", IP_ADDRESS_AMAZON_AWS]]];
        
        for (NSDictionary* item in json) {
            int sessionId = [[[item objectForKey:@"session"] objectForKey:@"sessionId"] integerValue];
            NSString* sessionName = (NSString *)[[item objectForKey:@"session"] objectForKey:@"sessionName"];
            NSString* sessionDescription = (NSString *)[[item objectForKey:@"session"] objectForKey:@"sessionDescription"];
            NSString* sessionDateFrom = (NSString *)[[item objectForKey:@"session"] objectForKey:@"dateFrom"];
            NSString* sessionDateTo = (NSString *)[[item objectForKey:@"session"] objectForKey:@"dateTo"];
            int eventId = [[[[item objectForKey:@"session"] objectForKey:@"event"] objectForKey:@"eventId"] integerValue];
            NSString* videoUrl = (NSString *)[[item objectForKey:@"session"] objectForKey:@"videoUrl"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString* fixedDateFromString = [sessionDateFrom stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            NSRange dateFromRange = [fixedDateFromString rangeOfString:@"+"];
            if(dateFromRange.location != NSNotFound)
            {
                fixedDateFromString = [fixedDateFromString substringToIndex:dateFromRange.location];
            }
            NSDate* dateFrom = [df dateFromString:fixedDateFromString];
            
            NSString* fixedDateToString = [sessionDateTo stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            NSRange dateToRange = [fixedDateToString rangeOfString:@"+"];
            if(dateToRange.location != NSNotFound)
            {
                fixedDateToString = [fixedDateToString substringToIndex:dateToRange.location];
            }
            NSDate* dateTo = [df dateFromString:fixedDateToString];
            
            Session* session = [[Session alloc] initWithSessionId:sessionId sessionName:sessionName sessionDescription:sessionDescription dateFrom:dateFrom dateTo:dateTo eventId:eventId image:nil videoUrl:videoUrl];
            [tempArray addObject:session];
        }
        
        UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
        self.sessions = [NSMutableArray arrayWithCapacity:1];
        
        if (tempArray) {
            tempSessionsArray = tempArray;
        } else  {
            return;
        }
        
        // (1)
        for (Session *theObject in tempSessionsArray) {
            NSInteger sect = [theCollation sectionForObject:theObject collationStringSelector:@selector(sessionName)];
            theObject.sectionNumber = sect;
        }
        // (2)
        NSInteger highSection = [[theCollation sectionTitles] count];
        NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
        for (int i=0; i<=highSection; i++) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
            [sectionArrays addObject:sectionArray];
        }
        // (3)
        for (Session *theObject in tempSessionsArray) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:theObject.sectionNumber] addObject:theObject];
        }
        // (4)
        for (NSMutableArray *sectionArray in sectionArrays) {
            NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                                collationStringSelector:@selector(sessionName)];
            [self.sessions addObject:sortedSection];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [myTableView reloadData];
        });
    });
}

- (void) myModalViewControllerDidFinishAddingSession:(AddSessionViewController *)controller
{
    NSLog(@"Should dismiss");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self populateSessions];
}

- (void) myModalViewControllerDidCancel:(AddSessionViewController *)controller
{
    NSLog(@"Should dismiss");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self populateSessions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sessions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sessions objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.sessions objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailCell"];
    Session *session = [[self.sessions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [session sessionName];
    cell.detailTextLabel.text = [session sessionDescription];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Session *session = [[self.sessions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    selectedSession = session;
    self.sessionIdToSend = [session sessionId];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upload Banner", @"Edit Details", @"Attach Image/Video", nil];
    
    [actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    
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
            NSMutableArray *copiedArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.sessions.count; i++) {
                [copiedArray addObject:[[self.sessions objectAtIndex:i] mutableCopy]];
            }
            NSArray *itemsInSection = [self.sessions objectAtIndex:indexPath.section];
            Session *thisSession = [itemsInSection objectAtIndex:indexPath.row];
            [[copiedArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            self.sessions = copiedArray;
            
            NSString *urlDeleteString = [NSString stringWithFormat:@"%@resteasy/sessions/", IP_ADDRESS_AMAZON_AWS];
            long urlDeleteId = [thisSession sessionId];
            NSString *appendedId = [NSString stringWithFormat:@"%@%li", urlDeleteString, urlDeleteId];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appendedId]];
            [request setValue:encoded forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"DELETE"];
            [NSURLConnection connectionWithRequest:request delegate:self];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        NSLog(@"Should be upload");
        [self performSegueWithIdentifier:@"AddBannerSegue" sender:self];
    }
    else if(buttonIndex == 1) {
        NSLog(@"Should be edit");
        [self performSegueWithIdentifier:@"EditSessionDetails" sender:self];
    }
    else if (buttonIndex == 2) {
        NSLog(@"Should be image");
        [self performSegueWithIdentifier:@"UploadImageSegue" sender:self];
    }
}


@end
