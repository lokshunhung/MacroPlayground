import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroPlaygroundMacros

private let testMacros: [String: Macro.Type] = [
    "Synchronized": SynchronizedMacro.self,
]

final class SynchronizedMacroTests: XCTestCase {
    func testNoArgs() throws {
        assertMacroExpansion(
            """
            public struct Jar {
                private let lock = Lock()

                @Synchronized
                func foo(_ a: Int, b: Bool, c d: Double) {
                    print()
                }
            }
            """,
            expandedSource: """
            public struct Jar {
                private let lock = Lock()
                func foo(_ a: Int, b: Bool, c d: Double) {
                    print()
                }
                func $foo(_ a: Int, b: Bool, c d: Double) {
                    lock.withLock {
                        foo(a, b: b, c: d)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
}
