//
//  Document.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 11/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Document : NSObject {
    
    int documentId;
    NSString* documentName;
    NSString* documentUrl;
}

@property int documentId;
@property (nonatomic, retain) NSString* documentName;
@property (nonatomic, retain) NSString* documentUrl;

- (Document *) initWithDocumentId:(int) Id documentName:(NSString*) name documentUrl:(NSString*) url; 

@end
