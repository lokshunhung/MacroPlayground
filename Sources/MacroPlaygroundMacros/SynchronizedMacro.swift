import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SynchronizedMacro: SwiftSyntaxMacros.PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let fnDecl = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }

        let argument = node
            .argument?.as(TupleExprElementListSyntax.self)?.first?
            .expression.as(TupleExprElementSyntax.self)?
            .expression.as(MemberAccessExprSyntax.self)?
            .name.text
        let keyword = argument.flatMap(Keyword.modifierFrom(string:))
        let modifiers = if argument == "attached" {
            fnDecl.modifiers
        } else {
            ModifierListSyntax(itemsBuilder: {
                if let keyword {
                    DeclModifierSyntax(name: .keyword(keyword))
                }
                for modifier in fnDecl.modifiers ?? [] {
                    if modifier.detail == nil {
                        modifier
                    }
                }
            })
        }

        let attributes = fnDecl.attributes?.filter { element in
            let attrName = element.as(AttributeSyntax.self)?
                .attributeName.as(SimpleTypeIdentifierSyntax.self)?
                .name.tokenKind
            return attrName != .identifier("Synchronized")
        }
        let identifier = fnDecl.identifier
        let bodyStmts = CodeBlockItemListSyntax(itemsBuilder: {
            let callArguments = TupleExprElementListSyntax(itemsBuilder: {
                for param in fnDecl.signature.input.parameterList {
                    TupleExprElementSyntax(
                        label: param.firstName.tokenKind == .wildcard
                            ? nil
                            : param.firstName.text,
                        expression: IdentifierExprSyntax(
                            identifier: param.secondName ?? param.firstName
                        )
                    )
                }
            })
            """
            lock.withLock {
                \(identifier)(\(callArguments))
            }
            """
        })

        let peerDecl = fnDecl
            .with(\.attributes, attributes.map { .init($0) })
            .with(\.modifiers, modifiers)
            .with(\.identifier, .identifier("$" + identifier.text))
            .with(\.body, .init(statements: bodyStmts))
        return [
            DeclSyntax(peerDecl),
        ]
    }
}

private extension Keyword {
    static func modifierFrom(string: String) -> Self? {
        return switch string {
        case "open": .`open`
        case "public": .`public`
        case "internal": .`internal`
        case "fileprivate": .`fileprivate`
        case "private": .`private`
        default: nil
        }
    }
}
