//
//  SKProduct+priceAsString.h
//  HyperConnect
//
//  Created by Zois Avgerinos on 6/26/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (priceAsString)
@property (nonatomic, readonly) NSString *priceAsString;
@end



