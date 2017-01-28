//
//  main.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/27/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Cocoa

signal(SIGINT) { sig in
    print("Got SIGINT")
    NSApplication.shared().terminate(nil)
}

let delegate = AppDelegate()
NSApplication.shared().delegate = delegate
let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
