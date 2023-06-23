import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroPlaygroundMacros

let testMacros: [String: Macro.Type] = [
    "FatalCoderInit": FatalCoderInit.self,
]

final class MacroPlaygroundTests: XCTestCase {
    func testMacroBaseline() {
        assertMacroExpansion(
            """
            @FatalCoderInit
            class A: UIView {
            }
            """,
            expandedSource: """
            
            class A: UIView {
                required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroKeepsClassDeclModifiers() {
        assertMacroExpansion(
            """
            @FatalCoderInit
            fileprivate final class A: UIView {
            }
            """,
            expandedSource: """
            
            fileprivate final class A: UIView {
                required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
            }
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            @FatalCoderInit
            public class A: NSView {
            }
            """,
            expandedSource: """
            
            public class A: NSView {
                required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroAddsPublicModifierForOpenClassDecl() {
        assertMacroExpansion(
            """
            @FatalCoderInit
            open class A: UIView {
            }
            """,
            expandedSource: """
            
            open class A: UIView {
                public required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroErrorsOnNonClass() {
        assertMacroExpansion(
            """
            @FatalCoderInit
            struct A {
            }
            """,
            expandedSource: """
            
            struct A {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@FatalCoderInit can only be applied to a class",
                    line: 1, column: 1
                )
            ],
            macros: testMacros
        )
    }

    func testMacroCustomErrorMessage() {
        assertMacroExpansion(
            """
            @FatalCoderInit(message: "A custom error message for init(coder:)")
            class A: UIView {
            }
            """,
            expandedSource: """
            
            class A: UIView {
                required init?(coder: NSCoder) {
                    fatalError("A custom error message for init(coder:)")
                }
            }
            """,
            macros: testMacros
        )

        assertMacroExpansion(
            #"""
            @FatalCoderInit(
                message: """
                A custom multiline
                error message for init(coder:)
                """
            )
            class A: UIView {
            }
            """#,
            expandedSource: #"""

            class A: UIView {
                required init?(coder: NSCoder) {
                    fatalError("""
                        A custom multiline
                        error message for init(coder:)
                        """)
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testMacroCustomErrorMessageReference() {
        assertMacroExpansion(
            """
            let message: String = "A top-level identifier for fatalError to reference to for error message"
            @FatalCoderInit(message: message)
            class A: UIView {
            }
            """,
            expandedSource: """
            let message: String = "A top-level identifier for fatalError to reference to for error message"
            class A: UIView {
                required init?(coder: NSCoder) {
                    fatalError(message)
                }
            }
            """,
            macros: testMacros
        )

        assertMacroExpansion(
            """
            @FatalCoderInit(message: A.fatalCoderMessage)
            class A: UIView {
                static let fatalCoderMessage: String = "A type-level identifier for fatalError to reference to for error message"
            }
            """,
            expandedSource: """
            
            class A: UIView {
                static let fatalCoderMessage: String = "A type-level identifier for fatalError to reference to for error message"
                required init?(coder: NSCoder) {
                    fatalError(A.fatalCoderMessage)
                }
            }
            """,
            macros: testMacros
        )
    }
}
