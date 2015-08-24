//
//  TitleDetail.m
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleDetail.h"

@implementation TitleDetail

@synthesize title, detailText;

- (TitleDetail*) initWithTitle:(NSString *)cellTitle detailText:(NSString *)cellDetail 
{
    self.title = cellTitle;
    self.detailText = cellDetail;
    
    return self;
}

@end
