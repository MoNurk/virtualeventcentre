//
//  ConnectionToServer.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 28/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface ConnectionToServer : NSObject {
    
}

+ (NSMutableArray *) makeGETRequestWithURL:(NSURL *) urlRequest;
+ (NSHTTPURLResponse *) makePOSTReqeustWithURL:(NSURL *) urlRequest jsonData:(NSMutableDictionary *) jsonToSend;
+ (NSHTTPURLResponse *) makePOSTReqeustWithURL:(NSURL *)urlRequest;
+ (NSHTTPURLResponse *) makePUTReqeustWithURL:(NSURL *)urlRequest jsonData:(NSMutableDictionary *)jsonToSend;

@end
