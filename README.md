![](https://user-images.githubusercontent.com/1144197/28190263-470a80d2-67e7-11e7-81e6-17895d70bf75.png)

Soft U2F is a software U2F authenticator for OS X. It emulates a hardware U2F HID device and performs cryptographic operations using the OS X Keychain. This tool works with Google Chrome and Opera's built-in U2F implementations as well as with the U2F extensions for OS X Safari and Firefox.

## Installing

You can download the installer [here](https://github.com/github/SoftU2F/releases/download/0.0.4/SoftU2F.pkg).

## Usage

The app runs in the background. When a site loaded in a U2F-compatible browser attempts to register or authenticate with the software token, you'll see a notification asking you to accept or reject the request. You can experiment on [Yubico's U2F demo site](https://demo.yubico.com/u2f).

### Registration

![register](https://cloud.githubusercontent.com/assets/1144197/25875975/9bb638bc-34d7-11e7-8327-8f8a6be4a52d.png)

### Authentication

![authenticate](https://cloud.githubusercontent.com/assets/1144197/25875979/a710b67e-34d7-11e7-853c-ca54f9a24ee8.png)

## Uninstalling

Unload the launchd agent

```
$ launchctl unload ~/Library/LaunchAgents/com.github.SoftU2F.plist
```

Delete the launch agent plist

```
$ rm ~/Library/LaunchAgents/com.github.SoftU2F.plist
```

Delete the `.app`

```
$ sudo rm -rf /Applications/SoftU2F.app/
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

# Build softu2f.kext and SoftU2F.app.
script/build
```

### Running

There are two parts to Soft U2F: the driver and the app. To use a modified version of the driver, you must [disable System Integrity Protection](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html#//apple_ref/doc/uid/TP40016462-CH5-SW1). The app can be modified and run via Xcode normally.

## Known app-IDs/facets

Every website using U2F has an app-ID. For example, the app-ID of [Yubico's U2F demo page](https://demo.yubico.com/u2f) is `https://demo.yubico.com`. When the low-level U2F authenticator receives a request to register/authenticate a website, it doesn't receive the friendly app-ID string. Instead, it receives a SHA256 digest of the app-ID. To be able to show a helpful alert message when a website is trying to register/authenticate, a list of app-ID digests is maintained in this repository. You can find the list [here](https://github.com/github/SoftU2F/blob/master/SoftU2FTool/KnownFacets.swift). If your company's app-ID is missing from this list, open a pull request to add it.
