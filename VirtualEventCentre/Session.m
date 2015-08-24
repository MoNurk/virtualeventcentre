//
//  Session.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/09/2012.
//
//

#import "Session.h"

@implementation Session

@synthesize sessionId, sessionDescription, sessionName, imageUrl, dateFrom, dateTo, eventId, videoUrl, sectionNumber;

- (Session *) initWithSessionId:(int) Id sessionName:(NSString*) name sessionDescription:(NSString *) description dateFrom:(NSDate *) fromDate dateTo:(NSDate *) toDate eventId:(int) eventID image:(NSString*) sessionImage videoUrl:(NSString *) sessionVideo
{
    self.sessionId = Id;
    self.sessionName = name;
    self.sessionDescription = description;
    self.dateFrom = fromDate;
    self.dateTo = toDate;
    self.imageUrl = sessionImage;
    self.videoUrl = sessionVideo;
    self.eventId = eventID;
    
    return self;
}

@end
