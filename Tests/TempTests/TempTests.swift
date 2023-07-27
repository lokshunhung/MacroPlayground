//
//  TempTests.swift
//
//
//  Created by LS Hung on 27/07/2023.
//

import XCTest
import MacroPlayground

final class SomethingTest: XCTestCase {
//    @ParameterizedTest([
//        (1, 1),
//        (2, 2),
//    ])
    func testEquals(a: Int, b: Int) async throws {
        XCTAssertEqual(a, b)
    }

    func testEquals_0() async throws {
        func toTupleSplat<A, R>(_ f: @escaping (A) async throws -> R) -> (A) async throws -> R {
            return f
        }
        let testFunc = toTupleSplat(testEquals)
        return try await testFunc((1, 1))
    }

    func testEquals_1() async throws {
        func toTupleSplat<A, R>(_ f: @escaping (A) async throws -> R) -> (A) async throws -> R {
            return f
        }
        let testFunc = toTupleSplat(testEquals)
        return try await testFunc((2, 2))
    }
    
}
