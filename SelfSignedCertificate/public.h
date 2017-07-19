//
//  public.h
//  SelfSignedCertificate
//
//  Created by Benjamin P Toews on 8/19/16.
//

#ifndef public_h
#define public_h

#import <Foundation/Foundation.h>

@interface SelfSignedCertificate : NSObject

+ (NSData *)toDer;
+ (NSData *)signData:(NSData *)msg;
+ (bool)parseX509:(NSData *)data consumed:(NSInteger *)consumed;

@end

#endif /* public_h */
