import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FatalCoderInit: SwiftSyntaxMacros.MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else { throw Error.onlyApplicableToClass }

        let isOpen: Bool = classDecl.modifiers?
            .contains { modifier in
                if case .keyword(.open) = modifier.name.tokenKind {
                    true
                } else {
                    false
                }
            }
            ?? false

        let modifier: String = isOpen ? "public" : ""

        let message: String = node.argument?.as(TupleExprElementListSyntax.self)?.first?.expression.description ?? #""init(coder:) has not been implemented""#

        let initDecl: DeclSyntax = """
        \(raw: modifier) required init?(coder: NSCoder) {
            fatalError(\(raw: message))
        }
        """
        return [initDecl]
    }

    enum Error: Swift.Error, CustomStringConvertible {
        case onlyApplicableToClass

        var description: String {
            switch self {
            case .onlyApplicableToClass:
                return "@\(FatalCoderInit.self) can only be applied to a class"
            }
        }
    }
}

@main
struct MacroPlaygroundPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FatalCoderInit.self,
    ]
}
