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
        let declModifiers: [Keyword] = classDecl.modifiers?.map(\.name.tokenKind).compactMap { tokenKind in
            guard case TokenKind.keyword(let keyword) = tokenKind else { return nil }
            return keyword
        } ?? []
        return [
            DeclSyntax(InitializerDeclSyntax(
                modifiers: ModifierListSyntax(itemsBuilder: {
                    if declModifiers.contains(where: { $0 == .open }) {
                        DeclModifierSyntax(name: .keyword(.public))
                    }
                    DeclModifierSyntax(name: .keyword(.required))
                }),
                initKeyword: .keyword(.`init`),
                optionalMark: .postfixQuestionMarkToken(),
                signature: FunctionSignatureSyntax(
                    input: ParameterClauseSyntax(
                        parameterList: [
                            FunctionParameterSyntax(
                                firstName: .identifier("coder"),
                                type: SimpleTypeIdentifierSyntax(name: .identifier("NSCoder"))
                            ),
                        ]
                    )
                ),
                body: CodeBlockSyntax(statements: [
                    CodeBlockItemSyntax(
                        item: .expr(ExprSyntax(FunctionCallExprSyntax(
                            calledExpression: IdentifierExprSyntax(identifier: .identifier("fatalError")),
                            leftParen: .leftParenToken(),
                            argumentList: [
                                TupleExprElementSyntax(expression: errorMessageNode(from: node)),
                            ],
                            rightParen: .rightParenToken()
                        )))
                    ),
                ])
            )),
        ]
    }

    private static func errorMessageNode(from node: AttributeSyntax) -> ExprSyntax {
        if case .argumentList(let argumentList) = node.argument,
           let node = argumentList.first?.expression {
            return node
        }
        return ExprSyntax(StringLiteralExprSyntax(
            openQuote: .stringQuoteToken(),
            segments: [
                .stringSegment(StringSegmentSyntax(
                    content: .stringSegment("Not implemented")
                )),
            ],
            closeQuote: .stringQuoteToken()
        ))
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
