//
//  SelfSignedCertificate.m
//  SecurityKey
//
//  Created by Benjamin P Toews on 8/19/16.
//

#import "private.h"
#import "public.h"

// Yes, this is the private key from our cert. Yes, this sucks.
// But, U2F requires that the cert/key be shared between "devices"
// to prevent user-tracking. Fortunately, "theft" of this key doesn't
// get you anything...
const unsigned char *priv = (unsigned char*)
  "\x30\x77\x02\x01\x01\x04\x20\x03\x84\x2a\xc7\xf4\xcd\xe3\x67\xde"
  "\xa0\x56\xc6\x4f\x7f\x3b\x15\xea\x7d\x4b\xc4\x83\xca\xc6\x97\x9f"
  "\x2a\x31\x93\xad\x57\x31\x09\xa0\x0a\x06\x08\x2a\x86\x48\xce\x3d"
  "\x03\x01\x07\xa1\x44\x03\x42\x00\x04\xf6\x9c\xab\x24\x14\x4b\xb4"
  "\xef\x87\xf7\x0f\x23\x1c\x5c\xd4\xf5\x78\x04\xac\xf8\xe0\xc6\xb2"
  "\xb3\xe3\x52\x18\x3d\x80\x39\x1f\x6b\xd2\x79\xd2\x6a\x4c\x83\x64"
  "\x74\xe6\xc2\xda\x23\x93\xff\xac\x1d\x50\x34\x6c\x5c\x23\x90\x65"
  "\x57\x93\x3e\xcb\x93\xff\x6e\xde\xd1";

/*
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 1 (0x1)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: CN=Soft U2F, O=GitHub Inc., OU=Security
        Validity
            Not Before: Jul 24 23:38:27 2017 GMT
            Not After : Jul 22 23:38:27 2027 GMT
        Subject: CN=Soft U2F, O=GitHub Inc., OU=Security
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
            EC Public Key:
                pub:
                    04:f6:9c:ab:24:14:4b:b4:ef:87:f7:0f:23:1c:5c:
                    d4:f5:78:04:ac:f8:e0:c6:b2:b3:e3:52:18:3d:80:
                    39:1f:6b:d2:79:d2:6a:4c:83:64:74:e6:c2:da:23:
                    93:ff:ac:1d:50:34:6c:5c:23:90:65:57:93:3e:cb:
                    93:ff:6e:de:d1
                ASN1 OID: prime256v1
        X509v3 extensions:
            1.3.6.1.4.1.45724.2.1.1:
                ....
    Signature Algorithm: ecdsa-with-SHA256
        30:45:02:21:00:f6:c8:fd:40:c2:32:b4:d2:a6:15:24:10:44:
        5f:b0:78:6c:63:69:74:d4:fd:f0:53:c5:46:be:c9:9a:c7:02:
        67:02:20:40:b5:f1:a4:5f:c7:fc:06:d4:88:9d:de:fb:8c:dc:
        23:ba:b0:42:d9:f0:83:3d:fd:06:29:7f:07:9d:81:f1:8a
*/
const unsigned char *cert = (unsigned char*)
  "\x30\x82\x01\x79\x30\x82\x01\x1f\x02\x01\x01\x30\x0a\x06\x08\x2a"
  "\x86\x48\xce\x3d\x04\x03\x02\x30\x3c\x31\x11\x30\x0f\x06\x03\x55"
  "\x04\x03\x0c\x08\x53\x6f\x66\x74\x20\x55\x32\x46\x31\x14\x30\x12"
  "\x06\x03\x55\x04\x0a\x0c\x0b\x47\x69\x74\x48\x75\x62\x20\x49\x6e"
  "\x63\x2e\x31\x11\x30\x0f\x06\x03\x55\x04\x0b\x0c\x08\x53\x65\x63"
  "\x75\x72\x69\x74\x79\x30\x1e\x17\x0d\x31\x37\x30\x37\x32\x34\x32"
  "\x33\x33\x38\x32\x37\x5a\x17\x0d\x32\x37\x30\x37\x32\x32\x32\x33"
  "\x33\x38\x32\x37\x5a\x30\x3c\x31\x11\x30\x0f\x06\x03\x55\x04\x03"
  "\x0c\x08\x53\x6f\x66\x74\x20\x55\x32\x46\x31\x14\x30\x12\x06\x03"
  "\x55\x04\x0a\x0c\x0b\x47\x69\x74\x48\x75\x62\x20\x49\x6e\x63\x2e"
  "\x31\x11\x30\x0f\x06\x03\x55\x04\x0b\x0c\x08\x53\x65\x63\x75\x72"
  "\x69\x74\x79\x30\x59\x30\x13\x06\x07\x2a\x86\x48\xce\x3d\x02\x01"
  "\x06\x08\x2a\x86\x48\xce\x3d\x03\x01\x07\x03\x42\x00\x04\xf6\x9c"
  "\xab\x24\x14\x4b\xb4\xef\x87\xf7\x0f\x23\x1c\x5c\xd4\xf5\x78\x04"
  "\xac\xf8\xe0\xc6\xb2\xb3\xe3\x52\x18\x3d\x80\x39\x1f\x6b\xd2\x79"
  "\xd2\x6a\x4c\x83\x64\x74\xe6\xc2\xda\x23\x93\xff\xac\x1d\x50\x34"
  "\x6c\x5c\x23\x90\x65\x57\x93\x3e\xcb\x93\xff\x6e\xde\xd1\xa3\x17"
  "\x30\x15\x30\x13\x06\x0b\x2b\x06\x01\x04\x01\x82\xe5\x1c\x02\x01"
  "\x01\x04\x04\x03\x02\x03\x08\x30\x0a\x06\x08\x2a\x86\x48\xce\x3d"
  "\x04\x03\x02\x03\x48\x00\x30\x45\x02\x21\x00\xf6\xc8\xfd\x40\xc2"
  "\x32\xb4\xd2\xa6\x15\x24\x10\x44\x5f\xb0\x78\x6c\x63\x69\x74\xd4"
  "\xfd\xf0\x53\xc5\x46\xbe\xc9\x9a\xc7\x02\x67\x02\x20\x40\xb5\xf1"
  "\xa4\x5f\xc7\xfc\x06\xd4\x88\x9d\xde\xfb\x8c\xdc\x23\xba\xb0\x42"
  "\xd9\xf0\x83\x3d\xfd\x06\x29\x7f\x07\x9d\x81\xf1\x8a";

