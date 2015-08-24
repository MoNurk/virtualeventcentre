//
//  Event.m
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 28/08/2012.
//
//

#import "Event.h"

@implementation Event

@synthesize eventId, eventName, eventDescription, dateFrom, dateTo, sectionNumber;

-(Event *) initWithEventId:(int)Id eventName:(NSString *)name eventDescription:(NSString *)description
{
    self.eventId = Id;
    self.eventName = name;
    self.eventDescription = description;
    
    return self;
}

@end
