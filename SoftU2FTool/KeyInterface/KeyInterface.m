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
//  KeyInterface.m
//  tidas_objc_prototype
//

#import "KeyInterface.h"
#import <CommonCrypto/CommonCrypto.h>

#define newCFDict CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)

@implementation KeyInterface

+ (bool)publicKeyExists:(NSString*)keyName
{
    CFTypeRef publicKeyResult = nil;
    CFMutableDictionaryRef publicKeyExistsQuery = newCFDict;
    CFDictionarySetValue(publicKeyExistsQuery, kSecClass,               kSecClassKey);
    CFDictionarySetValue(publicKeyExistsQuery, kSecAttrKeyType,         kSecAttrKeyTypeEC);
    CFDictionarySetValue(publicKeyExistsQuery, kSecAttrApplicationTag,  (__bridge const void *)(keyName));
    CFDictionarySetValue(publicKeyExistsQuery, kSecAttrKeyClass,        kSecAttrKeyClassPublic);
    CFDictionarySetValue(publicKeyExistsQuery, kSecReturnData,          kCFBooleanTrue);

    OSStatus status = SecItemCopyMatching(publicKeyExistsQuery, (CFTypeRef *)&publicKeyResult);

    if (status == errSecItemNotFound) {
        return false;
    }
    else if (status == errSecSuccess) {
        return true;
    }
    else {
        [NSException raise:@"Unexpected OSStatus" format:@"Status: %i", (int)status];
        return nil;
    }
}

+ (SecKeyRef) lookupPublicKeyRef:(NSString*)keyName
{
    CFMutableDictionaryRef getPublicKeyQuery = newCFDict;
    CFDictionarySetValue(getPublicKeyQuery, kSecClass,                kSecClassKey);
    CFDictionarySetValue(getPublicKeyQuery, kSecAttrKeyType,          kSecAttrKeyTypeEC);
    CFDictionarySetValue(getPublicKeyQuery, kSecAttrApplicationTag,   (__bridge const void *)(keyName));
    CFDictionarySetValue(getPublicKeyQuery, kSecAttrKeyClass,         kSecAttrKeyClassPublic);
    CFDictionarySetValue(getPublicKeyQuery, kSecReturnData,           kCFBooleanTrue);
    CFDictionarySetValue(getPublicKeyQuery, kSecReturnPersistentRef,  kCFBooleanTrue);

    static SecKeyRef publicKeyRef;

    OSStatus status = SecItemCopyMatching(getPublicKeyQuery, (CFTypeRef *)&publicKeyRef);
    if (status == errSecSuccess)
        return (SecKeyRef)publicKeyRef;
    else if (status == errSecItemNotFound)
        return nil;
    else
        [NSException raise:@"Unexpected OSStatus" format:@"Status: %i", (int)status];
    return false;
}

+ (NSData *) publicKeyBits:(NSString*)keyName
{
    if (![self publicKeyExists:keyName])
        return nil;
    return (NSData *) CFDictionaryGetValue((CFDictionaryRef)[self lookupPublicKeyRef:keyName], kSecValueData);

}

+ (SecKeyRef) lookupPrivateKeyRef:(NSString*)keyName
{
    CFMutableDictionaryRef getPrivateKeyRef = newCFDict;
    CFDictionarySetValue(getPrivateKeyRef, kSecClass, kSecClassKey);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrLabel, (__bridge const void *)(keyName));
    CFDictionarySetValue(getPrivateKeyRef, kSecReturnRef, kCFBooleanTrue);
    CFDictionarySetValue(getPrivateKeyRef, kSecUseOperationPrompt, @"Authenticate to sign data");

    static SecKeyRef privateKeyRef;

    OSStatus status = SecItemCopyMatching(getPrivateKeyRef, (CFTypeRef *)&privateKeyRef);
    if (status == errSecItemNotFound)
        return nil;

    return (SecKeyRef)privateKeyRef;
}

+ (bool)generateKeyPair:(NSString*)keyName
{
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(
                                                                    kCFAllocatorDefault,
                                                                    kSecAttrAccessibleWhenUnlocked,
                                                                    kSecAccessControlPrivateKeyUsage, // maybe kSecAccessControlUserPresence too?
                                                                    &error
                                                                    );

    if (error != errSecSuccess) {
        NSLog(@"Generate key error: %@\n", error);
    }

    return [self generateKeyPairWithAccessControlObject:sacObject withKeyName:keyName];
}