const int priv_len = 121;
const int cert_len = 381;

@implementation SelfSignedCertificate {}

+ (NSData *)toDer {
  int len;
  unsigned char *buf;
  X509 *x509;
  const unsigned char *crt_cpy = cert;

  x509 = d2i_X509(NULL, &crt_cpy, cert_len);
  if (x509 == NULL) {
    printf("failed to parse cert\n");
    return nil;
  }

  buf = NULL;
  len = i2d_X509(x509, &buf);
  if (len < 0) {
    printf("failed to export cert\n");
    X509_free(x509);
    return nil;
  }

  X509_free(x509);

  return [[NSData alloc] initWithBytes:buf length:len];
}

+ (NSData *)signData:(NSData *)msg {
  EVP_MD_CTX ctx;
  const unsigned char *cmsg = (const unsigned char *)[msg bytes];
  unsigned char *sig;
  unsigned int len;
  EC_KEY *ec;
  EVP_PKEY *pkey;
  const unsigned char *priv_cpy = priv;

  ec = d2i_ECPrivateKey(NULL, &priv_cpy, priv_len);
  if (ec == NULL) {
    printf("error importing private key\n");
    return nil;
  }

  if (EC_KEY_check_key(ec) != 1) {
    printf("error checking key\n");
    EC_KEY_free(ec);
    return nil;
  }

  pkey = EVP_PKEY_new();
  if (pkey == NULL) {
    printf("failed to init pkey\n");
    EC_KEY_free(ec);
    return nil;
  }

  if (EVP_PKEY_assign_EC_KEY(pkey, ec) != 1) {
    printf("failed to assing ec to pkey\n");
    EC_KEY_free(ec);
    EVP_PKEY_free(pkey);
    return nil;
  }

  // `ec` memory is managed by `pkey` from here.

  if (EVP_SignInit(&ctx, EVP_sha256()) != 1) {
    printf("failed to init signing context\n");
    EVP_PKEY_free(pkey);
    return nil;
  };

  if (EVP_SignUpdate(&ctx, cmsg, (unsigned int)[msg length]) != 1) {
    printf("failed to update digest\n");
    EVP_PKEY_free(pkey);
    return nil;
  }

  sig = (unsigned char *)malloc(EVP_PKEY_size(pkey));
  if (sig == NULL) {
    printf("failed to malloc for sig\n");
    EVP_PKEY_free(pkey);
    return nil;
  }

  if (EVP_SignFinal(&ctx, sig, &len, pkey) != 1) {
    printf("failed to finalize digest\n");
    free(sig);
    EVP_PKEY_free(pkey);
    return nil;
  }

  return [[NSData alloc] initWithBytes:sig length:len];
}

+ (bool)parseX509:(NSData *)data consumed:(NSInteger *)consumed;
{
  X509 *crt;
  const unsigned char *crtStart, *crtEnd;
  crtStart = crtEnd = [data bytes];

  crt = d2i_X509(NULL, &crtEnd, [data length]);

  if (crt == NULL) {
    return false;
  } else {
    X509_free(crt);
    *consumed = crtEnd - crtStart;
    return true;
  }
}

@end
