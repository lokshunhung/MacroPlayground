//
//  ParameterizedTestMacro.swift
//
//
//  Created by LS Hung on 26/07/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ParameterizedTestMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }
        guard funcDecl.identifier.text.starts(with: "test") else {
            return []
        }

//        guard let attrTypeArg = node.attributeName.as(SimpleTypeIdentifierSyntax.self)?
//                                    .genericArgumentClause?.arguments else {
//            return [] // TODO: fixer
//        }
        guard let attrArgs = node.argument?.as(TupleExprElementListSyntax.self),
              let attrArg = attrArgs.first, attrArgs.count == 1 else {
            return []
        }

        switch parseParameterizedValues(attrArg) {
        case .invalid:
            return []
        case .array(let arrayExpr):
            return arrayExpr.elements.enumerated()
                .map { index, element in
                    return parameterizedTestFuncDecl(of: "\(index)",
                                                     calling: element.expression,
                                                     for: funcDecl)
                }
        case .dictionary(let dictExpr):
            return dictExpr.content.as(DictionaryElementListSyntax.self)?
                .compactMap { element -> DeclSyntax? in
                    guard let name = element.keyExpression.as(StringLiteralExprSyntax.self) else { return nil }
                    return parameterizedTestFuncDecl(of: name.description,
                                                     calling: element.valueExpression,
                                                     for: funcDecl)
                }
                ?? []
        }
    }

    private enum ParameterizedValues { case invalid, array(ArrayExprSyntax), dictionary(DictionaryExprSyntax) }
    private static func parseParameterizedValues(_ attrArg: TupleExprElementSyntax) -> ParameterizedValues {
        if let array = attrArg.expression.as(ArrayExprSyntax.self) {
            return .array(array)
        }
        if let dictionary = attrArg.expression.as(DictionaryExprSyntax.self) {
            return .dictionary(dictionary)
        }
        return .invalid
    }

    private static func parameterizedTestFuncDecl(of name: String,
                                                  calling argument: ExprSyntax,
                                                  for funcDecl: FunctionDeclSyntax) -> DeclSyntax {
        let identifier = funcDecl.identifier
                                 .with(\.leadingTrivia, [])
                                 .with(\.trailingTrivia, [])
        let argument = argument.with(\.leadingTrivia, [])
                               .with(\.trailingTrivia, [])
        let isAsync = funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrows = funcDecl.signature.effectSpecifiers?.throwsSpecifier != nil
        switch (isAsync, isThrows) {
        case (false, false):
            return DeclSyntax(try! FunctionDeclSyntax(
                "func \(identifier)_\(raw: name)()") {
                    """
                    func toTupleSplat<A, R>(_ f: @escaping (A) -> R) -> (A) -> R {
                        return f
                    }
                    """
                    "let testFunc = toTupleSplat(\(identifier))"
                    "return testFunc(\(argument))"
                })
        case (false, true):
            return DeclSyntax(try! FunctionDeclSyntax(
                "func \(identifier)_\(raw: name)() throws") {
                    """
                    func toTupleSplat<A, R>(_ f: @escaping (A) throws -> R) -> (A) throws -> R {
                        return f
                    }
                    """
                    "let testFunc = toTupleSplat(\(identifier))"
                    "return try testFunc(\(argument))"
                })
        case (true, false):
            return DeclSyntax(try! FunctionDeclSyntax(
                "func \(identifier)_\(raw: name)() async") {
                    """
                    func toTupleSplat<A, R>(_ f: @escaping (A) async -> R) -> (A) async -> R {
                        return f
                    }
                    """
                    "let testFunc = toTupleSplat(\(identifier))"
                    "return await testFunc(\(argument))"
                })
        case (true, true):
            return DeclSyntax(try! FunctionDeclSyntax(
                "func \(identifier)_\(raw: name)() async throws") {
                    """
                    func toTupleSplat<A, R>(_ f: @escaping (A) async throws -> R) -> (A) async throws -> R {
                        return f
                    }
                    """
                    "let testFunc = toTupleSplat(\(identifier))"
                    "return try await testFunc(\(argument))"
                })
        }
    }
}
