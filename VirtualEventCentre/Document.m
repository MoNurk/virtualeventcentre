//
//  Document.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 11/09/2012.
//
//

#import "Document.h"

@implementation Document

@synthesize documentId, documentName, documentUrl;

- (Document *) initWithDocumentId:(int)Id documentName:(NSString *)name documentUrl:(NSString *)url
{
    self.documentId = Id;
    self.documentName = name;
    self.documentUrl = url;
    
    return self; 
}

@end
