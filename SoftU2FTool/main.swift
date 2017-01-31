//
//  main.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/27/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Cocoa

let app = NSApplication.shared()

signal(SIGINT) { sig in
    print("Got SIGINT")
    app.terminate(nil)
}

let delegate = AppDelegate()
app.delegate = delegate
let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
