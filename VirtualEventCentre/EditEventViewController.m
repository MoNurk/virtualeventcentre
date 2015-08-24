//
//  EditEventViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import "EditEventViewController.h"
#import "UploadBannerViewController.h"
#import "ConnectionToServer.h"

@interface EditEventViewController ()

@end

@implementation EditEventViewController

@synthesize event, events, eventTable, eventToSend, finalEvents, tempEventsArray, eventIdToSend;

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
    [self populateEventsTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateEventsTable
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        
        NSMutableArray * json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events", IP_ADDRESS_AMAZON_AWS]]];
        
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
        for (Event *theObject in tempEventsArray) {
            NSInteger sect = [theCollation sectionForObject:theObject collationStringSelector:@selector(eventName)];
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
        });
    });
}

- (void) myModalViewControllerDidFinishAddingEvent:(AddEventViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self populateEventsTable];
}

- (void) myModalViewControllerDidCancel:(AddEventViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)presentAddEventView:(id)sender
{
    [self.navigationController performSegueWithIdentifier:@"AddEventSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddEventSegue"])
    {
        AddEventViewController * addEventVC = [segue destinationViewController];
        addEventVC.delegate = self;
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
            for (int i = 0; i < self.events.count; i++) {
                [copiedArray addObject:[[self.events objectAtIndex:i] mutableCopy]];
            }
            NSArray *itemsInSection = [self.events objectAtIndex:indexPath.section];
            Event *thisEvent = [itemsInSection objectAtIndex:indexPath.row];
            [[copiedArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            self.events = copiedArray;
            
            NSString *urlDeleteString = [NSString stringWithFormat:@"%@resteasy/events/", IP_ADDRESS_AMAZON_AWS];
            long urlDeleteId = [thisEvent eventId];
            NSString *appendedId = [NSString stringWithFormat:@"%@%li", urlDeleteString, urlDeleteId];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appendedId]];
            [request setValue:encoded forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"DELETE"];
            [NSURLConnection connectionWithRequest:request delegate:self];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    Event *eventObj = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = eventObj.eventName;
    cell.detailTextLabel.text = eventObj.eventDescription;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
