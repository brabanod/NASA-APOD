//
//  XCTAssert+Extension.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 28.11.22.
//

import Foundation
import XCTest

// Async declarations of XCTAssert functions

public func AsyncAssertEqual<T>(_ expression1: @autoclosure () async throws -> T, _ expression2: @autoclosure () async throws -> T, file: StaticString = #file, line: UInt = #line) async where T : Equatable {
    do {
        let result1 = try await expression1()
        let result2 = try await expression2()
        XCTAssertEqual(result1, result2, file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
