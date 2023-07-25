import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroPlaygroundPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CollectArrayMacro.self,
        FatalCoderInitMacro.self,
        SynchronizedMacro.self,
        ParameterizedMacro.self,
    ]
}
