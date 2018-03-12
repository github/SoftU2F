//
//  Mutex.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 3/12/18.
//  Copyright © 2018 GitHub. All rights reserved.
//

import Foundation

class Mutex {
    private var semaphore = DispatchSemaphore(value: 1)

    func lock() {
        semaphore.wait()
    }

    func unlock() {
        semaphore.signal()
    }
}
