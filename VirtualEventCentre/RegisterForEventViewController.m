//
//  RegisterForEventViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 01/02/2013.
//
//

#import "ConnectionToServer.h"
#import "RegisterForEventViewController.h"

@interface RegisterForEventViewController ()

@end

@implementation RegisterForEventViewController

@synthesize event, eventToSend, tempEventsArray, events, finalEvents, registerTable, eventIdToSend, registerButton, reloadButton;

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
    
    //Change colour of nav bar
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    [self populateRegisterTable];
}

- (void) viewDidAppear:(BOOL)animated
{
//    [self populateRegisterTable];
}

- (IBAction)reload:(id)sender
{
    [self populateRegisterTable];
}

- (void)populateRegisterTable
{
    int userId = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userId];
    
    //[busyIndicator setHidden:NO];
    //[busyIndicator startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        
        NSMutableArray * json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events/register/%i", IP_ADDRESS_AMAZON_AWS, userId]]];
        
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
            [registerTable reloadData];
            //[busyIndicator stopAnimating];
        });
    });
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
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *itemsInSection = [self.events objectAtIndex:indexPath.section];
    Event *thisEvent = [itemsInSection objectAtIndex:indexPath.row];
    
    self.eventIdToSend = thisEvent.eventId;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    Event *eventObj = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = eventObj.eventName;
    cell.detailTextLabel.text = eventObj.eventDescription;
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) registerForEvent:(id)sender
{
    int userId = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userId];
    
    NSHTTPURLResponse * urlResponse = [ConnectionToServer makePOSTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events/register/%i/%i", IP_ADDRESS_AMAZON_AWS, userId, self.eventIdToSend]]];
    
    if ([urlResponse statusCode] == 202) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Registered" message:@"You have successfully registered for this event" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    [self populateRegisterTable];
}

@end
