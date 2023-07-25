//
//  ParameterizedMacroTests.swift
//
//
//  Created by LS Hung on 25/07/2023.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import MacroPlaygroundMacros

private let testMacros: [String: Macro.Type] = [
    "Parameterized": ParameterizedMacro.self,
]

final class ParameterizedMacroTests: XCTestCase {
    override static var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(name: NSStringFromClass(self))

        self.testInvocations.forEach { invocation in
            let test = Self(invocation: invocation)
//            test.input =
            suite.addTest(test)
        }

        return suite
    }

    func testMacro() {
        assertMacroExpansion(
            """
            struct Input {
                var a: Int, b: Int
            }
            @Parameterized<Input>(
                .init(a: 1, b: 2)
            )
            final class ParameterizedXCTestTests: XCTestCase {
            }
            """,
            expandedSource: """
            struct Input {
                var a: Int, b: Int
            }
            final class ParameterizedXCTestTests: XCTestCase {
                var input: Input!
                override static var defaultTestSuite: XCTestSuite {
                    let testSuite = XCTestSuite(name: NSStringFromClass(self))
                    addNewTest(.init(a: 1, b: 2), to: testSuite)
                    return testSuite
                }
                private static func addNewTest(_ input: Input, to testSuite: XCTestSuite) {
                    for invocation in self.testInvocations {
                        let testCase = ParameterizedXCTestTests(invocation: invocation)
                        testCase.input = input
                        testSuite.addTest(testCase)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
}
