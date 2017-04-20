# SoftU2FTool

SoftU2FTool is a software U2F authenticator for OS X. It emulates a hardware U2F HID device using [SoftU2F](https://github.com/mastahyeti/SoftU2F) and performs cryptographic operations using the OS X Keychain. This tool works with Google Chrome and Opera's built-in U2F implementations as well as with the U2F extensions for OS X Safari and Firefox.

## Installing

**Disclaimer:** *This app is dangerous and shouldn't be used. It includes a kernel extension that was written by a novice C programmer. This could permanently damage your system. Additionally, while the app was written by a security nerd, it hasn't received outside security review and shouldn't be trusted for authenticating with actual sites.*

You can download the installer [here](https://github.com/mastahyeti/SoftU2FTool/releases/download/0.0.1/SoftU2FTool.pkg).

## Usage

The app runs in the background. When a site loaded in a U2F-compatible browser attempts to register or authenticate with the software token, you'll see a notification asking you to accept or reject the request. You can experiment on [Yubico's U2F demo site](https://demo.yubico.com/u2f).

### Registration

![register](https://cloud.githubusercontent.com/assets/1144197/25237689/9b718160-25a8-11e7-84be-c88fbe1e7a1a.png)

### Authentication

![authenticate](https://cloud.githubusercontent.com/assets/1144197/25237695/9da69ff6-25a8-11e7-9391-1a55a7c14891.png)

## Uninstalling

Unload the launchd agent

```
$ launchctl unload ~/Library/LaunchAgents/com.github.SoftU2FTool.plist
```

Delete the launch agent plist

```
$ rm ~/Library/LaunchAgents/com.github.SoftU2FTool.plist
```

Delete the `.app`

```
$ sudo rm -rf /Applications/SoftU2FTool.app/
```

Unload the kernel extension (this may fail if a browser is still talking to the driver. Deleting the `.kext` and restarting the system will fix this)

```
$ sudo kextunload /Library/Extensions/softu2f.kext
```

Delete the kernel extension

```
$ sudo rm -rf /Library/Extensions/softu2f.kext
```

Done

## Hacking

### Building

You must have Xcode Command Line Tools installed to build this project.

```bash
# Install Commaned Line Tools
xcode-select --install

# Build softu2f.kext and SoftU2FTool.app.
script/build
```

### Running

There are two parts to SoftU2FTool: the kext and the app. To use a modified version of the kext, you must [disable System Integrity Protection](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html#//apple_ref/doc/uid/TP40016462-CH5-SW1). The app can be modified and run via Xcode normally.

## Known app-IDs/facets

Every website using U2F has an app-ID. For example, the app-ID of [Yubico's U2F demo page](https://demo.yubico.com/u2f) is `https://demo.yubico.com`. When the low-level U2F authenticator receives a request to register/authenticate a website, it doesn't receive the friendly app-ID string. Instead, it receives a SHA256 digest of the app-ID. To be able to show a helpful alert message when a website is trying to register/authenticate, a list of app-ID digests is maintained in this repository. You can find the list [here](https://github.com/mastahyeti/SoftU2FTool/blob/master/SoftU2FTool/KnownFacets.swift). If your companies app-ID is missing from this list, open a pull request to add it.