+ (bool) generateKeyPairWithAccessControlObject:(SecAccessControlRef)accessControlRef withKeyName:(NSString*)keyName
{
    // create dict of private key info
    CFMutableDictionaryRef accessControlDict = newCFDict;;
    CFDictionaryAddValue(accessControlDict, kSecAttrAccessControl, accessControlRef);
    CFDictionaryAddValue(accessControlDict, kSecAttrIsPermanent, kCFBooleanTrue);
    CFDictionaryAddValue(accessControlDict, kSecAttrLabel, (__bridge const void *)keyName);

    // create dict which actually saves key into keychain
    CFMutableDictionaryRef generatePairRef = newCFDict;
    //CFDictionaryAddValue(generatePairRef, kSecAttrTokenID, kSecAttrTokenIDSecureEnclave);
    CFDictionaryAddValue(generatePairRef, kSecAttrKeyType, kSecAttrKeyTypeEC);
    CFDictionaryAddValue(generatePairRef, kSecAttrKeySizeInBits, (__bridge const void *)([NSNumber numberWithInt:256]));
    CFDictionaryAddValue(generatePairRef, kSecPrivateKeyAttrs, accessControlDict);

    static SecKeyRef publicKeyRef;
    static SecKeyRef privateKeyRef;

    OSStatus status = SecKeyGeneratePair(generatePairRef, &publicKeyRef, &privateKeyRef);

    if (status != errSecSuccess) {
        NSLog(@"Error calling SecKeyGeneratePair: %d\n", (int)status);
        return NO;
    }

    [self savePublicKeyFromRef:publicKeyRef withName:keyName];
    return YES;
}

+ (bool) savePublicKeyFromRef:(SecKeyRef)publicKeyRef withName:(NSString*)keyName
{
    CFTypeRef keyBits;
    CFMutableDictionaryRef savePublicKeyDict = newCFDict;
    CFDictionaryAddValue(savePublicKeyDict, kSecClass,        kSecClassKey);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyType,  kSecAttrKeyTypeEC);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyClass, kSecAttrKeyClassPublic);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrApplicationTag, (__bridge const void *)(keyName));
    CFDictionaryAddValue(savePublicKeyDict, kSecValueRef, publicKeyRef);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrIsPermanent, kCFBooleanTrue);
    CFDictionaryAddValue(savePublicKeyDict, kSecReturnData, kCFBooleanTrue);

    OSStatus err = SecItemAdd(savePublicKeyDict, &keyBits);
    while (err == errSecDuplicateItem)
    {
        err = SecItemDelete(savePublicKeyDict);
    }
    err = SecItemAdd(savePublicKeyDict, &keyBits);

    return YES;
}

+(bool) deletePubKey:(NSString*)keyName {
    CFMutableDictionaryRef savePublicKeyDict = newCFDict;
    CFDictionaryAddValue(savePublicKeyDict, kSecClass,        kSecClassKey);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyType,  kSecAttrKeyTypeEC);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyClass, kSecAttrKeyClassPublic);
    CFDictionaryAddValue(savePublicKeyDict, kSecAttrApplicationTag, (__bridge const void *)(keyName));

    OSStatus err = SecItemDelete(savePublicKeyDict);
    while (err == errSecDuplicateItem)
    {
        err = SecItemDelete(savePublicKeyDict);
    }
    return true;
}

+(bool) deletePrivateKey:(NSString*)keyName {
    CFMutableDictionaryRef getPrivateKeyRef = newCFDict;
    CFDictionarySetValue(getPrivateKeyRef, kSecClass, kSecClassKey);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrLabel, (__bridge const void *)keyName);
    CFDictionarySetValue(getPrivateKeyRef, kSecReturnRef, kCFBooleanTrue);

    OSStatus err = SecItemDelete(getPrivateKeyRef);
    while (err == errSecDuplicateItem)
    {
        err = SecItemDelete(getPrivateKeyRef);
    }
    return true;
}

+ (void) generateSignatureForData:(NSData *)inputData withKeyName:(NSString*)keyName withCompletion:(void(^)(NSData*, NSError*))completion {
    SecKeyRef key = [self lookupPrivateKeyRef:keyName];

    uint8_t signature[256] = { 0 };
    size_t signatureLength = sizeof(signature);


    size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA256([inputData bytes], (CC_LONG)[inputData length], hashBytes)) {
        free(hashBytes);
        NSError *error = [NSError errorWithDomain:@"SecKeyError" code:1 userInfo:nil];
        completion(nil, error);
        return;
    }
    
    OSStatus status = SecKeyRawSign(key, kSecPaddingPKCS1, hashBytes, hashBytesSize, signature, &signatureLength);
    free(hashBytes);
    
    if (status == errSecSuccess) {
        NSData* signedHash = [NSData dataWithBytes:signature length:signatureLength];
        
        completion(signedHash, nil);
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"SecKeyError" code:status userInfo:nil];
        completion(nil, error);
    }
}

@end
