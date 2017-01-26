//
//  SelfSignedCertificate.h
//  SecurityKey
//
//  Created by Benjamin P Toews on 8/19/16.
//  Copyright © 2017 GitHub, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#undef I // complex.h defines some crazy `I` macro...
#import <openssl/x509.h>
#import <openssl/ec.h>
#import <openssl/ecdsa.h>
#import <openssl/evp.h>
#import <openssl/objects.h>
#import <openssl/asn1.h>
#import <openssl/pem.h>

@interface SelfSignedCertificate : NSObject;
@property EVP_PKEY* pkey;
@property X509* x509;

- (id)init;
- (NSData*)toDer;
- (NSData*)signData:(NSData*)msg;
+ (bool)parseX509:(NSData*)data consumed:(NSInteger *)consumed;

@end
