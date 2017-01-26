/* Copyright (c) 2016 Trail of Bits, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  KeyInterface.h
//  sep-example
//

#import <Foundation/Foundation.h>

#define kPrivateKeyName @"com.trailofbits.tidas.private"

@interface KeyInterface : NSObject

+ (bool) generateKeyPair:(NSString*)keyName;
+ (bool) publicKeyExists:(NSString*)keyName;
+ (bool) deletePubKey:(NSString*)keyName;
+ (bool) deletePrivateKey:(NSString*)keyName;
+ (SecKeyRef) lookupPublicKeyRef:(NSString*)keyName;;
+ (NSData *) publicKeyBits:(NSString*)keyName;;
+ (SecKeyRef) lookupPrivateKeyRef:(NSString*)keyName;

+ (void)generateSignatureForData:(NSData *)inputData withKeyName:(NSString*)keyName withCompletion:(void(^)(NSData*, NSError*))completion;

@end
