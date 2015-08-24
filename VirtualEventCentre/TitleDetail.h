//
//  TitleDetail.h
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TitleDetail : NSObject {
    
    NSString * title;
    NSString * detailText;
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* detailText;

- (TitleDetail *) initWithTitle:(NSString*) cellTitle detailText:(NSString*) cellDetail; 

@end
