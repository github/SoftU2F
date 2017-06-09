//
//  SelfSignedCertificate.m
//  SecurityKey
//
//  Created by Benjamin P Toews on 8/19/16.
//  Copyright © 2017 GitHub, inc. All rights reserved.
//

// http://opensource.apple.com/source/OpenSSL/OpenSSL-22/openssl/demos/x509/mkcert.c

#import "private.h"
#import "public.h"

const unsigned char *priv = (unsigned char*)
  "\x30\x77\x02\x01\x01\x04\x20\x03\x84\x2a\xc7\xf4\xcd\xe3\x67\xde"
  "\xa0\x56\xc6\x4f\x7f\x3b\x15\xea\x7d\x4b\xc4\x83\xca\xc6\x97\x9f"
  "\x2a\x31\x93\xad\x57\x31\x09\xa0\x0a\x06\x08\x2a\x86\x48\xce\x3d"
  "\x03\x01\x07\xa1\x44\x03\x42\x00\x04\xf6\x9c\xab\x24\x14\x4b\xb4"
  "\xef\x87\xf7\x0f\x23\x1c\x5c\xd4\xf5\x78\x04\xac\xf8\xe0\xc6\xb2"
  "\xb3\xe3\x52\x18\x3d\x80\x39\x1f\x6b\xd2\x79\xd2\x6a\x4c\x83\x64"
  "\x74\xe6\xc2\xda\x23\x93\xff\xac\x1d\x50\x34\x6c\x5c\x23\x90\x65"
  "\x57\x93\x3e\xcb\x93\xff\x6e\xde\xd1";

const unsigned char *cert = (unsigned char*)
  "\x30\x82\x01\x15\x30\x81\xbd\xa0\x03\x02\x01\x02\x02\x01\x01\x30"
  "\x0a\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x02\x30\x15\x31\x13\x30"
  "\x11\x06\x03\x55\x04\x03\x0c\x0a\x6d\x61\x73\x74\x61\x68\x79\x65"
  "\x74\x69\x30\x1e\x17\x0d\x31\x37\x30\x36\x30\x39\x31\x34\x30\x38"
  "\x31\x37\x5a\x17\x0d\x31\x37\x30\x36\x31\x30\x31\x34\x30\x38\x31"
  "\x37\x5a\x30\x15\x31\x13\x30\x11\x06\x03\x55\x04\x03\x0c\x0a\x6d"
  "\x61\x73\x74\x61\x68\x79\x65\x74\x69\x30\x59\x30\x13\x06\x07\x2a"
  "\x86\x48\xce\x3d\x02\x01\x06\x08\x2a\x86\x48\xce\x3d\x03\x01\x07"
  "\x03\x42\x00\x04\xf6\x9c\xab\x24\x14\x4b\xb4\xef\x87\xf7\x0f\x23"
  "\x1c\x5c\xd4\xf5\x78\x04\xac\xf8\xe0\xc6\xb2\xb3\xe3\x52\x18\x3d"
  "\x80\x39\x1f\x6b\xd2\x79\xd2\x6a\x4c\x83\x64\x74\xe6\xc2\xda\x23"
  "\x93\xff\xac\x1d\x50\x34\x6c\x5c\x23\x90\x65\x57\x93\x3e\xcb\x93"
  "\xff\x6e\xde\xd1\x30\x0a\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x02"
  "\x03\x47\x00\x30\x44\x02\x20\x7c\xa5\x9b\x1e\x3a\x0e\xc4\xe1\xff"
  "\x67\x76\xd3\xde\x93\xbc\x11\x02\xef\xbb\x1b\x18\x52\x32\x03\x07"
  "\xf0\xea\xb1\xfa\x36\x70\x33\x02\x20\x3f\x92\xec\x0c\xbe\xc6\xd5"
  "\xe8\x57\x92\x43\xe4\x3e\x4a\xdd\xd4\xd0\x8c\x7b\x6c\x02\x6c\xfd"
  "\x1e\x8f\x84\x34\x2f\xdf\x81\xe1\x36";

const int priv_len = 121;
const int cert_len = 281;

@implementation SelfSignedCertificate {
    EVP_PKEY *pkey;
    X509 *x509;
}

- (id)init {
  self = [super init];
  if (self) {
    if ([self generateKeyPair] && [self generateX509]) {
      printf("SelfSignedCertificate initialized\n");
    } else {
      printf("Error initializing SelfSignedCertificate\n");
    }
  }
  return self;
}

- (int)generateX509 {
  self->x509 = d2i_X509(NULL, &cert, cert_len);
  if (self->x509 == NULL) {
    printf("failed to parse cert\n");
    return 0;
  }

  return 1;
}

- (int)generateKeyPair {
  EC_KEY *ec = d2i_ECPrivateKey(NULL, &priv, priv_len);
  if (ec == NULL) {
    printf("error importing private key\n");
    return 0;
  }

  if (EC_KEY_check_key(ec) != 1) {
    printf("error checking key\n");
    EC_KEY_free(ec);
    return 0;
  }

  self->pkey = EVP_PKEY_new();
  if (self->pkey == NULL) {
    printf("failed to init pkey\n");
    EC_KEY_free(ec);
    return 0;
  }
  
  if (EVP_PKEY_assign_EC_KEY(self->pkey, ec) != 1) {
    printf("failed to assing ec to pkey\n");
    EC_KEY_free(ec);
    EVP_PKEY_free(self->pkey);
    self->pkey = NULL;
    return 0;
  }

  return 1;
}

- (NSData *)toDer {
  unsigned char *buf = NULL;
  unsigned int len = i2d_X509(self->x509, &buf);
  return [[NSData alloc] initWithBytes:buf length:len];
}

- (NSData *)signData:(NSData *)msg {
  EVP_MD_CTX ctx;
  const unsigned char *cmsg = (const unsigned char *)[msg bytes];
  unsigned char *sig = (unsigned char *)malloc(EVP_PKEY_size(self->pkey));
  unsigned int len;

  if (EVP_SignInit(&ctx, EVP_sha256()) != 1) {
    free(sig);
    printf("failed to init signing context\n");
    return nil;
  };

  if (EVP_SignUpdate(&ctx, cmsg, (unsigned int)[msg length]) != 1) {
    free(sig);
    printf("failed to update digest\n");
    return nil;
  }

  if (EVP_SignFinal(&ctx, sig, &len, self->pkey) != 1) {
    free(sig);
    printf("failed to finalize digest\n");
    return nil;
  }

  return [[NSData alloc] initWithBytes:sig length:len];
}

- (void)dealloc {
  if (self->x509 != NULL) {
    X509_free(self->x509);
    self->x509 = NULL;
  }

  if (self->pkey != NULL) {
    EVP_PKEY_free(self->pkey);
    self->pkey = NULL;
  }
}

+ (bool)parseX509:(NSData *)data consumed:(NSInteger *)consumed;
{
  X509 *crt = NULL;
  const unsigned char *crtStart, *crtEnd;
  crtStart = crtEnd = [data bytes];

  d2i_X509(&crt, &crtEnd, [data length]);

  if (crt == NULL) {
    return false;
  } else {
    X509_free(crt);
    *consumed = crtEnd - crtStart;
    return true;
  }
}

@end
