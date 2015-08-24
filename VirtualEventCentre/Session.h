//
//  Session.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Session : NSObject{

    long sessionId;
    NSString* sessionName;
    NSString* sessionDescription;
    NSDate* dateFrom;
    NSDate* dateTo;
    NSString* imageUrl;
    NSString* videoUrl;
    int eventId;
    
    NSInteger sectionNumber;
}

@property (nonatomic) long sessionId;
@property (nonatomic, retain) NSString* sessionName;
@property (nonatomic, retain) NSString* sessionDescription;
@property (nonatomic, retain) NSDate* dateFrom;
@property (nonatomic, retain) NSDate* dateTo;
@property (nonatomic) int eventId;
@property (nonatomic, retain) NSString* videoUrl;
@property (nonatomic, retain) NSString* imageUrl;

@property NSInteger sectionNumber;

- (Session *) initWithSessionId:(int) Id sessionName:(NSString*) name sessionDescription:(NSString *) description dateFrom:(NSDate *) fromDate dateTo:(NSDate *) toDate eventId:(int) eventID image:(NSString*) sessionImage videoUrl:(NSString *) sessionVideo;

@end
