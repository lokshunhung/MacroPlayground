import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroPlaygroundPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FatalCoderInitMacro.self,
        SynchronizedMacro.self,
        ParameterizedTestMacro.self,
        ParameterizedMacro.self,
    ]
}
