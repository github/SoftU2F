//
//  Utils.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/31/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

// Helper for making CFDictionary.
func makeCFDictionary(_ members: (CFString, AnyObject)...) -> CFDictionary {
    var dict = [String:AnyObject]()

    members.forEach { elt in
        dict[elt.0 as String] = elt.1
    }

    return dict as CFDictionary
}
