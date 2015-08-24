//
//  Event.h
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 28/08/2012.
//
//

#import <Foundation/Foundation.h>

@interface Event : NSObject {
    
    long eventId;
    NSString* eventName;
    NSString* eventDescription;
    NSDate* dateFrom;
    NSDate* dateTo;
    
    NSInteger sectionNumber;
    
}

@property (nonatomic) long eventId;
@property (nonatomic, retain) NSString* eventName;
@property (nonatomic, retain) NSString* eventDescription;
@property (nonatomic, retain) NSDate* dateFrom;
@property (nonatomic, retain) NSDate* dateTo;

@property NSInteger sectionNumber;

- (Event *) initWithEventId:(int) Id eventName:(NSString*) name eventDescription:(NSString *) description;

@end
