![](https://user-images.githubusercontent.com/1144197/28190263-470a80d2-67e7-11e7-81e6-17895d70bf75.png)

Soft U2F is a software U2F authenticator for macOS. It emulates a hardware U2F HID device and performs cryptographic operations using the macOS Keychain. This tool works with Google Chrome/Chromium, Safari, Firefox and Opera's built-in U2F implementations.

We take the security of this project seriously. Report any security vulnerabilities to the [GitHub Bug Bounty Program](https://hackerone.com/github).

## Installing

You can download the installer [here](https://github.com/github/SoftU2F/releases/latest).

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

Tell macOS to forget about the installation

```
$ sudo pkgutil --forget com.GitHub.SoftU2F
```

Done

## Security considerations

A USB authenticator stores key material in hardware, whereas Soft U2F stores its keys in the macOS Keychain. There is an argument to be made that it is more secure to store keys in hardware since malware running on your computer can access the contents of your Keychain but cannot export the contents of a hardware authenticator. On the other hand, malware can also access your browser's cookies and has full access to all authenticated website sessions, regardless of where U2F keys are stored.

In the case of malware installed on your computer, one meaningful difference between hardware and software key storage for U2F is the duration of the compromise. With hardware key storage, you are only compromised while the malware is running on your computer. With software key storage, you could continue to be compromised, even after the malware has been removed.

Some people may decide the attack scenario above is worth the usability tradeoff of hardware key storage. But, for many, the security of software-based U2F is sufficient and helps to mitigate against many common attacks such as password dumps, brute force attacks, and phishing related exploits.

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


## License

This project is MIT licensed, except for the files in [`/inc`](https://github.com/github/SoftU2F/tree/master/inc), which are included with their own licenses.
