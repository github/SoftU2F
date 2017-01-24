//
//  DataReaderTests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class DataReaderTests: XCTestCase {
    func testUInt8() throws {
        var raw:[UInt8] = [0x00, 0x01, 0x02]
        let data = Data(bytes: &raw, count: raw.count)
        let reader = DataReader(data: data, offset: 1)
        var ores:UInt8?
        var res:UInt8
        
        XCTAssertEqual(2, reader.remaining)
        ores = reader.peek()
        XCTAssertEqual(ores, 0x01)
        XCTAssertEqual(2, reader.remaining)
        res = try reader.read()
        XCTAssertEqual(res, 0x01)
        
        XCTAssertEqual(1, reader.remaining)
        ores = reader.peek()
        XCTAssertEqual(ores, 0x02)
        XCTAssertEqual(1, reader.remaining)
        res = try reader.read()
        XCTAssertEqual(res, 0x02)
        
        XCTAssertEqual(0, reader.remaining)
        ores = reader.peek()
        XCTAssertEqual(ores, nil)
        XCTAssertEqual(0, reader.remaining)
        
        do {
            res = try reader.read()
            XCTAssert(false, "expected exception")
        } catch DataReader.DRError.End {
            // pass
        }
        
        XCTAssertEqual(0, reader.remaining)
    }
    
    func testUInt16() throws {
        var raw:[UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        let data = Data(bytes: &raw, count: raw.count)
        let reader = DataReader(data: data, offset: 0)
        var ores:UInt16?
        var res:UInt16
        
        XCTAssertEqual(5, reader.remaining)
        ores = reader.peek()
        XCTAssertEqual(ores, 0x0001)
        XCTAssertEqual(5, reader.remaining)
        res = try reader.read()
        XCTAssertEqual(res, 0x0001)
        
        XCTAssertEqual(3, reader.remaining)
        ores = reader.peek(endian: .Little)
        XCTAssertEqual(ores, 0x0302)
        XCTAssertEqual(3, reader.remaining)
        res = try reader.read(endian: .Little)
        XCTAssertEqual(res, 0x0302)
        
        XCTAssertEqual(1, reader.remaining)
        ores = reader.peek()
        XCTAssertEqual(ores, nil)
        
        do {
            res = try reader.read()
            XCTAssert(false, "expected exception")
        } catch DataReader.DRError.End {
            // pass
        }
        
        XCTAssertEqual(1, reader.remaining)
    }
    
    func testReadOptionalUInt8() {
        var raw:[UInt8] = [0x00]
        let data = Data(bytes: &raw, count: raw.count)
        let reader = DataReader(data: data)
        var ores:UInt8?
        
        XCTAssertEqual(1, reader.remaining)
        ores = reader.read()
        XCTAssertEqual(ores, 0x00)
        
        XCTAssertEqual(0, reader.remaining)
        ores = reader.read()
        XCTAssertEqual(ores, nil)
        
        XCTAssertEqual(0, reader.remaining)
    }
    
    func testReadBytes() throws {
        var raw:[UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        let data = Data(bytes: &raw, count: raw.count)
        let reader = DataReader(data: data, offset: 0)
        var ores: Data?
        var res: Data
        
        let expected = data.subdata(in: 0..<3)
        XCTAssertEqual(5, reader.remaining)
        ores = reader.peekData(2)
        XCTAssertEqual(ores, expected)
        XCTAssertEqual(5, reader.remaining)
        res = try reader.readData(2)
        XCTAssertEqual(res, expected)
        
        XCTAssertEqual(3, reader.remaining)
        ores = reader.peekData(4)
        XCTAssertEqual(ores, nil)
        XCTAssertEqual(3, reader.remaining)
        
        do {
            res = try reader.readData(4)
            XCTAssert(false, "expected exception")
        } catch DataReader.DRError.End {
            // pass
        }
        
        XCTAssertEqual(3, reader.remaining)
    }
    
    func testReadBytesWithUIntArgs() throws {
        var raw:[UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        let data = Data(bytes: &raw, count: raw.count)
        let reader = DataReader(data: data, offset: 0)
        var ores: Data?
        var res: Data
        
        let expected = data.subdata(in: 0..<3)
        XCTAssertEqual(5, reader.remaining)
        ores = reader.peekData(UInt8(2))
        XCTAssertEqual(ores, expected)
        XCTAssertEqual(5, reader.remaining)
        res = try reader.readData(Int16(2))
        XCTAssertEqual(res, expected)
        
        XCTAssertEqual(3, reader.remaining)
        ores = reader.peekData(UInt32(4))
        XCTAssertEqual(ores, nil)
        XCTAssertEqual(3, reader.remaining)
        
        do {
            res = try reader.readData(UInt64(4))
            XCTAssert(false, "expected exception")
        } catch DataReader.DRError.End {
            // pass
        }
        
        XCTAssertEqual(3, reader.remaining)
    }
    
    enum Place: UInt8, EndianEnumProtocol {
        typealias RawValue = UInt8
        
        case first  = 0x01
        case second = 0x02
        case third  = 0x03
    }
    
    func testReadEnum() throws {
        let reader = DataReader(data: Data(int: UInt32(0x01020304)))
        var p:Place
        var op:Place?
        
        XCTAssertEqual(4, reader.remaining)
        op = reader.peek()
        XCTAssertEqual(Place.first, op)
        XCTAssertEqual(4, reader.remaining)
        p = try reader.read()
        XCTAssertEqual(Place.first, p)

        XCTAssertEqual(3, reader.remaining)
        p = try reader.read()
        XCTAssertEqual(Place.second, p)
        
        XCTAssertEqual(2, reader.remaining)
        p = try reader.read()
        XCTAssertEqual(Place.third, p)
        
        XCTAssertEqual(1, reader.remaining)
        op = reader.peek()
        XCTAssertEqual(nil, op)
        
        do {
            p = try reader.read()
            XCTFail("expected an exception")
        } catch DataReader.DRError.TypeError {
            // pass.
        }
        
        XCTAssertEqual(0, reader.remaining)
        op = reader.peek()
        XCTAssertEqual(nil, op)
        
        do {
            p = try reader.read()
            XCTFail("expected an exception")
        } catch DataReader.DRError.End {
            // pass
        }
    }

    func testReadOptionalEnum() {
        let reader = DataReader(data: Data(int: UInt32(0x01020304)))
        var op:Place?

        XCTAssertEqual(4, reader.remaining)
        op = reader.peek()
        XCTAssertEqual(Place.first, op)
        XCTAssertEqual(4, reader.remaining)
        op = reader.read()
        XCTAssertEqual(Place.first, op)
        
        XCTAssertEqual(3, reader.remaining)
        op = reader.read()
        XCTAssertEqual(Place.second, op)
        
        XCTAssertEqual(2, reader.remaining)
        op = reader.read()
        XCTAssertEqual(Place.third, op)
        
        XCTAssertEqual(1, reader.remaining)
        op = reader.read()
        XCTAssertEqual(nil, op)
        
        XCTAssertEqual(0, reader.remaining)
        op = reader.read()
        XCTAssertEqual(nil, op)
    }
}
