//
//  EventDetailViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/09/2012.
//
//

#import "EventDetailViewController.h"
#import "SessionDetailViewController.h"
#import "ConnectionToServer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController

@synthesize sessions, tempSessionsArray, thisEventId, finalSessions, myTableView, myTableViewCell, sessionToSend, busyIndicator, url;

- (void) setId:(int)Id withUrlToLoad:(NSString *)urlToLoad
{
    self.thisEventId = Id;
    self.url = urlToLoad; 
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
    [self populateSessions];
}

- (void) populateSessions
{
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        
        NSMutableArray* json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:url]];
        
        for (NSDictionary* item in json) {
            int sessionId = [[[item objectForKey:@"session"] objectForKey:@"sessionId"] integerValue];
            NSString* sessionName = (NSString *)[[item objectForKey:@"session"] objectForKey:@"sessionName"];
            NSString* sessionDescription = (NSString *)[[item objectForKey:@"session"] objectForKey:@"sessionDescription"];
            NSString* sessionDateFrom = (NSString *)[[item objectForKey:@"session"] objectForKey:@"dateFrom"];
            NSString* sessionDateTo = (NSString *)[[item objectForKey:@"session"] objectForKey:@"dateTo"];
            int eventId = [[[[item objectForKey:@"session"] objectForKey:@"event"] objectForKey:@"eventId"] integerValue];
            NSString* videoUrl = (NSString *)[[item objectForKey:@"session"] objectForKey:@"videoUrl"];
            NSString* imageUrl = (NSString *)[[item objectForKey:@"session"] objectForKey:@"image"];
            
            Session* session = [[Session alloc] initWithSessionId:sessionId sessionName:sessionName sessionDescription:sessionDescription dateFrom:[self fixDateAndTime:sessionDateFrom] dateTo:[self fixDateAndTime:sessionDateTo] eventId:eventId image:imageUrl videoUrl:videoUrl];
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
            [activityIndicator stopAnimating];
        });
    });
}

- (NSDate *) fixDateAndTime:(NSString *) wrongDT
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* fixedDateString = [wrongDT stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSRange range = [fixedDateString rangeOfString:@"+"];
    NSRange range2 = [fixedDateString rangeOfString:@"Z"];
    if(range.location != NSNotFound)
    {
        fixedDateString = [fixedDateString substringToIndex:range.location];
    }
    else if (range2.location != NSNotFound)
    {
        fixedDateString = [fixedDateString substringToIndex:range2.location];
    }
    
    return [df dateFromString:fixedDateString];
}

- (NSString*) checkIfStringIsNil:(NSString*)stringToCheck
{
    NSString* stringToReturn;
    if (stringToCheck == nil) {
        stringToReturn = @"No information";
    }
    else {
        stringToReturn = stringToCheck;
    }
    return stringToReturn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SessionDetailSegue"])
    {
        SessionDetailViewController* sdvc = [segue destinationViewController];
        [sdvc setMySession:sessionToSend];
    }
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *itemsInSection = [self.sessions objectAtIndex:indexPath.section];
    Session *selectedSession = [itemsInSection objectAtIndex:indexPath.row];
    
    sessionToSend = selectedSession;
    
    [self performSegueWithIdentifier:@"SessionDetailSegue" sender:self];
}

@end
