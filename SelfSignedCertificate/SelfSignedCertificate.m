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
  self->x509 = X509_new();
  if (self->x509 == NULL) {
    printf("failed to init x509\n");
    return 0;
  }

  X509_set_version(self->x509, 2);
  ASN1_INTEGER_set(X509_get_serialNumber(self->x509), 1);
  X509_gmtime_adj(X509_get_notBefore(self->x509), 0);
  X509_gmtime_adj(X509_get_notAfter(self->x509), (long)60 * 60 * 24 * 1);

  X509_NAME *name = X509_get_subject_name(self->x509);
  X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (const unsigned char *)"mastahyeti", -1, -1, 0);

  X509_set_issuer_name(self->x509, name);

  if (!X509_set_pubkey(self->x509, self->pkey)) {
    printf("failed to set public key.\n");
    return 0;
  }

  if (!X509_sign(self->x509, self->pkey, EVP_sha256())) {
    printf("failed to sign cert\n");
    return 0;
  }
  
  unsigned char *buf = NULL;
  unsigned int len = i2d_X509(self->x509, &buf);
  printf("Cert: ");
  for (int i = 0; i < len; i++) {
    printf("%02x", buf[i]);
  }
  printf("\n");

  return 1;
}

- (int)generateKeyPair {
  self->pkey = EVP_PKEY_new();
  if (self->pkey == NULL) {
    printf("failed to init pkey\n");
    return 0;
  }

  EC_KEY *ec = EC_KEY_new();
  if (ec == NULL) {
    printf("EC_KEY_new failed\n");
    return 0;
  }

  EC_GROUP *ecg = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1);
  if (ecg == NULL) {
    printf("EC_GROUP_new_by_curve_name failed\n");
    return 0;
  }

  EC_GROUP_set_asn1_flag(ecg, NID_X9_62_prime256v1);
  EC_KEY_set_group(ec, ecg);

  if (EC_KEY_generate_key(ec) != 1) {
    printf("couldn't generate ec key\n");
    return 0;
  }

  if (EC_KEY_check_key(ec) != 1) {
    printf("error checking key\n");
    return 0;
  }

  if (EVP_PKEY_assign_EC_KEY(self->pkey, ec) != 1) {
    printf("failed to assing ec to pkey\n");
    EC_KEY_free(ec);
    return 0;
  }
  
  unsigned char *priv = NULL;
  int len = i2d_ECPrivateKey(ec, &priv);
  if (len < 0) {
    printf("error exporting private key.\n");
    return 0;
  }
  
  printf("priv: ");
  for (int i = 0; i < len; i++) {
    printf("%02x", priv[i]);
  }
  printf("\n");

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
  X509_free(self->x509);
  self->x509 = NULL;
  EVP_PKEY_free(self->pkey);
  self->pkey = NULL;
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
