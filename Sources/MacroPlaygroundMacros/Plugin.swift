import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroPlaygroundPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FatalCoderInitMacro.self,
    ]
}
