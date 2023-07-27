//
//  ParameterizedTestMacroTests.swift
//
//
//  Created by LS Hung on 27/07/2023.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import MacroPlaygroundMacros

private let testMacros: [String: Macro.Type] = [
    "ParameterizedTest": ParameterizedTestMacro.self,
]

final class ParameterizedTestMacroTests: XCTestCase {
    func test() {
        assertMacroExpansion(
            """
            """,
            expandedSource: """
            """,
            macros: testMacros
        )
    }
}
