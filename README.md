# SoftU2FTool

SoftU2FTool is a software U2F authenticator for OS X. It emulates a hardware U2F HID device using [SoftU2F](https://github.com/mastahyeti/SoftU2F) and performs cryptographic operations using the OS X Keychain. This tool works with Google Chrome and Opera's built-in U2F implementations as well as with the U2F extensions for OS X Safari and Firefox.

## Building

You must have Xcode Command Line Tools installed to build this project.

```bash
# Install Commaned Line Tools
xcode-select --install

# Build softu2f.kext and SoftU2FTool.app.
script/build
```

## Running

I'm waiting on Apple to get a certificate for signing kernel extension. In the meantime, you'll have to [disable System Integrity Protection](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html#//apple_ref/doc/uid/TP40016462-CH5-SW1) before trying to load `softu2f.kext` and run `SoftU2FTool.app`.

```bash
script/run
```

With the app running, you'll receive notifications when sites try to register or authenticate with U2F.

### Registration

![register](https://cloud.githubusercontent.com/assets/1144197/22489751/80e4748e-e7d6-11e6-9e4e-11e48ddff331.png)

### Authentication

![authenticate](https://cloud.githubusercontent.com/assets/1144197/22489753/824fbb80-e7d6-11e6-82c5-7f6ac0d6042b.png)
