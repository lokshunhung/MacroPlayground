//
//  ObservableObjectTests.swift
//  
//
//  Created by LS Hung on 29/06/2023.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroPlaygroundMacros

private let testMacros: [String: Macro.Type]  = [
    "ObservableObject": ObservableObjectMacro.self,
    "NotPublished": NotPublishedMacro.self,
]

final class ObservableObjectTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
            """
            @ObservableObject
            public class VM {
                @NotPublished
                public var a: Int
                public var b: Bool

                public init(a: Int, b: Bool) {
                    self.a = a
                    self.b = b
                }
            }
            """,
            expandedSource: """

            public class VM {
                public var a: Int
                @Published
                    public var b: Bool

                public init(a: Int, b: Bool) {
                    self.a = a
                    self.b = b
                }
            }
            extension VM: ObservableObject {
            }
            """,
            macros: testMacros
        )
    }

    func testMacroThrowsIfManualConformanceToObservableObject() throws {
        assertMacroExpansion(
            """
            @ObservableObject
            public class VM: ObservableObject {
            }
            """,
            expandedSource: """

            public class VM: ObservableObject {
            }
            """,
            diagnostics: [
                .init(message: "Unnecessary ObservableObject conformance", line: 2, column: 18),
            ],
            macros: testMacros
        )
    }
}
