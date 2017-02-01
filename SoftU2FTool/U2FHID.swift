//
//  HIDU2F.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

class U2FHID {
    enum MessageType:UInt8 {
        case Ping  = 0x81  // Echo data through local processor only
        case Msg   = 0x83  // Send U2F message frame
        case Lock  = 0x84  // Send lock channel command
        case Init  = 0x86  // Channel initialization
        case Wink  = 0x88  // Send device identification wink
        case Sync  = 0xBC  // Protocol resync command
        case Error = 0xBF  // Error response
    }

    typealias HIDMessageHandler = (_ msg: softu2f_hid_message) -> Bool
    typealias CHIDMessageHandler = (_ ctx:OpaquePointer?, _ msg:UnsafeMutablePointer<softu2f_hid_message>?) -> Bool

    static let shared = U2FHID()
    private static var hasShared = false

    let ctx:OpaquePointer?
    private var handlers = [UInt8:HIDMessageHandler]()
    private var runThread:Thread?

    init?() {
        // Only allow the one singleton instance.
        if U2FHID.hasShared {
            return nil
        }

        ctx = softu2f_init(SOFTU2F_DEBUG)

        if ctx == nil {
            return nil
        }

        U2FHID.hasShared = true
    }

    deinit {
        if ctx != nil {
            softu2f_deinit(ctx)
            U2FHID.hasShared = false
        }
    }

    // Send a U2F level message to the client with the given CID.
    func sendMsg(cid:UInt32, data:Data) -> Bool {
        var msg = softu2f_hid_message()

        msg.cmd = MessageType.Msg.rawValue
        msg.bcnt = UInt16(data.count)
        msg.cid = cid
        msg.data = Unmanaged.passUnretained(data as CFData)

        return withUnsafeMutablePointer(to: &msg) { msgPtr in
            return softu2f_hid_msg_send(ctx, msgPtr)
        }
    }

    // Register a handler for the given type of U2F HID message.
    func handle(_ type: MessageType, with handler: @escaping HIDMessageHandler) {
        handlers[type.rawValue] = handler

        softu2f_hid_msg_handler_register(ctx, type.rawValue) { (_ ctx:OpaquePointer?, _ msgPtr:UnsafeMutablePointer<softu2f_hid_message>?) -> Bool in
            if let cmd = msgPtr?.pointee.cmd {
                if let handler:HIDMessageHandler = U2FHID.shared?.handlers[cmd] {
                    return handler(msgPtr!.pointee)
                }
            }

            return false
        }
    }

    // Start running softu2f device in a background thread.
    func run() -> Bool {
        if runThread != nil {
            return false
        }

        print("Starting U2FHID thread")
        runThread = Thread() {
            print("U2FHID thread started")
            softu2f_run(self.ctx)
            self.runThread = nil
            print("U2FHID thread stopped")
        }

        runThread?.start()

        return true
    }

    // Stop running the softu2f device.
    func stop() -> Bool {
        guard let thread = runThread else { return false }

        print("Stopping U2FHID thread")
        softu2f_shutdown(ctx)

        for _ in 0..<3 {
            if thread.isFinished {
                return true
            } else {
                sleep(1)
            }
        }

        return false
    }
}
